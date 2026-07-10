import 'package:equatable/equatable.dart';

class ChatMessage extends Equatable {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final List<String>? sources;
  final List<Map<String, dynamic>>? dbFound;

  const ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.sources,
    this.dbFound,
  });

  ChatMessage copyWith({
    String? text,
    bool? isUser,
    DateTime? timestamp,
    List<String>? sources,
    List<Map<String, dynamic>>? dbFound,
  }) {
    return ChatMessage(
      text: text ?? this.text,
      isUser: isUser ?? this.isUser,
      timestamp: timestamp ?? this.timestamp,
      sources: sources ?? this.sources,
      dbFound: dbFound ?? this.dbFound,
    );
  }

  @override
  List<Object?> get props => [text, isUser, timestamp, sources, dbFound];
}
