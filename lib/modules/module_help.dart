import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import 'food_module.dart';
import 'module_ids.dart';

/// Per-module “why this helps” copy (replaces a global Sources tile).
void showModuleHelp(BuildContext context, String moduleId) {
  if (moduleId == BaselineModuleId.food) {
    showFoodSourcesHelp(context);
    return;
  }

  final scheme = Theme.of(context).colorScheme;
  final l10n = AppLocalizations.of(context)!;
  final body = _bodyFor(moduleId, l10n);
  if (body == null) return;

  showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(BaselineModuleId.localizedLabel(l10n, moduleId)),
      content: SingleChildScrollView(
        child: Text(
          body,
          style: TextStyle(color: scheme.onSurfaceVariant, height: 1.45),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(),
          child: Text(l10n.dialogGotIt),
        ),
      ],
    ),
  );
}

String? _bodyFor(String moduleId, AppLocalizations l10n) {
  switch (moduleId) {
    case BaselineModuleId.mentalState:
      return l10n.mentalStateHelp;
    case BaselineModuleId.sleep:
      return l10n.sleepHelp;
    case BaselineModuleId.meds:
      return l10n.medsHelp;
    case BaselineModuleId.movement:
      return l10n.movementHelp;
    case BaselineModuleId.here:
      return l10n.groundingHelp;
    case BaselineModuleId.food:
      return null;
    default:
      return null;
  }
}
