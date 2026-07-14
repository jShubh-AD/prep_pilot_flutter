import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/core/errors/failures.dart';
import 'package:mobile/core/services/deepgram_service.dart';
import 'package:mobile/core/services/microphone_service.dart';
import 'package:mobile/features/chat/domain/chat_usecase.dart';
import '../../../../core/services/audio_player_service.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/repositories/chat_repository.dart';
import 'chat_event.dart';
import 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final ChatUseCase chatUseCase;
  StreamSubscription<String>? _transcriptSubscription;
  StreamSubscription<double>? _amplitudeSubscription;

  ChatBloc({required this.chatUseCase})
    : super(const ChatState(messages: [], isLoading: false)) {
    on<InitChatSession>(_onInitChatSession);
    on<SendChatMessage>(_onSendChatMessage);
    on<ClearChatHistory>(_onClearChatHistory);
    on<LimitDialogDismissed>(_dismissDailyLimitDialog);
    on<StartAudioTranscription>(_onStartAudioTranscription);
    on<AudioTranscriptionReceived>(_onAudioTranscriptionReceived);
    on<MicScaleChanged>(_onMicScaleChanged);
    on<StopAudioTranscription>(_onStopAudioTranscription);
  }

  Future<void> _onStartAudioTranscription(StartAudioTranscription event, emit) async {
    emit(
      state.copyWith(
        showMicOverlay: true,
        transcription: "",
        micScale: 0,
        isAudio: false,
      ),
    );
    final dg = DeepgramService();
    await dg.connect();
    final ms = MicrophoneService();
    Stream<Uint8List>? audioStream = ms.audioStream;
    if (audioStream == null) await ms.startListeningMicrophone();

    audioStream = ms.audioStream!;
    await dg.startStreaming(audioStream);
    await _transcriptSubscription?.cancel();
    _transcriptSubscription = dg.transcriptStream.listen((transcript) {
      add(AudioTranscriptionReceived(transcript: transcript));
    });
    await _amplitudeSubscription?.cancel();
    _amplitudeSubscription = ms.amplitudeStream.listen((scale) {
      add(MicScaleChanged(micScale: scale));
    });
  }

  void _onAudioTranscriptionReceived(AudioTranscriptionReceived event, emit) {
    emit(state.copyWith(transcription: event.transcript));
  }

  void _onMicScaleChanged(MicScaleChanged event, emit) {
    emit(state.copyWith(micScale: event.micScale));
  }

  Future<void> _onStopAudioTranscription(StopAudioTranscription event, emit) async {
    emit(
      state.copyWith(
        showMicOverlay: false,
        isAudio: state.transcription.isNotEmpty,
      ),
    );
    await _transcriptSubscription?.cancel();
    await _amplitudeSubscription?.cancel();
    _amplitudeSubscription = null;
    _transcriptSubscription = null;
    await MicrophoneService().stopListeningMicrophone();
    await DeepgramService().stopStreaming();
  }

  void _dismissDailyLimitDialog(LimitDialogDismissed even, emit) {
    emit(state.copyWith(showLimitExceededDialog: false));
  }

  void _onInitChatSession(InitChatSession event, emit) {
    AudioPlayerService().initAudioPlayer();
    final initMsg = 'Ask me anything about ${event.subject.subjectName}!';
    emit(ChatState.initial(initMsg));
  }

  void _onClearChatHistory(ClearChatHistory event, emit) {
    final initMsg = 'Ask me anything about ${event.subject.subjectName}!';
    emit(ChatState.initial(initMsg));
  }

  Future<void> _onSendChatMessage(SendChatMessage event, emit) async {
    final ap = AudioPlayerService();
    final text = event.messageText.trim();
    await ap.stopStream();

    final userMsg = ChatMessage(
      text: text,
      isUser: true,
      timestamp: DateTime.now(),
    );

    final messages = List<ChatMessage>.from(state.messages)
      ..addAll([userMsg, ChatMessage(
        text: "",
        isUser: false,
        timestamp: DateTime.now(),
      )]);

    emit(
      state.copyWith(
        messages: messages,
        isLoading: true,
        error: null,
      )
    );
    final sessionId = await _getSessionId();

    try {
      final stream = chatUseCase.querySubject(
        query: text,
        subjectId: event.subjectId,
        sessionId: sessionId,
        // format: state.isAudio ? "audio" : "text"
        format: "audio",
      );

      await for (final eventData in stream) {
        if (eventData is ChatStreamToken) {
          final token = eventData.token;
          final updated = _appendAssistantText(token.text ?? "");

          if (token.audio != null) {
            if (!ap.isPlaying) await ap.startStream();
            await ap.playChunk(token.audio!);
          }

          emit(
            state.copyWith(
              messages: updated,
              showLimitExceededDialog: false,
            ),
          );
          continue;
        }

        if (eventData is ChatStreamDone) {
          final done = eventData.done;

          await chatUseCase.saveSessionInfo(
            sessionId: done.sessionId,
            tokensUsed: done.tokensUsed,
            tokensAvailable: done.tokensAvailable,
            totalTime: done.totalTime,
          );

          emit(
            state.copyWith(
              isLoading: false,
              tokenUsed: done.tokensUsed,
              tokenLeft: done.tokensAvailable,
              sessionId: done.sessionId,
              showLimitExceededDialog: false,
            ),
          );
        }
      }
    } on ExceededFreeLimit catch (e) {
      _emitError(emit, e.message, showLimitDialog: true);
    } on ServerFailure catch (e) {
      _emitError(emit, e.message);
    } catch (e) {
      _emitError(emit, e.toString());
    } finally {
      if (ap.isPlaying) await ap.stopStream();
    }
  }

  List<ChatMessage> _appendAssistantText(String text) {
    final updated = List<ChatMessage>.from(state.messages);

    if (updated.isNotEmpty && !updated.last.isUser) {
      updated[updated.length - 1] = updated.last.copyWith(
        text: updated.last.text + text,
      );
    }
    return updated;
  }

  Future<String?> _getSessionId() async {
    return state.sessionId ?? (await chatUseCase.getLatestSession())?.sessionId;
  }

  void _emitError(Emitter<ChatState> emit, String message, {bool showLimitDialog = false}) {
    final updated = List<ChatMessage>.from(state.messages)
      ..add(
        ChatMessage(
          text: "**Error:** $message",
          isUser: false,
          timestamp: DateTime.now(),
        ),
      );
    emit(
      state.copyWith(
        messages: updated,
        isLoading: false,
        showLimitExceededDialog: showLimitDialog,
      ),
    );
  }

  @override
  Future<void> close() async {
    await AudioPlayerService().dispose();
    await _transcriptSubscription?.cancel();
    await _amplitudeSubscription?.cancel();
    return super.close();
  }
}
