import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();
  @override
  List<Object> get props => [];
}

class AuthLoginRequested extends AuthEvent {
  final String login;
  final String password;
  const AuthLoginRequested({required this.login, required this.password});
  @override
  List<Object> get props => [login, password];
}

class AuthCheckSession extends AuthEvent {}

class AuthLogoutRequested extends AuthEvent {}
