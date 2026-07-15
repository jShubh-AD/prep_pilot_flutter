import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConstants {
  static final String env = dotenv.env['ENV'] ?? "DEV";
  static final String baseUrl = env.toLowerCase() == 'prod'
      ? (dotenv.env['PROD_URL'] ?? "")
      : (dotenv.env['DEV_URL'] ?? "");
  static final deepgramKey = dotenv.env['DEEPGRAM_KEY'] ?? '';
  static const int timeOut = 2;
}
