import 'package:flutter_herodex3000/barrel_files/models.dart';
import 'package:flutter_herodex3000/barrel_files/interfaces.dart';
import 'package:flutter_herodex3000/barrel_files/factories.dart';
import 'package:flutter_herodex3000/barrel_files/repositories.dart';

class AgentDataManager implements IAgentDataManager{
  static final clientFactory = HttpClientFactory();
  final SuperHeroApiRepository apiHeroRepo;
  final List<AgentModel> _agentsList = [];

  // Private constructor for Singleton
  AgentDataManager._internal({required this.apiHeroRepo});

  // Single static instance
  static AgentDataManager? _instance;

  // Factory only creates once
  factory AgentDataManager({SuperHeroApiRepository? apiRepo}){
    _instance ??= AgentDataManager._internal(
      apiHeroRepo: apiRepo ?? SuperHeroApiRepository(clientFactory: clientFactory),
    );
    return _instance!;
  }

  
  // Function to create new agent/villian with check for if the name already exist and wont create a duplicate
  @override
  Future<AgentModel?> createAgent(AgentModel agent) async {

    try {
      final agentAlreadyExists = _agentsList.any((a) => a.name.toLowerCase() == agent.name.toLowerCase());

      if(agentAlreadyExists){     
        return null;
      }

      final newAgent = AgentModel(
        agentId: agent.agentId,
        name: agent.name,
        powerstats: agent.powerstats,
        biography: agent.biography,
        appearance: agent.appearance,
        image: agent.image,
        work: agent.work,
        connections: agent.connections,
      );
      _agentsList.add(newAgent);

      return newAgent;      
    } catch (e) {
        throw Exception("❌ Misslyckades att spara hjälte/skurk: $e");
    }

  }
  
  // Function to get all heroes/villians in the local list _agentsList
  @override
  Future<List<AgentModel>> getAllAgentsLocal() async {
    return _agentsList;
  }
  
  // Function to get agent/villian by name in the local list _agentsList
  @override
  Future<List<AgentModel>> getAgentByNameLocal(String agentName) async {
    final search = agentName.toLowerCase();
    return _agentsList
        .where((a) => a.name.toLowerCase().contains(search))
        .toList();
  }
  
  // Function to get agent/villian by name from the api https://superheroapi.com/
  @override
  Future<List<AgentModel>> getAgentByNameApi(String agentName) async {
    return apiHeroRepo.getAgentByName(agentName);
  }
  
  // Function to delete agent/villian from local list _agentsList
  @override
  Future<void> deleteAgent(String id) async {
    _agentsList.removeWhere((a) => a.agentId == id);
  }
  
  // Function to sort heroes and villians ans return Map with them sorted
  @override
  Future<Map<String, List<AgentModel>>> sortedAgents() async {
    final heroes = _agentsList
        .where((h) => h.biography.alignment.toLowerCase() == "good")
        .toList();

    final villains = _agentsList
        .where((v) => v.biography.alignment.toLowerCase() == "bad")
        .toList();

    final neutrals = _agentsList
        .where((v) => v.biography.alignment.toLowerCase() == "neutral")
        .toList();
    
    return {
      "heroes": heroes,
      "villains": villains,
      "neutrals" : neutrals
    };
  }
  

  
  // Function to get a agent/villian by Id in the local list _agentsList
  @override
  Future<AgentModel?> getAgentByIdLocal(String id) async {
    try {
      var agent = _agentsList.firstWhere((a) => a.agentId == id);
      return agent;
    } catch (_) {
      return null;
    }
  }
  
    // Function to load heroes/villians from the local json file to the _agentsList
  // @override
  // Future<int> loadHeroesFromJsonToHeroesList() async {
  //   try {
  //     final parsedJsonHeroes = await localFileRepo.readLocalHeroFile();

  //     _agentsList
  //       ..clear()
  //       ..addAll(parsedJsonHeroes);

  //     return _agentsList.length;
  //   } catch (e) {
  //     throw Exception("❌ Misslyckades att ladda hjältar och skurkar: $e");
  //   }
  // }

  
  // Function to update the local json file with the local list _agentsList
  // @override
  // Future<void> updateJsonWithHeroesList() async {
  //   try {
  //     await localFileRepo.updateLocalHeroFile(_agentsList);
  //   } catch (e) {
  //     throw Exception("❌ Misslyckades att spara hjältar och skurkar: $e");
  //   }
  // }


  // Update agent prepered function
  // @override
  // Future<AgentModel> updateHero(AgentModel updatedHero) async {
  //   final index = _agentsList.indexWhere((h) => h.heroId == updatedHero.heroId);
  //   if (index == -1) {
  //     throw Exception("Hero with ID ${updatedHero.heroId} not found");
  //   }
  //   _agentsList[index] = updatedHero;
  //   return updatedHero;
  // }

}