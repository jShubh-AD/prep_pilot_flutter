import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../domain/entities/chat_message.dart';

class ChatMessageWidget extends StatelessWidget {
  final ChatMessage message;

  const ChatMessageWidget({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final align = message.isUser
        ? CrossAxisAlignment.end
        : CrossAxisAlignment.start;

    final bubbleDecoration = message.isUser
        ? BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color(0xFF3B82F6), // Royal Blue
                Color(0xFF2563EB), // Indigo Blue
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16.0),
              topRight: Radius.circular(16.0),
              bottomLeft: Radius.circular(16.0),
              bottomRight: Radius.circular(4.0),
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF3B82F6).withOpacity(0.12),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          )
        : BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16.0),
              topRight: Radius.circular(16.0),
              bottomLeft: Radius.circular(4.0),
              bottomRight: Radius.circular(16.0),
            ),
            border: Border.all(color: const Color(0xFFE2E8F0), width: 1.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          );

    final padding = message.isUser
        ? const EdgeInsets.symmetric(
            vertical: 10.0,
            horizontal: 16.0,
          )
        : const EdgeInsets.symmetric(
            vertical: 12.0,
            horizontal: 16.0,
          );

    final screenWidth = MediaQuery.of(context).size.width;
    final maxBubbleWidth = message.isUser
        ? screenWidth * 0.75
        : screenWidth * 0.82;

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      builder: (context, animValue, child) {
        return Transform.translate(
          offset: Offset(0, 12 * (1.0 - animValue)),
          child: Opacity(
            opacity: animValue,
            child: child,
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
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
                      maxWidth: maxBubbleWidth,
                    ),
                    decoration: bubbleDecoration,
                    padding: padding,
                    child: MarkdownBody(
                      data: message.text,
                      styleSheet: MarkdownStyleSheet(
                        p: GoogleFonts.plusJakartaSans(
                          color: message.isUser ? Colors.white : const Color(0xFF1E293B),
                          fontSize: 15.0,
                          height: 1.5,
                          fontWeight: FontWeight.w400,
                        ),
                        strong: GoogleFonts.plusJakartaSans(
                          color: message.isUser ? Colors.white : const Color(0xFF0F172A),
                          fontWeight: FontWeight.bold,
                        ),
                        em: GoogleFonts.plusJakartaSans(
                          color: message.isUser ? Colors.white : const Color(0xFF334155),
                          fontStyle: FontStyle.italic,
                        ),
                        code: GoogleFonts.firaCode(
                          color: message.isUser ? Colors.white : const Color(0xFF0F172A),
                          backgroundColor: message.isUser ? Colors.white24 : const Color(0xFFF1F5F9),
                          fontSize: 13.0,
                        ),
                        codeblockDecoration: BoxDecoration(
                          color: const Color(0xFF0F172A),
                          borderRadius: BorderRadius.circular(10.0),
                          border: Border.all(color: const Color(0xFF1E293B), width: 1.0),
                        ),
                        listBullet: GoogleFonts.plusJakartaSans(
                          color: message.isUser ? Colors.white : const Color(0xFF475569),
                        ),
                        a: GoogleFonts.plusJakartaSans(
                          color: message.isUser ? Colors.white.withOpacity(0.9) : const Color(0xFF2563EB),
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
