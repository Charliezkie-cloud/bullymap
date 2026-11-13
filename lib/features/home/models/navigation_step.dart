import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

class NavigationStep {
  final String instruction;
  final String? modifier;
  final String? type;
  final double distance;
  final double duration;
  final Position location;

  const NavigationStep({
    required this.instruction,
    required this.modifier,
    required this.type,
    required this.distance,
    required this.duration,
    required this.location,
  });

  factory NavigationStep.fromJson(Map<String, dynamic> json) {
    final maneuver = json['maneuver'] as Map<String, dynamic>? ?? {};
    final coords = (maneuver['location'] as List<dynamic>?) ?? [0.0, 0.0];

    return NavigationStep(
      instruction: maneuver['instruction'] as String? ?? 'Proceed along route',
      modifier: maneuver['modifier'] as String?,
      type: maneuver['type'] as String?,
      distance: (json['distance'] as num?)?.toDouble() ?? 0.0,
      duration: (json['duration'] as num?)?.toDouble() ?? 0.0,
      location: Position(
        (coords[0] as num).toDouble(),
        (coords[1] as num).toDouble(),
      ),
    );
  }

  IconData get maneuverIcon {
    final mod = modifier?.toLowerCase() ?? '';
    final t = type?.toLowerCase() ?? '';

    if (t == 'arrive') return Icons.place;
    if (t == 'depart') return Icons.navigation;
    if (mod.contains('uturn')) return Icons.u_turn_left;
    if (mod.contains('sharp right')) return Icons.turn_sharp_right;
    if (mod.contains('sharp left')) return Icons.turn_sharp_left;
    if (mod.contains('slight right')) return Icons.turn_slight_right;
    if (mod.contains('slight left')) return Icons.turn_slight_left;
    if (mod.contains('right')) return Icons.turn_right;
    if (mod.contains('left')) return Icons.turn_left;
    if (mod.contains('straight')) return Icons.straight;
    return Icons.straight;
  }

  String get formattedDistance {
    if (distance >= 1000) {
      return '${(distance / 1000).toStringAsFixed(1)} km';
    }
    return '${distance.round()} m';
  }
}
