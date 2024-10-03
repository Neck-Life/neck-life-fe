import 'dart:developer';

import 'package:dio/dio.dart';

abstract class NetworkHelper {
  static final Dio dio = Dio()
    ..interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          log('REQ : [${options.method}] ${options.path}');
          return handler.next(options);
        },
        onResponse: (response, handler) {
          log('RES : [${response.statusCode}] ${response.requestOptions.path}');
          return handler.next(response);
        },
        onError: (DioException e, handler) {
          log('ERR : [${e.response?.statusCode}] ${e.requestOptions.path}');
          return handler.next(e);
        },
      ),
    );
}
