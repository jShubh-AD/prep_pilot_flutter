import 'package:flutter/material.dart';

class ChatInputBox extends StatefulWidget {
  final TextEditingController messageController;
  final FocusNode focusNode;
  final String buttonState;
  final void Function(String) onTap;
  final void Function() longPress;
  final void Function() longPressUp;

  const ChatInputBox({
    super.key,
    required this.buttonState,
    required this.onTap,
    required this.longPress,
    required this.longPressUp,
    required this.messageController,
    required this.focusNode
  });

  @override
  State<ChatInputBox> createState() => _ChatInputBoxState();
}

class _ChatInputBoxState extends State<ChatInputBox> {
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    widget.messageController.addListener(_handleTextChanged);
  }

  void _handleTextChanged() {
    setState(() {
      _hasText = widget.messageController.text.isNotEmpty;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFFFF),
                  borderRadius: BorderRadius.circular(100),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: TextField(
                  cursorColor: Colors.black,
                  controller: widget.messageController,
                  focusNode: widget.focusNode,
                  maxLines: 10,
                  minLines: 1,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 16.0,
                  ),
                  decoration: const InputDecoration(
                    hintText: 'Message PrepPilot...',
                    hintStyle: TextStyle(
                      color: Color(0xFF9B9B9B),
                      fontSize: 16.0,
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 12.0),
                  ),
                  textInputAction: TextInputAction.newline,
                  onSubmitted: (c) => widget.onTap(c),
                ),
              ),
            ),
            const SizedBox(width: 8.0),
            AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: getButtonColor(),
                shape: BoxShape.circle,
              ),
              child: InkWell(
                overlayColor: WidgetStatePropertyAll(Colors.transparent),
                onLongPress: _hasText ? null : widget.longPress,
                onLongPressUp: widget.longPressUp,
                child: IconButton(
                  icon: Icon(_hasText ? Icons.arrow_upward : Icons.mic,
                    color: getIconColor(),
                    size: 20.0,
                  ),
                  onLongPress:widget.longPress,
                  onPressed: _hasText ? () => widget.onTap(widget.messageController.text) : null,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color getButtonColor() => switch (widget.buttonState) {
    'listening' => Colors.green,
    'has_text' => Colors.blueAccent,
    _ => Colors.white,
  };

  Color getIconColor() => switch (widget.buttonState) {
    'listening' => Colors.white,
    'has_text' => Colors.white,
    _ => Colors.black,
  };

}
