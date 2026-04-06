import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const BaselineDemoApp());
}

class BaselineDemoApp extends StatelessWidget {
  const BaselineDemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'The Baseline',
      theme: _buildTheme(),
      home: const BaselineHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }

  // Calm, evidence‑based color palette (Tailwind emerald + slate)
  ThemeData _buildTheme() {
    const primary = Color(0xFF059669); // emerald-600
    const primaryLight = Color(0xFFD1FAE5); // emerald-50
    const surface = Color(0xFFF8FAFC); // slate-50
    const textPrimary = Color(0xFF0F172A); // slate-900
    const textSecondary = Color(0xFF475569); // slate-600

    return ThemeData(
      useMaterial3: true,
      fontFamily: '.SF Pro Text',
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: primary,
        secondary: Color(0xFFF59E0B),
        surface: surface,
        background: surface,
        onPrimary: Colors.white,
        onSurface: textPrimary,
      ),
      scaffoldBackgroundColor: surface,
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        color: Colors.white,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: primaryLight,
          foregroundColor: primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(40),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          textStyle: const TextStyle(fontWeight: FontWeight.w500),
        ),
      ),
      textTheme: const TextTheme(
        titleLarge: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w600,
          color: textPrimary,
          letterSpacing: -0.3,
        ),
        titleMedium: TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        bodyMedium: TextStyle(
          fontSize: 15,
          color: textSecondary,
        ),
        bodySmall: TextStyle(
          fontSize: 13,
          color: textSecondary,
        ),
      ),
    );
  }
}

// Data model for a food category
class FoodCategory {
  final String title;
  final String subtitle;
  final int maxPortions;
  final IconData icon;
  int current;

  FoodCategory({
    required this.title,
    required this.subtitle,
    required this.maxPortions,
    required this.icon,
    this.current = 0,
  });
}

class BaselineHomePage extends StatefulWidget {
  const BaselineHomePage({super.key});

  @override
  State<BaselineHomePage> createState() => _BaselineHomePageState();
}

class _BaselineHomePageState extends State<BaselineHomePage> {
  // Food data
  final Map<String, FoodCategory> _foodCategories = {
    'protein': FoodCategory(
      title: 'Protein',
      subtitle: '1–2 portions',
      maxPortions: 2,
      icon: Icons.egg,
    ),
    'greens': FoodCategory(
      title: 'Greens',
      subtitle: '3–5 portions (fruits & veggies)',
      maxPortions: 5,
      icon: Icons.eco,
    ),
    'beans': FoodCategory(
      title: 'Beans & Chickpeas',
      subtitle: '1–2 portions',
      maxPortions: 2,
      icon: Icons.grain,
    ),
    'fillers': FoodCategory(
      title: 'Fillers',
      subtitle: '1–3 portions (rice, pasta, bread)',
      maxPortions: 3,
      icon: Icons.bakery_dining,
    ),
    'sweets': FoodCategory(
      title: 'Sweet treat',
      subtitle: '1 portion (chocolate, dessert)',
      maxPortions: 1,
      icon: Icons.cake,
    ),
  };

  bool _exerciseCompleted = false;
  String? _exerciseType;

  // SharedPreferences instance
  late SharedPreferences _prefs;
  static const String _lastDateKey = 'last_date';
  static const String _foodDataKey = 'food_data';
  static const String _exerciseKey = 'exercise_completed';
  static const String _exerciseTypeKey = 'exercise_type';

  // ---------------------------------------------------------------------------
  // Persistence & daily reset
  // ---------------------------------------------------------------------------
  Future<void> _loadState() async {
    _prefs = await SharedPreferences.getInstance();

    final String today = DateTime.now().toIso8601String().split('T')[0];
    final String? lastDate = _prefs.getString(_lastDateKey);

    if (lastDate != today) {
      // New day: reset everything
      _resetAllFood(shouldSave: false);
      _resetExercise(shouldSave: false);
      await _prefs.setString(_lastDateKey, today);
    } else {
      // Load saved food counts
      final List<String>? savedCounts = _prefs.getStringList(_foodDataKey);
      if (savedCounts != null && savedCounts.length == _foodCategories.length) {
        int idx = 0;
        for (var category in _foodCategories.values) {
          category.current = int.parse(savedCounts[idx]);
          idx++;
        }
      }
      // Load exercise state
      final bool? exerciseDone = _prefs.getBool(_exerciseKey);
      if (exerciseDone == true) {
        _exerciseCompleted = true;
        _exerciseType = _prefs.getString(_exerciseTypeKey);
      }
    }
    setState(() {});
  }

  Future<void> _saveState() async {
    final List<String> counts =
        _foodCategories.values.map((c) => c.current.toString()).toList();
    await _prefs.setStringList(_foodDataKey, counts);
    await _prefs.setBool(_exerciseKey, _exerciseCompleted);
    if (_exerciseType != null) {
      await _prefs.setString(_exerciseTypeKey, _exerciseType!);
    }
  }

  // ---------------------------------------------------------------------------
  // Food logic
  // ---------------------------------------------------------------------------
  void _updateFoodCount(String key, int delta) {
    setState(() {
      final category = _foodCategories[key];
      if (category == null) return;
      final newValue = category.current + delta;
      if (newValue >= 0 && newValue <= category.maxPortions) {
        category.current = newValue;
        _saveState();
        HapticFeedback.selectionClick();
      }
    });
  }

  void _resetAllFood({bool shouldSave = true}) {
    setState(() {
      for (var category in _foodCategories.values) {
        category.current = 0;
      }
      if (shouldSave) _saveState();
      HapticFeedback.lightImpact();
    });
  }

  // ---------------------------------------------------------------------------
  // Exercise logic
  // ---------------------------------------------------------------------------
  void _completeExercise(String type) {
    setState(() {
      _exerciseCompleted = true;
      _exerciseType = type;
      _saveState();
    });
    HapticFeedback.mediumImpact();
  }

  void _resetExercise({bool shouldSave = true}) {
    setState(() {
      _exerciseCompleted = false;
      _exerciseType = null;
      if (shouldSave) _saveState();
    });
    HapticFeedback.lightImpact();
  }

  // ---------------------------------------------------------------------------
  // Help dialog (scientific explanations)
  // ---------------------------------------------------------------------------
  void _showHelpDialog(String section) {
    final String title = section == 'food' ? 'Why this works' : 'Why movement helps';
    final String content = section == 'food'
        ? '• Protein: supports satiety & muscle repair.\n'
          '• Greens: fiber, vitamins, antioxidants.\n'
          '• Beans & chickpeas: choline & tryptophan → serotonin (Mol Psychiatry, 2021).\n'
          '• Fillers: complex carbs for steady energy.\n'
          '• Sweet treat: quick dopamine boost (J Affect Disord, 2019).'
        : '• Light movement reduces inflammation & improves mood (JAMA Psychiatry, 2022).\n'
          '• No intensity required – just gentle activation.';

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // UI Components
  // ---------------------------------------------------------------------------
  Widget _buildBatteryIndicator(int current, int max) {
    return Row(
      children: List.generate(max, (index) {
        final isFilled = index < current;
        return Expanded(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOutCubic,
            margin: const EdgeInsets.symmetric(horizontal: 2),
            height: 8,
            decoration: BoxDecoration(
              color: isFilled
                  ? const Color(0xFF059669)
                  : const Color(0xFFE2E8F0), // slate-200
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        );
      }),
    );
  }

  // Touch‑friendly stepper button with ripple & hover
  Widget _buildStepperButton(IconData icon, VoidCallback onPressed,
      {bool enabled = true}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: enabled ? onPressed : null,
        borderRadius: BorderRadius.circular(30),
        splashColor: const Color(0xFF059669).withOpacity(0.2),
        highlightColor: const Color(0xFF059669).withOpacity(0.1),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: enabled ? const Color(0xFFD1FAE5) : const Color(0xFFF1F5F9),
          ),
          child: Icon(
            icon,
            size: 20,
            color: enabled ? const Color(0xFF059669) : const Color(0xFF94A3B8),
          ),
        ),
      ),
    );
  }

  Widget _buildFoodCard(String key, FoodCategory category) {
    final isMinDisabled = category.current == 0;
    final isMaxDisabled = category.current == category.maxPortions;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(category.icon, size: 24, color: const Color(0xFF059669)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        category.title,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        category.subtitle,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                    child: _buildBatteryIndicator(category.current, category.maxPortions)),
                const SizedBox(width: 20),
                Row(
                  children: [
                    _buildStepperButton(Icons.remove,
                        () => _updateFoodCount(key, -1),
                        enabled: !isMinDisabled),
                    const SizedBox(width: 12),
                    SizedBox(
                      width: 32,
                      child: Center(
                        child: Text(
                          '${category.current}/${category.maxPortions}',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    _buildStepperButton(Icons.add, () => _updateFoodCount(key, 1),
                        enabled: !isMaxDisabled),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------
  @override
  void initState() {
    super.initState();
    _loadState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App bar
          SliverAppBar(
            title: const Text(
              'The Baseline',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 22,
                letterSpacing: -0.2,
              ),
            ),
            centerTitle: false,
            elevation: 0,
            backgroundColor: Colors.transparent,
            foregroundColor: const Color(0xFF059669),
            floating: true,
          ),
          // Subtle intro
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
              child: Text(
                'Small steps, every day 🌱',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontStyle: FontStyle.italic,
                      color: const Color(0xFF64748B),
                    ),
              ),
            ),
          ),
          // Food section header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
              child: Row(
                children: [
                  const Icon(Icons.restaurant, color: Color(0xFF059669), size: 28),
                  const SizedBox(width: 12),
                  const Text(
                    'Nourishment',
                    style: TextStyle(
                        fontSize: 28, fontWeight: FontWeight.w600, letterSpacing: -0.3),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.help_outline, size: 20, color: Color(0xFF94A3B8)),
                    onPressed: () => _showHelpDialog('food'),
                    tooltip: 'Why this works',
                  ),
                  TextButton(
                    onPressed: () => _resetAllFood(),
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF64748B),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    child: const Text('Reset all'),
                  ),
                ],
              ),
            ),
          ),
          // Food cards
          for (var entry in _foodCategories.entries)
            SliverToBoxAdapter(child: _buildFoodCard(entry.key, entry.value)),
          // Movement section header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 32, 20, 12),
              child: Row(
                children: [
                  const Icon(Icons.directions_walk, color: Color(0xFF059669), size: 28),
                  const SizedBox(width: 12),
                  const Text(
                    'Movement',
                    style: TextStyle(
                        fontSize: 28, fontWeight: FontWeight.w600, letterSpacing: -0.3),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.help_outline, size: 20, color: Color(0xFF94A3B8)),
                    onPressed: () => _showHelpDialog('movement'),
                    tooltip: 'Why this works',
                  ),
                  if (_exerciseCompleted)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD1FAE5),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.check_circle, size: 16, color: Color(0xFF059669)),
                          const SizedBox(width: 6),
                          Text(
                            _exerciseType == 'walk' ? 'Walk done' : 'Workout done',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF059669),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
          // Movement card
          SliverToBoxAdapter(
            child: Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  switchInCurve: Curves.easeOutCubic,
                  switchOutCurve: Curves.easeInCubic,
                  child: _exerciseCompleted
                      ? Column(
                          key: const ValueKey('completed'),
                          children: [
                            const Icon(Icons.celebration, size: 48, color: Color(0xFF059669)),
                            const SizedBox(height: 12),
                            Text(
                              _exerciseType == 'walk'
                                  ? 'You took a walk today. That’s wonderful! 🚶'
                                  : 'You did a light workout. Your body thanks you! 💪',
                              style: Theme.of(context).textTheme.bodyMedium,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 20),
                            OutlinedButton(
                              onPressed: () => _resetExercise(),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(0xFF64748B),
                                side: const BorderSide(color: Color(0xFFCBD5E1)),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(40),
                                ),
                              ),
                              child: const Text('Reset'),
                            ),
                          ],
                        )
                      : Column(
                          key: const ValueKey('choices'),
                          children: [
                            const Text(
                              'Choose one gentle activity for today:',
                              style: TextStyle(fontSize: 16),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: () => _completeExercise('walk'),
                                    icon: const Icon(Icons.accessible_forward, size: 20),
                                    label: const Text('Go for a walk'),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: () => _completeExercise('workout'),
                                    icon: const Icon(Icons.fitness_center, size: 20),
                                    label: const Text('Light workout'),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                ),
              ),
            ),
          ),
          // Footer
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Text(
                'Listen to what feels right for you today.\nNo pressure, just presence.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: const Color(0xFF94A3B8),
                      fontStyle: FontStyle.italic,
                    ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}