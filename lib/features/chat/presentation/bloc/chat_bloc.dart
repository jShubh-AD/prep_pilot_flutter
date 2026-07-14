import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/core/errors/failures.dart';
import 'package:mobile/core/services/deepgram_service.dart';
import 'package:mobile/core/services/microphone_service.dart';
import 'package:mobile/features/chat/domain/chat_usecase.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/repositories/chat_repository.dart';
import 'chat_event.dart';
import 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final ChatUseCase chatUseCase;
  StreamSubscription<String>? _transcriptSubscription;
  StreamSubscription<double>? _amplitudeSubscription;

  ChatBloc({
    required this.chatUseCase,
  }) : super(const ChatState(messages: [], isLoading: false)) {
    on<InitChatSession>(_onInitChatSession);
    on<SendChatMessage>(_onSendChatMessage);
    on<ClearChatHistory>(_onClearChatHistory);
    on<LimitDialogDismissed>(_dismissDailyLimitDialog);
    on<StartAudioTranscription>(_onStartAudioTranscription);
    on<AudioTranscriptionReceived>(_onAudioTranscriptionReceived);
    on<MicScaleChanged>(_onMicScaleChanged);
    on<StopAudioTranscription>(_onStopAudioTranscription);
  }
  Future<void> _onStartAudioTranscription(StartAudioTranscription event, emit) async{
    emit(state.copyWith(showMicOverlay: true, transcription: "", micScale: 0, isAudio: false));
    final dg = DeepgramService();
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

  Future<void> _onStopAudioTranscription(StopAudioTranscription event, emit) async{
    await _transcriptSubscription?.cancel();
    await _amplitudeSubscription?.cancel();
    _amplitudeSubscription = null;
    _transcriptSubscription = null;
    await MicrophoneService().stopListeningMicrophone();
    await DeepgramService().stopStreaming();
    emit(state.copyWith(showMicOverlay: false, isAudio: state.transcription.isNotEmpty));
  }

  void _dismissDailyLimitDialog (LimitDialogDismissed even, emit){
    emit(state.copyWith(showLimitExceededDialog: false));
  }

  void _onInitChatSession(InitChatSession event, emit) {
    emit(ChatState.initial(
        'Ask me anything about ${event.subject.subjectName}!'));
  }

  void _onClearChatHistory(ClearChatHistory event, emit) {
    emit(ChatState.initial('Ask me anything about ${event.subject.subjectName}!'));
  }

  Future<void> _onSendChatMessage(SendChatMessage event, emit) async {
    final text = event.messageText;
    if (text.trim().isEmpty) return;
    final userMsg = ChatMessage(
        text: text, isUser: true, timestamp: DateTime.now());

    final updatedMessagesWithUser = List<ChatMessage>.from(state.messages)
      ..addAll([userMsg]);

    emit(state.copyWith(
      messages: updatedMessagesWithUser,
      clearAudio: true,
    ));
    if (state.tokenLeft != null && state.tokenLeft! <= 0) {
      final currentMessages = List<ChatMessage>.from(state.messages);
      currentMessages.add(ChatMessage(
        text: '**Limit Exceeded**: You have exceeded your daily limit of 20,000 Tokens.\n*Tokens left: ${state.tokenLeft ?? 0}*',
        isUser: false,
        timestamp: DateTime.now(),
      ));
      emit(state.copyWith(
        messages: currentMessages,
        showLimitExceededDialog: true,
        isLoading: false,
        clearAudio: true,
      ));
      return;
    }

    final botPlaceholder = ChatMessage(
        text: "", isUser: false, timestamp: DateTime.now());

    final updateMessagesWithBotPlaceholder = List<ChatMessage>.from(state.messages)
      ..addAll([botPlaceholder]);

    emit(state.copyWith(
      messages: updateMessagesWithBotPlaceholder,
      isLoading: true,
      error: null,
      clearAudio: true,
    ));

    int audioSeq = 0;
    
    // Get session ID from state or load the latest session from local storage if null
    String? sessionId = state.sessionId;
    if (sessionId == null) {
      try {
        final lastSession = await chatUseCase.getLatestSession();
        sessionId = lastSession?.sessionId;
      } catch (e) {
        print('Error getting latest session ID: $e');
      }
    }

    try {
      final stream = chatUseCase.querySubject(
        query: text,
        subjectId: event.subjectId,
        sessionId: sessionId,
        format: state.isAudio ? "audio" : "text",
      );

      await emit.forEach<ChatStreamEvent>(
        stream,
        onData: (eventData) {
          if (eventData is ChatStreamToken) {
            final token = eventData.token;
            print("[TOKEN]: ${jsonEncode(token).toString()}");
            final currentMessages = List<ChatMessage>.from(state.messages);
            if (currentMessages.isNotEmpty) {
              final lastMsg = currentMessages.last;
              if (!lastMsg.isUser) {
                final newText = lastMsg.text + (token.text ?? "");
                currentMessages[currentMessages.length - 1] =
                    lastMsg.copyWith(text: newText);
              }
            }

            AudioChunkEvent? audioEvent;
            if (token.audio != null) {
              audioSeq++;
              audioEvent = AudioChunkEvent(token.audio!, audioSeq);
            }

            return state.copyWith(
              showLimitExceededDialog: false,
              messages: currentMessages,
              audioChunk: audioEvent,
              clearAudio: audioEvent == null,
            );
          } else if (eventData is ChatStreamDone) {
            final doneEvent = eventData.done;
            chatUseCase.saveSessionInfo(
              sessionId: doneEvent.sessionId,
              tokensUsed: doneEvent.tokensUsed,
              tokensAvailable: doneEvent.tokensAvailable,
              totalTime: doneEvent.totalTime,
            ).then((_) {
              print('Session info saved successfully for session: ${doneEvent.sessionId}');
            }).catchError((error) {
              print('Error saving session info: $error');
            });
            print("[DONE]: ${jsonEncode(doneEvent).toString()}");
            return state.copyWith(
              isLoading: false,
              tokenUsed: doneEvent.tokensUsed,
              tokenLeft: doneEvent.tokensAvailable,
              clearAudio: true,
              isAudio: false,
              showLimitExceededDialog: false,
              sessionId: doneEvent.sessionId,
            );
          }
          return state;
        },

          onError: (error, stackTrace) {
            if (error is ExceededFreeLimit){
              final currentMessages = List<ChatMessage>.from(state.messages);
              currentMessages.add(
                ChatMessage(
                  text: '**Error:** ${error.message}',
                  isUser: false,
                  timestamp: DateTime.now(),
                ),
              );
              return state.copyWith(
                messages: currentMessages,
                isLoading: false,
                clearAudio: true,
                isAudio: false,
                showLimitExceededDialog: true,
              );
            }

            final message = switch (error) {
              ServerFailure e => e.message,
              _ => error.toString(),
            };

            final currentMessages = List<ChatMessage>.from(state.messages);
            currentMessages.add(
              ChatMessage(
                text: '**Error:** $message',
                isUser: false,
                timestamp: DateTime.now(),
              ),
            );

            return state.copyWith(
              messages: currentMessages,
              isAudio: false,
              isLoading: false,
              clearAudio: true,
            );
        });
    } catch (e) {
      final errorMsg = e.toString();
      final currentMessages = List<ChatMessage>.from(state.messages);
      currentMessages.add(ChatMessage(
        text: '**Error:** $errorMsg',
        isUser: false,
        timestamp: DateTime.now(),
      ));
      emit(state.copyWith(
        messages: currentMessages,
        isAudio: false,
        isLoading: false,
        clearAudio: true,
      ));
    }
  }

  @override
  Future<void> close() async {
    await _transcriptSubscription?.cancel();
    await _amplitudeSubscription?.cancel();
    return super.close();
  }

}
