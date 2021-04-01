import 'dart:async';
import 'package:alexa4_http/alexa4_http.dart';

import 'package:http/http.dart' show MultipartFile;

class HttpTestService extends ChopperService {
  static HttpTestService create([ChopperClient? client]) =>
      HttpTestService(client);

  HttpTestService([ChopperClient? client]) {
    if (client == null) return;
    this.client = client;
  }

  final definitionType = HttpTestService;

  Future<Response> getTest(String id, {String dynamicHeader = ''}) {
    final $url = '/test/get/$id';
    final $headers = {'test': dynamicHeader};
    final $request = Request('GET', $url, client.baseUrl, headers: $headers);
    return client.send($request);
  }

  Future<Response> headTest() {
    final $url = '/test/head';
    final $request = Request('HEAD', $url, client.baseUrl);
    return client.send($request);
  }

  Future<Response> optionsTest() {
    final $url = '/test/options';
    final $request = Request('OPTIONS', $url, client.baseUrl);
    return client.send($request);
  }

  Future<Response> getAll() {
    final $url = '/test';
    final $request = Request('GET', $url, client.baseUrl);
    return client.send($request);
  }

  Future<Response> getAllWithTrailingSlash() {
    final $url = '/test/';
    final $request = Request('GET', $url, client.baseUrl);
    return client.send($request);
  }

  Future<Response> getQueryTest(
      {String name = '', int? number, int? def = 42}) {
    final $url = '/test/query';
    final $params = <String, dynamic>{
      'name': name,
      'int': number,
      'default_value': def
    };
    final $request = Request('GET', $url, client.baseUrl, parameters: $params);
    return client.send($request);
  }

  Future<Response> getQueryMapTest(Map<String, dynamic> query) {
    final $url = '/test/query_map';
    final $params = query;
    final $request = Request('GET', $url, client.baseUrl, parameters: $params);
    return client.send($request);
  }

  Future<Response> getQueryMapTest2(Map<String, dynamic> query, {bool? test}) {
    final $url = '/test/query_map';
    final $params = <String, dynamic>{'test': test};
    $params.addAll(query);
    final $request = Request('GET', $url, client.baseUrl, parameters: $params);
    return client.send($request);
  }

  Future<Response> getBody(dynamic body) {
    final $url = '/test/get_body';
    final $body = body;
    final $request = Request('GET', $url, client.baseUrl, body: $body);
    return client.send($request);
  }

  Future<Response> postTest(String data) {
    final $url = '/test/post';
    final $body = data;
    final $request = Request('POST', $url, client.baseUrl, body: $body);
    return client.send($request);
  }

  Future<Response> postStreamTest(Stream<List<int>> byteStream) {
    final $url = '/test/post';
    final $body = byteStream;
    final $request = Request('POST', $url, client.baseUrl, body: $body);
    return client.send($request);
  }

  Future<Response> putTest(String test, String data) {
    final $url = '/test/put/$test';
    final $body = data;
    final $request = Request('PUT', $url, client.baseUrl, body: $body);
    return client.send($request);
  }

  Future<Response> deleteTest(String id) {
    final $url = '/test/delete/$id';
    final $headers = {'foo': 'bar'};
    final $request = Request('DELETE', $url, client.baseUrl, headers: $headers);
    return client.send($request);
  }

  Future<Response> patchTest(String id, String data) {
    final $url = '/test/patch/$id';
    final $body = data;
    final $request = Request('PATCH', $url, client.baseUrl, body: $body);
    return client.send($request);
  }

  Future<Response> mapTest(Map<String, String> map) {
    final $url = '/test/map';
    final $body = map;
    final $request = Request('POST', $url, client.baseUrl, body: $body);
    return client.send($request);
  }

  Future<Response> postForm(Map<String, String> fields) {
    final $url = '/test/form/body';
    final $body = fields;
    final $request = Request('POST', $url, client.baseUrl, body: $body);
    return client.send($request);
  }

  Future<Response> postFormUsingHeaders(Map<String, String> fields) {
    final $url = '/test/form/body';
    final $headers = {'content-type': 'application/x-www-form-urlencoded'};
    final $request =
        Request('POST', $url, client.baseUrl, body: fields, headers: $headers);
    return client.send($request);
  }

  Future<Response> postFormFields(String foo, int bar) {
    final $url = '/test/form/body/fields';
    final $body = <String, String>{'foo': foo, 'bar': bar.toString()};
    final $request = Request('POST', $url, client.baseUrl, body: $body);
    return client.send($request);
  }

  Future<Response> postResources(
      Map<dynamic, dynamic> a, Map<dynamic, dynamic> b) {
    final $url = '/test/multi';
    final $parts = <PartValue>[
      PartValue<Map<dynamic, dynamic>>('1', a),
      PartValue<Map<dynamic, dynamic>>('2', b)
    ];
    final $request =
        Request('POST', $url, client.baseUrl, parts: $parts, multipart: true);
    return client.send($request);
  }

  Future<Response> postFile(List<int> bytes) {
    final $url = '/test/file';
    final $parts = <PartValue>[PartValueFile<List<int>>('file', bytes)];
    final $request =
        Request('POST', $url, client.baseUrl, parts: $parts, multipart: true);
    return client.send($request);
  }

  Future<Response> postMultipartFile(MultipartFile file, {String? id}) {
    final $url = '/test/file';
    final $parts = <PartValue>[
      PartValue<String?>('id', id),
      PartValueFile<MultipartFile>('file', file)
    ];
    final $request =
        Request('POST', $url, client.baseUrl, parts: $parts, multipart: true);
    return client.send($request);
  }

  Future<Response> postListFiles(List<MultipartFile> files) {
    final $url = '/test/files';
    final $parts = <PartValue>[
      PartValueFile<List<MultipartFile>>('files', files)
    ];
    final $request =
        Request('POST', $url, client.baseUrl, parts: $parts, multipart: true);
    return client.send($request);
  }

  Future<dynamic> fullUrl() {
    final $url = 'https://test.com';
    final $request = Request('GET', $url, client.baseUrl);
    return client.send($request);
  }

  Future<Response> listString() {
    final $url = '/test/list/string';
    final $request = Request('GET', $url, client.baseUrl);
    return client.send($request);
  }

  Future<Response> noBody() {
    final $url = '/test/no-body';
    final $request = Request('POST', $url, client.baseUrl);
    return client.send($request);
  }
}
