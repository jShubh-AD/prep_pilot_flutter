import 'package:equatable/equatable.dart';

class Subject extends Equatable {
  final bool? success;
  final String? message;
  final List<SubjectItem>? data;

  const Subject({this.success, this.message, this.data});

  @override
  List<Object?> get props => [success, message, data];
}

class SubjectItem extends Equatable {
  final int? subjectId;
  final String? subjectName;
  final List<String>? subjectCodes;
  final List<String>? universities;
  final List<String>? slugs;
  final int? semester;

  const SubjectItem({
    this.subjectId,
    this.subjectName,
    this.subjectCodes,
    this.universities,
    this.slugs,
    this.semester,
  });

  @override
  List<Object?> get props => [
        subjectId,
        subjectName,
        subjectCodes,
        universities,
        slugs,
        semester,
      ];
}
