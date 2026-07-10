import 'package:flutter/material.dart';

class ChatInputBox extends StatefulWidget {
  final void Function(String) onTap;
  final void Function() longPress;

  const ChatInputBox({super.key, required this.onTap, required this.longPress});

  @override
  State<ChatInputBox> createState() => _ChatInputBoxState();
}

class _ChatInputBoxState extends State<ChatInputBox> {
  late final TextEditingController _messageController;
  late final FocusNode _focusNode;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _messageController = TextEditingController();
    _focusNode = FocusNode();
    _messageController.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    final hasText = _messageController.text.trim().isNotEmpty;
    if (hasText != _hasText) {
      setState(() {
        _hasText = hasText;
      });
    }
  }

  @override
  void dispose() {
    _messageController.removeListener(_onTextChanged);
    _messageController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _handleSend() {
    final text = _messageController.text;
    if (text.trim().isNotEmpty) {
      widget.onTap(text);
      _messageController.clear();
      _focusNode.requestFocus();
    } else {
      widget.onTap("");
    }
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
                  controller: _messageController,
                  focusNode: _focusNode,
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
                  onSubmitted: (_) => _handleSend(),
                ),
              ),
            ),
            const SizedBox(width: 8.0),
            AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: _hasText
                    ? Colors.blueAccent
                    : Colors.white,
                shape: BoxShape.circle,
              ),
              child: InkWell(
                onLongPress: _hasText ? null :widget.longPress,
                child: IconButton(
                  icon: Icon(
                    _hasText ? Icons.arrow_upward : Icons.mic,
                    color: _hasText ? Colors.white : const Color(0xFF000000),
                    size: 20.0,
                  ),
                  onLongPress:widget.longPress,
                  onPressed: _hasText ? _handleSend : null,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
