import 'package:flutter/material.dart';

import 'food_module.dart';
import 'module_ids.dart';

/// Per-module “why this helps” copy (replaces a global Sources tile).
void showModuleHelp(BuildContext context, String moduleId) {
  if (moduleId == BaselineModuleId.food) {
    showFoodSourcesHelp(context);
    return;
  }

  final scheme = Theme.of(context).colorScheme;
  final body = _bodyFor(moduleId);
  if (body == null) return;

  showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(BaselineModuleId.label(moduleId)),
      content: SingleChildScrollView(
        child: Text(
          body,
          style: TextStyle(color: scheme.onSurfaceVariant, height: 1.45),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(),
          child: const Text('Got it'),
        ),
      ],
    ),
  );
}

String? _bodyFor(String moduleId) {
  switch (moduleId) {
    case BaselineModuleId.mentalState:
      return 'This area is for right now only: naming how you feel, a tiny bit of '
          'gratitude or grounding, and gentle “thought lens” prompts inspired by '
          'cognitive approaches. It is not a substitute for care from a qualified '
          'professional when you need it.';
    case BaselineModuleId.sleep:
      return 'Sleep affects mood, energy, and regulation. Logging “going to sleep” '
          'and “awake” with simple duration (today only) supports awareness without '
          'tracking streaks or judging rest.';
    case BaselineModuleId.meds:
      return 'A minimal today-only checklist can reduce mental load. This is not '
          'medical advice; use your clinician’s plan and seek help for urgent concerns.';
    case BaselineModuleId.movement:
      return 'Any movement counts toward care and activation. No intensity or '
          'duration — a small nudge beats “all or nothing.”';
    case BaselineModuleId.here:
      return 'A single tap to anchor yourself in the present — Gestalt “here and now”. '
          'No tracking, no memory, no score: the smallest possible caring action.';
    case BaselineModuleId.food:
      return null;
    default:
      return null;
  }
}
