import 'package:intl/intl.dart';

import '../models/user_profile.dart';
import 'gemini_service.dart';

/// The result of asking for today's act: the suggestion itself plus a short
/// context line like "Saturday morning · because you care about animals".
class DailyPrompt {
  const DailyPrompt({required this.text, required this.context});

  final String text;
  final String context;
}

/// The heart of Act2Impact: turns real-world context (time of day, day of
/// week, the user's interests) into one small, doable act of kindness.
///
/// It always works offline via a curated prompt bank. If a Gemini API key is
/// configured, it upgrades to live AI generation and falls back to the bank
/// on any failure — so the app never shows an error instead of kindness.
class PromptEngine {
  Future<DailyPrompt> dailyPrompt({
    required UserProfile profile,
    required int refreshCount,
    String? geminiKey,
  }) async {
    final now = DateTime.now();
    final weekday = DateFormat('EEEE').format(now);
    final daypart = _daypart(now);
    final interest = _interestForToday(profile, refreshCount);
    final context = '$weekday $daypart · because you care about $interest';

    if (geminiKey != null && geminiKey.isNotEmpty) {
      final aiText = await GeminiService.generateActPrompt(
        apiKey: geminiKey,
        weekday: weekday,
        daypart: daypart,
        interests: profile.interests,
      );
      if (aiText != null && aiText.isNotEmpty) {
        return DailyPrompt(text: aiText, context: '$context · via Gemini');
      }
    }

    final pool = [
      ...?_bank[interest],
      ...?_daypartBank[daypart],
    ];
    // Deterministic pick: same suggestion all day, next one on "show another".
    final seed = now.year * 1000 + int.parse(DateFormat('D').format(now));
    final text = pool[(seed + refreshCount) % pool.length];
    return DailyPrompt(text: text, context: context);
  }

  String _daypart(DateTime now) {
    if (now.hour < 12) return 'morning';
    if (now.hour < 17) return 'afternoon';
    return 'evening';
  }

  String _interestForToday(UserProfile profile, int refreshCount) {
    if (profile.interests.isEmpty) return 'people';
    final dayIndex = DateTime.now().day + refreshCount;
    return profile.interests[dayIndex % profile.interests.length];
  }

  /// The offline prompt bank, grouped by interest tag.
  static const Map<String, List<String>> _bank = {
    'people': [
      'Send a good-morning message to someone you have not talked to in months.',
      'Call an older relative just to hear how their day went.',
      'Offer to carry something heavy for someone today.',
      'Genuinely compliment three people — be specific about why.',
      'Let someone go ahead of you in a queue today.',
      'Write one thing you appreciate about a family member, then tell them.',
    ],
    'animals': [
      'Put out a bowl of clean water for street animals near your home.',
      'Feed a stray cat or dog something safe today.',
      'Share a local shelter\'s adoption post so one animal gets seen.',
      'Spend five quiet minutes with an animal that usually gets ignored.',
    ],
    'environment': [
      'Pick up five pieces of litter on your usual route.',
      'Carry a reusable bag today and skip one plastic bag.',
      'Unplug chargers you are not using before you leave home.',
      'Plant one seed — a chili from your kitchen counts.',
      'Refill someone\'s water bottle along with your own.',
    ],
    'community': [
      'Thank a bus driver, guard, or cleaner by name if you can.',
      'Tell a street vendor to keep the change, with a smile.',
      'Recommend a friend\'s small business to someone who needs it today.',
      'Leave a glowing review for a struggling local shop you like.',
      'Introduce two people who would get along but have never met.',
    ],
    'wellbeing': [
      'Send someone the song that always lifts your mood, and say why.',
      'Check in on the quietest person in your group chat.',
      'Tell a friend one specific thing you admire about them.',
      'Text a friend who had a stressful week — then just listen.',
      'Remind someone that the thing they are worried about does not define them.',
    ],
  };

  /// Extra suggestions mixed in by time of day.
  static const Map<String, List<String>> _daypartBank = {
    'morning': [
      'Greet the first three people you meet with a real smile.',
      'Make tea or breakfast for someone before they ask.',
    ],
    'afternoon': [
      'Share your snack or buy one extra for someone nearby.',
      'Compliment a classmate or colleague on work they did quietly.',
    ],
    'evening': [
      'Message someone: "I thought of you today" — and mean it.',
      'Thank one person who helped you this week, in detail.',
    ],
  };
}
