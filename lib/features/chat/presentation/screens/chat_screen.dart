import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_portal/flutter_portal.dart';
import 'package:flutter_sound/public/flutter_sound.dart';
import 'package:mobile/core/widgets/chat_inputbox.dart';
import 'package:mobile/features/chat/presentation/widgets/chat_message.dart';
import 'package:mobile/features/chat/presentation/widgets/limit_dialog.dart';
import 'package:mobile/features/chat/presentation/widgets/listening_overlay.dart';
import '../../../subject/domain/entities/subject_item.dart';
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
  final TextEditingController messageController = TextEditingController();
  final FocusNode focusNode = FocusNode();

  final ScrollController _scrollController = ScrollController();
  int _lastPlayedSeq = 0;

  @override
  void initState() {
    super.initState();
    focusNode.requestFocus();
    context.read<ChatBloc>().add(InitChatSession(widget.subject));
    messageController.addListener(_messageControllerListener);
  }

  void _messageControllerListener(){
    setState(() {});
  }

  @override
  void dispose() {
    messageController.dispose();
    focusNode.dispose();
    _scrollController.dispose();
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
    focusNode.unfocus();
    messageController.clear();
    _scrollToBottom();
  }

  DateTime _nextMidnight() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day + 1);
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ChatBloc, ChatState>(
      listener: (context, state) {
        if(state.showMicOverlay){
          if (state.transcription.isNotEmpty && state.transcription != messageController.text){
            messageController.text = state.transcription;
          }
        }

        if(state.showLimitExceededDialog){
          showFreeLimitDialog(context, usedTokens: 20000, refreshAt: _nextMidnight());
        }

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
          } catch (e) {
            print("Error playing audio chunk: $e");
          }
        }
      },
      builder: (context, state) {
        final messages = state.messages;
        final isLoading = state.isLoading;
        final showMicOverlay = state.showMicOverlay;
        final micScale = state.micScale;
        final transcription= state.transcription;

        return PortalTarget(
          visible: showMicOverlay,
          anchor: const Aligned(follower: Alignment.center,target: Alignment.center),
          portalFollower: MicOverlay(scale: micScale, transcription: transcription),
          child: Scaffold(
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
                    style: const TextStyle(color: Colors.black, fontSize: 12),
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
                      return ChatMessageWidget(message: message);
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
                              Color(0xFF000000),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                // Message Input Field
                ChatInputBox(
                  onTap: _sendMessage,
                  longPress: onLongPressDown,
                  longPressUp: onLongPressUp,
                  messageController: messageController,
                  focusNode: focusNode,
                  buttonState: getButtonState(showMicOverlay),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String getButtonState(bool isListening){
    if (isListening) return 'listening';
    if (messageController.text.isNotEmpty) return 'has_text';
    return "idle";
  }

  Future<void> onLongPressDown() async{
    context.read<ChatBloc>().add(StartAudioTranscription());
  }
  Future<void> onLongPressUp() async {
    context.read<ChatBloc>().add(StopAudioTranscription());
  }
}
