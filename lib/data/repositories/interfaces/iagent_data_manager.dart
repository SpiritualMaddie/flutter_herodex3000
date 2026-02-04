import 'package:flutter_herodex3000/barrel_files/models.dart';

abstract class IAgentDataManager {

  Future<List<AgentModel>> getAgentByNameApi(String agentName);
  Future<void> saveAgentToFirestore(AgentModel agent);
  Future<void> deleteAgentFromFirestore(String agentId);
  Future<List<AgentModel>> getAllAgentsFromFirestore();
  Future<bool> isAgentInFirestore(String agentId);
}