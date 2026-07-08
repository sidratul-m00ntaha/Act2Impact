import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import '../theme.dart';

/// The heart of the app: one AI-suggested act of kindness for today.
class TodayScreen extends StatelessWidget {
  const TodayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text('Hello, ${app.profile?.handle ?? ''}',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: kMuted)),
            const SizedBox(height: 4),
            Text("Today's act", style: Theme.of(context).textTheme.displaySmall),
            const SizedBox(height: 20),
            _PromptCard(app: app),
            const SizedBox(height: 16),
            if (!app.todayDone)
              Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      onPressed:
                          app.promptLoading ? null : () => _logIt(context),
                      icon: const Icon(Icons.check_rounded),
                      label: const Text('I did this'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  OutlinedButton(
                    onPressed: app.promptLoading
                        ? null
                        : () => context.read<AppState>().anotherPrompt(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                    ),
                    child: const Text('Show another'),
                  ),
                ],
              )
            else
              SoftCard(
                child: Column(
                  children: [
                    const Text('🌱', style: TextStyle(fontSize: 36)),
                    const SizedBox(height: 8),
                    Text('Done for today',
                        style: Theme.of(context).textTheme.headlineSmall),
                    const SizedBox(height: 6),
                    Text(
                      'Your act is on the Butterfly feed, anonymously. '
                      'If it inspires someone, you\'ll hear its echo.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: kMuted),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 20),
            // The AI suggestion is a starting point, never a limit — any
            // kindness counts, and you can log as many acts as you like.
            Center(
              child: TextButton.icon(
                onPressed: () => _logOwnAct(context),
                icon: const Icon(Icons.edit_outlined, size: 18),
                label: const Text('Did something else kind? Log your own act'),
                style: TextButton.styleFrom(foregroundColor: kPrimary),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _logOwnAct(BuildContext context) async {
    final app = context.read<AppState>();
    final controller = TextEditingController();
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: kCard,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Your own act of kindness'),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLength: 120,
          decoration: const InputDecoration(
            hintText: 'What did you do? One line is enough…',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              final text = controller.text.trim();
              if (text.isEmpty) return;
              Navigator.pop(context);
              await app.logCustomAct(text);
            },
            child: const Text('Log it anonymously'),
          ),
        ],
      ),
    );
  }

  Future<void> _logIt(BuildContext context) async {
    final app = context.read<AppState>();
    final controller = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: kCard,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Beautiful. How did it go?'),
        content: TextField(
          controller: controller,
          maxLength: 120,
          decoration: const InputDecoration(
            hintText: 'Optional: one line about what happened…',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Log it anonymously'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await app.logAct(note: controller.text);
    }
  }
}

class _PromptCard extends StatelessWidget {
  const _PromptCard({required this.app});

  final AppState app;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [kPrimary, Color(0xFF14907C)],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: kPrimary.withValues(alpha: 0.35),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: app.promptLoading || app.today == null
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: CircularProgressIndicator(color: Colors.white),
              ),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  app.today!.context,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  app.today!.text,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        height: 1.35,
                      ),
                ),
              ],
            ),
    );
  }
}
