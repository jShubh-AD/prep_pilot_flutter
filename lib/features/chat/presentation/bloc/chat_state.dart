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
  final AudioChunkEvent? audioChunk;

  const ChatState({
    required this.messages,
    required this.isLoading,
    this.error,
    this.audioChunk,
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
    );
  }

  ChatState copyWith({
    List<ChatMessage>? messages,
    bool? isLoading,
    String? error,
    AudioChunkEvent? audioChunk,
    bool clearAudio = false,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      audioChunk: clearAudio ? null : (audioChunk ?? this.audioChunk),
    );
  }

  @override
  List<Object?> get props => [messages, isLoading, error, audioChunk];
}
