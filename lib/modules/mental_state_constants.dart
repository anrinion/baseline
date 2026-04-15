import 'dart:math';

import 'package:clock/clock.dart';

/// Shared constants for Mental State functionality
class MentalStateConstants {
  MentalStateConstants._();

  /// List of cognitive distortions used in thought lens exercises
  static const List<Map<String, String>> cognitiveDistortions = [
    {
      'title': 'All-or-Nothing Thinking',
      'description': 'Seeing things in absolute, black-and-white categories. If a situation falls short of perfect, you see it as a total failure.',
      'example': 'I didn\'t get a perfect score, so I\'m a complete failure.',
    },
    {
      'title': 'Overgeneralization',
      'description': 'Coming to a general conclusion based on a single incident or a single piece of evidence.',
      'example': 'I felt awkward at that party. I\'m always awkward.',
    },
    {
      'title': 'Mental Filter',
      'description': 'Picking out a single negative detail and dwelling on it exclusively.',
      'example': 'I got many compliments, but I can only think about the one criticism.',
    },
    {
      'title': 'Disqualifying the Positive',
      'description': 'Rejecting positive experiences by insisting they "don\'t count."',
      'example': 'I only succeeded because I got lucky, not because I\'m skilled.',
    },
    {
      'title': 'Jumping to Conclusions',
      'description': 'Making negative interpretations even though there are no definite facts.',
      'example': 'They didn\'t text back immediately, so they must be angry with me.',
    },
    {
      'title': 'Magnification or Minimization',
      'description': 'Exaggerating the importance of problems and shortcomings, or minimizing the importance of your desirable qualities.',
      'example': 'Making a small mistake feels catastrophic, while achievements feel insignificant.',
    },
    {
      'title': 'Emotional Reasoning',
      'description': 'Assuming that your negative emotions necessarily reflect the way things really are.',
      'example': 'I feel anxious, so there must be danger.',
    },
    {
      'title': 'Should Statements',
      'description': 'Using "shoulds," "oughts," and "musts" to motivate yourself, which often leads to guilt.',
      'example': 'I should exercise more. I should be more productive.',
    },
    {
      'title': 'Labeling and Mislabeling',
      'description': 'An extreme form of overgeneralization. Instead of describing your error, you attach a negative label to yourself.',
      'example': 'I made a mistake, so I\'m an idiot.',
    },
    {
      'title': 'Personalization',
      'description': 'Seeing yourself as the cause of some negative external event for which you were not, in fact, primarily responsible.',
      'example': 'My child got bad grades, so I must be a terrible parent.',
    },
  ];

  /// Gets a cognitive distortion by index, wrapping around if necessary
  static Map<String, String> getDistortion(int index) {
    if (cognitiveDistortions.isEmpty) {
      return {
        'title': 'Unknown',
        'description': 'No cognitive distortions available.',
        'example': 'N/A',
      };
    }
    final safeIndex = index % cognitiveDistortions.length;
    return cognitiveDistortions[safeIndex];
  }

  /// Gets the total number of cognitive distortions
  static int get distortionCount => cognitiveDistortions.length;

  /// Gets a random cognitive distortion that's different from the previous day's
  static Map<String, String> getRandomDistortion(int previousIndex) {
    if (cognitiveDistortions.isEmpty) {
      return {
        'title': 'Unknown',
        'description': 'No cognitive distortions available.',
        'example': 'N/A',
      };
    }
    
    final random = Random(clock.now().millisecondsSinceEpoch);
    int newIndex;
    
    do {
      newIndex = random.nextInt(cognitiveDistortions.length);
    } while (newIndex == previousIndex && cognitiveDistortions.length > 1);
    
    return cognitiveDistortions[newIndex];
  }

  /// Gets the index of a random cognitive distortion that's different from the previous day's
  static int getRandomDistortionIndex(int previousIndex) {
    if (cognitiveDistortions.isEmpty) {
      return 0;
    }
    
    final random = Random(clock.now().millisecondsSinceEpoch);
    int newIndex;
    
    do {
      newIndex = random.nextInt(cognitiveDistortions.length);
    } while (newIndex == previousIndex && cognitiveDistortions.length > 1);
    
    return newIndex;
  }
}
