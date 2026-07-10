import '../repositories/chat_repository.dart';

class QuerySubjectUseCase {
  final ChatRepository repository;

  QuerySubjectUseCase(this.repository);

  Stream<ChatStreamEvent> call({
    required String query,
    required int subjectId,
    String format = "text",
  }) {
    return repository.querySubject(
      query: query,
      subjectId: subjectId,
      format: format,
    );
  }
}
