import 'package:equatable/equatable.dart';

class SignalEntity extends Equatable {
  final String id;
  final String pair;
  final String direction;
  final double openPrice;
  final double closePrice;
  final double takeProfit;
  final double stopLoss;
  final DateTime openTime;
  final DateTime? closeTime;
  final String status;
  final double? profit;

  const SignalEntity({
    required this.id,
    required this.pair,
    required this.direction,
    required this.openPrice,
    required this.closePrice,
    required this.takeProfit,
    required this.stopLoss,
    required this.openTime,
    this.closeTime,
    required this.status,
    this.profit,
  });

  // BUY, BUY LIMIT, BUY STOP all show green
  bool get isBuy => direction.toUpperCase().contains('BUY');
  bool get isClosed => status.toLowerCase() == 'closed';

  @override
  List<Object?> get props => [id, pair, direction, openPrice, openTime];
}
