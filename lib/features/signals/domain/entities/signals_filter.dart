import 'package:equatable/equatable.dart';

class SignalsFilter extends Equatable {
  final List<String> selectedPairs;
  final DateTime fromDate;
  final DateTime toDate;

  const SignalsFilter({
    required this.selectedPairs,
    required this.fromDate,
    required this.toDate,
  });

  // Default: last 30 days, all pairs
  factory SignalsFilter.defaultFilter() {
    final now = DateTime.now();
    return SignalsFilter(
      selectedPairs: const ['EURUSD', 'GBPUSD'],
      fromDate: now.subtract(const Duration(days: 30)),
      toDate: now,
    );
  }

  SignalsFilter copyWith({
    List<String>? selectedPairs,
    DateTime? fromDate,
    DateTime? toDate,
  }) {
    return SignalsFilter(
      selectedPairs: selectedPairs ?? this.selectedPairs,
      fromDate: fromDate ?? this.fromDate,
      toDate: toDate ?? this.toDate,
    );
  }

  // Convert to Unix timestamps for API
  int get fromTimestamp => fromDate.millisecondsSinceEpoch ~/ 1000;
  int get toTimestamp => toDate.millisecondsSinceEpoch ~/ 1000;

  String get pairsParam => selectedPairs.join(',');

  @override
  List<Object> get props => [selectedPairs, fromDate, toDate];
}
