import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/chat_bloc.dart';
import '../bloc/chat_event.dart';

void showFreeLimitDialog(
  BuildContext context, {
  required int usedTokens,
  required DateTime refreshAt,
  int dailyLimit = 20000,
}) {
  final tokensLeft = (dailyLimit - usedTokens).clamp(0, dailyLimit);
  final timeUntilRefresh = refreshAt.difference(DateTime.now());
  final hours = timeUntilRefresh.inHours.clamp(0, 24);
  final minutes = timeUntilRefresh.inMinutes.remainder(60).clamp(0, 59);

  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text('Free limit reached'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('You have reached your free usage limit.'),
          const SizedBox(height: 12),
          _LimitRow(label: 'Daily limit', value: '$dailyLimit tokens'),
          _LimitRow(label: 'Used', value: '$usedTokens tokens'),
          _LimitRow(label: 'Remaining', value: '$tokensLeft tokens'),
          const SizedBox(height: 8),
          Text(
            'Refreshes in ${hours}h ${minutes}m',
            style: const TextStyle(fontStyle: FontStyle.italic),
          ),
          const SizedBox(height: 12),
          const Text(
            'Register for free to get unlimited usage.',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => {
            context.read<ChatBloc>().add(const LimitDialogDismissed()),
            Navigator.pop(context),
          },
          child: const Text('Not now', style: TextStyle(color: Colors.black)),
        ),
        FilledButton(
          onPressed: () {
            Navigator.pop(context);
            context.read<ChatBloc>().add(const LimitDialogDismissed());
          },
          child: const Text('Register', style: TextStyle(color: Colors.black)),
        ),
      ],
    ),
  );
}

class _LimitRow extends StatelessWidget {
  const _LimitRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey.shade600)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
