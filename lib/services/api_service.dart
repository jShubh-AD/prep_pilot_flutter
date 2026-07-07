import "dart:convert";
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

// --------------------------
// Session response
// --------------------------

class SessionResponse {
  bool? success;
  String? message;
  SessionData? data;

  SessionResponse({this.success, this.message, this.data});

  factory SessionResponse.fromJson(Map<String, dynamic> json) {
    return SessionResponse(
      success: json['success'] as bool?,
      message: json['message'] as String?,
      data: json['data'] != null
          ? SessionData.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['success'] = success;
    data['message'] = message;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class SessionData {
  String? userId;
  String? sessionKey;
  bool? isGuest;
  int? tokensUsed;
  int? messagesCount;

  SessionData({
    this.userId,
    this.sessionKey,
    this.isGuest,
    this.tokensUsed,
    this.messagesCount,
  });

  factory SessionData.fromJson(Map<String, dynamic> json) {
    return SessionData(
      userId: json['user_id'] as String?,
      sessionKey: json['session_key'] as String?,
      isGuest: json['is_guest'] as bool?,
      tokensUsed: json['tokens_used'] as int?,
      messagesCount: json['messages_count'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['user_id'] = userId;
    data['session_key'] = sessionKey;
    data['is_guest'] = isGuest;
    data['tokens_used'] = tokensUsed;
    data['messages_count'] = messagesCount;
    return data;
  }
}

// --------------------------
// Chat query request
// --------------------------

class ChatQueryRequest {
  String? query;
  int? subjectId;
  String? sessionId;
  int? topK;

  ChatQueryRequest({this.query, this.subjectId, this.sessionId, this.topK});

  factory ChatQueryRequest.fromJson(Map<String, dynamic> json) {
    return ChatQueryRequest(
      query: json['query'] as String?,
      subjectId: json['subject_id'] as int?,
      sessionId: json['session_id'] as String?,
      topK: json['top_k'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['query'] = query;
    data['subject_id'] = subjectId;
    data['session_id'] = sessionId;
    data['top_k'] = topK;
    return data;
  }
}

// --------------------------
// Query response (chats answer)
// --------------------------

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
      answer: data['answer'] as String? ?? 'No answer provided.',
      llmContext: contextList.map((e) => e.toString()).toList(),
      dbFound: dbFoundList.map((e) {
        if (e is Map) {
          return e.map((key, value) => MapEntry(key.toString(), value));
        }
        return <String, dynamic>{};
      }).toList(),
    );
  }
}

// --------------------------
// Chat IDs (string list)
// --------------------------

class ChatIdResponse {
  bool? success;
  String? message;
  List<String>? data;

  ChatIdResponse({this.success, this.message, this.data});

  factory ChatIdResponse.fromJson(Map<String, dynamic> json) {
    final dataList = json['data'];
    return ChatIdResponse(
      success: json['success'] as bool?,
      message: json['message'] as String?,
      data: dataList != null ? List<String>.from(dataList) : <String>[],
    );
  }

  Map<String, dynamic> toJson() {
    final result = <String, dynamic>{};
    result['success'] = success;
    result['message'] = message;
    result['data'] = data;
    return result;
  }
}

// --------------------------
// API Service
// --------------------------

class ApiService {
  static const String baseUrl = "http://52.66.210.111:8000";

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

  // Send query to LLM RAG endpoint (chats)
  static Future<QueryResponse> querySubject(
    String query,
    String subjectId, {
    int topK = 5,
  }) async {
    final url = Uri.parse('$baseUrl/chats/query');
    try {
      print('🚀 Sending query: $query | subject: $subjectId | top_k: $topK');

      final response = await http
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'query': query,
              'subject_id': int.parse(subjectId), // agar subjectId String hai
              'top_k': topK,
            }),
          )
          .timeout(const Duration(minutes: 2));

      print('📥 Status: ${response.statusCode} | Body: ${response.body}');

      if (response.statusCode == 200) {
        if (response.statusCode == 200) {
          final body = response.body;

          String answer = "";

          for (var line in body.split('\n')) {
            if (line.startsWith("data:")) {
              final jsonString = line.replaceFirst("data:", "").trim();

              if (jsonString.isNotEmpty) {
                final jsonData = jsonDecode(jsonString);

                if (jsonData["text"] != null) {
                  answer += jsonData["text"];
                }
              }
            }
          }

          return QueryResponse(answer: answer, llmContext: [], dbFound: []);
        } else {
          print('❌ Backend success == false');
          throw Exception('Backend reported failure in query');
        }
      } else {
        final errJson = jsonDecode(response.body) as Map<String, dynamic>;
        final errorMsg = errJson['detail'] ?? 'Unknown error';
        print('❌ HTTP error: ${response.statusCode} | $errorMsg');
        throw Exception(errorMsg);
      }
    } catch (e) {
      print('💥 Exception in querySubject: $e');
      throw Exception('Failed to get answer: $e');
    }
  }

  // Optional: get session
  static Future<SessionResponse> getSession() async {
    final url = Uri.parse('$baseUrl/session'); // endpoint confirm karna
    try {
      final response = await http.get(url).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        return SessionResponse.fromJson(json);
      } else {
        throw Exception(
          'Failed to load session. Status code: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Error fetching session: $e');
      throw Exception('Failed to connect to backend for session: $e');
    }
  }

  // Optional: chart endpoint
  static Future<QueryResponse> getChatChart(ChatQueryRequest request) async {
    final url = Uri.parse('$baseUrl/chart'); // endpoint confirm karna
    try {
      final response = await http
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(request.toJson()),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        if (data['success'] == true) {
          return QueryResponse.fromJson(data);
        } else {
          throw Exception('Backend reported failure in chart request');
        }
      } else {
        final errJson = jsonDecode(response.body) as Map<String, dynamic>;
        final errorMsg = errJson['detail'] ?? 'Unknown error';
        throw Exception(errorMsg);
      }
    } catch (e) {
      print('Error in getChatChart: $e');
      throw Exception('Failed to get chart: $e');
    }
  }
}
