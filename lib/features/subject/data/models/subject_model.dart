import '../../domain/entities/subject_item.dart';

class SubjectModel extends Subject {
  const SubjectModel({
    super.success,
    super.message,
    super.data,
  });

  factory SubjectModel.fromJson(Map<String, dynamic> json) {
    final dataList = json['data'] as List<dynamic>?;
    return SubjectModel(
      success: json['success'] as bool?,
      message: json['message'] as String?,
      data: dataList != null
          ? dataList
                .whereType<Map<String, dynamic>>()
                .map((e) => SubjectItemModel.fromJson(e))
                .toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'data': data?.map((e) {
        if (e is SubjectItemModel) {
          return e.toJson();
        }
        return SubjectItemModel(
          subjectId: e.subjectId,
          subjectName: e.subjectName,
          subjectCodes: e.subjectCodes,
          universities: e.universities,
          slugs: e.slugs,
          semester: e.semester,
        ).toJson();
      }).toList(),
    };
  }
}

class SubjectItemModel extends SubjectItem {
  const SubjectItemModel({
    super.subjectId,
    super.subjectName,
    super.subjectCodes,
    super.universities,
    super.slugs,
    super.semester,
  });

  factory SubjectItemModel.fromJson(Map<String, dynamic> json) {
    return SubjectItemModel(
      subjectId: json['subject_id'] as int?,
      subjectName: json['subject_name'] as String?,
      subjectCodes: json['subject_codes'] != null
          ? List<String>.from(json['subject_codes'] as List)
          : <String>[],
      universities: json['universities'] != null
          ? List<String>.from(json['universities'] as List)
          : <String>[],
      slugs: json['slugs'] != null
          ? List<String>.from(json['slugs'] as List)
          : <String>[],
      semester: json['semester'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'subject_id': subjectId,
      'subject_name': subjectName,
      'subject_codes': subjectCodes,
      'universities': universities,
      'slugs': slugs,
      'semester': semester,
    };
  }
}
