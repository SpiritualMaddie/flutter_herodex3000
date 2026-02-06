/// Lightweight view model used for list cards in Search and Roster.
/// Maps from the full [AgentModel] so the UI never touches the data layer directly.
class AgentSummary {
  final String id;
  final String name;
  final String imageUrl;
  final String alignment;
  final int power;
  final int strength;
  final int intelligence;

  const AgentSummary({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.alignment,
    required this.power,
    required this.strength,
    required this.intelligence,
  });

  bool get isHero => alignment.trim().toLowerCase() == 'good';
}