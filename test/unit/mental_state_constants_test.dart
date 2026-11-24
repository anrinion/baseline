import 'dart:ui';

import 'package:baseline/l10n/app_localizations.dart';
import 'package:baseline/modules/mental_state_constants.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('saved thought lens indices keep their meaning in Swedish', () {
    final en = lookupAppLocalizations(const Locale('en'));
    final sv = lookupAppLocalizations(const Locale('sv'));
    const originalTitles = [
      'All-or-Nothing Thinking',
      'Overgeneralization',
      'Mental Filter',
      'Disqualifying the Positive',
      'Jumping to Conclusions',
      'Magnification or Minimization',
      'Emotional Reasoning',
      'Should Statements',
      'Labeling and Mislabeling',
      'Personalization',
    ];
    for (var i = 0; i < originalTitles.length; i++) {
      final original = MentalStateConstants.getDistortion(i, en);
      final translated = MentalStateConstants.getDistortion(i, sv);
      expect(original.title, originalTitles[i]);
      expect(translated.title, isNot(original.title));
      expect(translated.description, isNot(original.description));
      expect(translated.example, isNot(original.example));
    }
    expect(
      MentalStateConstants.getDistortion(0, sv).title,
      sv.cbtDistortionAllOrNothingTitle,
    );
    expect(
      MentalStateConstants.getDistortion(
        MentalStateConstants.distortionCount,
        sv,
      ),
      MentalStateConstants.getDistortion(0, sv),
    );
  });
}
