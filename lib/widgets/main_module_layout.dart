import 'package:flutter/material.dart';

import '../modules/module_ids.dart';
import '../state/app_state.dart';
import 'food_module_tile.dart';
import 'here_module_tile.dart';
import 'mental_state_tile.dart';
import 'module_tile.dart';
import 'movement_module_tile.dart';

/// Default home layout: two 50/50 pair rows, full-width anchor, then a tall
/// full-width Food band. Rows with no enabled modules are omitted so the rest
/// expands — no dead columns.
class MainModuleLayout extends StatelessWidget {
  const MainModuleLayout({super.key, required this.appState});

  final AppState appState;

  /// Pair rows share space; Food row gets more vertical room for glance content.
  static const int _flexPair = 1;
  static const int _flexFood = 2;

  Widget _tile(BuildContext context, String moduleId) {
    if (moduleId == BaselineModuleId.food) {
      return const FoodModuleTile();
    }
    if (moduleId == BaselineModuleId.movement) {
      return const MovementModuleTile();
    }
    if (moduleId == BaselineModuleId.mentalState) {
      return const MentalStateModuleTile();
    }
    return ModuleTile(moduleId: moduleId);
  }

  /// Only enabled modules; each gets equal width in the row. Single tile = full width.
  Widget? _pairRow(BuildContext context, List<String> slotIds) {
    final enabled =
        slotIds.where((id) => appState.settings.isModuleEnabled(id)).toList();
    if (enabled.isEmpty) return null;

    return Expanded(
      flex: _flexPair,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final id in enabled) Expanded(child: _tile(context, id)),
        ],
      ),
    );
  }

  Widget? _foodBand(BuildContext context) {
    if (!appState.settings.isModuleEnabled(BaselineModuleId.food)) return null;
    return Expanded(
      flex: _flexFood,
      child: _tile(context, BaselineModuleId.food),
    );
  }

  @override
  Widget build(BuildContext context) {
    final r1 = _pairRow(context, [BaselineModuleId.mentalState, BaselineModuleId.sleep]);
    final r2 = _pairRow(context, [BaselineModuleId.meds, BaselineModuleId.movement]);
    final food = _foodBand(context);
    final here = appState.settings.isModuleEnabled(BaselineModuleId.here)
        ? const HereModuleTile()
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        r1,
        r2,
        here,
        food,
      ].whereType<Widget>().toList(),
    );
  }
}
