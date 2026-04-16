import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../utils/adaptive_layout.dart';
import '../utils/layout_constants.dart';
import '../modules/grounding_module.dart';
import 'module_tile.dart';
import '../modules/module_ids.dart';
import '../state/app_state.dart';
import '../l10n/app_localizations.dart';

/// Grounding anchor module — tap to affirm presence. Shows a random
/// affirmation phrase, then the button reappears after 30 seconds.
/// No persisted state; purely ephemeral.
class GroundingModuleTile extends StatefulWidget {
  const GroundingModuleTile({super.key});

  @override
  State<GroundingModuleTile> createState() => _GroundingModuleTileState();
}

class _GroundingModuleTileState extends State<GroundingModuleTile>
    with TickerProviderStateMixin {
  GroundingController? _controller;

  @override
  void initState() {
    super.initState();
    _controller = GroundingController(this);
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  void _onPressed(BuildContext context) => _controller?.trigger(context);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final theme = Theme.of(context);
        final scheme = theme.colorScheme;
        final l10n = AppLocalizations.of(context)!;
        final appState = Provider.of<AppState>(context);
        final label = appState.settings.hereButtonText;

        final availableWidth = constraints.maxWidth.isFinite
            ? TileAvailableSpace.width(constraints.maxWidth, padding: TilePadding.small + TileSpacing.normal)
            : 300.0;
        final availableHeight = constraints.maxHeight.isFinite
            ? constraints.maxHeight - 56
            : 100.0;

        final mode = resolveStandardTileMode(
          availableWidth: availableWidth,
          availableHeight: availableHeight,
          thresholds: const AdaptiveTileThresholds(
            microHeight: 60,
            microWidth: 100,
            compactHeight: 60,
            compactWidth: 100,
            expandedHeight: 100,
            expandedWidth: 100,
          ),
        );

        if (mode == AdaptiveTileMode.micro) {
          return const ModuleTile(moduleId: BaselineModuleId.here);
        }

        return TileCard(
          isCompact: mode.isCompact,
          child: Padding(
            padding: EdgeInsets.all(TilePadding.forMode(mode)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Header row (icon + title + help) ──
                Row(
                  children: [
                    Icon(
                      Icons.center_focus_strong_outlined,
                      color: scheme.primary,
                      size: TileIconSizes.forMode(mode),
                    ),
                    const SizedBox(width: TileSpacing.medium),
                    Expanded(
                      child: Text(
                        l10n.grounding,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: scheme.onSurface,
                          fontSize: mode.isCompact ? TileFontSizes.compactHeader : null,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                    TileModeIndicator(mode: mode),
                    TileHelpButton(
                      moduleId: BaselineModuleId.here,
                      compact: mode.isCompact,
                    ),
                  ],
                ),

                const SizedBox(height: TileSpacing.small),

                // ── Button / affirmation ──
                Expanded(
                  child: _controller != null
                      ? GroundingContent(
                          controller: _controller!,
                          label: label,
                          onPressed: () => _onPressed(context),
                          minButtonHeight: mode.isCompact ? 44 : 52,
                          borderRadius: mode.isCompact
                              ? TileBorderRadius.chip + 4
                              : TileBorderRadius.tile - 4,
                          buttonStyle: GroundingButtonStyle.tile,
                        )
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
