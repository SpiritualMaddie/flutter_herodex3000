import 'package:flutter/foundation.dart';
import 'package:flutter_herodex3000/barrel_files/dart_flutter_packages.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_herodex3000/barrel_files/models.dart';
import 'package:flutter_herodex3000/barrel_files/interfaces.dart';

class SuperHeroApiRepository implements ISuperHeroApiRepository {
  final String baseUrl;
  final IHttpClientFactory clientFactory;

  SuperHeroApiRepository({
    required this.clientFactory,
    String? envBaseUrl,
  }) : baseUrl = envBaseUrl ?? (dotenv.env['API_URL_WITH_KEY'] ?? "") {
    if (baseUrl.isEmpty) {
      throw Exception("❌ baseUrl är tomt.");
    }
  }

  // List of CORS proxies to try (in order)
  static const List<String> _corsProxies = [
    'https://corsproxy.io/?', // Usually more reliable
    'https://api.allorigins.win/raw?url=',
  ];

  // Proxy API requests on web to bypass CORS.
  // On mobile, use direct URL.
  // Tries multiple proxies as fallback.
  String _getProxiedUrl(String endpoint, {int proxyIndex = 0}) {
    final fullUrl = "$baseUrl$endpoint";

    // On mobile/desktop: use direct URL
    if (!kIsWeb) return fullUrl;

    // On web: try proxy at given index
    if (proxyIndex >= _corsProxies.length) {
      debugPrint('⚠️ All CORS proxies exhausted, trying direct URL');
      return fullUrl; // Last resort: try direct
    }

    final proxy = _corsProxies[proxyIndex];
    final proxiedUrl = '$proxy${Uri.encodeComponent(fullUrl)}';
    debugPrint('🌐 Using CORS proxy ${proxyIndex + 1}/${_corsProxies.length}: $proxy');
    return proxiedUrl;
  }

  // Function to get hero/villain by name from the API https://superheroapi.com/
  @override
  Future<List<AgentModel>> getAgentByName(String agentName) async {
    // Try each proxy
    for (int proxyIndex = 0; proxyIndex <= _corsProxies.length; proxyIndex++) {
      final searchUrl = Uri.parse(_getProxiedUrl("/search/$agentName", proxyIndex: proxyIndex));
      debugPrint('🔍 Searching: $agentName (proxy attempt ${proxyIndex + 1}/${_corsProxies.length + 1})');

      try {
        for (int attempt = 0; attempt < 5; attempt++) {
          final client = clientFactory.create();
          try {
            final response = await client
                .get(searchUrl)
                .timeout(const Duration(seconds: 8));

            if (response.statusCode == 200) {
              final agents = await _parseAgents(response.body);
              if (agents.isNotEmpty) {
                debugPrint('✅ Found ${agents.length} agents (proxy ${proxyIndex + 1})');
                return agents;
              } else {
                debugPrint('⚠️ API returned success but no results');
                return [];
              }
            } else {
              debugPrint("❌ Request failed with status: ${response.statusCode}");
            }
          } catch (e) {
            debugPrint("❌ Attempt ${attempt + 1} failed: $e");
          } finally {
            client.close();
          }

          if (attempt < 1) await Future.delayed(const Duration(seconds: 1));
        }
      } on FormatException catch (e) {
        debugPrint("❌ JSON decode error (proxy ${proxyIndex + 1}): $e");
        // Try next proxy
        continue;
      } on SocketException catch (e) {
        debugPrint("❌ Network error (proxy ${proxyIndex + 1}): $e");
        // Try next proxy
        continue;
      } catch (e, stack) {
        debugPrint("❌ Unknown error (proxy ${proxyIndex + 1}): $e");
        debugPrint("Stacktrace: $stack");
        // Try next proxy
        continue;
      }
    }

    debugPrint('❌ All proxies failed for search: $agentName');
    return [];
  }

  Future<List<AgentModel>> _parseAgents(String responseBody) async {
    try {
      final jsonBody = jsonDecode(responseBody);

      if (jsonBody == null) {
        debugPrint('⚠️ JSON body is null');
        return [];
      }

      if (jsonBody["response"] != "success") {
        debugPrint('⚠️ API response not success: ${jsonBody["response"]}');
        return [];
      }

      final results = jsonBody["results"];
      if (results == null) {
        debugPrint('⚠️ No results field in response');
        return [];
      }

      final List<dynamic> resultsList = results is List ? results : [];

      return resultsList
          .map((item) => AgentModel.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    } catch (e, stack) {
      debugPrint('❌ Error parsing agents: $e');
      debugPrint('Stacktrace: $stack');
      return [];
    }
  }
}