import 'dart:async';

import 'package:alexa4_http/alexa4_http.dart';
import 'package:http/testing.dart';
import 'package:http/http.dart' as http;
import 'package:test/test.dart';
import 'test_service.dart';

void main() {
  group('Interceptors', () {
    final requestClient = MockClient(
      (request) async {
        expect(
          request.url.toString(),
          equals('/test/get/1234/intercept'),
        );
        return http.Response('', 200);
      },
    );

    final responseClient = MockClient(
      (request) async => http.Response('body', 200),
    );

    tearDown(() {
      requestClient.close();
      responseClient.close();
    });

    test('RequestInterceptor', () async {
      final chopper = ChopperClient(
        interceptors: [RequestIntercept()],
        services: [
          HttpTestService.create(),
        ],
        client: requestClient,
      );

      await chopper.getService<HttpTestService>().getTest('1234');
    });

    test('ResponseInterceptor', () async {
      final chopper = ChopperClient(
        interceptors: [ResponseIntercept()],
        services: [
          HttpTestService.create(),
        ],
        client: responseClient,
      );

      await chopper.getService<HttpTestService>().getTest('1234');

      expect(ResponseIntercept.intercepted, isA<_Intercepted>());
    });

    test('headers', () async {
      final client = MockClient((http.Request req) async {
        expect(req.headers.containsKey('foo'), isTrue);
        expect(req.headers['foo'], equals('bar'));
        return http.Response('', 200);
      });

      final chopper = ChopperClient(
        interceptors: [
          HeadersInterceptor({'foo': 'bar'})
        ],
        services: [
          HttpTestService.create(),
        ],
        client: client,
      );

      await chopper.getService<HttpTestService>().getTest('1234');
    });

    final fakeRequest = Request(
      'POST',
      '/',
      'base',
      body: 'test',
      headers: {'foo': 'bar'},
    );

    test('Http logger interceptor request', () async {
      final logger = HttpLoggingInterceptor();

      final logs = [];
      chopperLogger.onRecord.listen((r) => logs.add(r.message));
      await logger.onRequest(fakeRequest);

      expect(
        logs,
        equals(
          [
            '--> POST base/',
            'foo: bar',
            'content-type: text/plain; charset=utf-8',
            'test',
            '--> END POST (4-byte body)',
          ],
        ),
      );
    });

    test('Http logger interceptor response', () async {
      final logger = HttpLoggingInterceptor();

      final fakeResponse = Response(
        'responseBodyBase',
        200,
        headers: {'foo': 'bar'},
        request: await fakeRequest.toBaseRequest(),
      );

      final logs = [];
      chopperLogger.onRecord.listen((r) => logs.add(r.message));
      await logger.onResponse(fakeResponse, null);

      expect(
        logs,
        equals(
          [
            '<-- 200 base/',
            'foo: bar',
            'responseBodyBase',
            '--> END POST (16-byte body)',
          ],
        ),
      );
    });
  });
}

class ResponseIntercept implements ResponseInterceptor {
  static dynamic intercepted;

  @override
  Future<Response> onResponse(Response response, Request req) async {
    intercepted = _Intercepted(response.body);
    return response;
  }
}

class RequestIntercept implements RequestInterceptor {
  @override
  Future<Request> onRequest(Request request) async =>
      request.copyWith(url: '${request.url}/intercept');
}

class _Intercepted<BodyType> {
  final BodyType body;

  _Intercepted(this.body);
}
