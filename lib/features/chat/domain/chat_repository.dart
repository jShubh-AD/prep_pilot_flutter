import 'package:mobile/features/chat/domain/repositories/chat_repository.dart';

import 'entities/done_event.dart';

abstract class ChatRepository {
  Stream<ChatStreamEvent> querySubject({
    required String query,
    required int subjectId,
    String? sessionId,
    String format = "text",
  });

  Future<void> saveSessionInfo({
    required String sessionId,
    required int tokensUsed,
    required int tokensAvailable,
    required double totalTime,
  });

  Future<DoneEvent?> getLatestSession();
}
