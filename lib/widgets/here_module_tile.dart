import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../modules/module_help.dart';
import '../modules/module_ids.dart';
import '../state/app_state.dart';

/// Grounding anchor module: primary action + help (same role as the old standalone button).
class HereModuleTile extends StatelessWidget {
  const HereModuleTile({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Consumer<AppState>(
      builder: (context, appState, _) {
        final label = appState.settings.hereButtonText;

        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        appState.updateTodayState((state) {
                          state.hereTapped = true;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(52),
                      ),
                      child: Text(label),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.help_outline, color: scheme.outline),
                    tooltip: 'Why this helps',
                    onPressed: () => showModuleHelp(context, BaselineModuleId.here),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
