import 'package:mobile/features/subject/data/repositories/subject_repository_impl.dart';
import '../entities/subject_item.dart';
import '../repositories/subject_repository.dart';

class GetSubjectsUseCase {
  final SubjectRepository repository = SubjectRepositoryImpl();

  Future<Subject> call() async {
    return await repository.getSubjects();
  }
}
