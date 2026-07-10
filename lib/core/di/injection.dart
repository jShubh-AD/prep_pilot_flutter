import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import '../../features/chat/data/datasources/chat_remote_datasource.dart';
import '../../features/chat/data/repositories/chat_repository_impl.dart';
import '../../features/chat/domain/repositories/chat_repository.dart';
import '../../features/chat/domain/usecases/query_subject.dart';
import '../../features/chat/presentation/bloc/chat_bloc.dart';
import '../../features/subject/data/datasources/subject_remote_datasource.dart';
import '../../features/subject/data/repositories/subject_repository_impl.dart';
import '../../features/subject/domain/repositories/subject_repository.dart';
import '../../features/subject/domain/usecases/get_subjects.dart';
import '../../features/subject/presentation/bloc/subject_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Features - Subject
  sl.registerFactory(() => SubjectBloc(getSubjectsUseCase: sl()));
  sl.registerLazySingleton<GetSubjectsUseCase>(() => GetSubjectsUseCase(sl()));
  sl.registerLazySingleton<SubjectRepository>(
      () => SubjectRepositoryImpl(remoteDataSource: sl()));
  sl.registerLazySingleton<SubjectRemoteDataSource>(
      () => SubjectRemoteDataSourceImpl(client: sl()));

  // Features - Chat
  sl.registerFactory(() => ChatBloc(querySubjectUseCase: sl()));
  sl.registerLazySingleton<QuerySubjectUseCase>(() => QuerySubjectUseCase(sl()));
  sl.registerLazySingleton<ChatRepository>(
      () => ChatRepositoryImpl(remoteDataSource: sl()));
  sl.registerLazySingleton<ChatRemoteDataSource>(
      () => ChatRemoteDataSourceImpl());

  // External
  sl.registerLazySingleton(() => http.Client());
}
