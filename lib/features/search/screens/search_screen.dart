// features/search/screens/search_screen.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_herodex3000/barrel_files/models.dart';
import 'package:flutter_herodex3000/barrel_files/screens.dart';
import 'package:flutter_herodex3000/data/managers/agent_cache.dart';
import 'package:flutter_herodex3000/data/managers/agent_data_manager.dart';
import 'package:flutter_herodex3000/presentation/helpers/agent_summary_mapper.dart';
import 'package:flutter_herodex3000/presentation/widgets/responsive_scaffold.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_herodex3000/presentation/view_models/agent_summary.dart';
import 'package:flutter_herodex3000/presentation/widgets/agent_card.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final AgentDataManager _dataManager = AgentDataManager();
  Timer? _debounce;
  bool _isLoading = false;

  /// List of full models
  List<AgentModel> _fullAgents = [];

  /// View Model summery of Agent Model that cards display.
  List<AgentSummary> _summaries = [];

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    if (query.trim().isEmpty) {
      setState(() {
        _fullAgents = [];
        _summaries = [];
        _isLoading = false;
      });
      return;
    }
    setState(() => _isLoading = true);
    _debounce = Timer(const Duration(milliseconds: 1200), () {
      _performSearch(query.trim());
    });
  }

  Future<void> _performSearch(String query) async {
    try {
      final agents = await _dataManager.getAgentByNameApi(query);

      if (!mounted) return;

      setState(() {
        _fullAgents = agents;
        _summaries = AgentSummaryMapper.toSummaryList(agents);
        _isLoading = false;
      });
    } catch (e, st) {
      debugPrint('❌ SearchScreen._performSearch: $e\n$st');
      if (!mounted) return;
      setState(() {
        _fullAgents = [];
        _summaries = [];
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveScaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: TextField(
          controller: _searchController,
          onChanged: _onSearchChanged,
          style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
          decoration: InputDecoration(
            hintText: "SEARCH FOR FELLOW AGENTS...",
            hintStyle: TextStyle(color: Theme.of(context).colorScheme.primary, fontSize: 12),
            border: InputBorder.none,
            prefixIcon: Icon(Icons.search, color: Theme.of(context).colorScheme.primary),
          ),
        ),
      ),
      child: _isLoading
          ? _buildLoadingState()
          : _summaries.isEmpty
              ? _buildInitialState()
              : _buildResultsState(),
    );
  }

  // VIEW 1: INITIAL STATE
  Widget _buildInitialState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.radar, size: 150, color: Theme.of(context).colorScheme.primary.withAlpha(20)),
          const SizedBox(height: 16),
          Text(
            "AWAITING INPUT",
            style: TextStyle(color: Theme.of(context).colorScheme.primary, letterSpacing: 2, fontSize: 17),
          ),
          Text(
            "READY TO SEARCH",
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              letterSpacing: 1,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // VIEW 2: LOADING STATE (SHIMMER)
  Widget _buildLoadingState() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.8,
      ),
      itemCount: 6,
      itemBuilder: (context, index) => Shimmer.fromColors(
        baseColor: Theme.of(context).colorScheme.primary.withAlpha(20),
        highlightColor: Theme.of(context).colorScheme.primary.withAlpha(60),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  // VIEW 3: RESULTS STATE — uses shared AgentCard
   Widget _buildResultsState() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.8,
      ),
      itemCount: _fullAgents.length,
      itemBuilder: (context, index) {
        final summary = AgentSummaryMapper.toSummary(_fullAgents[index]);
        return AgentCard(
          agent: summary,
          layout: AgentCardLayout.grid,
          onTap: () {
             // Cache the full model, then navigate
            //AgentCache.put(_fullAgents[index]);
            Navigator.push(
              context, 
            MaterialPageRoute(
              builder: (context) => AgentDetailsScreen(agent: _fullAgents[index], showSaveButton: true,)));
            //context.go('/details/${summary.id}');
          },
        );
      },
    );
  }
}