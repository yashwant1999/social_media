import 'package:fpdart/fpdart.dart';
import 'package:social_media/core/failure.dart';

typedef FutureEither<T> = Future<Either<Failure, T>>;
typedef FutureVoid = FutureEither<void>;
