import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import '../state/settings.dart';
import '../l10n/localization_service.dart';
import '../l10n/app_localizations.dart';
import '../theme/themes.dart';
import 'main_screen.dart';

class InitialScreen extends StatefulWidget {
  const InitialScreen({super.key});

  @override
  State<InitialScreen> createState() => _InitialScreenState();
}

class _InitialScreenState extends State<InitialScreen> {
  String? selectedLanguage;
  String? selectedThemeMode;
  String? selectedManualAppearance;
  String? selectedLightTheme;
  String? selectedDarkTheme;
  int selectedLightStartMinutes = 7 * 60;
  int selectedDarkStartMinutes = 21 * 60;

  @override
  void initState() {
    super.initState();
    // Initialize with current settings for better UX
    final appState = Provider.of<AppState>(context, listen: false);
    final localizationService = Provider.of<LocalizationService>(context, listen: false);

    selectedLanguage = localizationService.currentLanguageCode;
    selectedThemeMode = appState.settings.themeMode;
    selectedManualAppearance = appState.settings.usesDarkManualTheme ? 'dark' : 'light';
    selectedLightTheme = appState.settings.lightThemeKey;
    selectedDarkTheme = appState.settings.darkThemeKey;
    selectedLightStartMinutes = appState.settings.scheduleLightStartMinutes;
    selectedDarkStartMinutes = appState.settings.scheduleDarkStartMinutes;
  }

  /// Apply selected theme settings to AppState immediately so user sees the change
  void _applyThemeSettings() {
    if (selectedThemeMode == null || selectedLightTheme == null || selectedDarkTheme == null) return;
    if (selectedThemeMode == Settings.themeModeManual && selectedManualAppearance == null) return;

    final appState = Provider.of<AppState>(context, listen: false);
    final currentTheme = appState.settings.theme;
    final currentThemeMode = appState.settings.themeMode;
    final currentLightTheme = appState.settings.lightThemeKey;
    final currentDarkTheme = appState.settings.darkThemeKey;

    // Determine the new theme key based on manual appearance selection
    final newTheme = selectedManualAppearance == 'dark' ? selectedDarkTheme! : selectedLightTheme!;

    // Only update if something changed (avoid unnecessary rebuilds)
    if (currentTheme != newTheme ||
        currentThemeMode != selectedThemeMode ||
        currentLightTheme != selectedLightTheme ||
        currentDarkTheme != selectedDarkTheme) {
      appState.updateSettings((settings) {
        settings.lightThemeKey = selectedLightTheme!;
        settings.darkThemeKey = selectedDarkTheme!;
        settings.themeMode = selectedThemeMode!;
        settings.theme = newTheme;
      });
    }
  }

  /// Apply selected language to LocalizationService immediately so user sees the change
  Future<void> _applyLanguageSetting() async {
    if (selectedLanguage == null) return;

    final localizationService = Provider.of<LocalizationService>(context, listen: false);
    if (localizationService.currentLanguageCode != selectedLanguage) {
      await localizationService.setLanguage(selectedLanguage!);
    }
  }

  bool get canContinue =>
      selectedLanguage != null &&
      selectedThemeMode != null &&
      selectedManualAppearance != null &&
      selectedLightTheme != null &&
      selectedDarkTheme != null;

  String get _selectedManualThemeKey =>
      selectedManualAppearance == 'dark' ? selectedDarkTheme! : selectedLightTheme!;

  Future<void> _onContinue() async {
    if (!canContinue) return;

    final appState = Provider.of<AppState>(context, listen: false);
    final localizationService = Provider.of<LocalizationService>(context, listen: false);

    // Update language if changed
    if (selectedLanguage != localizationService.currentLanguageCode) {
      await localizationService.setLanguage(selectedLanguage!);
    }

    appState.updateSettings((settings) {
      settings.lightThemeKey = selectedLightTheme!;
      settings.darkThemeKey = selectedDarkTheme!;
      settings.scheduleLightStartMinutes = selectedLightStartMinutes;
      settings.scheduleDarkStartMinutes = selectedDarkStartMinutes;
      settings.themeMode = selectedThemeMode!;
      settings.theme = _selectedManualThemeKey;
      settings.isFirstLaunch = false;
    });

    // Navigate to Main Screen, replacing the Initial Screen
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(builder: (_) => const MainScreen()),
      );
    }
  }

  Widget _buildLanguageButton(String languageCode, String displayName) {
    final isSelected = selectedLanguage == languageCode;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          setState(() => selectedLanguage = languageCode);
          _applyLanguageSetting();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: isSelected ? Theme.of(context).colorScheme.primary : null,
          foregroundColor: isSelected ? Theme.of(context).colorScheme.onPrimary : null,
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: isSelected 
              ? BorderSide(color: Theme.of(context).colorScheme.primary)
              : BorderSide(color: Theme.of(context).colorScheme.outline),
          ),
        ),
        child: Text(
          displayName,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }

  Widget _buildThemeOption({
    required String displayName,
    required ThemeData previewTheme,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected 
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.outline,
            width: isSelected ? 2 : 1,
          ),
          color: previewTheme.colorScheme.surface,
        ),
        child: Column(
          children: [
            // Theme preview header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: previewTheme.colorScheme.primaryContainer,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: previewTheme.colorScheme.primary,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      displayName,
                      style: TextStyle(
                        color: previewTheme.colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  if (isSelected)
                    Icon(
                      Icons.check_circle,
                      color: previewTheme.colorScheme.primary,
                      size: 20,
                    ),
                ],
              ),
            ),
            // Theme preview content
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    height: 8,
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: previewTheme.colorScheme.secondaryContainer,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 8,
                          decoration: BoxDecoration(
                            color: previewTheme.colorScheme.tertiaryContainer,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Container(
                          height: 8,
                          decoration: BoxDecoration(
                            color: previewTheme.colorScheme.outline,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getThemeModeLabel(AppLocalizations l10n, String mode) {
    switch (mode) {
      case Settings.themeModeDevice:
        return l10n.themeModeDevice;
      case Settings.themeModeSchedule:
        return l10n.themeModeSchedule;
      case Settings.themeModeManual:
      default:
        return l10n.themeModeManual;
    }
  }

  String _getThemeModeDescription(AppLocalizations l10n, String mode) {
    switch (mode) {
      case Settings.themeModeDevice:
        return l10n.themeModeDeviceDescription;
      case Settings.themeModeSchedule:
        return l10n.themeModeScheduleDescription;
      case Settings.themeModeManual:
      default:
        return l10n.themeModeManualDescription;
    }
  }

  TimeOfDay _timeOfDayFromMinutes(int minutes) {
    return TimeOfDay(
      hour: minutes ~/ 60,
      minute: minutes % 60,
    );
  }

  Future<void> _pickTime(
    BuildContext context, {
    required int initialMinutes,
    required ValueChanged<int> onSelected,
  }) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _timeOfDayFromMinutes(initialMinutes),
    );
    if (picked == null) return;
    onSelected(picked.hour * 60 + picked.minute);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const SizedBox(height: 16),
            
            Text(
              l10n.initialScreenTitle,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 16),
            
            Text(
              l10n.initialScreenMessage,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 40),
            
            Text(
              l10n.initialScreenLanguageTitle,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: _buildLanguageButton('en', l10n.languageEnglish),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildLanguageButton('ru', l10n.languageRussian),
                ),
              ],
            ),
            
            const SizedBox(height: 32),
            
            Text(
              l10n.initialScreenThemeTitle,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.themeBehaviorHelp,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            RadioGroup<String>(
              groupValue: selectedThemeMode,
              onChanged: (value) {
                if (value == null) return;
                setState(() {
                  selectedThemeMode = value;
                });
                _applyThemeSettings();
              },
              child: Column(
                children: [
                  for (final mode in [
                    Settings.themeModeManual,
                    Settings.themeModeDevice,
                    Settings.themeModeSchedule,
                  ])
                    RadioListTile<String>(
                      title: Text(_getThemeModeLabel(l10n, mode)),
                      subtitle: Text(_getThemeModeDescription(l10n, mode)),
                      value: mode,
                    ),
                ],
              ),
            ),
            if (selectedThemeMode == Settings.themeModeManual) ...[
              const SizedBox(height: 8),
              Text(
                l10n.themeManualChoiceLabel,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              RadioGroup<String>(
                groupValue: selectedManualAppearance,
                onChanged: (value) {
                  if (value == null) return;
                  setState(() {
                    selectedManualAppearance = value;
                  });
                  _applyThemeSettings();
                },
                child: Column(
                  children: [
                    RadioListTile<String>(
                      title: Text(l10n.themeUseLight),
                      value: 'light',
                    ),
                    RadioListTile<String>(
                      title: Text(l10n.themeUseDark),
                      value: 'dark',
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 12),
            Text(
              l10n.themeLightSectionLabel,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildThemeOption(
                    displayName: l10n.themeLight1,
                    previewTheme: BaselineThemes.light1(),
                    isSelected: selectedLightTheme == 'light1',
                    onTap: () {
                  setState(() => selectedLightTheme = 'light1');
                  _applyThemeSettings();
                },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildThemeOption(
                    displayName: l10n.themeLight2,
                    previewTheme: BaselineThemes.light2(),
                    isSelected: selectedLightTheme == 'light2',
                    onTap: () {
                  setState(() => selectedLightTheme = 'light2');
                  _applyThemeSettings();
                },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              l10n.themeDarkSectionLabel,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildThemeOption(
                    displayName: l10n.themeDark1,
                    previewTheme: BaselineThemes.dark1(),
                    isSelected: selectedDarkTheme == 'dark1',
                    onTap: () {
                  setState(() => selectedDarkTheme = 'dark1');
                  _applyThemeSettings();
                },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildThemeOption(
                    displayName: l10n.themeDark2,
                    previewTheme: BaselineThemes.dark2(),
                    isSelected: selectedDarkTheme == 'dark2',
                    onTap: () {
                  setState(() => selectedDarkTheme = 'dark2');
                  _applyThemeSettings();
                },
                  ),
                ),
              ],
            ),
            if (selectedThemeMode == Settings.themeModeSchedule) ...[
              const SizedBox(height: 20),
              Text(
                l10n.themeScheduleLabel,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(l10n.themeScheduleLightStarts),
                subtitle: Text(
                  MaterialLocalizations.of(context).formatTimeOfDay(
                    _timeOfDayFromMinutes(selectedLightStartMinutes),
                    alwaysUse24HourFormat: MediaQuery.of(context).alwaysUse24HourFormat,
                  ),
                ),
                trailing: const Icon(Icons.schedule),
                onTap: () => _pickTime(
                  context,
                  initialMinutes: selectedLightStartMinutes,
                  onSelected: (minutes) {
                    setState(() {
                      selectedLightStartMinutes = minutes;
                    });
                  },
                ),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(l10n.themeScheduleDarkStarts),
                subtitle: Text(
                  MaterialLocalizations.of(context).formatTimeOfDay(
                    _timeOfDayFromMinutes(selectedDarkStartMinutes),
                    alwaysUse24HourFormat: MediaQuery.of(context).alwaysUse24HourFormat,
                  ),
                ),
                trailing: const Icon(Icons.schedule),
                onTap: () => _pickTime(
                  context,
                  initialMinutes: selectedDarkStartMinutes,
                  onSelected: (minutes) {
                    setState(() {
                      selectedDarkStartMinutes = minutes;
                    });
                  },
                ),
              ),
            ],
            
            const SizedBox(height: 32),
            
            ElevatedButton(
              onPressed: canContinue ? _onContinue : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 32),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                l10n.initialScreenContinue,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
            ),
            
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
