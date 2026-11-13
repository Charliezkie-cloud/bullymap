import 'package:bullymap/features/home/models/navigation_step.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

class NavigationRoute {
  final List<Position> geometry;
  final double distance;
  final double duration;
  final List<NavigationStep> steps;

  const NavigationRoute({
    required this.geometry,
    required this.distance,
    required this.duration,
    required this.steps,
  });

  // Methods
  factory NavigationRoute.fromJson(Map<String, dynamic> json) {
    final rawGeometry = json['geometry'] as Map<String, dynamic>? ?? {};
    final rawCoords = (rawGeometry['coordinates'] as List<dynamic>?) ?? [];

    final geometry = rawCoords.map((coord) {
      final list = coord as List<dynamic>;
      return Position((list[0] as num).toDouble(), (list[1] as num).toDouble());
    }).toList();

    final legs = (json['legs'] as List<dynamic>?) ?? [];
    final steps = <NavigationStep>[];

    for (final leg in legs) {
      final legSteps = (leg['steps'] as List<dynamic>?) ?? [];
      for (final step in legSteps) {
        steps.add(NavigationStep.fromJson(step as Map<String, dynamic>));
      }
    }

    return NavigationRoute(
      geometry: geometry,
      distance: (json['distance'] as num?)?.toDouble() ?? 0.0,
      duration: (json['duration'] as num?)?.toDouble() ?? 0.0,
      steps: steps,
    );
  }

  String get formattedDuration {
    final minutes = (duration / 60).round();
    if (minutes < 60) return '$minutes min';
    final hours = minutes ~/ 60;
    final remainingMinutes = minutes % 60;
    return '${hours}h ${remainingMinutes}m';
  }

  String get formattedDistance {
    if (distance >= 1000) {
      return '${(distance / 1000).toStringAsFixed(1)} km';
    }
    return '${distance.round()} m';
  }

  String get etaString {
    final arrivalTime = DateTime.now().add(Duration(seconds: duration.round()));
    final hour = arrivalTime.hour > 12
        ? arrivalTime.hour - 12
        : (arrivalTime.hour == 0 ? 12 : arrivalTime.hour);
    final minute = arrivalTime.minute.toString().padLeft(2, '0');
    final period = arrivalTime.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }
}
