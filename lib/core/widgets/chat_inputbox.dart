import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class ChatInputBox extends StatelessWidget {
  final TextEditingController messageController;
  final FocusNode focusNode;
  final String buttonState;
  final bool hasText;
  final void Function(String)? onTap;
  final void Function()? longPress;
  final void Function()? longPressUp;

  const ChatInputBox({
    super.key,
    required this.hasText,
    required this.buttonState,
    required this.onTap,
    required this.longPress,
    required this.longPressUp,
    required this.messageController,
    required this.focusNode
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: TextField(
                  cursorColor: const Color(0xFF2563EB),
                  controller: messageController,
                  focusNode: focusNode,
                  maxLines: 5,
                  minLines: 1,
                  style: GoogleFonts.plusJakartaSans(
                    color: const Color(0xFF1E293B),
                    fontSize: 15.0,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Ask from MasterJI...',
                    hintStyle: GoogleFonts.plusJakartaSans(
                      color: const Color(0xFF94A3B8),
                      fontSize: 15.0,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: const BorderRadius.all(Radius.circular(24.0)),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: const BorderRadius.all(Radius.circular(24.0)),
                      borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1.5),
                    ),
                    filled: true,
                    fillColor: const Color(0xFFFFFFFF),
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 13.0, horizontal: 18.0),
                  ),
                  textInputAction: TextInputAction.newline,
                  onSubmitted: (c) => onTap?.call(c),
                ),
              ),
            ),
            const SizedBox(width: 10.0),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onLongPressStart: hasText ? null : (_) {
                HapticFeedback.lightImpact();
                longPress?.call();
              },
              onLongPressEnd: hasText ? null : (_) {
                HapticFeedback.lightImpact();
                longPressUp?.call();
              },
              onTap: hasText ? () => onTap?.call(messageController.text) : null,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                width: _buttonSize(),
                height: _buttonSize(),
                decoration: BoxDecoration(
                  color: _getButtonColor(),
                  shape: BoxShape.circle,
                  boxShadow: [
                    if (buttonState == "listening")
                      BoxShadow(
                        color: const Color(0xFF10B981).withOpacity(0.4),
                        blurRadius: 14,
                        spreadRadius: 2,
                      )
                    else
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                  ],
                ),
                child: Center(
                  child: Icon(
                    hasText ? Icons.arrow_upward : Icons.mic,
                    color: _getIconColor(),
                    size: _iconSize(),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  double _iconSize() => buttonState == "listening" ? 28.0 : 20.0;

  double _buttonSize() => buttonState == "listening" ? 56.0 : 48.0;

  Color _getButtonColor() => switch (buttonState) {
    'listening' => const Color(0xFF10B981),
    'has_text' => const Color(0xFF2563EB),
    _ => const Color(0xFFF1F5F9),
  };

  Color _getIconColor() => switch (buttonState) {
    'listening' => Colors.white,
    'has_text' => Colors.white,
    _ => const Color(0xFF475569),
  };
}
