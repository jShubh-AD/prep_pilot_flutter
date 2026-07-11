import 'package:mobile/features/chat/data/chat_repository_impl.dart';
import 'package:mobile/features/chat/domain/repositories/chat_repository.dart';

import 'chat_repository.dart';
import 'entities/done_event.dart';

class ChatUseCase extends ChatRepository {
  final repository = ChatRepositoryImpl();

  @override
  Stream<ChatStreamEvent> querySubject({
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

  @override
  Future<DoneEvent?> getLatestSession() async {
    return await repository.getLatestSession();
  }

  @override
  Future<void> saveSessionInfo({
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