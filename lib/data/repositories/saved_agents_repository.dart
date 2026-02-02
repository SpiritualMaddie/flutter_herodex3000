import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_herodex3000/data/models/agent_model.dart';
// TODO change name
/// Handles saving/loading the user's roster in Firestore.
///
/// Structure in Firestore:
///   /users/{userId}/saved_agents/{agentId}  →  AgentModel.toJson()
///
/// Each agent is its own document so adding/removing one agent
/// doesn't rewrite the whole list.
class SavedAgentsRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  SavedAgentsRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })
      : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  /// Returns the collection reference for the current user's saved agents.
  /// Throws if no user is signed in.
  CollectionReference<Map<String, dynamic>> get _collection {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw Exception('No authenticated user');
    return _firestore.collection('users').doc(uid).collection('saved_agents');
  }

  /// Saves an agent to the user's roster.
  /// Uses the agent's ID as the document ID so duplicates overwrite cleanly.
  Future<void> saveAgent(AgentModel agent) async {
    try {
      await _collection.doc(agent.agentId).set(agent.toJson());
    } catch (e, st) {
      debugPrint('❌ SavedAgentsRepository.saveAgent: $e\n$st');
      throw Exception('Failed to save agent: $e');
    }
  }

  /// Removes an agent from the user's roster by ID.
  Future<void> removeAgent(String agentId) async {
    try {
      await _collection.doc(agentId).delete();
    } catch (e, st) {
      debugPrint('❌ SavedAgentsRepository.removeAgent: $e\n$st');
      throw Exception('Failed to remove agent: $e');
    }
  }

  /// Loads all saved agents for the current user.
  /// Returns an empty list on any error — never throws to the caller.
  Future<List<AgentModel>> getAllSavedAgents() async {
    try {
      final snapshot = await _collection.get();
      return snapshot.docs
          .map((doc) => AgentModel.fromJson(doc.data()))
          .toList();
    } catch (e, st) {
      debugPrint('❌ SavedAgentsRepository.getAllSavedAgents: $e\n$st');
      return [];
    }
  }

  /// Checks if a specific agent is already saved.
  Future<bool> isAgentSaved(String agentId) async {
    try {
      final doc = await _collection.doc(agentId).get();
      return doc.exists;
    } catch (e, st) {
      debugPrint('❌ SavedAgentsRepository.isAgentSaved: $e\n$st');
      return false;
    }
  }
}