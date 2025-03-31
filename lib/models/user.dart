class User {
  final int? userId;
  final String? firstName;
  final String? lastName;
  final String? email;
  final String? contactNumber;
  final String? role;
  final String? passportNumber;
  final String? nationality;
  final DateTime? dateOfBirth;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  User({
    this.userId,
    this.firstName,
    this.lastName,
    this.email,
    this.contactNumber,
    this.role,
    this.passportNumber,
    this.nationality,
    this.dateOfBirth,
    this.createdAt,
    this.updatedAt,
  });

  String get fullName => '$firstName $lastName';

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userId: json['user_id'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      email: json['email'],
      contactNumber: json['contact_number'],
      role: json['role'],
      passportNumber: json['passport_number'],
      nationality: json['nationality'],
      dateOfBirth: json['date_of_birth'] != null
          ? DateTime.parse(json['date_of_birth'])
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'contact_number': contactNumber,
      'role': role,
      'passport_number': passportNumber,
      'nationality': nationality,
      'date_of_birth': dateOfBirth?.toIso8601String(),
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
