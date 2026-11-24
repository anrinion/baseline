import 'dart:math';

import 'package:clock/clock.dart';

import '../l10n/app_localizations.dart';

typedef CognitiveDistortion = ({
  String title,
  String description,
  String example,
});

/// Shared constants for Mental State functionality.
class MentalStateConstants {
  MentalStateConstants._();

  // Indices are persisted in TodayState. Append new cards to the end.
  static final _distortions = <CognitiveDistortion Function(AppLocalizations)>[
    (l10n) => (
      title: l10n.cbtDistortionAllOrNothingTitle,
      description: l10n.cbtDistortionAllOrNothingDescription,
      example: l10n.cbtDistortionAllOrNothingExample,
    ),
    (l10n) => (
      title: l10n.cbtDistortionOvergeneralizationTitle,
      description: l10n.cbtDistortionOvergeneralizationDescription,
      example: l10n.cbtDistortionOvergeneralizationExample,
    ),
    (l10n) => (
      title: l10n.cbtDistortionMentalFilterTitle,
      description: l10n.cbtDistortionMentalFilterDescription,
      example: l10n.cbtDistortionMentalFilterExample,
    ),
    (l10n) => (
      title: l10n.cbtDistortionDisqualifyingPositiveTitle,
      description: l10n.cbtDistortionDisqualifyingPositiveDescription,
      example: l10n.cbtDistortionDisqualifyingPositiveExample,
    ),
    (l10n) => (
      title: l10n.cbtDistortionJumpingToConclusionsTitle,
      description: l10n.cbtDistortionJumpingToConclusionsDescription,
      example: l10n.cbtDistortionJumpingToConclusionsExample,
    ),
    (l10n) => (
      title: l10n.cbtDistortionMagnificationMinimizationTitle,
      description: l10n.cbtDistortionMagnificationMinimizationDescription,
      example: l10n.cbtDistortionMagnificationMinimizationExample,
    ),
    (l10n) => (
      title: l10n.cbtDistortionEmotionalReasoningTitle,
      description: l10n.cbtDistortionEmotionalReasoningDescription,
      example: l10n.cbtDistortionEmotionalReasoningExample,
    ),
    (l10n) => (
      title: l10n.cbtDistortionShouldStatementsTitle,
      description: l10n.cbtDistortionShouldStatementsDescription,
      example: l10n.cbtDistortionShouldStatementsExample,
    ),
    (l10n) => (
      title: l10n.cbtDistortionLabelingTitle,
      description: l10n.cbtDistortionLabelingDescription,
      example: l10n.cbtDistortionLabelingExample,
    ),
    (l10n) => (
      title: l10n.cbtDistortionPersonalizationTitle,
      description: l10n.cbtDistortionPersonalizationDescription,
      example: l10n.cbtDistortionPersonalizationExample,
    ),
  ];

  static int get distortionCount => _distortions.length;

  /// Gets a localized card by index, wrapping around if necessary.
  static CognitiveDistortion getDistortion(int index, AppLocalizations l10n) =>
      _distortions[index % distortionCount](l10n);

  /// Gets a random card different from the previous day's.
  static CognitiveDistortion getRandomDistortion(
    int previousIndex,
    AppLocalizations l10n,
  ) => getDistortion(getRandomDistortionIndex(previousIndex), l10n);

  /// Gets the index of a random card different from the previous day's.
  static int getRandomDistortionIndex(int previousIndex) {
    final random = Random(clock.now().millisecondsSinceEpoch);
    int newIndex;
    do {
      newIndex = random.nextInt(distortionCount);
    } while (newIndex == previousIndex && distortionCount > 1);
    return newIndex;
  }
}
