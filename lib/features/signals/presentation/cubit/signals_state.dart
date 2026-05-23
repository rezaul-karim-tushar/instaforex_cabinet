import 'package:equatable/equatable.dart';
import '../../domain/entities/signal_entity.dart';
import '../../domain/entities/signals_filter.dart';

abstract class SignalsState extends Equatable {
  final SignalsFilter filter;
  const SignalsState({required this.filter});
  @override
  List<Object?> get props => [filter];
}

class SignalsInitial extends SignalsState {
  const SignalsInitial({required super.filter});
}

class SignalsLoading extends SignalsState {
  const SignalsLoading({required super.filter});
}

class SignalsLoaded extends SignalsState {
  final List<SignalEntity> signals;
  const SignalsLoaded({required this.signals, required super.filter});
  @override
  List<Object?> get props => [signals, filter];
}

class SignalsError extends SignalsState {
  final String message;
  const SignalsError({required this.message, required super.filter});
  @override
  List<Object?> get props => [message, filter];
}
