import 'package:fpdart/fpdart.dart';
import '../../core/errors/failures.dart';

abstract class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}

// Para casos sin parámetros
class NoParams {
  const NoParams();
}
