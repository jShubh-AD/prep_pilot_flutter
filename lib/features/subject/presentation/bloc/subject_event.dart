import 'package:equatable/equatable.dart';

abstract class SubjectEvent extends Equatable {
  const SubjectEvent();

  @override
  List<Object?> get props => [];
}

class FetchSubjectsEvent extends SubjectEvent {
  const FetchSubjectsEvent();
}
