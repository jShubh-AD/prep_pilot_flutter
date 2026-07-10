import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/network/api_constants.dart';
import '../models/subject_model.dart';

abstract class SubjectRemoteDataSource {
  Future<SubjectModel> fetchSubjects();
}

class SubjectRemoteDataSourceImpl implements SubjectRemoteDataSource {
  final http.Client client;

  SubjectRemoteDataSourceImpl({required this.client});

  @override
  Future<SubjectModel> fetchSubjects() async {
    final url = Uri.parse('${ApiConstants.baseUrl}/subjects');
    try {
      final response = await client.get(url).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        return SubjectModel.fromJson(json);
      } else {
        throw Exception(
          'Failed to load subjects. Status code: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Failed to connect to backend: $e');
    }
  }
}
