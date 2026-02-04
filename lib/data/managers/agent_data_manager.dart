import 'package:flutter_herodex3000/barrel_files/models.dart';
import 'package:flutter_herodex3000/barrel_files/interfaces.dart';
import 'package:flutter_herodex3000/barrel_files/factories.dart';
import 'package:flutter_herodex3000/barrel_files/repositories.dart';
import 'package:flutter_herodex3000/data/repositories/firestore_repository.dart';

/// Handles [AgentModel] data from and to Firestore 
/// and from the api https://superheroapi.com/

class AgentDataManager implements IAgentDataManager{
  static final clientFactory = HttpClientFactory();
  final SuperHeroApiRepository apiHeroRepo;
  final FirestoreRepository firestoreRepo;

  // Private constructor for Singleton
  AgentDataManager._internal({required this.apiHeroRepo, required this.firestoreRepo});

  // Single static instance
  static AgentDataManager? _instance;

  // Factory only creates once
  factory AgentDataManager({SuperHeroApiRepository? apiRepo}){
    _instance ??= AgentDataManager._internal(
      apiHeroRepo: apiRepo ?? SuperHeroApiRepository(clientFactory: clientFactory),
      firestoreRepo: FirestoreRepository(),
    );
    return _instance!;
  }
  
  // Function to get agent/villian by name from the api https://superheroapi.com/
  @override
  Future<List<AgentModel>> getAgentByNameApi(String agentName) async {
    return apiHeroRepo.getAgentByName(agentName);
  }
  
  // Function to delete agent from Firestore
  @override
  Future<void> deleteAgentFromFirestore(String agentId) {
    return firestoreRepo.deleteAgent(agentId);
  }
  
  // Function to get all agents from Firestore
  @override
  Future<List<AgentModel>> getAllAgentsFromFirestore() {
    return firestoreRepo.getAllSavedAgents();
  }
  
  // Function to check if an agent is already in Firestore
  @override
  Future<bool> isAgentInFirestore(String agentId) {
    return firestoreRepo.isAgentSaved(agentId);
  }
  
  // Function to save agent to Firestore
  @override
  Future<void> saveAgentToFirestore(AgentModel agent) {
    return firestoreRepo.saveAgent(agent);
  }
}