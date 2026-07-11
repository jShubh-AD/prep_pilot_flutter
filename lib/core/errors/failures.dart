abstract class Failure {
  final String message;

  const Failure(this.message);
}

class ServerFailure extends Failure {
  final int statusCode;

  const ServerFailure({required this.statusCode, required String message})
    : super(message);
}

class ExceededFreeLimit extends Failure {
  final int statusCode;

  ExceededFreeLimit({required this.statusCode, required String message})
      : super(message);
}
