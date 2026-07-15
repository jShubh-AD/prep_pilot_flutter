import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_portal/flutter_portal.dart';
import 'package:google_fonts/google_fonts.dart';
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

  bool get hasText => messageController.text.isNotEmpty;

  @override
  void initState() {
    super.initState();
    focusNode.requestFocus();
    context.read<ChatBloc>().add(InitChatSession(widget.subject));
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
    final message = text.trim();
    if (message.isEmpty) return;
    context.read<ChatBloc>().add(
      SendChatMessage(
        messageText: message,
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
        if (!state.showMicOverlay &&
            state.transcription.isNotEmpty &&
            state.transcription != messageController.text) {
          messageController.text = state.transcription;
        }
        if(state.showLimitExceededDialog){
          showFreeLimitDialog(context, usedTokens: 20000, refreshAt: _nextMidnight());
        }
        _scrollToBottom();
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
            backgroundColor: const Color(0xFFF8FAFC),
            appBar: AppBar(
              backgroundColor: const Color(0xFFF8FAFC),
              elevation: 0,
              scrolledUnderElevation: 0,
              iconTheme: const IconThemeData(color: Color(0xFF0F172A)),
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.subject.subjectName.toString(),
                    style: GoogleFonts.plusJakartaSans(
                      color: const Color(0xFF0F172A),
                      fontSize: 18.0,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    widget.subject.subjectCodes?.isNotEmpty == true
                        ? widget.subject.subjectCodes!.first
                        : 'MasterJI is teaching (pay attention)',
                    style: GoogleFonts.plusJakartaSans(
                      color: const Color(0xFF64748B),
                      fontSize: 11.0,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(1.0),
                child: Container(
                  color: const Color(0xFFE2E8F0),
                  height: 1.0,
                ),
              ),
            ),
            body: Column(
              children: [
                // Message List
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.only(
                      left: 16.0,
                      right: 16.0,
                      top: 16.0,
                      bottom: 24.0,
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
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: EdgeInsets.only(left: 16.0, bottom: 12.0, top: 4.0),
                      child: ThreeDotThinkingIndicator(),
                    ),
                  ),

                // Message Input Field
                ValueListenableBuilder<TextEditingValue>(
                  valueListenable: messageController,
                  builder: (BuildContext context, value, Widget? child) {
                    return ChatInputBox(
                      onTap: state.isLoading ? null : _sendMessage,
                      longPress: state.isLoading ? null :  onLongPressDown,
                      longPressUp: state.isLoading ? null :  onLongPressUp,
                      messageController: messageController,
                      focusNode: focusNode,
                      hasText: value.text.isNotEmpty,
                      buttonState: getButtonState(showMicOverlay, value),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String getButtonState(bool isListening, TextEditingValue v){
    if (isListening) return 'listening';
    if (v.text.isNotEmpty) return 'has_text';
    return "idle";
  }

  Future<void> onLongPressDown() async{
    context.read<ChatBloc>().add(StartAudioTranscription());
  }
  Future<void> onLongPressUp() async {
    print("longpressup called");
    context.read<ChatBloc>().add(StopAudioTranscription());
  }
}

class ThreeDotThinkingIndicator extends StatefulWidget {
  const ThreeDotThinkingIndicator({super.key});

  @override
  State<ThreeDotThinkingIndicator> createState() => _ThreeDotThinkingIndicatorState();
}

class _ThreeDotThinkingIndicatorState extends State<ThreeDotThinkingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
          bottomLeft: Radius.circular(4),
          bottomRight: Radius.circular(16),
        ),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(3, (index) {
          return AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final double delay = index * 0.2;
              final double value = (_controller.value - delay).clamp(0.0, 1.0);
              // Staggered sine bounce
              final double bounce = math.sin(value * 2 * math.pi) * -4.0;
              // Staggered opacity
              final double progress = math.sin(_controller.value * math.pi * 2 - (index * 1.0));
              final double opacity = (0.3 + (progress + 1.0) * 0.35).clamp(0.3, 1.0);

              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 3.0),
                transform: Matrix4.translationValues(0, bounce.clamp(-4.0, 0.0), 0),
                width: 6.0,
                height: 6.0,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF3B82F6).withOpacity(opacity),
                ),
              );
            },
          );
        }),
      ),
    );
  }
}
