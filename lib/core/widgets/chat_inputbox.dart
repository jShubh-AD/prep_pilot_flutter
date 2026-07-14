import 'package:flutter/material.dart';

class ChatInputBox extends StatefulWidget {
  final TextEditingController messageController;
  final FocusNode focusNode;
  final String buttonState;
  final void Function(String)? onTap;
  final void Function()? longPress;
  final void Function()? longPressUp;

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
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: TextField(
                cursorColor: Colors.black,
                controller: widget.messageController,
                focusNode: widget.focusNode,
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
                onSubmitted: (c) => widget.onTap?.call(c),
              ),
            ),
            const SizedBox(width: 8.0),
            AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: buttonSize(),
              height: buttonSize(),
              decoration: BoxDecoration(
                  color: getButtonColor(),
                  shape: BoxShape.circle
              ),
              child: InkWell(
                overlayColor: WidgetStatePropertyAll(Colors.transparent),
                onLongPress: _hasText ? null : () => widget.longPress?.call(),
                onLongPressUp: _hasText ? null : () => widget.longPressUp?.call(),
                child: IconButton(
                  onPressed: _hasText ? () => widget.onTap?.call(widget.messageController.text) : null,
                  icon: Icon(
                    _hasText ? Icons.arrow_upward : Icons.mic,
                    color: getIconColor(),
                    size: iconSize(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  double iconSize() => widget.buttonState == "listening" ? 40.0 : 20.0;
  double buttonSize() => widget.buttonState == "listening" ? 68.0 : 48.0;

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
