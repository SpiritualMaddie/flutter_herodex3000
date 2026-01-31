import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_herodex3000/barrel_files/models.dart';
import 'package:flutter_herodex3000/barrel_files/interfaces.dart';

class SuperHeroApiRepository implements ISuperHeroApiRepository{
  final String baseUrl;
  final IHttpClientFactory clientFactory;
  
  // Create and load dotenv instance
  //static final dotenvEnv = dotenv.DotEnv(includePlatformEnvironment: true)..load();

  SuperHeroApiRepository({
    required this.clientFactory,
    String? envBaseUrl,
  }) : baseUrl = envBaseUrl ?? (dotenv.env['API_URL_WITH_KEY'] ?? ""){
    if(baseUrl.isEmpty){
      throw Exception("❌ baseUrl är tomt.");
    }
  }
  
  // Function to get hero/villian by name from the API https://superheroapi.com/ that reads from the .env for the API key
  @override
  Future<List<AgentModel>> getAgentByName(String agentName) async {

    final searchUrl = Uri.parse("$baseUrl/search/$agentName");
    
      try {
        for(int attempt = 0; attempt < 3; attempt++){
          final client = clientFactory.create();
          try {
            final response = await client
              .get(searchUrl)
              .timeout(const Duration(seconds: 10));
           if(response.statusCode == 200){
            return _parseAgents(response.body);       
          }
          else{
            debugPrint("❌ Request misslyckades med status: ${response.statusCode}");
            // return [];
          } 
          } finally {
              client.close();
          }
              
          if(attempt <2) await Future.delayed(const Duration(seconds: 2));
        }
      } on FormatException catch (e){ // JSON decode or unexpected body
          debugPrint("❌ Fel vid tolkning av JSON: $e");
          return [];
      } on SocketException catch (e){ // No internet or DNS issue
          debugPrint("❌ Nätverksfel: $e");
          return [];
      } catch (e, stack) {            // Catch everything else
          debugPrint("❌ Oväntat fel: $e");
          debugPrint("Stacktrace: $stack");
          return [];
      }
    return [];
  }

  Future<List<AgentModel>> _parseAgents(String responseBody) async {
    final jsonBody = jsonDecode(responseBody);

    if (jsonBody == null || jsonBody["response"] != "success") return [];

    final List<dynamic> results = jsonBody["results"];

    return results
              .map((item) => AgentModel
              .fromJson(Map<String, dynamic>.from(item)))
              .toList();
  }

}