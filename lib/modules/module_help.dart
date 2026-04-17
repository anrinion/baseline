import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:url_launcher/url_launcher.dart';

import '../l10n/app_localizations.dart';
import 'food_module.dart';
import 'module_ids.dart';

/// Per-module “why this helps” copy (replaces a global Sources tile).
void showModuleHelp(BuildContext context, String moduleId) {
  if (moduleId == BaselineModuleId.food) {
    showFoodSourcesHelp(context);
    return;
  }
  if (moduleId == BaselineModuleId.sleep) {
    showSleepHelp(context);
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

/// Shows HTML-formatted sleep help with clickable citations.
void showSleepHelp(BuildContext context) {
  final scheme = Theme.of(context).colorScheme;
  final l10n = AppLocalizations.of(context)!;
  final scrollController = ScrollController();

  showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(BaselineModuleId.localizedLabel(l10n, BaselineModuleId.sleep)),
      content: SizedBox(
        width: double.maxFinite,
        child: Scrollbar(
          controller: scrollController,
          child: SingleChildScrollView(
            key: const ValueKey('sleepHelpScroll'),
            controller: scrollController,
            child: SelectionArea(
              child: Html(
                data: '${l10n.sleepHelp}${l10n.sleepHelpReferences}',
                style: {
                  "body": Style(
                    color: scheme.onSurfaceVariant,
                    fontSize: FontSize(14),
                    lineHeight: LineHeight(1.5),
                  ),
                  "p": Style(
                    margin: Margins.only(bottom: 12),
                  ),
                  "a": Style(
                    color: scheme.primary,
                    textDecoration: TextDecoration.none,
                    fontWeight: FontWeight.w500,
                  ),
                  "h3": Style(
                    color: scheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                },
                onLinkTap: (url, renderContext, attributes) async {
                  if (url?.startsWith('#ref-') ?? false) {
                    final anchorContext = AnchorKey.forId(
                      const ValueKey('sleepHelpScroll'),
                      url!.substring(1),
                    )?.currentContext;
                    if (anchorContext != null) {
                      Scrollable.ensureVisible(
                        anchorContext,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOut,
                        alignment: 0.1,
                      );
                    }
                  } else if (url != null && (url.startsWith('http://') || url.startsWith('https://'))) {
                    final uri = Uri.tryParse(url);
                    if (uri != null && await canLaunchUrl(uri)) {
                      await launchUrl(uri, mode: LaunchMode.externalApplication);
                    }
                  }
                },
              ),
            ),
          ),
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
      return null; // Uses showSleepHelp with HTML
    case BaselineModuleId.meds:
      return l10n.medsHelp;
    case BaselineModuleId.movement:
      return l10n.movementHelp;
    case BaselineModuleId.here:
      return l10n.groundingHelp;
    case BaselineModuleId.food:
      return null; // Uses showFoodSourcesHelp with HTML
    default:
      return null;
  }
}
