import '../entities/subject_item.dart';
import '../repositories/subject_repository.dart';

class GetSubjectsUseCase {
  final SubjectRepository repository;

  GetSubjectsUseCase(this.repository);

  Future<Subject> call() async {
    return await repository.getSubjects();
  }
}
