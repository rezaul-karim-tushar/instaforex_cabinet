import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../cubit/signals_cubit.dart';
import '../cubit/signals_state.dart';
import '../widgets/signal_card.dart';
import '../widgets/signals_filter_sheet.dart';
import '../../../../injection_container.dart';

class SignalsPage extends StatelessWidget {
  const SignalsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) return const SizedBox();

    return BlocProvider(
      create: (_) => sl<SignalsCubit>()
        ..loadSignals(
          login: authState.auth.login,
          partnerToken: authState.auth.partnerToken,
        ),
      child: const _SignalsView(),
    );
  }
}

class _SignalsView extends StatelessWidget {
  const _SignalsView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Signals Archive'),
        actions: [
          BlocBuilder<SignalsCubit, SignalsState>(
            builder: (context, state) {
              return IconButton(
                tooltip: 'Filter',
                icon: const Icon(Icons.tune_rounded),
                onPressed: () => _openFilter(context, state.filter),
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<SignalsCubit, SignalsState>(
        builder: (context, state) {
          if (state is SignalsLoading) {
            return _SignalsShimmer();
          }

          if (state is SignalsError) {
            return _buildError(context, state.message);
          }

          if (state is SignalsLoaded) {
            if (state.signals.isEmpty) {
              return _buildEmpty(context);
            }
            return RefreshIndicator(
              onRefresh: () async {
                final authState = context.read<AuthBloc>().state;
                if (authState is AuthAuthenticated) {
                  await context.read<SignalsCubit>().loadSignals(
                        login: authState.auth.login,
                        partnerToken: authState.auth.partnerToken,
                        filter: state.filter,
                      );
                }
              },
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: state.signals.length,
                itemBuilder: (_, i) => SignalCard(signal: state.signals[i]),
              ),
            );
          }

          return const SizedBox();
        },
      ),
    );
  }

  Future<void> _openFilter(BuildContext context, filter) async {
    final result = await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SignalsFilterSheet(currentFilter: filter),
    );

    if (result != null && context.mounted) {
      final authState = context.read<AuthBloc>().state;
      if (authState is AuthAuthenticated) {
        context.read<SignalsCubit>().loadSignals(
              login: authState.auth.login,
              partnerToken: authState.auth.partnerToken,
              filter: result,
            );
      }
    }
  }

  Widget _buildError(BuildContext context, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.wifi_off_rounded, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(message,
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge
                    ?.copyWith(color: Colors.grey.shade600)),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: () {
                final authState = context.read<AuthBloc>().state;
                if (authState is AuthAuthenticated) {
                  context.read<SignalsCubit>().loadSignals(
                        login: authState.auth.login,
                        partnerToken: authState.auth.partnerToken,
                      );
                }
              },
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.bar_chart_outlined, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            'No signals found',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(color: Colors.grey.shade600),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your filters',
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: Colors.grey.shade400),
          ),
        ],
      ),
    );
  }
}

class _SignalsShimmer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: 6,
        itemBuilder: (_, __) => Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          height: 140,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
