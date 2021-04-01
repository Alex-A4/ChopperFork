import 'dart:convert';

import 'package:test/test.dart';
import 'package:alexa4_http/alexa4_http.dart';
import 'test_service.dart';
import 'package:http/testing.dart';
import 'package:http/http.dart' as http;

void main() {
  final sample = {
    'foo': 'bar',
  };

  final res = {
    'result': 'ok',
  };
  group('JSON', () {
    final buildClient = (bool json, http.Client httpClient) => ChopperClient(
          services: [
            // the generated service
            HttpTestService.create(),
          ],
          client: httpClient,
          converter:
              json ? JsonConverter() as Converter : FormUrlEncodedConverter(),
        );

    test('default json', () async {
      final httpClient = MockClient((http.Request req) async {
        expect(req.url.toString(), equals('/test/map'));
        expect(req.headers['content-type'], 'application/json; charset=utf-8');
        expect(req.body, equals(json.encode(sample)));
        return http.Response(
          json.encode(res),
          200,
          headers: {'content-type': 'application/json; charset=utf-8'},
        );
      });

      final chopper = buildClient(
        true,
        httpClient,
      );

      final result =
          await chopper.getService<HttpTestService>().mapTest(sample);

      expect(result.body, equals(res));

      httpClient.close();
    });
  });
}
