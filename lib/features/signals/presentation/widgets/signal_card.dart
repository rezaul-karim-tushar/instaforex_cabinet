import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/signal_entity.dart';

class SignalCard extends StatelessWidget {
  final SignalEntity signal;
  const SignalCard({super.key, required this.signal});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isBuy = signal.isBuy;
    final directionColor = isBuy ? Colors.green.shade600 : Colors.red.shade600;
    final directionBg = isBuy ? Colors.green.shade50 : Colors.red.shade50;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Pair + direction badge
                Row(
                  children: [
                    Text(
                      signal.pair,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: directionBg,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        signal.direction.toUpperCase(),
                        style: TextStyle(
                          color: directionColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                // Status chip
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: signal.isClosed
                        ? Colors.grey.shade100
                        : Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    signal.isClosed ? 'Closed' : 'Active',
                    style: TextStyle(
                      fontSize: 12,
                      color: signal.isClosed
                          ? Colors.grey.shade600
                          : Colors.blue.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),

            // Price grid
            Row(
              children: [
                _PriceItem(label: 'Open', value: signal.openPrice),
                _PriceItem(label: 'Close', value: signal.closePrice),
                _PriceItem(label: 'TP', value: signal.takeProfit),
                _PriceItem(label: 'SL', value: signal.stopLoss),
              ],
            ),

            const SizedBox(height: 12),

            // Footer: date + profit
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  DateFormat('dd MMM yyyy, HH:mm').format(signal.openTime),
                  style:
                      theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
                ),
                if (signal.profit != null)
                  Text(
                    '${signal.profit! >= 0 ? '+' : ''}${signal.profit!.toStringAsFixed(2)}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: signal.profit! >= 0
                          ? Colors.green.shade600
                          : Colors.red.shade600,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PriceItem extends StatelessWidget {
  final String label;
  final double value;
  const _PriceItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: Theme.of(context)
                  .textTheme
                  .labelSmall
                  ?.copyWith(color: Colors.grey)),
          const SizedBox(height: 2),
          Text(
            value.toStringAsFixed(5),
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
