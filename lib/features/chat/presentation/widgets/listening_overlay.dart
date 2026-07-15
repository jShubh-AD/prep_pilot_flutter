import 'package:flutter/material.dart';

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
    final color = Theme.of(context).primaryColor;

    return IgnorePointer(
      child: Material(
        color: Colors.black12,
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
                    opacity: 0.15,
                  ),
                  _Pulse(
                    scale: scale + 0.2,
                    color: color,
                    opacity: 0.25,
                  ),
      
                  // Fixed mic
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: color,
                      boxShadow: [
                        BoxShadow(
                          color: color.withValues(alpha: 0.35),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.mic,
                      color: Colors.white,
                      size: 50,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 300),
                child: Text(
                  transcription.isEmpty ? "Listening..." : transcription,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
              ),
            ],
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
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeOut,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 120),
        opacity: (1 / scale).clamp(0.0, 1.0) * opacity,
        child: Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
          ),
        ),
      ),
    );
  }
}