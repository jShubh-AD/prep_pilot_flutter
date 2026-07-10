import 'package:equatable/equatable.dart';

class TokenEvent extends Equatable {
  final String? text;
  final String? audio;
  final double time;

  const TokenEvent({
    this.text,
    this.audio,
    required this.time,
  });

  @override
  List<Object?> get props => [text, audio, time];
}
