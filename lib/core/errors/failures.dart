abstract class Failure {
  final String message;
  final String? code;
  
  Failure({required this.message, this.code});
  
  @override
  String toString() => 'Failure: $message (Code: $code)';
}

class ServerFailure extends Failure {
  ServerFailure({required super.message, super.code});
}

class NetworkFailure extends Failure {
  NetworkFailure({required super.message, super.code});
}

class CacheFailure extends Failure {
  CacheFailure({required super.message, super.code});
}

class AuthFailure extends Failure {
  AuthFailure({required super.message, super.code});
}

class ValidationFailure extends Failure {
  ValidationFailure({required super.message, super.code});
}

class NotFoundException extends Failure {
  NotFoundException({required super.message, super.code});
}

class UnauthorizedException extends Failure {
  UnauthorizedException({required super.message, super.code});
}
