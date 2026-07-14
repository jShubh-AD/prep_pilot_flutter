import 'package:equatable/equatable.dart';
import '../entities/token_event.dart';
import '../entities/done_event.dart';

abstract class ChatStreamEvent extends Equatable {
  const ChatStreamEvent();

  @override
  List<Object?> get props => [];
}

class ChatStreamToken extends ChatStreamEvent {
  final TokenEvent token;
  const ChatStreamToken(this.token);

  @override
  List<Object?> get props => [token];
}

class ChatStreamDone extends ChatStreamEvent {
  final DoneEvent done;
  const ChatStreamDone(this.done);

  @override
  List<Object?> get props => [done];
}