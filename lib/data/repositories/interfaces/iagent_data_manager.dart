import 'package:flutter_herodex3000/barrel_files/models.dart';

abstract class IAgentDataManager {

  Future<void> createAgent(AgentModel agent);
  Future<List<AgentModel>> getAllAgentsLocal();
  Future<List<AgentModel>> getAgentByNameLocal(String agentName);
  Future<List<AgentModel>> getAgentByNameApi(String agentName);
  Future<AgentModel?> getAgentByIdLocal(String id);
  Future<Map<String, List<AgentModel>>> sortedAgents();
  Future<void> deleteAgent(String id);
  //Future<void> updateJsonWithHeroesList();
  //Future<void> loadHeroesFromJsonToHeroesList();
  //Future<AgentModel> updateHero(AgentModel updatedHero);
}