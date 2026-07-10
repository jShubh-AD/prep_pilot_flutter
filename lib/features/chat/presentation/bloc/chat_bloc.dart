import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/repositories/chat_repository.dart';
import '../../domain/usecases/query_subject.dart';
import 'chat_event.dart';
import 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final QuerySubjectUseCase querySubjectUseCase;

  ChatBloc({required this.querySubjectUseCase})
      : super(const ChatState(messages: [], isLoading: false)) {
    on<InitChatSession>(_onInitChatSession);
    on<SendChatMessage>(_onSendChatMessage);
    on<ClearChatHistory>(_onClearChatHistory);
  }

  void _onInitChatSession(
    InitChatSession event,
    Emitter<ChatState> emit,
  ) {
    emit(ChatState.initial(
        'Ask me anything about **${event.subject.subjectName}**!'));
  }

  void _onClearChatHistory(
    ClearChatHistory event,
    Emitter<ChatState> emit,
  ) {
    emit(ChatState.initial(
        'Chat history cleared. Ask me anything about **${event.subject.subjectName}**!'));
  }

  Future<void> _onSendChatMessage(
    SendChatMessage event,
    Emitter<ChatState> emit,
  ) async {
    final text = event.messageText;
    if (text.trim().isEmpty) return;

    final userMsg = ChatMessage(
        text: text, isUser: true, timestamp: DateTime.now());
    final botPlaceholder = ChatMessage(
        text: "", isUser: false, timestamp: DateTime.now());

    final updatedMessages = List<ChatMessage>.from(state.messages)
      ..addAll([userMsg, botPlaceholder]);

    emit(state.copyWith(
      messages: updatedMessages,
      isLoading: true,
      error: null,
      clearAudio: true,
    ));

    int audioSeq = 0;

    try {
      final stream = querySubjectUseCase(
        query: text,
        subjectId: event.subjectId,
        format: "audio",
      );

      await emit.forEach<ChatStreamEvent>(
        stream,
        onData: (eventData) {
          if (eventData is ChatStreamToken) {
            final token = eventData.token;
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
              messages: currentMessages,
              audioChunk: audioEvent,
              clearAudio: audioEvent == null,
            );
          } else if (eventData is ChatStreamDone) {
            return state.copyWith(
              isLoading: false,
              clearAudio: true,
            );
          }
          return state;
        },
        onError: (error, stackTrace) {
          final errorMsg = error.toString();
          final currentMessages = List<ChatMessage>.from(state.messages);
          currentMessages.add(ChatMessage(
            text: '**Error:** $errorMsg',
            isUser: false,
            timestamp: DateTime.now(),
          ));
          return state.copyWith(
            messages: currentMessages,
            isLoading: false,
            clearAudio: true,
          );
        },
      );
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
        isLoading: false,
        clearAudio: true,
      ));
    }
  }
}
