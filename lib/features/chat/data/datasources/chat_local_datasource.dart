import 'package:hive/hive.dart';
import '../models/done_event_model.dart';

abstract class ChatLocalDataSource {
  Future<void> saveSessionInfo({
    required String sessionId,
    required int tokensUsed,
    required int tokensAvailable,
    required double totalTime,
  });

  Future<DoneEventModel?> getLatestSession();
}

class ChatLocalDataSourceImpl implements ChatLocalDataSource {
  final Box _sessionBox;
  ChatLocalDataSourceImpl(this._sessionBox);

  @override
  Future<void> saveSessionInfo({
    required String sessionId,
    required int tokensUsed,
    required int tokensAvailable,
    required double totalTime,
  }) async {
    await _sessionBox.put(sessionId, {
      'session_id': sessionId,
      'tokens_used': tokensUsed,
      'tokens_available': tokensAvailable,
      'total_time': totalTime,
    });
  }

  @override
  Future<DoneEventModel?> getLatestSession() async {
    if (_sessionBox.isEmpty) return null;
    final lastEntry = _sessionBox.values.last;
    if (lastEntry is Map) {
      final Map<String, dynamic> json = Map<String, dynamic>.from(lastEntry);
      json['total_time'] ??= 0.0;
      return DoneEventModel.fromJson(json);
    }
    return null;
  }
}
