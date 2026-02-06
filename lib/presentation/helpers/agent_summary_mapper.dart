import 'package:flutter_herodex3000/barrel_files/models.dart';
import 'package:flutter_herodex3000/presentation/view_models/agent_summary.dart';

/// Maps between data models and view models.
/// Keeps the conversion logic out of both the UI and the data layer.
class AgentSummaryMapper {
  /// Converts a single [AgentModel] to an [AgentSummary].
  static AgentSummary toSummary(AgentModel agent) {
    return AgentSummary(
      id: agent.agentId,
      name: agent.name,
      imageUrl: agent.image?.url ?? '',
      alignment: agent.biography.alignment,
      power: agent.powerstats.power,
      strength: agent.powerstats.strength,
      intelligence: agent.powerstats.intelligence
    );
  }

  /// Converts a list of [AgentModel] to a list of [AgentSummary].
  static List<AgentSummary> toSummaryList(List<AgentModel> agents) {
    return agents.map(toSummary).toList();
  }
}