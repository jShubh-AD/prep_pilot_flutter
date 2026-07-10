import 'package:equatable/equatable.dart';

class DoneEvent extends Equatable {
  final String sessionId;
  final int tokensUsed;
  final int tokensAvailable;
  final double totalTime;

  const DoneEvent({
    required this.sessionId,
    required this.tokensUsed,
    required this.tokensAvailable,
    required this.totalTime,
  });

  @override
  List<Object?> get props => [sessionId, tokensUsed, tokensAvailable, totalTime];
}
