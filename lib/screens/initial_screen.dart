import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
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
  String? selectedTheme;

  @override
  void initState() {
    super.initState();
    // Initialize with current settings for better UX
    final appState = Provider.of<AppState>(context, listen: false);
    final localizationService = Provider.of<LocalizationService>(context, listen: false);
    
    selectedLanguage = localizationService.currentLanguageCode;
    selectedTheme = appState.settings.theme;
  }

  bool get canContinue => selectedLanguage != null && selectedTheme != null;

  Future<void> _onContinue() async {
    if (!canContinue) return;

    final appState = Provider.of<AppState>(context, listen: false);
    final localizationService = Provider.of<LocalizationService>(context, listen: false);

    // Update language if changed
    if (selectedLanguage != localizationService.currentLanguageCode) {
      await localizationService.setLanguage(selectedLanguage!);
    }

    // Update theme if changed
    if (selectedTheme != appState.settings.theme) {
      appState.updateSettings((settings) {
        settings.theme = selectedTheme!;
      });
    }

    // Mark first launch as completed
    appState.updateSettings((settings) {
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
        onPressed: () => setState(() => selectedLanguage = languageCode),
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

  Widget _buildThemeOption(String themeKey, String displayName, ThemeData previewTheme) {
    final isSelected = selectedTheme == themeKey;

    return GestureDetector(
      onTap: () => setState(() => selectedTheme = themeKey),
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              
              // App title
              Text(
                l10n.initialScreenTitle,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 16),
              
              // Welcome message
              Text(
                l10n.initialScreenMessage,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 48),
              
              // Language selection
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
              
              // Theme selection
              Text(
                l10n.initialScreenThemeTitle,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              
              // Theme options in 2x2 grid
              Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildThemeOption(
                          'light1',
                          l10n.themeLight1,
                          BaselineThemes.light1(),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildThemeOption(
                          'light2',
                          l10n.themeLight2,
                          BaselineThemes.light2(),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildThemeOption(
                          'dark1',
                          l10n.themeDark1,
                          BaselineThemes.dark1(),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildThemeOption(
                          'dark2',
                          l10n.themeDark2,
                          BaselineThemes.dark2(),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              
              const SizedBox(height: 48),
              
              // Continue button
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
              
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
