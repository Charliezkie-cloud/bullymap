import 'package:bullymap/features/home/data/models/pinned_location.dart';
import 'package:flutter/material.dart';

class LocationDetailsSheet extends StatelessWidget {
  // Constants
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
    required this.scrollController,
  });

  // Widget methods
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final selectedLocation = location;

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
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.symmetric(horizontal: 12),
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

              const SizedBox(height: 12),

              if (isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (selectedLocation == null)
                const Text('No location information available')
              else ...[
                Text(
                  selectedLocation.name,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),

                Text(
                  selectedLocation.address,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),

                const SizedBox(height: 12),
                const Divider(),
                const SizedBox(height: 12),

                _CoordinateRow(
                  label: 'Latitude',
                  value: selectedLocation.latitude.toStringAsFixed(6),
                ),

                const SizedBox(height: 12),

                _CoordinateRow(
                  label: 'Longitude',
                  value: selectedLocation.longitude.toStringAsFixed(6),
                ),

                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () => onStartNavigation(selectedLocation),
                    icon: const Icon(Icons.navigation),
                    label: const Text('Start navigation'),
                    style: FilledButton.styleFrom(
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

class _CoordinateRow extends StatelessWidget {
  // Constants
  final String label;
  final String value;

  const _CoordinateRow({required this.label, required this.value});

  // Widget methods
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label),
        SelectableText(
          value,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
