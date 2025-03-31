class Route {
  final int? routeId;
  final String? origin;
  final String? destination;
  final double? distance;
  final String? estimatedDuration;
  final int? flightCount;

  Route({
    this.routeId,
    this.origin,
    this.destination,
    this.distance,
    this.estimatedDuration,
    this.flightCount,
  });

  factory Route.fromJson(Map<String, dynamic> json) {
    return Route(
      routeId: json['route_id'],
      origin: json['origin'],
      destination: json['destination'],
      distance: json['distance'] != null ? json['distance'].toDouble() : null,
      estimatedDuration: json['estimated_duration'],
      flightCount: json['flight_count'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'route_id': routeId,
      'origin': origin,
      'destination': destination,
      'distance': distance,
      'estimated_duration': estimatedDuration,
      'flight_count': flightCount,
    };
  }
}
