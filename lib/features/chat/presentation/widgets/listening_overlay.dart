import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MicOverlay extends StatelessWidget {
  final double scale;
  final String transcription;

  const MicOverlay({
    super.key,
    required this.scale,
    required this.transcription,
  });

  @override
  Widget build(BuildContext context) {
    const color = Color(0xFF3B82F6); // Refined Royal Blue for AI state

    return IgnorePointer(
      child: Material(
        color: Colors.black.withOpacity(0.55),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    _Pulse(
                      scale: scale + 0.4,
                      color: color,
                      opacity: 0.18,
                    ),
                    _Pulse(
                      scale: scale + 0.2,
                      color: color,
                      opacity: 0.3,
                    ),
        
                    // Central mic button
                    Container(
                      width: 110,
                      height: 110,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFF3B82F6),
                            Color(0xFF2563EB),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF3B82F6).withOpacity(0.4),
                            blurRadius: 30,
                            spreadRadius: 8,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.mic,
                        color: Colors.white,
                        size: 48,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                const WaveformVisualizer(),
                const SizedBox(height: 24),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 320),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        transcription.isEmpty ? "Listening..." : transcription,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.plusJakartaSans(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.2,
                          shadows: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        transcription.isEmpty
                            ? "Speak now, release to send"
                            : "Release to send message",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.plusJakartaSans(
                          color: Colors.white70,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.1,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Pulse extends StatelessWidget {
  final double scale;
  final Color color;
  final double opacity;

  const _Pulse({
    required this.scale,
    required this.color,
    required this.opacity,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: scale,
      duration: const Duration(milliseconds: 150),
      curve: Curves.easeOutCubic,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 150),
        opacity: (1 / scale).clamp(0.0, 1.0) * opacity,
        child: Container(
          width: 110,
          height: 110,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                color.withOpacity(0.5),
                color.withOpacity(0.1),
                Colors.transparent,
              ],
              stops: const [0.0, 0.6, 1.0],
            ),
            border: Border.all(
              color: color.withOpacity(0.35),
              width: 1.5,
            ),
          ),
        ),
      ),
    );
  }
}

class WaveformVisualizer extends StatefulWidget {
  const WaveformVisualizer({super.key});

  @override
  State<WaveformVisualizer> createState() => _WaveformVisualizerState();
}

class _WaveformVisualizerState extends State<WaveformVisualizer>
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
    return SizedBox(
      height: 24,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(7, (index) {
          return AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              // Generate sine wave height variation
              final double progress = math.sin(_controller.value * math.pi * 2 - (index * 0.6));
              final double height = 4.0 + (progress + 1.0) * 10.0; // height ranges from 4 to 24

              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 2.5),
                width: 3.5,
                height: height,
                decoration: BoxDecoration(
                  color: const Color(0xFF3B82F6).withOpacity(0.85),
                  borderRadius: BorderRadius.circular(2.0),
                ),
              );
            },
          );
        }),
      ),
    );
  }
}