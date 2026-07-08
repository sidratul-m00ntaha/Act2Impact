import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/kind_act.dart';
import '../state/app_state.dart';
import '../theme.dart';

/// The Butterfly feed: anonymous kind acts from the community.
/// One reaction only — "This inspired me" — no likes, no comments.
class FeedScreen extends StatelessWidget {
  const FeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final sorted = [...app.acts]
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text('Butterfly feed',
                style: Theme.of(context).textTheme.displaySmall),
            const SizedBox(height: 4),
            Text(
              'Small anonymous acts, drifting by. Tap the butterfly when one moves you.',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: kMuted),
            ),
            const SizedBox(height: 20),
            for (final act in sorted) ...[
              _ActCard(act: act),
              const SizedBox(height: 12),
            ],
          ],
        ),
      ),
    );
  }
}

class _ActCard extends StatelessWidget {
  const _ActCard({required this.act});

  final KindAct act;

  @override
  Widget build(BuildContext context) {
    final app = context.read<AppState>();
    final isMine = act.isMine(app.uid);
    final echoed = act.wasEchoedBy(app.uid);

    return SoftCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                isMine ? '${act.authorHandle} (you)' : act.authorHandle,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontSize: 14,
                      color: isMine ? kPrimary : kInk,
                    ),
              ),
              const Spacer(),
              Text(
                _timeAgo(act.createdAt),
                style: const TextStyle(color: kMuted, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(act.text, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 14),
          Row(
            children: [
              Text('🦋 ${act.echoes}',
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w700)),
              const Spacer(),
              if (!isMine)
                TextButton.icon(
                  onPressed: echoed ? null : () => app.inspire(act),
                  icon: Icon(
                    echoed
                        ? Icons.auto_awesome
                        : Icons.auto_awesome_outlined,
                    size: 18,
                  ),
                  label: Text(
                    echoed ? 'It inspired you' : 'This inspired me',
                  ),
                  style: TextButton.styleFrom(foregroundColor: kPrimary),
                ),
            ],
          ),
        ],
      ),
    );
  }

  String _timeAgo(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}
