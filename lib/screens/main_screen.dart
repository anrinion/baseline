import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import '../widgets/module_tile.dart';
import 'settings_screen.dart';

class MainScreen extends StatelessWidget {
  final List<String> modules = [
    'Food',
    'Movement',
    'Sleep',
    'Meds',
    'CBT',
    'Sources',
  ];

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Baseline'),
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: GridView.count(
              physics: NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              childAspectRatio: 1.2,
              children: modules
                  .map((name) => ModuleTile(moduleName: name))
                  .toList(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () {
                appState.updateTodayState((state) {
                  state.hereTapped = true;
                });
              },
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 60),
                foregroundColor: Colors.green,
              ),
              child: Text(appState.settings.hereButtonText),
            ),
          ),
        ],
      ),
    );
  }
}
