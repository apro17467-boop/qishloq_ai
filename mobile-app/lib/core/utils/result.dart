import 'package:qishloq_ai_mobile/core/network/api_exception.dart';

abstract class Result<T> {
  const Result();

  factory Result.success(T data) = Success<T>;
  factory Result.failure(ApiException error) = Failure<T>;

  bool get isSuccess => this is Success<T>;
  bool get isFailure => this is Failure<T>;

  T? get dataOrNull => this is Success<T> ? (this as Success<T>).data : null;
  ApiException? get errorOrNull => this is Failure<T> ? (this as Failure<T>).error : null;
}

class Success<T> extends Result<T> {
  final T data;
  const Success(this.data);
}

class Failure<T> extends Result<T> {
  final ApiException error;
  const Failure(this.error);
}
