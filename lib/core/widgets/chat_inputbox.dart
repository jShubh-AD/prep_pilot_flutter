import 'package:flutter/material.dart';


class ChatInputBox extends StatelessWidget {
  final void Function(String) onTap;
  final void Function() longPress;

  const ChatInputBox({
    super.key,
    required this.onTap,
    required this.longPress
  });

  @override
  Widget build(BuildContext context) {
    final FocusNode focusNode = FocusNode();
    final TextEditingController messageController = TextEditingController();
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A),
                  borderRadius: BorderRadius.circular(24.0),
                  border: Border.all(color: Colors.white10),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: TextField(
                  controller: messageController,
                  focusNode: focusNode,
                  maxLines: 4,
                  minLines: 1,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    hintText: 'Type a message...',
                    hintStyle: TextStyle(color: Colors.white38),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 12.0),
                  ),
                  onSubmitted: (val) => onTap(val),
                ),
              ),
            ),
            const SizedBox(width: 12.0),
            Container(
              decoration: const BoxDecoration(
                color: Color(0xFF6366F1),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: Icon(
                  messageController.text.isEmpty ? Icons.mic : Icons.send,
                  color: Colors.white,
                ),
                onPressed: () => onTap(messageController.text),
                onLongPress: () {
                  print("long press");
                },
              ),
            ),
          ],
        ),
      ),
    );
  }}