import 'package:flutter_herodex3000/data/interfaces/ihttp_client_factory.dart';
import 'package:http/http.dart' as http;

class HttpClientFactory implements IHttpClientFactory {
  @override
  http.Client create() => http.Client();
}