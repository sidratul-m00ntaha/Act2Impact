import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import '../theme.dart';
import 'echoes_screen.dart';
import 'feed_screen.dart';
import 'today_screen.dart';

/// The main scaffold once onboarding is done: an app bar with settings and
/// a bottom navigation bar switching between the three tabs.
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _tab = 0;

  static const _screens = [TodayScreen(), FeedScreen(), EchoesScreen()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Act2Impact 🦋'),
        actions: [
          IconButton(
            tooltip: 'Settings',
            onPressed: () => _openSettings(context),
            icon: const Icon(Icons.settings_outlined),
          ),
        ],
      ),
      body: _screens[_tab],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (i) => setState(() => _tab = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.wb_sunny_outlined),
            selectedIcon: Icon(Icons.wb_sunny),
            label: 'Today',
          ),
          NavigationDestination(
            icon: Icon(Icons.forum_outlined),
            selectedIcon: Icon(Icons.forum),
            label: 'Feed',
          ),
          NavigationDestination(
            icon: Icon(Icons.graphic_eq),
            label: 'Echoes',
          ),
        ],
      ),
    );
  }

  Future<void> _openSettings(BuildContext context) async {
    final app = context.read<AppState>();
    final keyController = TextEditingController(text: app.geminiKey ?? '');

    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: kCard,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Settings'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Gemini API key (optional)\nAdds live AI-generated daily acts. '
              'Without it, the built-in suggestion bank is used.',
              style: TextStyle(fontSize: 13, color: kMuted),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: keyController,
              obscureText: true,
              decoration: const InputDecoration(hintText: 'AIza…'),
            ),
          ],
        ),
        actions: [
          if (app.firebaseActive)
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                await app.signOut();
              },
              style:
                  TextButton.styleFrom(foregroundColor: Colors.red.shade700),
              child: const Text('Sign out'),
            )
          else
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                await app.resetApp();
              },
              style:
                  TextButton.styleFrom(foregroundColor: Colors.red.shade700),
              child: const Text('Reset app'),
            ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(context);
              await app.setGeminiKey(keyController.text);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
