class Flight {
  final int? flightId;
  final String? flightNumber;
  final int? routeId;
  final String? origin;
  final String? destination;
  final int? aircraftId;
  final String? aircraftModel;
  final String? registrationNumber;
  final DateTime? departureTime;
  final DateTime? arrivalTime;
  final String? status;
  final String? gate;
  final String? captainName;
  final int? captainId;
  final int? bookedSeats;
  final int? totalCapacity;

  Flight({
    this.flightId,
    this.flightNumber,
    this.routeId,
    this.origin,
    this.destination,
    this.aircraftId,
    this.aircraftModel,
    this.registrationNumber,
    this.departureTime,
    this.arrivalTime,
    this.status,
    this.gate,
    this.captainName,
    this.captainId,
    this.bookedSeats,
    this.totalCapacity,
  });

  String get formattedDepartureTime {
    return departureTime != null 
      ? '${departureTime!.hour.toString().padLeft(2, '0')}:${departureTime!.minute.toString().padLeft(2, '0')}'
      : '--:--';
  }

  String get formattedDepartureDate {
    return departureTime != null 
      ? '${departureTime!.day.toString().padLeft(2, '0')}.${departureTime!.month.toString().padLeft(2, '0')}'
      : '--:--';
  }

  String get formattedArrivalDate {
    return arrivalTime != null 
      ? '${arrivalTime!.day.toString().padLeft(2, '0')}.${arrivalTime!.month.toString().padLeft(2, '0')}'
      : '--:--';
  }

  String get duration {
    if (departureTime == null || arrivalTime == null) {
      return '--:--';
    }
    
    final difference = arrivalTime!.difference(departureTime!);
    final hours = difference.inHours;
    final minutes = difference.inMinutes.remainder(60);
    
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}';
  }

  factory Flight.fromJson(Map<String, dynamic> json) {
    return Flight(
      flightId: json['flight_id'],
      flightNumber: json['flight_number'],
      routeId: json['route_id'],
      origin: json['origin'],
      destination: json['destination'],
      aircraftId: json['aircraft_id'],
      aircraftModel: json['aircraft_model'],
      registrationNumber: json['registration_number'],
      departureTime: json['departure_time'] != null 
          ? DateTime.parse(json['departure_time']) 
          : null,
      arrivalTime: json['arrival_time'] != null 
          ? DateTime.parse(json['arrival_time']) 
          : null,
      status: json['status'],
      gate: json['gate'],
      captainName: json['captain_name'],
      captainId: json['captain_id'],
      bookedSeats: json['booked_seats'],
      totalCapacity: json['total_capacity'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'flight_id': flightId,
      'flight_number': flightNumber,
      'route_id': routeId,
      'origin': origin,
      'destination': destination,
      'aircraft_id': aircraftId,
      'aircraft_model': aircraftModel,
      'registration_number': registrationNumber,
      'departure_time': departureTime?.toIso8601String(),
      'arrival_time': arrivalTime?.toIso8601String(),
      'status': status,
      'gate': gate,
      'captain_name': captainName,
      'captain_id': captainId,
      'booked_seats': bookedSeats,
      'total_capacity': totalCapacity,
    };
  }
}
