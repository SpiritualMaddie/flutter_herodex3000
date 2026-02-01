import 'package:flutter/material.dart';
import 'package:flutter_herodex3000/presentation/view_models/agent_summary.dart';

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

  // TODO Colors based on alignment doesnt work
  // Also make small alignment "hero" or "villain" in right corner
  Color get _accentColor => agent.isHero ? Colors.cyan : Colors.redAccent;

  @override
  Widget build(BuildContext context) {
    final card = switch (layout) {
      AgentCardLayout.grid => _buildGridCard(),
      AgentCardLayout.list => _buildListCard(),
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
  Widget _buildGridCard() {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF121F2B),
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
                  child: _buildImageOrPlaceholder(expanded: true),
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
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  _buildMiniStatBar('PWR', agent.power, _accentColor),
                  const SizedBox(height: 4),
                  _buildMiniStatBar('STR', agent.strength, Colors.brown),
                  const SizedBox(height: 4),
                  _buildMiniStatBar('INT', agent.intelligence, Colors.grey),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- LIST CARD (Roster) ---
  Widget _buildListCard() {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF121F2B),
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
                child: _buildImageOrPlaceholder(expanded: false),
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
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        agent.alignment.toUpperCase(),
                        style: TextStyle(
                          color: _accentColor,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _buildMiniStatBar('PWR', agent.power, _accentColor),
                  const SizedBox(height: 4),
                  _buildMiniStatBar('STR', agent.strength, Colors.brown),
                  const SizedBox(height: 4),
                  _buildMiniStatBar('INT', agent.intelligence, Colors.grey),
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
  Widget _buildImageOrPlaceholder({required bool expanded}) {
    final placeholder = Container(
      color: const Color(0xFF0A111A),
      child: Center(
        child: Icon(
          Icons.person,
          size: expanded ? 50 : 28,
          color: _accentColor.withAlpha(100),
        ),
      ),
    );

    if (agent.imageUrl.trim().isEmpty) return placeholder;

    return Image.network(
      agent.imageUrl,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => placeholder,
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return placeholder;
      },
    );
  }

  /// Compact stat bar used in both grid and list cards.
  /// [value] is 0–100 from the API, normalized to 0.0–1.0 for the progress indicator.
  Widget _buildMiniStatBar(String label, int value, Color color) {
    return Row(
      children: [
        SizedBox(
          width: 30,
          child: Text(
            label,
            style: const TextStyle(color: Colors.grey, fontSize: 8),
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