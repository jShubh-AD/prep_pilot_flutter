import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: TextField(
                cursorColor: Colors.black,
                controller: messageController,
                focusNode: focusNode,
                maxLines: 5,
                minLines: 1,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 16.0,
                ),
                decoration: const InputDecoration(
                  hintText: 'Ask from MasterJI...',
                  hintStyle: TextStyle(
                    color: Color(0xFF9B9B9B),
                    fontSize: 16.0,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(50)),
                    borderSide: BorderSide.none
                  ),
                  filled: true,
                  fillColor: Color(0xFFFFFFFF),
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 20.0),
                ),
                textInputAction: TextInputAction.newline,
                onSubmitted: (c) => onTap?.call(c),
              ),
            ),
            const SizedBox(width: 8.0),
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
                duration: const Duration(milliseconds: 150),
                width: _buttonSize(),
                height: _buttonSize(),
                decoration: BoxDecoration(color: _getButtonColor(), shape: BoxShape.circle),
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

  double _iconSize() => buttonState == "listening" ? 40.0 : 20.0;

  double _buttonSize() => buttonState == "listening" ? 68.0 : 48.0;

  Color _getButtonColor() => switch (buttonState) {
    'listening' => Colors.green,
    'has_text' => Colors.blueAccent,
    _ => Colors.white,
  };

  Color _getIconColor() => switch (buttonState) {
    'listening' => Colors.white,
    'has_text' => Colors.white,
    _ => Colors.black,
  };
}
