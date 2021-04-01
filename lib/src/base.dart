import 'dart:async';
import 'package:meta/meta.dart';
import 'package:http/http.dart' show Client, Response;
import 'constants.dart';

import 'interceptor.dart';
import 'request.dart';

Type _typeOf<T>() => T;

@visibleForTesting
final allowedInterceptorsType = <Type>[
  RequestInterceptor,
  ResponseInterceptor,
];

/// ChopperClient is the main class of the Chopper API
/// Used to manager services, encode data, intercept request, response and error.
class ChopperClient {
  /// Base url of each request to your api
  /// hostname of your api for example
  final String baseUrl;

  /// Http client used to do request
  /// from `package:http/http.dart`
  final Client httpClient;

  final Map<Type, ChopperService> _services = {};
  final _requestInterceptors = [];
  final _responseInterceptors = [];
  final _requestController = StreamController<Request>.broadcast();
  final _responseController = StreamController<Response>.broadcast();

  final bool _clientIsInternal;

  /// Inject any service using the [services] parameter.
  ChopperClient({
    this.baseUrl = '',
    Client? client,
    Iterable interceptors = const [],
    Iterable<ChopperService> services = const [],
  })  : httpClient = client ?? Client(),
        _clientIsInternal = client == null {
    if (interceptors.every(_isAnInterceptor) == false) {
      throw ArgumentError(
        'Unsupported type for interceptors, it only support the following types:\n'
        '${allowedInterceptorsType.join('\n - ')}',
      );
    }

    _requestInterceptors.addAll(interceptors.where(_isRequestInterceptor));
    _responseInterceptors.addAll(interceptors.where(_isResponseInterceptor));

    services.toSet().forEach((s) {
      s.client = this;
      _services[s.definitionType] = s;
    });
  }

  bool _isRequestInterceptor(value) => value is RequestInterceptor;

  bool _isResponseInterceptor(value) => value is ResponseInterceptor;

  bool _isAnInterceptor(value) =>
      _isResponseInterceptor(value) || _isRequestInterceptor(value);

  /// Retrieve any service injected into the [ChopperClient]
  ///
  /// ```dart
  /// final chopper = ChopperClient(
  ///     baseUrl: 'localhost:8000',
  ///     services: [
  ///       // inject the generated service
  ///       TodosListService.create()
  ///     ],
  ///   );
  ///
  /// final todoService = chopper.getService<TodosListService>();
  /// ```
  ServiceType getService<ServiceType extends ChopperService>() {
    final serviceType = _typeOf<ServiceType>();
    if (serviceType == dynamic || serviceType == ChopperService) {
      throw Exception(
          'Service type should be provided, `dynamic` is not allowed.');
    }
    final service = _services[serviceType];
    if (service == null) {
      throw Exception('Service of type \'$serviceType\' not found.');
    }
    return service as ServiceType;
  }

  Future<Request> _interceptRequest(Request req) async {
    for (final i in _requestInterceptors) {
      if (i is RequestInterceptor) {
        req = await i.onRequest(req);
      }
    }

    return req;
  }

  Future<Response> _interceptResponse(
    Response res,
    Request interceptedRequest,
  ) async {
    for (final i in _responseInterceptors) {
      if (i is ResponseInterceptor) {
        res = await i.onResponse(res, interceptedRequest);
      }
    }

    return res;
  }

  /// Send request function that apply all interceptors and converters
  /// The error saves to body
  Future<Response> send(Request request) async {
    var req = await _interceptRequest(request);
    _requestController.add(req);

    final streamRes = await httpClient.send(await req.toBaseRequest());

    var res = await Response.fromStream(streamRes);

    res = await _interceptResponse(res, req);

    _responseController.add(res);

    return res;
  }

  /// Http GET request using [send] function
  Future<Response> get(
    String url, {
    Map<String, String>? headers,
    Map<String, dynamic>? parameters,
    String? baseUrl,
  }) =>
      send(Request(
        HttpMethod.Get,
        url,
        baseUrl ?? this.baseUrl,
        headers: headers,
        parameters: parameters,
      ));

  /// Http POST request using [send] function
  Future<Response> post(
    String url, {
    dynamic? body,
    List<PartValue>? parts,
    Map<String, String>? headers,
    Map<String, dynamic>? parameters,
    bool? multipart,
    String? baseUrl,
  }) =>
      send(Request(
        HttpMethod.Post,
        url,
        baseUrl ?? this.baseUrl,
        body: body,
        parts: parts,
        headers: headers,
        multipart: multipart,
        parameters: parameters,
      ));

  /// Http PUT request using [send] function
  Future<Response> put(
    String url, {
    dynamic? body,
    List<PartValue>? parts,
    Map<String, String>? headers,
    Map<String, dynamic>? parameters,
    bool? multipart,
    String? baseUrl,
  }) =>
      send(Request(
        HttpMethod.Put,
        url,
        baseUrl ?? this.baseUrl,
        body: body,
        parts: parts,
        headers: headers,
        multipart: multipart,
        parameters: parameters,
      ));

  /// Http PATCH request using [send] function
  Future<Response> patch(
    String url, {
    dynamic? body,
    List<PartValue>? parts,
    Map<String, String>? headers,
    Map<String, dynamic>? parameters,
    bool? multipart,
    String? baseUrl,
  }) =>
      send(Request(
        HttpMethod.Patch,
        url,
        baseUrl ?? this.baseUrl,
        body: body,
        parts: parts,
        headers: headers,
        multipart: multipart,
        parameters: parameters,
      ));

  /// Makes a HTTP OPTIONS request using the [send] function.
  Future<Response> options(
    String url, {
    Map<String, String> headers = const {},
    Map<String, dynamic>? parameters,
    String? baseUrl,
  }) =>
      send(Request(
        HttpMethod.Options,
        url,
        baseUrl ?? this.baseUrl,
        headers: headers,
        parameters: parameters,
      ));

  /// Http DELETE request using [send] function
  Future<Response> delete(
    String url, {
    Map<String, String>? headers,
    Map<String, dynamic>? parameters,
    String? baseUrl,
  }) =>
      send(Request(
        HttpMethod.Delete,
        url,
        baseUrl ?? this.baseUrl,
        headers: headers,
        parameters: parameters,
      ));

  /// Http Head request using [send] function
  Future<Response> head(
    String url, {
    Map<String, String>? headers,
    Map<String, dynamic>? parameters,
    String? baseUrl,
  }) =>
      send(Request(
        HttpMethod.Head,
        url,
        baseUrl ?? this.baseUrl,
        headers: headers,
        parameters: parameters,
      ));

  /// dispose [ChopperClient] to clean memory.
  ///
  /// It won't close the http client if you provided it in the [ChopperClient] constructor.
  @mustCallSuper
  void dispose() {
    _requestController.close();
    _responseController.close();

    _services.clear();

    _requestInterceptors.clear();
    _responseInterceptors.clear();

    if (_clientIsInternal) {
      httpClient.close();
    }
  }

  /// Event stream of request just before http call
  /// all converters and interceptors have been run
  Stream<Request> get onRequest => _requestController.stream;

  /// Event stream of response
  /// all converters and interceptors have been run
  Stream<Response> get onResponse => _responseController.stream;
}

/// Used by generator to generate apis
abstract class ChopperService {
  late ChopperClient client;

  /// Used internally to retrieve the service from [ChopperClient].
  // TODO: use runtimeType
  Type get definitionType;
}

extension ResponseAddition on Response {
  bool get isSuccessful => statusCode >= 200 && statusCode < 300;
}
