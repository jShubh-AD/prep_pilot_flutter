import 'package:equatable/equatable.dart';
import '../../domain/entities/chat_message.dart';

class AudioChunkEvent extends Equatable {
  final String base64Audio;
  final int sequenceNumber;

  const AudioChunkEvent(this.base64Audio, this.sequenceNumber);

  @override
  List<Object?> get props => [base64Audio, sequenceNumber];
}

class ChatState extends Equatable {
  final List<ChatMessage> messages;
  final bool isLoading;
  final String? error;
  final int? tokenUsed;
  final int? tokenLeft;
  final AudioChunkEvent? audioChunk;
  final String? sessionId;

  const ChatState({
    required this.messages,
    required this.isLoading,
    this.tokenUsed,
    this.tokenLeft,
    this.error,
    this.audioChunk,
    this.sessionId,
  });

  factory ChatState.initial(String initialText) {
    return ChatState(
      messages: [
        ChatMessage(
          text: initialText,
          isUser: false,
          timestamp: DateTime.now(),
        ),
      ],
      isLoading: false,
      sessionId: null,
    );
  }

  ChatState copyWith({
    List<ChatMessage>? messages,
    int? tokenUsed,
    int? tokenLeft,
    bool? isLoading,
    String? error,
    AudioChunkEvent? audioChunk,
    bool clearAudio = false,
    String? sessionId,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      tokenLeft: tokenLeft ?? this.tokenLeft,
      tokenUsed: tokenUsed ?? this.tokenUsed,
      error: error ?? this.error,
      audioChunk: clearAudio ? null : (audioChunk ?? this.audioChunk),
      sessionId: sessionId ?? this.sessionId,
    );
  }

  @override
  List<Object?> get props => [messages, isLoading, error, audioChunk, sessionId];
}
