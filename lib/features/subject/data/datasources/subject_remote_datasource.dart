import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:mobile/core/errors/failures.dart';
import 'package:mobile/core/network/dio_client.dart';

import '../../../../core/network/api_constants.dart';
import '../models/subject_model.dart';


class SubjectRemoteDataSourceImpl{
  final client = DioClient.instance;

  Future<SubjectModel> fetchSubjects() async {
    final url = '${ApiConstants.baseUrl}/subjects';
    try {
      final response = await client
          .get(url)
          .timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        return SubjectModel.fromJson(response.data);
      } else {
        throw ServerFailure(
          statusCode: response.statusCode!,
          message: "Something went wrong",
        );
      }
    } on DioException catch (e) {
      throw ServerFailure(
        statusCode: e.response!.statusCode!,
        message: e.response!.data!["detail"],
      );
    }
  }
}
