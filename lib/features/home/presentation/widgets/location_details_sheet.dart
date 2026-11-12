
import 'package:bullymap/features/home/models/pinned_location.dart';
import 'package:flutter/material.dart';

class LocationDetailsSheet extends StatelessWidget {
  final PinnedLocation? location;
  final ValueChanged<PinnedLocation> onStartNavigation;
  final VoidCallback onClose;
  final ScrollController scrollController;
  final bool isLoading;

  const LocationDetailsSheet({
    super.key,
    required this.location,
    required this.isLoading,
    required this.onClose,
    required this.onStartNavigation,
    required this.scrollController
  });

  Widget _coordinateRow(BuildContext context, String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label),
        SelectableText(
          value,
          style: const TextStyle(fontWeight: FontWeight.w600)
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            children: [              
              Row(
                children: [
                  const Spacer(),
                  Container(
                    width: 40,
                    height: 5,
                    decoration: BoxDecoration(
                      color: colors.outlineVariant,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  const Spacer(),
                ],
              ),

              Row(
                children: [
                  const Spacer(),
                  IconButton(
                    onPressed: onClose,
                    icon: const Icon(Icons.close),
                    tooltip: 'Close',
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),

              const SizedBox(height: 12),

              if (isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (location == null)
                const Text('No location information available')
              else ...[
                Text(
                  location!.name,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                
                Text(
                  location!.address,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),

                const SizedBox(height: 12),
                const Divider(),
                const SizedBox(height: 12),

                _coordinateRow(
                  context,
                  'Latitude',
                  location!.latitude.toStringAsFixed(6),
                ),

                const SizedBox(height: 12),

                _coordinateRow(
                  context,
                  'Longitude',
                  location!.longitude.toStringAsFixed(6),
                ),

                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () => onStartNavigation(location!),
                    icon: const Icon(Icons.navigation),
                    label: const Text('Start navigation'),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
