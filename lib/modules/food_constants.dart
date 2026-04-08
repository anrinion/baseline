import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../state/today_state.dart';

enum FoodCategoryId {
  protein,
  greens,
  legumes,
  fillers,
  treat,
}

class FoodCategoryDef {
  final FoodCategoryId id;
  final int maxPortions;
  final IconData icon;

  const FoodCategoryDef({
    required this.id,
    required this.maxPortions,
    required this.icon,
  });

  static const List<FoodCategoryDef> all = [
    FoodCategoryDef(
      id: FoodCategoryId.protein,
      maxPortions: 2,
      icon: Icons.egg_outlined,
    ),
    FoodCategoryDef(
      id: FoodCategoryId.greens,
      maxPortions: 5,
      icon: Icons.eco_outlined,
    ),
    FoodCategoryDef(
      id: FoodCategoryId.legumes,
      maxPortions: 2,
      icon: Icons.grain,
    ),
    FoodCategoryDef(
      id: FoodCategoryId.fillers,
      maxPortions: 3,
      icon: Icons.bakery_dining_outlined,
    ),
    FoodCategoryDef(
      id: FoodCategoryId.treat,
      maxPortions: 1,
      icon: Icons.cake_outlined,
    ),
  ];

  String title(AppLocalizations l10n) {
    switch (id) {
      case FoodCategoryId.protein:
        return l10n.foodProteinLabel;
      case FoodCategoryId.greens:
        return l10n.foodGreensLabel;
      case FoodCategoryId.legumes:
        return l10n.foodBeansLabel;
      case FoodCategoryId.fillers:
        return l10n.foodFillersLabel;
      case FoodCategoryId.treat:
        return l10n.foodTreatLabel;
    }
  }

  String subtitle(AppLocalizations l10n) {
    switch (id) {
      case FoodCategoryId.protein:
        return l10n.foodProteinSubtitle;
      case FoodCategoryId.greens:
        return l10n.foodGreensSubtitle;
      case FoodCategoryId.legumes:
        return l10n.foodBeansSubtitle;
      case FoodCategoryId.fillers:
        return l10n.foodFillersSubtitle;
      case FoodCategoryId.treat:
        return l10n.foodTreatSubtitle;
    }
  }

  int countFrom(TodayState s) {
    switch (id) {
      case FoodCategoryId.protein:
        return s.proteinCount;
      case FoodCategoryId.greens:
        return s.greensCount;
      case FoodCategoryId.legumes:
        return s.legumesCount;
      case FoodCategoryId.fillers:
        return s.fillersCount;
      case FoodCategoryId.treat:
        return s.treatCount;
    }
  }

  void setCount(TodayState s, int value) {
    final v = value.clamp(0, maxPortions).toInt();
    switch (id) {
      case FoodCategoryId.protein:
        s.proteinCount = v;
      case FoodCategoryId.greens:
        s.greensCount = v;
      case FoodCategoryId.legumes:
        s.legumesCount = v;
      case FoodCategoryId.fillers:
        s.fillersCount = v;
      case FoodCategoryId.treat:
        s.treatCount = v;
    }
  }

  static int totalMaxPortions() =>
      all.fold<int>(0, (sum, c) => sum + c.maxPortions);

  static int totalLogged(TodayState s) =>
      all.fold<int>(0, (sum, c) => sum + c.countFrom(s));
}
