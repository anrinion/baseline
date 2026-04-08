import 'package:flutter/material.dart';

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
  final String title;
  final String subtitle;
  final int maxPortions;
  final IconData icon;

  const FoodCategoryDef({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.maxPortions,
    required this.icon,
  });

  static const List<FoodCategoryDef> all = [
    FoodCategoryDef(
      id: FoodCategoryId.protein,
      title: 'Protein',
      subtitle: '1–2 portions',
      maxPortions: 2,
      icon: Icons.egg_outlined,
    ),
    FoodCategoryDef(
      id: FoodCategoryId.greens,
      title: 'Greens',
      subtitle: '3–5 portions (fruits & veggies)',
      maxPortions: 5,
      icon: Icons.eco_outlined,
    ),
    FoodCategoryDef(
      id: FoodCategoryId.legumes,
      title: 'Beans & chickpeas',
      subtitle: '1–2 portions',
      maxPortions: 2,
      icon: Icons.grain,
    ),
    FoodCategoryDef(
      id: FoodCategoryId.fillers,
      title: 'Fillers',
      subtitle: '1–3 portions (rice, pasta, bread)',
      maxPortions: 3,
      icon: Icons.bakery_dining_outlined,
    ),
    FoodCategoryDef(
      id: FoodCategoryId.treat,
      title: 'Sweet treat',
      subtitle: '1 portion (chocolate, dessert)',
      maxPortions: 1,
      icon: Icons.cake_outlined,
    ),
  ];

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
