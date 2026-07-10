import 'package:mobile/features/chat/domain/repositories/chat_repository.dart';

import 'chat_repository.dart';
import 'entities/done_event.dart';

class ChatUseCase {
  final ChatRepository repository;
  ChatUseCase({required this.repository});

  Stream<ChatStreamEvent> sendSubjectQuery({
    required String query,
    required int subjectId,
    String? sessionId,
    String format = "text",
  }) {
    return repository.querySubject(
      query: query,
      subjectId: subjectId,
      sessionId: sessionId,
      format: format,
    );
  }

  Future<DoneEvent?> getLatestSession() async {
    return await repository.getLatestSession();
  }


  Future<void> saveSession({
    required String sessionId,
    required int tokensUsed,
    required int tokensAvailable,
    required double totalTime,
  }) async {
    await repository.saveSessionInfo(
      sessionId: sessionId,
      tokensUsed: tokensUsed,
      tokensAvailable: tokensAvailable,
      totalTime: totalTime,
    );
  }
}