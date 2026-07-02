import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;

class Subject {
  bool? success;
  String? message;
  List<Data>? data;

  Subject({this.success, this.message, this.data});

  Subject.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add(new Data.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data =  Map<String, dynamic>();
    data['success'] = this.success;
    data['message'] = this.message;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Data {
  int? subjectId;
  String? subjectName;
  List<String>? subjectCodes;
  List<String>? universities;
  List<String>? slugs;
  int? semester;

  Data(
      {this.subjectId,
        this.subjectName,
        this.subjectCodes,
        this.universities,
        this.slugs,
        this.semester});

  Data.fromJson(Map<String, dynamic> json) {
    subjectId = json['subject_id'];
    subjectName = json['subject_name'];
    subjectCodes = json['subject_codes'].cast<String>();
    universities = json['universities'].cast<String>();
    slugs = json['slugs'].cast<String>();
    semester = json['semester'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['subject_id'] = this.subjectId;
    data['subject_name'] = this.subjectName;
    data['subject_codes'] = this.subjectCodes;
    data['universities'] = this.universities;
    data['slugs'] = this.slugs;
    data['semester'] = this.semester;
    return data;
  }
}


class QueryResponse {
  final String answer;
  final List<String> llmContext;
  final List<Map<String, dynamic>> dbFound;

  QueryResponse({
    required this.answer,
    required this.llmContext,
    required this.dbFound,
  });

  factory QueryResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? {};
    
    final contextList = data['llm_context'] as List<dynamic>? ?? [];
    final dbFoundList = data['db_found'] as List<dynamic>? ?? [];

    return QueryResponse(
      answer: data['answer'] ?? 'No answer provided.',
      llmContext: contextList.map((e) => e.toString()).toList(),
      dbFound: dbFoundList.map((e) => Map<String, dynamic>.from(e as Map)).toList(),
    );
  }
}

class ApiService {
  static String  baseUrl = "http://3.111.245.143:8000";

  // Fetch all subjects from Backend
  static Future<Subject> fetchSubjects() async {
    final url = Uri.parse('http://3.111.245.143:8000/subjects');
    try {
      final response = await http.get(url).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final  subjects = Subject.fromJson(json);
        return subjects;
      } else {
        throw Exception('Failed to load subjects. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print(e);
      throw Exception('Failed to connect to backend: $e');
    }
  }

  // Send query to LLM RAG endpoint
  static Future<QueryResponse> querySubject(String query, String subjectId, {int topK = 5}) async {
    final url = Uri.parse('$baseUrl/query');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'query': query,
          'subject': subjectId,
          'top_k': topK,
        }),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        if (data['success'] == true) {
          return QueryResponse.fromJson(data);
        } else {
          throw Exception('Backend reported failure in query');
        }
      } else {
        final errorMsg = jsonDecode(response.body)['detail'] ?? 'Unknown error';
        throw Exception(errorMsg);
      }
    } catch (e) {
      throw Exception('Failed to get answer: $e');
    }
  }
}
