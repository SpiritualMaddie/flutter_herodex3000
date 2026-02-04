import 'package:flutter_herodex3000/data/models/agent_model.dart';

// TODO look through comments can be removed?
/// In-memory cache so go_router can look up a full [AgentModel] by ID.
/// When the app navigate to /details/:id, it puts the agent here first,
/// then the route builder fetches it back out.
class AgentCache {
  static final Map<String, AgentModel> _cache = {};

  static void put(AgentModel agent) {
    _cache[agent.agentId] = agent;
  }

  static AgentModel? get(String id) {
    return _cache[id];
  }

  /// Clear cache if needed (e.g. on logout)
  static void clear() {
    _cache.clear();
  }
}