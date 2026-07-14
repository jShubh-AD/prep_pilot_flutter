import 'package:equatable/equatable.dart';
import '../../../subject/domain/entities/subject_item.dart';

abstract class ChatEvent extends Equatable {
  const ChatEvent();

  @override
  List<Object?> get props => [];
}

class LimitDialogDismissed extends ChatEvent{
  const LimitDialogDismissed();
}

class InitChatSession extends ChatEvent {
  final SubjectItem subject;
  const InitChatSession(this.subject);

  @override
  List<Object?> get props => [subject];
}

class SendChatMessage extends ChatEvent {
  final String messageText;
  final int subjectId;

  const SendChatMessage({
    required this.messageText,
    required this.subjectId,
  });

  @override
  List<Object?> get props => [messageText, subjectId];
}

class ClearChatHistory extends ChatEvent {
  final SubjectItem subject;

  const ClearChatHistory(this.subject);

  @override
  List<Object?> get props => [subject];
}

class StartAudioTranscription extends ChatEvent {
  const StartAudioTranscription();
}

class AudioTranscriptionReceived extends ChatEvent {
  final String transcript;
  const AudioTranscriptionReceived({required this.transcript});

  @override
  List<Object> get props => [transcript];
}

class MicScaleChanged extends ChatEvent {
  final double micScale;
  const MicScaleChanged({required this.micScale});

  @override
  List<Object> get props => [micScale];
}


class StopAudioTranscription extends ChatEvent {
  const StopAudioTranscription();
}
