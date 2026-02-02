import 'package:http/http.dart' as http;

abstract class IHttpClientFactory {
  http.Client create();
}