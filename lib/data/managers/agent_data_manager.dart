import 'package:flutter_herodex3000/barrel_files/models.dart';
import 'package:flutter_herodex3000/barrel_files/interfaces.dart';
import 'package:flutter_herodex3000/barrel_files/factories.dart';
import 'package:flutter_herodex3000/barrel_files/repositories.dart';

///
/// Handles [AgentModel] data from and to Firestore 
/// and from the API https://superheroapi.com/
/// via [SuperHeroApiRepository] and [FirestoreRepository]
/// 

class AgentDataManager implements IAgentDataManager{
  static final clientFactory = HttpClientFactory();
  final SuperHeroApiRepository apiHeroRepo;
  final FirestoreRepository firestoreRepo;

  /// Private constructor for Singleton
  AgentDataManager._internal({required this.apiHeroRepo, required this.firestoreRepo});

  /// Single static instance
  static AgentDataManager? _instance;

  /// Factory only creates once
  factory AgentDataManager({SuperHeroApiRepository? apiRepo}){
    _instance ??= AgentDataManager._internal(
      apiHeroRepo: apiRepo ?? SuperHeroApiRepository(clientFactory: clientFactory),
      firestoreRepo: FirestoreRepository(),
    );
    return _instance!;
  }
  
  /// Function to get agent/villian by name from the api https://superheroapi.com/ via [SuperHeroApiRepository]
  @override
  Future<List<AgentModel>> getAgentByNameApi(String agentName) async {
    return apiHeroRepo.getAgentByName(agentName);
  }
  
  /// Function to delete agent from Firestore via [FirestoreRepository]
  @override
  Future<void> deleteAgentFromFirestore(String agentId) {
    return firestoreRepo.deleteAgent(agentId);
  }
  
  /// Function to get all agents from Firestore via [FirestoreRepository]
  @override
  Future<List<AgentModel>> getAllAgentsFromFirestore() {
    return firestoreRepo.getAllSavedAgents();
  }
  
  /// Function to check if an agent is already in Firestore via [FirestoreRepository]
  @override
  Future<bool> isAgentInFirestore(String agentId) {
    return firestoreRepo.isAgentSaved(agentId);
  }
  
  /// Function to save agent to Firestore via [FirestoreRepository]
  @override
  Future<void> saveAgentToFirestore(AgentModel agent) {
    return firestoreRepo.saveAgent(agent);
  }
}