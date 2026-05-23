import '../../domain/entities/signal_entity.dart';

class SignalModel extends SignalEntity {
  const SignalModel({
    required super.id,
    required super.pair,
    required super.direction,
    required super.openPrice,
    required super.closePrice,
    required super.takeProfit,
    required super.stopLoss,
    required super.openTime,
    super.closeTime,
    required super.status,
    super.profit,
  });

  factory SignalModel.fromJson(Map<String, dynamic> json) {
    // Cmd values: 0=BUY, 1=SELL, others are pending orders
    final cmd = json['Cmd'] ?? json['cmd'] ?? 0;
    final direction = _cmdToDirection(cmd);

    return SignalModel(
      id: (json['Id'] ?? json['id'] ?? '').toString(),
      pair: json['Pair'] ?? json['pair'] ?? '',
      direction: direction,
      openPrice: _toDouble(json['Price'] ?? json['OpenPrice'] ?? json['price']),
      closePrice: _toDouble(json['ClosePrice'] ?? json['closePrice'] ?? 0),
      takeProfit: _toDouble(json['Tp'] ?? json['TakeProfit'] ?? json['tp']),
      stopLoss: _toDouble(json['Sl'] ?? json['StopLoss'] ?? json['sl']),
      openTime: _toDateTime(
          json['ActualTime'] ?? json['OpenTime'] ?? json['actualTime']),
      closeTime: _toDateTimeNullable(json['CloseTime'] ?? json['closeTime']),
      status: _cmdToStatus(cmd),
      profit: _toDoubleNullable(json['Profit'] ?? json['profit']),
    );
  }

  // Cmd 0 = BUY, 1 = SELL, 2 = BUY LIMIT, 3 = SELL LIMIT, 4 = BUY STOP, 5 = SELL STOP
  static String _cmdToDirection(dynamic cmd) {
    final c = int.tryParse(cmd.toString()) ?? 0;
    switch (c) {
      case 0:
        return 'BUY';
      case 1:
        return 'SELL';
      case 2:
        return 'BUY LIMIT';
      case 3:
        return 'SELL LIMIT';
      case 4:
        return 'BUY STOP';
      case 5:
        return 'SELL STOP';
      default:
        return 'BUY';
    }
  }

  static String _cmdToStatus(dynamic cmd) {
    final c = int.tryParse(cmd.toString()) ?? 0;
    // 0,1 = market orders (active), 2,3,4,5 = pending orders
    return (c <= 1) ? 'Active' : 'Pending';
  }

  static double _toDouble(dynamic val) {
    if (val == null) return 0.0;
    return double.tryParse(val.toString()) ?? 0.0;
  }

  static double? _toDoubleNullable(dynamic val) {
    if (val == null) return null;
    return double.tryParse(val.toString());
  }

  static DateTime _toDateTime(dynamic val) {
    if (val == null) return DateTime.now();
    if (val is int) return DateTime.fromMillisecondsSinceEpoch(val * 1000);
    return DateTime.tryParse(val.toString()) ?? DateTime.now();
  }

  static DateTime? _toDateTimeNullable(dynamic val) {
    if (val == null) return null;
    if (val is int) return DateTime.fromMillisecondsSinceEpoch(val * 1000);
    return DateTime.tryParse(val.toString());
  }
}
