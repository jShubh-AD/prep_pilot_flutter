import "dart:convert";
import 'package:flutter_client_sse/constants/sse_request_type_enum.dart';
import 'package:flutter_client_sse/flutter_client_sse.dart';
import 'package:http/http.dart' as http;

class Subject {
  bool? success;
  String? message;
  List<SubjectItem>? data;

  Subject({this.success, this.message, this.data});

  factory Subject.fromJson(Map<String, dynamic> json) {
    final dataList = json['data'] as List<dynamic>?;
    return Subject(
      success: json['success'] as bool?,
      message: json['message'] as String?,
      data: dataList != null
          ? dataList
                .whereType<Map<String, dynamic>>()
                .map((e) => SubjectItem.fromJson(e))
                .toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['success'] = success;
    data['message'] = message;
    if (this.data != null) {
      data['data'] = this.data!.map((e) => e.toJson()).toList();
    }
    return data;
  }
}

class subject_id {
  bool? success;
  String? message;
  List<String>? data;

  subject_id({this.success, this.message, this.data});

  subject_id.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
    data = json['data'].cast<String>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = this.success;
    data['message'] = this.message;
    data['data'] = this.data;
    return data;
  }
}

class SubjectItem {
  int? subjectId;
  String? subjectName;
  List<String>? subjectCodes;
  List<String>? universities;
  List<String>? slugs;
  int? semester;

  SubjectItem({
    this.subjectId,
    this.subjectName,
    this.subjectCodes,
    this.universities,
    this.slugs,
    this.semester,
  });

  factory SubjectItem.fromJson(Map<String, dynamic> json) {
    return SubjectItem(
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
    final data = <String, dynamic>{};
    data['subject_id'] = subjectId;
    data['subject_name'] = subjectName;
    data['subject_codes'] = subjectCodes;
    data['universities'] = universities;
    data['slugs'] = slugs;
    data['semester'] = semester;
    return data;
  }
}


class TokenEvent {
  final String? text;
  final String? audio;
  final double time;

  TokenEvent({
    this.text,
    this.audio,
    required this.time,
  });

  factory TokenEvent.fromJson(Map<String, dynamic> json) {
    return TokenEvent(
      text: json['text'],
      audio: json['audio'] != null ? json["audio"] : null ,
      time: (json['time'] as num).toDouble(),
    );
  }
}

class DoneEvent {
  final String sessionId;
  final int tokensUsed;
  final int tokensAvailable;
  final double totalTime;

  DoneEvent({
    required this.sessionId,
    required this.tokensUsed,
    required this.tokensAvailable,
    required this.totalTime,
  });

  factory DoneEvent.fromJson(Map<String, dynamic> json) {
    return DoneEvent(
      sessionId: json['session_id'],
      tokensUsed: json['tokens_used'],
      tokensAvailable: json['tokens_available'],
      totalTime: (json['total_time'] as num).toDouble(),
    );
  }
}


class ApiService {
  static const String baseUrl = "http://192.168.1.22:8000";//"http://13.201.69.169:8000";

  // Fetch all subjects
  static Future<Subject> fetchSubjects() async {
    final url = Uri.parse('$baseUrl/subjects');
    try {
      final response = await http.get(url).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        return Subject.fromJson(json);
      } else {
        throw Exception(
          'Failed to load subjects. Status code: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Error fetching subjects: $e');
      throw Exception('Failed to connect to backend: $e');
    }
  }

  static Future<void> querySubject({
    required void Function(TokenEvent) tokenEvent,
    required void Function(DoneEvent) doneEvent,
    required String query,
    required int subjectId,
    String format = "text"
  }) async {
    try {
      final stream = SSEClient.subscribeToSSE(
        method: SSERequestType.POST,
        url: '$baseUrl/chats/query',
        header: {
          'Content-Type': 'application/json',
          'Accept': 'text/event-stream',
        },
        body: {
          'query': query,
          'subject_id': subjectId,
          'format': format,
        },
      );

      await for (final event in stream) {
        switch (event.event) {
          case 'token':
            print("[token]: ${event.data}");
            tokenEvent(TokenEvent.fromJson(jsonDecode(event.data!)));
            break;

          case 'done':
            doneEvent(DoneEvent.fromJson(jsonDecode(event.data!)));
            return;
        }
      }
    } catch (e) {
      print('💥 Exception in querySubject: $e');
      throw Exception('Failed to get answer: $e');
    }
  }
}
