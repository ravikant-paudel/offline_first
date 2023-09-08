import 'package:dio/dio.dart';

/// Custom exception class for Dio-related failures.
class DioWrapperException implements Exception {
  final String message;
  final int? statusCode;
  final Map<String, dynamic>? response;

  DioWrapperException({
    required this.message,
    this.statusCode,
    this.response,
  });

  @override
  String toString() {
    return 'DioWrapperException: $message\nStatusCode: $statusCode\nResponse: $response';
  }
}

/// A wrapper class around the Dio HTTP client for making API requests.
class DioWrapper {
  late Dio _dio;
  Map<String, dynamic>? _requestHeaders;

  CancelToken? cancelToken;
  String? _baseUrl;

  String? get baseUrl => _baseUrl;

  DioWrapper({String? baseUrl, Dio? dio}) {
    _baseUrl = baseUrl;

    const timeout = Duration(minutes: 1);
    final baseOptions = BaseOptions(
      baseUrl: _baseUrl ?? 'http://192.168.52.26:8000/api/',
      receiveTimeout: timeout,
      connectTimeout: timeout,
      validateStatus: (status) => status != null && status >= 200 && status < 300,
    );

    _dio = dio ?? Dio();

    _dio.options = baseOptions;
    cancelToken ??= CancelToken();
  }

  /// Makes a `GET` request to the specified [path].
  ///
  /// - [params]: Query parameters for the request.
  /// - [options]: Additional options for the GET request.
  /// - [hasAuthorization]: Adds an `Authorization` header if `true`. Defaults to `true`.
  Future<T> get<T>(
    String path, {
    Map<String, dynamic> params = const {},
    Options? options,
    bool hasAuthorization = true,
  }) async {
    final _options = options ?? Options();

    return _request(
      path: path,
      queryParameters: params,
      options: _options.copyWith(
        method: 'GET',
        contentType: Headers.jsonContentType,
      ),
      hasAuthorization: hasAuthorization,
    );
  }

  /// Makes a `POST` request to the specified [path].
  ///
  /// - [data]: Data to be sent with the POST request.
  /// - [options]: Additional options for the POST request.
  /// - [hasAuthorization]: Adds an `Authorization` header if `true`. Defaults to `true`.
  Future<T> post<T>(
    String path, {
    required Map<String, dynamic> data,
    Options? options,
    bool hasAuthorization = true,
  }) async {
    final _options = options ?? Options();

    return _request(
      path: path,
      data: data,
      options: _options.copyWith(
        method: 'POST',
        contentType: Headers.jsonContentType,
      ),
      hasAuthorization: hasAuthorization,
    );
  }

  /// Makes a `PUT` request to the specified [path].
  ///
  /// - [data]: Data to be sent with the PUT request.
  /// - [options]: Additional options for the PUT request.
  /// - [hasAuthorization]: Adds an `Authorization` header if `true`. Defaults to `true`.
  Future<T> put<T>(
    String path, {
    required Map<String, dynamic> data,
    Options? options,
    bool hasAuthorization = true,
  }) async {
    final _options = options ?? Options();

    return _request(
      path: path,
      data: data,
      options: _options.copyWith(
        method: 'PUT',
        contentType: Headers.jsonContentType,
      ),
      hasAuthorization: hasAuthorization,
    );
  }

  /// Makes a `DELETE` request to the specified [path].
  ///
  /// - [options]: Additional options for the DELETE request.
  Future<T> delete<T>(
    String path, {
    Options? options,
  }) async {
    final _options = options ?? Options();

    return _request(
      path: path,
      options: _options.copyWith(
        method: 'DELETE',
        contentType: Headers.formUrlEncodedContentType,
      ),
      hasAuthorization: true,
    );
  }

  Future<T> _request<T>({
    required String path,
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    bool hasAuthorization = true,
  }) async {
    if (cancelToken?.isCancelled ?? false) cancelToken = CancelToken();

    final _options = options ?? Options();
    final _path = Uri.parse(path).hasScheme ? path : '$_baseUrl$path';

    try {
      final _response = await _dio.request<Object>(
        _path,
        data: data,
        options: _options.copyWith(
          headers: {
            ..._getHeaders(hasAuthorization),
            if (options != null && options.headers != null) ...options.headers!,
          },
        ),
        queryParameters: queryParameters,
        cancelToken: cancelToken,
      );

      final _data = _response.data;

      if (_response.statusCode == 200) {
        if (_data is T) {
          return _data;
        } else if (_data is Map<String, dynamic>) {
          return _data as T;
        }
      }

      throw DioWrapperException(
        message: 'Request failed with status code ${_response.statusCode}',
        statusCode: _response.statusCode,
        response: _data as Map<String, dynamic>?,
      );
    } on DioException catch (e) {
      throw DioWrapperException(
        message: 'Request failed: ${e.message}',
        statusCode: e.response?.statusCode,
        response: e.response?.data,
      );
    }
  }

  Map<String, dynamic> _getHeaders([bool hasAuthorization = true]) {
    if (_requestHeaders == null) {
      _requestHeaders = {
        'User-Agent': 'Your App Name',
      };
    }

    if (hasAuthorization) {
      // Add your authorization token logic here
    }

    return _requestHeaders!;
  }

  /// Cancels the current HTTP request.
  void cancelRequest() {
    cancelToken?.cancel('Request cancelled');
  }
}
