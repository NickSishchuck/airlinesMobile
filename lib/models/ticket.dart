class Ticket {
  final int? ticketId;
  final int? userId;
  final int? flightId;
  final String? seatNumber;
  final String? ticketClass;
  final double? price;
  final DateTime? bookingDate;
  final String? paymentStatus;
  final String? flightNumber;
  final DateTime? departureTime;
  final DateTime? arrivalTime;
  final String? flightStatus;
  final String? gate;
  final String? origin;
  final String? destination;
  final String? passengerName;
  final String? passportNumber;
  final String? aircraftModel;
  final String? registrationNumber;

  Ticket({
    this.ticketId,
    this.userId,
    this.flightId,
    this.seatNumber,
    this.ticketClass,
    this.price,
    this.bookingDate,
    this.paymentStatus,
    this.flightNumber,
    this.departureTime,
    this.arrivalTime,
    this.flightStatus,
    this.gate,
    this.origin,
    this.destination,
    this.passengerName,
    this.passportNumber,
    this.aircraftModel,
    this.registrationNumber,
  });

  String get formattedDepartureTime {
    return departureTime != null 
      ? '${departureTime!.hour.toString().padLeft(2, '0')}:${departureTime!.minute.toString().padLeft(2, '0')}'
      : '--:--';
  }

  String get formattedDate {
    return departureTime != null 
      ? '${departureTime!.day.toString().padLeft(2, '0')}.${departureTime!.month.toString().padLeft(2, '0')}'
      : '';
  }

  String get formattedArrivalDate {
    return arrivalTime != null 
      ? '${arrivalTime!.day.toString().padLeft(2, '0')}.${arrivalTime!.month.toString().padLeft(2, '0')}'
      : '';
  }

  factory Ticket.fromJson(Map<String, dynamic> json) {
    return Ticket(
      ticketId: json['ticket_id'],
      userId: json['user_id'],
      flightId: json['flight_id'],
      seatNumber: json['seat_number'],
      ticketClass: json['class'],
      price: json['price'] != null ? json['price'].toDouble() : null,
      bookingDate: json['booking_date'] != null 
          ? DateTime.parse(json['booking_date']) 
          : null,
      paymentStatus: json['payment_status'],
      flightNumber: json['flight_number'],
      departureTime: json['departure_time'] != null 
          ? DateTime.parse(json['departure_time']) 
          : null,
      arrivalTime: json['arrival_time'] != null 
          ? DateTime.parse(json['arrival_time']) 
          : null,
      flightStatus: json['flight_status'],
      gate: json['gate'],
      origin: json['origin'],
      destination: json['destination'],
      passengerName: json['passenger_name'],
      passportNumber: json['passport_number'],
      aircraftModel: json['aircraft_model'],
      registrationNumber: json['registration_number'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ticket_id': ticketId,
      'user_id': userId,
      'flight_id': flightId,
      'seat_number': seatNumber,
      'class': ticketClass,
      'price': price,
      'booking_date': bookingDate?.toIso8601String(),
      'payment_status': paymentStatus,
      'flight_number': flightNumber,
      'departure_time': departureTime?.toIso8601String(),
      'arrival_time': arrivalTime?.toIso8601String(),
      'flight_status': flightStatus,
      'gate': gate,
      'origin': origin,
      'destination': destination,
      'passenger_name': passengerName,
      'passport_number': passportNumber,
      'aircraft_model': aircraftModel,
      'registration_number': registrationNumber,
    };
  }
}
