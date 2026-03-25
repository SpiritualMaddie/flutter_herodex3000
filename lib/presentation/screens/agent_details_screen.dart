import 'package:flutter_herodex3000/barrel_files/routing.dart';
import 'package:flutter_herodex3000/barrel_files/widgets.dart';
import 'package:flutter_herodex3000/barrel_files/models.dart';
import 'package:flutter_herodex3000/barrel_files/managers.dart';
import 'package:flutter_herodex3000/barrel_files/dart_flutter_packages.dart';

///
/// Full details view that takes an [AgentModel] and display all available information.
///
/// Features:
/// - Collapsing image header (SliverAppBar)
/// - Complete biography, appearance, work, and connections data
/// - Six powerstats with progress bars
/// - Conditional save button (hidden when viewed from Roster)
/// - Checks Firestore to see if already saved (disables button)
/// - Optimistic UI with error handling
///
/// Data Sections (only shown if data exists):
/// - Intel: Place of birth, first appearance, publisher, aliases
/// - Appearance: Gender, race, eye/hair color, height, weight
/// - Work: Occupation, base of operations
/// - Connections: Group affiliation, relatives
///
/// Why conditional sections: API data is inconsistent - some agents have
/// full bios, others have minimal info. Hiding empty sections keeps UI clean.
///
class AgentDetailsScreen extends StatefulWidget {
  final AgentModel agent;

  /// Controls save button visibility.
  ///
  /// true: Opened from Search → show save button
  /// false: Opened from Roster → hide save button (already saved)
  final bool showSaveButton;

  const AgentDetailsScreen({
    super.key,
    required this.agent,
    this.showSaveButton = true,
  });

  @override
  State<AgentDetailsScreen> createState() => _AgentDetailsScreenState();
}

class _AgentDetailsScreenState extends State<AgentDetailsScreen> {
  final AgentDataManager _agentDataRepo = AgentDataManager();
  bool _isSaved = false;

  // Convenience getters for alignment-based styling
  bool get _isHero =>
      widget.agent.biography.alignment.trim().toLowerCase() == 'good';
  Color get _accentColor => _isHero ? Colors.cyan : Colors.redAccent;

  @override
  void initState() {
    super.initState();
    // Only check Firestore if save button is visible
    if (widget.showSaveButton) {
      _checkIfSaved();
    }
  }

  /// Checks if agent already exists in user's Firestore roster.
  ///
  /// Called only when showSaveButton is true (opened from Search).
  /// Updates _isSaved state to disable save button if already saved.
  Future<void> _checkIfSaved() async {
    try {
      final saved = await _agentDataRepo.isAgentInFirestore(
        widget.agent.agentId,
      );
      if (!mounted) return;
      setState(() => _isSaved = saved);
    } catch (e, st) {
      debugPrint('❌ AgentDetailsScreen._checkIfSaved: $e\n$st');
    }
  }

  /// Generic action handler for save/delete operations.
  ///
  /// Returns a Future that can be awaited by the action button.
  /// Throws on error so button can show error state.
  Future<void> _performAction({
    required Future<void> Function() action,
    required String successMessage,
    required String errorMessage,
    bool popOnSuccess = false,
  }) async {
    await action();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Center(
          child: Text(
            successMessage,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: .bold,
              letterSpacing: 1.5,
            ),
          ),
        ),
        backgroundColor: Colors.green.withAlpha(90),
      ),
    );

    if (popOnSuccess && mounted) {
      Navigator.pop(context, true); // Signal that action was completed
    }
  }

  /// Saves agent to Firestore
  Future<void> _saveAgent() async {
    await _performAction(action: () async {
      await _agentDataRepo.saveAgentToFirestore(widget.agent);
      if(mounted) setState(() => _isSaved = true);
    }, 
    successMessage: "${widget.agent.name} saved to roster ✅", 
    errorMessage: "❌ Failed to save. Try again.",
    popOnSuccess: false,
    );
  }

  /// Deletes agent from Firestore
  Future<void> _deleteAgent() async {
    await _performAction(
      action: () => _agentDataRepo.deleteAgentFromFirestore(widget.agent.agentId),
      successMessage: "${widget.agent.name} deleted from roster ✅", 
      errorMessage: "❌ Failed to delete. Try again.",
      popOnSuccess: true, // Pop back to roster after successful delete
      );
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveScaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      child: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 24),
                  _buildAllStats(),
                  const SizedBox(height: 24),
                  _buildBiography(),
                  const SizedBox(height: 24),
                  _buildAppearance(),
                  const SizedBox(height: 24),
                  _buildWork(),
                  const SizedBox(height: 24),
                  _buildConnections(),
                  const SizedBox(height: 48),
                  // Show Save button from Search and Delete button from Roster
                  widget.showSaveButton
                      ? _AgentActionButton(
                          onPressed: _saveAgent,
                          isDisabled: _isSaved,
                          disabledText: "ALREADY IN ROSTER ✓",
                          activeText: "SAVE TO ROSTER",
                          backgroundColor: _isSaved
                              ? Theme.of(
                                  context,
                                ).colorScheme.primary.withAlpha(50)
                              : _accentColor,
                          textColor: _isSaved
                              ? Theme.of(
                                  context,
                                ).colorScheme.onSurface.withAlpha(90)
                              : (_accentColor ==
                                        Theme.of(context).colorScheme.primary
                                    ? Colors.black
                                    : Colors.white),
                        )
                      : _AgentActionButton(
                          onPressed: _deleteAgent,
                          activeText: "DELETE FROM ROSTER",
                          backgroundColor: Colors.redAccent,
                          textColor: Colors.black,
                        ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Collapsing app bar with agent image.
  ///
  /// Features:
  /// - CorsProxyImage with error handling
  /// - Custom back button with accent color
  Widget _buildSliverAppBar() {
    final imageUrl = widget.agent.image?.url;
    final hasImage = imageUrl != null && imageUrl.trim().isNotEmpty;

    return SliverAppBar(
      backgroundColor: Colors.transparent,
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back_ios,
          color: Theme.of(context).colorScheme.primary,
        ),
        onPressed: () => context.pop(),
      ),
      expandedHeight: 300,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [_accentColor.withAlpha(30), Colors.transparent],
            ),
          ),
          child: Center(
            child: hasImage
                ? CorsProxyImage(
                    imageUrl: imageUrl,
                    height: 200,
                    fit: BoxFit.contain,
                    errorWidget: Icon(
                      Icons.shield,
                      size: 120,
                      color: _accentColor,
                    ),
                  )
                : Icon(Icons.shield, size: 120, color: _accentColor),
          ),
        ),
      ),
    );
  }

  /// Agent name and alignment badge.
  Widget _buildHeader() {
    final bio = widget.agent.biography;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "AGENT CODENAME",
              style: TextStyle(
                color: _accentColor.withAlpha(180),
                fontSize: 12,
                fontWeight: .bold,
                letterSpacing: 1,
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
                bio.alignment == "good"
                    ? "HERO"
                    : bio.alignment == "bad"
                    ? "VILLAIN"
                    : bio.alignment == "neutral"
                    ? "NEUTRAL"
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
        const SizedBox(height: 4),
        Text(
          widget.agent.name,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
        ),
        // Full name + alter egos under the main name if available
        if (_hasContent(bio.fullName))
          Text(
            bio.fullName!,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 14,
              fontWeight: .bold,
            ),
          ),
        if (_hasContent(bio.alterEgos))
          Text(
            bio.alterEgos!,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 12,
            ),
          ),
      ],
    );
  }

  /// Six powerstats with labeled progress bars.
  ///
  /// - Progress bar (0-100 normalized to 0.0-1.0)
  Widget _buildAllStats() {
    final stats = widget.agent.powerstats;
    return Column(
      children: [
        _buildStatRow("INTELLIGENCE", stats.intelligence),
        _buildStatRow("STRENGTH", stats.strength),
        _buildStatRow("SPEED", stats.speed),
        _buildStatRow("DURABILITY", stats.durability),
        _buildStatRow("POWER", stats.power),
        _buildStatRow("COMBAT", stats.combat),
      ],
    );
  }

  /// Single powerstat row with label, value, and progress bar.
  ///
  /// Value is clamped to 0-100 (API sometimes returns out-of-range values).
  Widget _buildStatRow(String label, int value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 10,
                  letterSpacing: 1,
                  fontWeight: .bold,
                ),
              ),
              Text(
                '${value.clamp(0, 100)}',
                style: TextStyle(
                  color: _accentColor,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: value.clamp(0, 100) / 100.0,
              backgroundColor: Theme.of(
                context,
              ).colorScheme.primary.withAlpha(50),
              color: _accentColor,
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }

  /// Biography section
  ///
  /// Section only renders if at least one field has content.
  /// Uses _hasContent() to filter out null/empty strings.
  Widget _buildBiography() {
    final bio = widget.agent.biography;

    // Collect only the rows that have content
    final rows = <Widget>[];

    if (_hasContent(bio.placeOfBirth)) {
      rows.add(_buildInfoRow("Place of Birth", bio.placeOfBirth));
    }
    if (_hasContent(bio.firstAppearance)) {
      rows.add(_buildInfoRow("First Appearance", bio.firstAppearance));
    }
    if (_hasContent(bio.publisher)) {
      rows.add(_buildInfoRow("Publisher", bio.publisher));
    }
    if (bio.aliases != null && bio.aliases!.isNotEmpty) {
      rows.add(_buildInfoRow("Aliases", bio.aliases!.join(', ')));
    }

    // Don't render section if no data
    if (rows.isEmpty) return const SizedBox.shrink();

    return _buildSection("INTEL", rows);
  }

  /// Appearance section
  ///
  /// Height/weight are arrays like ["6'2\"", "188 cm"] - joined with " / ".
  /// Filters out null/empty values before joining.
  Widget _buildAppearance() {
    final app = widget.agent.appearance;
    final rows = <Widget>[];

    if (_hasContent(app.gender)) {
      rows.add(_buildInfoRow("Gender", app.gender));
    }
    if (_hasContent(app.race)) {
      rows.add(_buildInfoRow("Race", app.race));
    }
    if (_hasContent(app.eyeColor)) {
      rows.add(_buildInfoRow("Eye Color", app.eyeColor!));
    }
    if (_hasContent(app.hairColor)) {
      rows.add(_buildInfoRow("Hair Color", app.hairColor!));
    }

    if (app.height.isNotEmpty) {
      final heightStr = app.height
          .where((v) => v != null && v.toString().trim().isNotEmpty)
          .join(' / ');
      if (heightStr.isNotEmpty) {
        rows.add(_buildInfoRow("Height", heightStr));
      }
    }
    if (app.weight.isNotEmpty) {
      final weightStr = app.weight
          .where((v) => v != null && v.toString().trim().isNotEmpty)
          .join(' / ');
      if (weightStr.isNotEmpty) {
        rows.add(_buildInfoRow("Weight", weightStr));
      }
    }

    if (rows.isEmpty) return const SizedBox.shrink();

    return _buildSection("APPEARANCE", rows);
  }

  /// Work section
  Widget _buildWork() {
    final work = widget.agent.work;
    if (work == null) return const SizedBox.shrink();

    final rows = <Widget>[];

    if (_hasContent(work.occupation)) {
      rows.add(_buildInfoRow("Occupation", work.occupation!));
    }
    if (_hasContent(work.base)) {
      rows.add(_buildInfoRow("Base", work.base!));
    }

    if (rows.isEmpty) return const SizedBox.shrink();

    return _buildSection("WORK", rows);
  }

  /// Connections section
  Widget _buildConnections() {
    final conn = widget.agent.connections;
    if (conn == null) return const SizedBox.shrink();

    final rows = <Widget>[];

    if (_hasContent(conn.groupAffiliation)) {
      rows.add(_buildInfoRow("Affiliation", conn.groupAffiliation!));
    }
    if (_hasContent(conn.relatives)) {
      rows.add(_buildInfoRow("Relatives", conn.relatives!));
    }

    if (rows.isEmpty) return const SizedBox.shrink();

    return _buildSection("CONNECTIONS", rows);
  }

  // --- SHARED BUILDERS ---

  /// Wraps a list of info rows with colored section header.
  ///
  /// Used by all detail sections
  Widget _buildSection(String title, List<Widget> rows) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: _accentColor,
            fontSize: 12,
            letterSpacing: 2,
            fontWeight: .bold,
          ),
        ),
        const SizedBox(height: 12),
        ...rows,
      ],
    );
  }

  /// Single label/value row used in all detail sections.
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label.toUpperCase(),
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 10,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontSize: 13,
                fontWeight: .bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Returns true if a string has actual content (not null, not empty/whitespace).
  bool _hasContent(String? value) {
    return value != null && value.trim().isNotEmpty;
  }

}

// ===========================================================================
// REUSABLE ACTION BUTTON WIDGET
// ===========================================================================

/// Reusable action button for agent operations (save/delete).
///
/// Features:
/// - Automatic loading state management
/// - Error handling with SnackBar
/// - Disabled state support
/// - Customizable colors and text
/// - Spinner while loading
///
class _AgentActionButton extends StatefulWidget {
  final Future<void> Function() onPressed;
  final String activeText;
  final String? disabledText; // If null, button is never disabled
  final bool isDisabled;
  final Color backgroundColor;
  final Color textColor;
  final void Function(bool isLoading)? onLoadingChange;

  const _AgentActionButton({
    required this.onPressed,
    required this.activeText,
    this.disabledText,
    this.isDisabled = false,
    required this.backgroundColor,
    required this.textColor,
    // ignore: unused_element_parameter
    this.onLoadingChange,
  });

  @override
  State<_AgentActionButton> createState() => _AgentActionButtonState();
}

class _AgentActionButtonState extends State<_AgentActionButton> {
  bool _isLoading = false;

  Future<void> _handlePress() async {
    if (_isLoading || widget.isDisabled) return;

    setState(() => _isLoading = true);
    widget.onLoadingChange?.call(true);

    try {
      await widget.onPressed();
    } catch (e, st) {
      debugPrint('❌ _AgentActionButton error: $e\n$st');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Center(
            child: Text(
              "❌ Operation failed. Try again.",
              style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.5),
            ),
          ),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
        widget.onLoadingChange?.call(false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show disabled state if isDisabled is true
    if (widget.isDisabled && widget.disabledText != null) {
      return ElevatedButton(
        onPressed: null,
        style: ElevatedButton.styleFrom(
          backgroundColor: widget.backgroundColor,
          disabledBackgroundColor: widget.backgroundColor,
          minimumSize: const Size(double.infinity, 56),
        ),
        child: Text(
          widget.disabledText!,
          style: TextStyle(
            color: widget.textColor,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
      );
    }

    // Active button
    return ElevatedButton(
      onPressed: _isLoading ? null : _handlePress,
      style: ElevatedButton.styleFrom(
        backgroundColor: widget.backgroundColor,
        minimumSize: const Size(double.infinity, 56),
      ),
      child: _isLoading
          ? SizedBox(
              height: 24,
              width: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: widget.textColor,
              ),
            )
          : Text(
              widget.activeText,
              style: TextStyle(
                color: widget.textColor,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
    );
  }
}
