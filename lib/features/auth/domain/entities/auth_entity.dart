import 'package:equatable/equatable.dart';

class AuthEntity extends Equatable {
  final String login;
  final String peanutToken;
  final String partnerToken;

  const AuthEntity({
    required this.login,
    required this.peanutToken,
    required this.partnerToken,
  });

  @override
  List<Object> get props => [login, peanutToken, partnerToken];
}
