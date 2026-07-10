import '../entities/subject_item.dart';

abstract class SubjectRepository {
  Future<Subject> getSubjects();
}
