import 'package:bullymap/features/home/models/location_suggestion.dart';
import 'package:flutter/material.dart';

class MapSearchResultSheet extends StatelessWidget {
  // Constants
  final List<LocationSuggestion> suggestions;
  final ValueChanged<LocationSuggestion>? onSelected;
  final VoidCallback onClose;
  final ScrollController scrollController;

  const MapSearchResultSheet({
    super.key,
    required this.suggestions,
    required this.onClose,
    required this.scrollController,
    this.onSelected,
  });

  // Widget methods
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Material(
      color: colors.surface,
      elevation: 8,
      borderRadius: const BorderRadius.vertical(
        top: Radius.circular(24),
      ),
      clipBehavior: Clip.antiAlias,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: Column(
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 5,
                  decoration: BoxDecoration(
                    color: colors.outlineVariant,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),

              Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  onPressed: onClose,
                  icon: const Icon(Icons.close),
                  tooltip: 'Close',
                  visualDensity: VisualDensity.compact,
                ),
              ),

              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Search Results',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'By Nearest Location',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),

              Expanded(
                child: suggestions.isEmpty
                    ? const Center(child: Text('No results found'))
                    : ListView.separated(
                        controller: scrollController,
                        itemCount: suggestions.length,
                        padding: EdgeInsets.zero,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final item = suggestions[index];

                          return ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                            leading: const Icon(Icons.place_outlined),
                            title: Text(
                              item.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: item.placeFormatted.isEmpty
                                ? null
                                : Text(
                                    item.placeFormatted,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                            onTap: onSelected == null
                                ? null
                                : () => onSelected!(item),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}