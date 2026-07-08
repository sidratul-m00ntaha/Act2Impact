import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import '../theme.dart';

/// Your quiet impact: every act you logged and how far it echoed.
/// Deliberately no ranks, no points — just proof that kindness spreads.
class EchoesScreen extends StatelessWidget {
  const EchoesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final mine = app.myActs
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text('Your echoes',
                style: Theme.of(context).textTheme.displaySmall),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [kAccent, Color(0xFFE8894B)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                children: [
                  Text(
                    '${app.totalEchoes}',
                    style: Theme.of(context)
                        .textTheme
                        .displaySmall
                        ?.copyWith(color: Colors.white, fontSize: 44),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'times your kindness echoed in someone else',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            if (mine.isEmpty)
              SoftCard(
                child: Column(
                  children: [
                    const Text('🕊️', style: TextStyle(fontSize: 36)),
                    const SizedBox(height: 8),
                    Text('No acts yet',
                        style: Theme.of(context).textTheme.headlineSmall),
                    const SizedBox(height: 6),
                    Text(
                      'Do today\'s act and log it — echoes arrive quietly, '
                      'sometimes days later. That\'s the point.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: kMuted),
                    ),
                  ],
                ),
              )
            else
              for (final act in mine) ...[
                SoftCard(
                  padding: const EdgeInsets.all(18),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(act.text,
                            style: Theme.of(context).textTheme.bodyMedium),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        children: [
                          Text('🦋 ${act.echoes}',
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w800)),
                          const Text('echoes',
                              style:
                                  TextStyle(color: kMuted, fontSize: 11)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
              ],
          ],
        ),
      ),
    );
  }
}
