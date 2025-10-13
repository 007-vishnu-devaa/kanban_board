enum ApiStatus { initial, loading, success, failure }

/// A simple generic API response wrapper used across presentation layers to
/// represent loading/success/failure states with an optional payload and
/// error message.
class ApiResponse<T> {
  final ApiStatus status;
  final T? data;
  final String? message;

  const ApiResponse._(this.status, {this.data, this.message});

  const ApiResponse.initial() : this._(ApiStatus.initial);
  const ApiResponse.loading() : this._(ApiStatus.loading);
  const ApiResponse.success(T data) : this._(ApiStatus.success, data: data);
  const ApiResponse.failure(String message) : this._(ApiStatus.failure, message: message);

  bool get isLoading => status == ApiStatus.loading;
  bool get isSuccess => status == ApiStatus.success;
  bool get isFailure => status == ApiStatus.failure;
}
