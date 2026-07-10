import '../../domain/entities/token_event.dart';

class TokenEventModel extends TokenEvent {
  const TokenEventModel({
    super.text,
    super.audio,
    required super.time,
  });

  factory TokenEventModel.fromJson(Map<String, dynamic> json) {
    return TokenEventModel(
      text: json['text'] as String?,
      audio: json['audio'] as String?,
      time: (json['time'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'audio': audio,
      'time': time,
    };
  }
}
