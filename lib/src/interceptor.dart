import 'package:alexa4_http/alexa4_http.dart';
import 'package:meta/meta.dart';
import 'package:http/http.dart' as http;

import 'request.dart';
import 'utils.dart';

/// Interface to implements a response interceptor.
/// Not recommended to modify body inside interceptor, see [Converter] to decode body response.
///
/// [ResponseInterceptor] are call after [Converter.convertResponse].
///
/// See builtin interceptor [HttpLoggingInterceptor]
@immutable
abstract class ResponseInterceptor {
  Future<Response> onResponse(Response response, Request interceptedRequest);
}

/// Interface to implements a request interceptor.
/// Not recommended to modify body inside interceptor, see [Converter] to encode body request.
///
/// [RequestInterceptor] are call after [Converter.convertRequest]
///
/// See builtin interceptor [CurlInterceptor], [HttpLoggingInterceptor]
///
/// ```dart
/// class MyRequestInterceptor implements ResponseInterceptor {
///   @override
///   FutureOr<Request> onRequest(Request request) {
///     return applyHeader(request, 'auth_token', 'Bearer $token');
///   }
/// }
/// ```
@immutable
abstract class RequestInterceptor {
  Future<Request> onRequest(Request request);
}

/// Add [headers] to each request
@immutable
class HeadersInterceptor implements RequestInterceptor {
  final Map<String, String> headers;

  const HeadersInterceptor(this.headers);

  @override
  Future<Request> onRequest(Request request) async =>
      applyHeaders(request, headers);
}

@immutable
class HttpLoggingInterceptor
    implements RequestInterceptor, ResponseInterceptor {
  @override
  Future<Request> onRequest(Request request) async {
    final base = await request.toBaseRequest();
    chopperLogger.info('--> ${base.method} ${base.url}');
    base.headers.forEach((k, v) => chopperLogger.info('$k: $v'));

    var bytes = '';
    if (base is http.Request) {
      final body = base.body;
      if (body.isNotEmpty) {
        chopperLogger.info(body);
        bytes = ' (${base.bodyBytes.length}-byte body)';
      }
    }

    chopperLogger.info('--> END ${base.method}$bytes');
    return request;
  }

  @override
  Future<Response> onResponse(Response response, Request? request) async {
    final base = response.request;
    chopperLogger.info('<-- ${response.statusCode} ${base?.url}');

    response.headers.forEach((k, v) => chopperLogger.info('$k: $v'));

    var bytes;
    if (response.body.isNotEmpty) {
      chopperLogger.info(response.body);
      bytes = ' (${response.bodyBytes.length}-byte body)';
    }

    chopperLogger.info('--> END ${base?.method}$bytes');
    return response;
  }
}
