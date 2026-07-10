import '../../domain/entities/subject_item.dart';
import '../../domain/repositories/subject_repository.dart';
import '../datasources/subject_remote_datasource.dart';

class SubjectRepositoryImpl implements SubjectRepository {
  final SubjectRemoteDataSource remoteDataSource;

  SubjectRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Subject> getSubjects() async {
    return await remoteDataSource.fetchSubjects();
  }
}
