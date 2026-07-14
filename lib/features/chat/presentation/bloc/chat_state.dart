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
  final bool showLimitExceededDialog;
  final bool isAudio;
  final bool showMicOverlay;
  final double micScale;
  final String transcription;

  const ChatState({
    required this.messages,
    required this.isLoading,
    this.isAudio =false,
    this.showMicOverlay = false,
    this.micScale = 1.0,
    this.transcription = "",
    this.tokenUsed,
    this.tokenLeft,
    this.error,
    this.audioChunk,
    this.sessionId,
    this.showLimitExceededDialog = false,
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
    bool? showLimitExceededDialog,
    String? error,
    AudioChunkEvent? audioChunk,
    bool clearAudio = false,
    String? sessionId,
    bool? showMicOverlay,
    bool? isAudio,
    double? micScale,
    String? transcription
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      tokenLeft: tokenLeft ?? this.tokenLeft,
      tokenUsed: tokenUsed ?? this.tokenUsed,
      showLimitExceededDialog: showLimitExceededDialog ?? this.showLimitExceededDialog,
      error: error ?? this.error,
      audioChunk: clearAudio ? null : (audioChunk ?? this.audioChunk),
      sessionId: sessionId ?? this.sessionId,
      showMicOverlay: showMicOverlay ?? this.showMicOverlay,
      isAudio: isAudio ?? this.isAudio,
      micScale: micScale ?? this.micScale,
      transcription: transcription ?? this.transcription,
    );
  }

  @override
  List<Object?> get props => [
        messages,
        isLoading,
        error,
        tokenUsed,
        tokenLeft,
        audioChunk,
        sessionId,
        showLimitExceededDialog,
        showMicOverlay,
        transcription,
        micScale
      ];
}
