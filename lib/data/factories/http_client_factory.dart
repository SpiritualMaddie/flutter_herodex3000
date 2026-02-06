import 'package:flutter_herodex3000/barrel_files/interfaces.dart';
import 'package:http/http.dart' as http;

class HttpClientFactory implements IHttpClientFactory {
  @override
  http.Client create() => http.Client();
}