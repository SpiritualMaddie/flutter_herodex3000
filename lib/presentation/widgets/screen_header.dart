import 'package:flutter/material.dart';
import 'package:flutter_herodex3000/presentation/widgets/section_header.dart';

// Screen header with title and search bar.

class ScreenHeader extends StatelessWidget {
  final String title;
  final IconData? titleIcon;
  final TextEditingController searchController;
  final String searchHint;
  final String currentQuery;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback? onClearSearch;
  final Widget? additionalContent; // For filters, buttons, etc. below search

  const ScreenHeader({
    super.key,
    required this.title,
    this.titleIcon,
    required this.searchController,
    required this.searchHint,
    required this.currentQuery,
    required this.onSearchChanged,
    this.onClearSearch,
    this.additionalContent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      padding: const EdgeInsets.only(top: 56, left: 16, right: 16, bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          SectionHeader(
            icon: titleIcon,
            title: title,
            titleFontSize: 22,
            padding: const EdgeInsets.only(bottom: 20),
          ),

          // Search bar
          SizedBox(
            height: 44,
            child: TextField(
              controller: searchController,
              onChanged: onSearchChanged,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 14,
              ),
              decoration: InputDecoration(
                filled: true,
                fillColor: Theme.of(context).colorScheme.onSurface.withAlpha(20),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.primary.withAlpha(40),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.primary.withAlpha(100),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.primary.withAlpha(40),
                  ),
                ),
                hintText: searchHint,
                hintStyle: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontSize: 13,
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: Theme.of(context).colorScheme.primary,
                  size: 20,
                ),
                suffixIcon: currentQuery.isNotEmpty
                    ? IconButton(
                        icon: Icon(
                          Icons.close,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          size: 18,
                        ),
                        onPressed: onClearSearch ?? () => searchController.clear(),
                      )
                    : null,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),

          // Additional content (filters, buttons, etc.)
          if (additionalContent != null) ...[
            const SizedBox(height: 10),
            additionalContent!,
          ],
        ],
      ),
    );
  }
}