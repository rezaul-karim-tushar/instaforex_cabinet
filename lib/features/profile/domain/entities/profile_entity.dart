import 'package:equatable/equatable.dart';

class ProfileEntity extends Equatable {
  final String login;
  final String firstName;
  final String lastName;
  final String email;
  final String country;
  final String currency;
  final String lastFourPhone;

  const ProfileEntity({
    required this.login,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.country,
    required this.currency,
    required this.lastFourPhone,
  });

  String get fullName => '$firstName $lastName'.trim();

  String get maskedPhone =>
      lastFourPhone.isNotEmpty ? '•••• •••• $lastFourPhone' : 'Not provided';

  @override
  List<Object> get props => [
        login,
        firstName,
        lastName,
        email,
        country,
        currency,
        lastFourPhone,
      ];
}
