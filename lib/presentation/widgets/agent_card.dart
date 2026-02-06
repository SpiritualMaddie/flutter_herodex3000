import 'package:flutter_herodex3000/barrel_files/dart_flutter_packages.dart';
import 'package:flutter_herodex3000/presentation/view_models/agent_summary.dart';
import 'package:flutter_herodex3000/barrel_files/widgets.dart';

/// Shared card widget used in both Search (grid) and Roster (list).
///
/// [layout] controls the shape:
///   - [AgentCardLayout.grid]  → tall card for the search grid
///   - [AgentCardLayout.list]  → horizontal row for the roster list
///
/// [onTap] navigates to detail.
/// [onDismiss] is only used in Roster (swipe to remove). Pass null in Search.
enum AgentCardLayout { grid, list }

class AgentCard extends StatelessWidget {
  final AgentSummary agent;
  final AgentCardLayout layout;
  final VoidCallback onTap;
  final VoidCallback? onDismiss; // Only used in list layout (Roster)

  const AgentCard({
    super.key,
    required this.agent,
    required this.layout,
    required this.onTap,
    this.onDismiss,
  });

  // TODO Neutral should be different color
  Color get _accentColor => agent.isHero ? Colors.cyan : Colors.redAccent;

  @override
  Widget build(BuildContext context) {
    final card = switch (layout) {
      AgentCardLayout.grid => _buildGridCard(context),
      AgentCardLayout.list => _buildListCard(context),
    };

    // Wrap in Dismissible only for list layout when onDismiss is provided
    if (layout == AgentCardLayout.list && onDismiss != null) {
      return Dismissible(
        key: Key('agent_${agent.id}'),
        direction: DismissDirection.endToStart,
        onDismissed: (_) => onDismiss!(),
        background: Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.redAccent.withAlpha(20),
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: const Icon(Icons.delete_sweep, color: Colors.redAccent),
        ),
        child: card,
      );
    }

    return card;
  }

  // --- GRID CARD (Search) ---
  Widget _buildGridCard(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary.withAlpha(40),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _accentColor.withAlpha(24)),
        ),
        child: Column(
          children: [
            // Image area
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: _buildImageOrPlaceholder(expanded: true, context: context),
                ),
              ),
            ),
            // Info area
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    agent.name,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  _buildMiniStatBar('PWR', agent.power, _accentColor, context),
                  const SizedBox(height: 4),
                  _buildMiniStatBar('STR', agent.strength, Colors.brown, context),
                  const SizedBox(height: 4),
                  _buildMiniStatBar('INT', agent.intelligence, Theme.of(context).colorScheme.secondary.withAlpha(90), context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- LIST CARD (Roster) ---
  Widget _buildListCard(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary.withAlpha(40),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _accentColor.withAlpha(20)),
        ),
        child: Row(
          children: [
            // Thumbnail
            SizedBox(
              width: 60,
              height: 60,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: _buildImageOrPlaceholder(expanded: false, context: context),
              ),
            ),
            const SizedBox(width: 16),
            // Info & Stats
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        agent.name,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: _accentColor.withAlpha(30),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _accentColor.withAlpha(80)),
              ),
              child: Text(
                agent.alignment == "good" ? "HERO"
                  : agent.alignment == "bad" ? "VILLAIN"
                  : agent.alignment == "neutral" ? "NEUTRAL"
                  : "UNKNOWN",
                style: TextStyle(
                  color: _accentColor,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
            ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _buildMiniStatBar('PWR', agent.power, _accentColor, context),
                  const SizedBox(height: 4),
                  _buildMiniStatBar('STR', agent.strength, Colors.brown, context),
                  const SizedBox(height: 4),
                  _buildMiniStatBar('INT', agent.intelligence, Colors.grey, context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- SHARED HELPERS ---

  /// Shows the agent image if available, otherwise a placeholder icon.
  Widget _buildImageOrPlaceholder({required bool expanded, required BuildContext context}) {
    final placeholder = Container(
      color: Theme.of(context).colorScheme.surface,
      child: Center(
        child: Icon(
          Icons.person,
          size: expanded ? 50 : 28,
          color: _accentColor.withAlpha(100),
        ),
      ),
    );

    if (agent.imageUrl.trim().isEmpty) return placeholder;

    return CorsProxyImage(
      imageUrl:  agent.imageUrl,
      fit: BoxFit.cover,
      errorWidget: placeholder,
    );
  }

  /// Compact stat bar used in both grid and list cards.
  /// [value] is 0–100 from the API, normalized to 0.0–1.0 for the progress indicator.
  Widget _buildMiniStatBar(String label, int value, Color color, BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 30,
          child: Text(
            label,
            style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 8),
          ),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: (value.clamp(0, 100)) / 100.0,
              minHeight: 3,
              backgroundColor: Colors.black26,
              color: color,
            ),
          ),
        ),
      ],
    );
  }
}