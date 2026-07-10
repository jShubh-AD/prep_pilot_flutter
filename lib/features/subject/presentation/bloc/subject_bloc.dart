import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_subjects.dart';
import 'subject_event.dart';
import 'subject_state.dart';

class SubjectBloc extends Bloc<SubjectEvent, SubjectState> {
  final GetSubjectsUseCase getSubjectsUseCase;

  SubjectBloc({required this.getSubjectsUseCase}) : super(SubjectInitial()) {
    on<FetchSubjectsEvent>(_onFetchSubjects);
  }

  Future<void> _onFetchSubjects(
    FetchSubjectsEvent event,
    Emitter<SubjectState> emit,
  ) async {
    emit(SubjectLoading());
    try {
      final subject = await getSubjectsUseCase();
      emit(SubjectLoaded(subject));
    } catch (e) {
      emit(SubjectError(e.toString()));
    }
  }
}
