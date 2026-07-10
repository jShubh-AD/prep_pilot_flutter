import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_sound/public/flutter_sound.dart';
import 'package:mobile/core/widgets/chat_inputbox.dart';
import '../../../subject/domain/entities/subject_item.dart';
import '../../domain/entities/chat_message.dart';
import '../bloc/chat_bloc.dart';
import '../bloc/chat_event.dart';
import '../bloc/chat_state.dart';

class ChatScreen extends StatefulWidget {
  final SubjectItem subject;

  const ChatScreen({super.key, required this.subject});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  // ================ AUDIO =======================
  late final FlutterSoundPlayer _player;

  // ================ UI =======================
  final ScrollController _scrollController = ScrollController();
  int _lastPlayedSeq = 0;

  @override
  void initState() {
    super.initState();
    _initPlayer();
    context.read<ChatBloc>().add(InitChatSession(widget.subject));
  }

  Future<void> _initPlayer() async {
    _player = FlutterSoundPlayer();
    await _player.openPlayer();
    await _player.startPlayerFromStream(
      codec: Codec.pcm16,
      sampleRate: 24000,
      numChannels: 1,
      interleaved: false,
      bufferSize: 8192,
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _player.closePlayer();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendMessage(String text) {
    if (text.trim().isEmpty) return;
    context.read<ChatBloc>().add(
      SendChatMessage(
        messageText: text,
        subjectId: widget.subject.subjectId ?? 7,
      ),
    );
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ChatBloc, ChatState>(
      listener: (context, state) {
        _scrollToBottom();

        // Listen for new audio chunks to play
        if (state.audioChunk != null &&
            state.audioChunk!.sequenceNumber > _lastPlayedSeq) {
          _lastPlayedSeq = state.audioChunk!.sequenceNumber;
          try {
            final bytes = base64Decode(state.audioChunk!.base64Audio);
            final pcm = Int16List.view(
              bytes.buffer,
              bytes.offsetInBytes,
              bytes.lengthInBytes ~/ 2,
            );
            _player.int16Sink?.add([pcm]);
          } catch (e) {
            print("Error playing audio chunk: $e");
          }
        }
      },
      builder: (context, state) {
        final messages = state.messages;
        final isLoading = state.isLoading;

        return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            surfaceTintColor: Colors.transparent,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.subject.subjectName.toString(),
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 18.0,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  widget.subject.subjectCodes?.isNotEmpty == true
                      ? widget.subject.subjectCodes!.first
                      : 'PrepPilot Active Session',
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          body: Column(
            children: [
              // Message List
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    return _buildMessageBubble(message);
                  },
                ),
              ),

              // Loading indicator
              if (isLoading)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 8.0,
                    horizontal: 16.0,
                  ),
                  child: Row(
                    children: [
                      const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Color(0xFF10A37F),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Searching study documents...',
                        style: TextStyle(
                          color: const Color(0xFFECECF1).withOpacity(0.6),
                          fontSize: 13.0,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),

              // Message Input Field
              ChatInputBox(onTap: _sendMessage, longPress: () {print("long press");}),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
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
                    maxWidth: message.isUser ? 240 : double.infinity
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
                      listBullet: const TextStyle(color: Colors.black)),
                    ),
                  ),
                )
            ],
          ),
          Padding(
            padding: EdgeInsets.only(
              left: message.isUser ? 0.0 : 8.0,
              right: message.isUser ? 8.0 : 0.0,
            ),
            child: Text(
              '${message.timestamp.hour.toString().padLeft(2, '0')}:${message.timestamp.minute.toString().padLeft(2, '0')}',
              style: const TextStyle(color: Colors.black, fontSize: 10.0),
            ),
          ),
        ],
      ),
    );
  }
}
