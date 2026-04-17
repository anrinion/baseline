import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:url_launcher/url_launcher.dart';

import '../l10n/app_localizations.dart';
import 'food_module.dart';
import 'module_ids.dart';

/// Per-module "why this helps" copy (replaces a global Sources tile).
void showModuleHelp(BuildContext context, String moduleId) {
  if (moduleId == BaselineModuleId.food) {
    showFoodSourcesHelp(context);
    return;
  }
  if (moduleId == BaselineModuleId.sleep) {
    showSleepHelp(context);
    return;
  }
  if (moduleId == BaselineModuleId.mentalState) {
    showMentalStateHelp(context);
    return;
  }
  if (moduleId == BaselineModuleId.meds) {
    showMedsHelp(context);
    return;
  }
  if (moduleId == BaselineModuleId.movement) {
    showMovementHelp(context);
    return;
  }
  if (moduleId == BaselineModuleId.here) {
    showGroundingHelp(context);
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

/// Shows HTML-formatted help dialog with clickable citations and external links.
void _showHtmlHelpDialog({
  required BuildContext context,
  required String moduleId,
  required String htmlContent,
  required String scrollKey,
}) {
  final scheme = Theme.of(context).colorScheme;
  final l10n = AppLocalizations.of(context)!;
  final scrollController = ScrollController();
  final scrollValueKey = ValueKey(scrollKey);

  showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(BaselineModuleId.localizedLabel(l10n, moduleId)),
      content: SizedBox(
        width: double.maxFinite,
        child: Scrollbar(
          controller: scrollController,
          child: SingleChildScrollView(
            key: scrollValueKey,
            controller: scrollController,
            child: SelectionArea(
              child: Html(
                data: htmlContent,
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
                      scrollValueKey,
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
                  } else if (url != null &&
                      (url.startsWith('http://') || url.startsWith('https://'))) {
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

/// Shows HTML-formatted sleep help with clickable citations.
void showSleepHelp(BuildContext context) {
  final l10n = AppLocalizations.of(context)!;
  _showHtmlHelpDialog(
    context: context,
    moduleId: BaselineModuleId.sleep,
    htmlContent: '${l10n.sleepHelp}${l10n.sleepHelpReferences}',
    scrollKey: 'sleepHelpScroll',
  );
}

/// Shows HTML-formatted mental state help with clickable citations.
void showMentalStateHelp(BuildContext context) {
  final l10n = AppLocalizations.of(context)!;
  _showHtmlHelpDialog(
    context: context,
    moduleId: BaselineModuleId.mentalState,
    htmlContent: '${l10n.mentalStateHelp}${l10n.mentalStateReferences}',
    scrollKey: 'mentalStateHelpScroll',
  );
}

/// Shows HTML-formatted meds help with clickable citations.
void showMedsHelp(BuildContext context) {
  final l10n = AppLocalizations.of(context)!;
  _showHtmlHelpDialog(
    context: context,
    moduleId: BaselineModuleId.meds,
    htmlContent: '${l10n.medsHelp}${l10n.medsReferences}',
    scrollKey: 'medsHelpScroll',
  );
}

/// Shows HTML-formatted movement help with clickable citations.
void showMovementHelp(BuildContext context) {
  final l10n = AppLocalizations.of(context)!;
  _showHtmlHelpDialog(
    context: context,
    moduleId: BaselineModuleId.movement,
    htmlContent: '${l10n.movementHelp}${l10n.movementReferences}',
    scrollKey: 'movementHelpScroll',
  );
}

/// Shows HTML-formatted grounding help with clickable citations.
void showGroundingHelp(BuildContext context) {
  final l10n = AppLocalizations.of(context)!;
  _showHtmlHelpDialog(
    context: context,
    moduleId: BaselineModuleId.here,
    htmlContent: '${l10n.groundingHelp}${l10n.groundingReferences}',
    scrollKey: 'groundingHelpScroll',
  );
}

String? _bodyFor(String moduleId, AppLocalizations l10n) {
  switch (moduleId) {
    case BaselineModuleId.mentalState:
      return null; // Uses showMentalStateHelp with HTML
    case BaselineModuleId.sleep:
      return null; // Uses showSleepHelp with HTML
    case BaselineModuleId.meds:
      return null; // Uses showMedsHelp with HTML
    case BaselineModuleId.movement:
      return null; // Uses showMovementHelp with HTML
    case BaselineModuleId.here:
      return null; // Uses showGroundingHelp with HTML
    case BaselineModuleId.food:
      return null; // Uses showFoodSourcesHelp with HTML
    default:
      return null;
  }
}
