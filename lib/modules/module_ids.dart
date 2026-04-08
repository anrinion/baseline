/// Stable ids for main-grid modules (persisted in [Settings]).
abstract class BaselineModuleId {
  static const String mentalState = 'mentalState';
  static const String sleep = 'sleep';
  static const String meds = 'meds';
  static const String movement = 'movement';
  /// Grounding anchor (“I’m here”); same band as before, but a real module (help + optional).
  static const String here = 'here';
  static const String food = 'food';

  /// Default: all modules on.
  static const List<String> all = [
    mentalState,
    sleep,
    meds,
    movement,
    here,
    food,
  ];

  static String label(String id) {
    switch (id) {
      case mentalState:
        return 'Mental state';
      case sleep:
        return 'Sleep';
      case meds:
        return 'Meds';
      case movement:
        return 'Movement';
      case here:
        return 'Grounding';
      case food:
        return 'Food';
      default:
        return id;
    }
  }

  /// Default home grid: first pair row, second pair row (see [MainModuleLayout]).
  static const List<String> pairRow1 = [mentalState, sleep];
  static const List<String> pairRow2 = [meds, movement];
}
