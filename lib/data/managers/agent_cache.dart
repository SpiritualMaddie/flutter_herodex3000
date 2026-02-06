import 'package:flutter_herodex3000/data/models/agent_model.dart';

/// In-memory cache so go_router can look up a full [AgentModel] by ID.
/// Never used but planned to be implemented - ran out of time
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