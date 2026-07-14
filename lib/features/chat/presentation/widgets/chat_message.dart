import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../../domain/entities/chat_message.dart';

class ChatMessageWidget extends StatelessWidget {
  final ChatMessage message;

  const ChatMessageWidget({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final align = message.isUser
        ? CrossAxisAlignment.end
        : CrossAxisAlignment.start;
    final bubbleColor = message.isUser
        ? Colors.grey.shade50.withOpacity(0.8)
        : Colors.transparent;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Column(
        crossAxisAlignment: align,
        children: [
          Row(
            mainAxisAlignment: message.isUser
                ? MainAxisAlignment.end
                : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Flexible(
                child: Container(
                  constraints: BoxConstraints(
                    maxWidth: message.isUser ? 240 : double.infinity,
                  ),
                  decoration: BoxDecoration(
                    color: bubbleColor,
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  padding: message.isUser
                      ? const EdgeInsets.symmetric(
                          vertical: 10.0,
                          horizontal: 16.0,
                        )
                      : const EdgeInsets.symmetric(
                          vertical: 8.0,
                          horizontal: 4.0,
                        ),
                  child: MarkdownBody(
                    data: message.text,
                    styleSheet: MarkdownStyleSheet(
                      p: const TextStyle(
                        color: Colors.black,
                        fontSize: 16.0,
                        height: 1.5,
                      ),
                      strong: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w600,
                      ),
                      em: const TextStyle(
                        color: Colors.black,
                        fontStyle: FontStyle.italic,
                      ),
                      code: const TextStyle(
                        color: Colors.black,
                        backgroundColor: Color(0xFF1E1E1E),
                        fontFamily: 'monospace',
                        fontSize: 14.0,
                      ),
                      codeblockDecoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      listBullet: const TextStyle(color: Colors.black),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
