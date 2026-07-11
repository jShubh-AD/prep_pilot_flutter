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
