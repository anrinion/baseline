import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';

class ModuleTile extends StatelessWidget {
  final String moduleName;
  const ModuleTile({required this.moduleName});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(12),
      child: InkWell(
        onTap: () => _openModule(context),
        child: Center(child: Text(moduleName)),
      ),
    );
  }

  void _openModule(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => _ModulePlaceholderModal(moduleName: moduleName),
    );
  }
}

class _ModulePlaceholderModal extends StatelessWidget {
  final String moduleName;
  const _ModulePlaceholderModal({required this.moduleName});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    return AlertDialog(
      title: Text(moduleName),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('This is a placeholder module.'),

          SizedBox(height: 16),

          ElevatedButton(
            onPressed: () {
              appState.updateTodayState((state) {
                // simulate module interaction
                state.cbtTemp = "Touched $moduleName";
              });
            },
            child: Text('Simulate action'),
          ),

          SizedBox(height: 8),

          Text(
            'State: ${appState.todayState.cbtTemp}',
            style: TextStyle(fontSize: 12),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Close'),
        )
      ],
    );
  }
}