import 'package:flutter/material.dart';

import '../modules/module_ids.dart';
import '../state/app_state.dart';
import 'food_module_tile.dart';
import 'here_module_tile.dart';
import 'mental_state_tile.dart';
import 'meds_module_tile.dart';
import 'module_tile.dart';
import 'movement_module_tile.dart';
import 'sleep_module_tile.dart';

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
    if (moduleId == BaselineModuleId.sleep) {
      return const SleepModuleTile();
    }
    if (moduleId == BaselineModuleId.meds) {
      return const MedsModuleTile();
    }
    return ModuleTile(moduleId: moduleId);
  }

  @override
  Widget build(BuildContext context) {
    return DeviceOrientationBuilder(
      builder: (BuildContext context, Orientation orientation) {
        // Collect all tiles with their original positions
        final mentalState = appState.settings.isModuleEnabled(BaselineModuleId.mentalState)
            ? _tile(context, BaselineModuleId.mentalState)
            : null;
        final sleep = appState.settings.isModuleEnabled(BaselineModuleId.sleep)
            ? _tile(context, BaselineModuleId.sleep)
            : null;
        final meds = appState.settings.isModuleEnabled(BaselineModuleId.meds)
            ? _tile(context, BaselineModuleId.meds)
            : null;
        final movement = appState.settings.isModuleEnabled(BaselineModuleId.movement)
            ? _tile(context, BaselineModuleId.movement)
            : null;
        final food = appState.settings.isModuleEnabled(BaselineModuleId.food)
            ? _tile(context, BaselineModuleId.food)
            : null;
        final here = appState.settings.isModuleEnabled(BaselineModuleId.here)
            ? const HereModuleTile()
            : null;

        if (orientation == Orientation.landscape) {
          // Landscape: rotate in-place - right column becomes top row, left column becomes bottom row
          // Original layout: [mentalState, sleep] / [meds, movement] / here / food
          // Target: [sleep, movement, food] / [mentalState, meds, here]
          final topRow = [sleep, movement, food].whereType<Widget>().toList();
          final bottomRow = [mentalState, meds, here].whereType<Widget>().toList();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (topRow.isNotEmpty)
                Expanded(
                  flex: _flexPair,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [for (final w in topRow) Expanded(child: w)],
                  ),
                ),
              if (bottomRow.isNotEmpty)
                Expanded(
                  flex: _flexPair,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [for (final w in bottomRow) Expanded(child: w)],
                  ),
                ),
            ],
          );
        }

        // Portrait: original layout
        final r1 = _buildPairRow([mentalState, sleep]);
        final r2 = _buildPairRow([meds, movement]);
        final foodBand = food != null
            ? Expanded(flex: _flexFood, child: food)
            : null;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ?r1,
            ?r2,
            if (here != null)
              Expanded(
                flex: _flexPair,
                child: here,
              ),
            ?foodBand,
          ],
        );
      },
    );
  }

  Widget? _buildPairRow(List<Widget?> tiles) {
    final enabled = tiles.whereType<Widget>().toList();
    if (enabled.isEmpty) return null;

    return Expanded(
      flex: _flexPair,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [for (final w in enabled) Expanded(child: w)],
      ),
    );
  }
}
