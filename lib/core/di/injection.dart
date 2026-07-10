import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mobile/features/chat/domain/chat_usecase.dart';
import '../../features/chat/data/datasources/chat_local_datasource.dart';
import '../../features/chat/data/datasources/chat_remote_datasource.dart';
import '../../features/chat/data/chat_repository_impl.dart';
import '../../features/chat/domain/chat_repository.dart';
import '../../features/chat/presentation/bloc/chat_bloc.dart';
import '../../features/subject/data/datasources/subject_remote_datasource.dart';
import '../../features/subject/data/repositories/subject_repository_impl.dart';
import '../../features/subject/domain/repositories/subject_repository.dart';
import '../../features/subject/domain/usecases/get_subjects.dart';
import '../../features/subject/presentation/bloc/subject_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Hive Initialization
  await Hive.initFlutter();
  final sessionBox = await Hive.openBox('session_box');
  sl.registerLazySingleton<Box>(() => sessionBox);

  // Features - Subject
  sl.registerFactory(() => SubjectBloc(getSubjectsUseCase: sl()));
  sl.registerLazySingleton<GetSubjectsUseCase>(() => GetSubjectsUseCase(sl()));
  sl.registerLazySingleton<SubjectRepository>(
      () => SubjectRepositoryImpl(remoteDataSource: sl()));
  sl.registerLazySingleton<SubjectRemoteDataSource>(
      () => SubjectRemoteDataSourceImpl(client: sl()));

  // Features - Chat
  sl.registerFactory(() => ChatBloc(
    chatUseCase: ChatUseCase(repository: sl())
      ));
  sl.registerLazySingleton<ChatRepository>(
      () => ChatRepositoryImpl(remoteDataSource: sl(), localDataSource: sl()));
  sl.registerLazySingleton<ChatRemoteDataSource>(
      () => ChatRemoteDataSourceImpl());
  sl.registerLazySingleton<ChatLocalDataSource>(
      () => ChatLocalDataSourceImpl(sl<Box>()));

  // External
  sl.registerLazySingleton(() => http.Client());
}
