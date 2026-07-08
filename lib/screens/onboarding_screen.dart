import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import '../theme.dart';

/// Two-step onboarding: pick an anonymous butterfly handle, then choose the
/// causes you care about (which the PromptEngine uses to personalize acts).
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  static const _adjectives = [
    'Quiet', 'Gentle', 'Bright', 'Kind', 'Warm', 'Brave', 'Soft', 'Golden'
  ];
  static const _spirits = [
    'Butterfly', 'Firefly', 'Sparrow', 'Lantern', 'River', 'Breeze',
    'Clover', 'Ember'
  ];
  static const _allInterests = {
    'people': 'People around me',
    'animals': 'Animals',
    'environment': 'The environment',
    'community': 'My local community',
    'wellbeing': 'Mental wellbeing',
  };

  late String _handle = _randomHandle();
  final Set<String> _selected = {};

  String _randomHandle() {
    final r = Random();
    return '${_adjectives[r.nextInt(_adjectives.length)]} '
        '${_spirits[r.nextInt(_spirits.length)]} ${r.nextInt(98) + 1}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                const SizedBox(height: 24),
                Text('🦋', style: const TextStyle(fontSize: 48)),
                const SizedBox(height: 12),
                Text(
                  'Act2Impact',
                  style: Theme.of(context).textTheme.displaySmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'One small act of kindness a day.\nNo likes, no leaderboards — just echoes.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: kMuted),
                ),
                const SizedBox(height: 32),
                SoftCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Your anonymous name',
                          style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 4),
                      Text(
                        'Everyone here is anonymous, so kindness never becomes showing off.',
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(color: kMuted, fontSize: 13),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              _handle,
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall
                                  ?.copyWith(color: kPrimary),
                            ),
                          ),
                          IconButton(
                            tooltip: 'Shuffle',
                            onPressed: () =>
                                setState(() => _handle = _randomHandle()),
                            icon: const Icon(Icons.casino_outlined),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                SoftCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('What do you care about?',
                          style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 4),
                      Text(
                        'Pick up to three. Your daily acts are shaped around these.',
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(color: kMuted, fontSize: 13),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _allInterests.entries.map((entry) {
                          final selected = _selected.contains(entry.key);
                          return FilterChip(
                            label: Text(entry.value),
                            selected: selected,
                            selectedColor: kPrimary.withValues(alpha: 0.15),
                            checkmarkColor: kPrimary,
                            onSelected: (on) => setState(() {
                              if (on && _selected.length < 3) {
                                _selected.add(entry.key);
                              } else {
                                _selected.remove(entry.key);
                              }
                            }),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: _selected.isEmpty
                      ? null
                      : () => context
                          .read<AppState>()
                          .completeOnboarding(_handle, _selected.toList()),
                  child: const Text('Start my first act'),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
