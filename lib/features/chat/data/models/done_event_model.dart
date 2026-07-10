import '../../domain/entities/done_event.dart';

class DoneEventModel extends DoneEvent {
  const DoneEventModel({
    required super.sessionId,
    required super.tokensUsed,
    required super.tokensAvailable,
    required super.totalTime,
  });

  factory DoneEventModel.fromJson(Map<String, dynamic> json) {
    return DoneEventModel(
      sessionId: json['session_id'] as String,
      tokensUsed: json['tokens_used'] as int,
      tokensAvailable: json['tokens_available'] as int,
      totalTime: (json['total_time'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'session_id': sessionId,
      'tokens_used': tokensUsed,
      'tokens_available': tokensAvailable,
      'total_time': totalTime,
    };
  }
}
