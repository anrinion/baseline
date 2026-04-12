import 'package:flutter/material.dart';

import '../../modules/module_ids.dart';
import '../../modules/movement_module.dart';
import '../../state/app_state.dart';
import '../../l10n/app_localizations.dart';

/// Editor for movement options with icon selection.
/// Shows a list where each row has a text field and icon dropdown,
/// with a trash icon to delete. New items can be added at the bottom.
class MovementOptionsEditor extends StatefulWidget {
  final AppState appState;
  final AppLocalizations l10n;

  const MovementOptionsEditor({
    super.key,
    required this.appState,
    required this.l10n,
  });

  @override
  State<MovementOptionsEditor> createState() => _MovementOptionsEditorState();
}

class _MovementOptionsEditorState extends State<MovementOptionsEditor> {
  late List<MovementOption> _options;
  final List<TextEditingController> _controllers = [];
  final List<FocusNode> _focusNodes = [];
  late List<bool> _userOverrodeIcon;
  MovementOption? _lastDeleted;
  int? _lastDeletedIndex;
  bool _isAddingNewItem = false;

  @override
  void initState() {
    super.initState();
    _loadOptions();
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    for (final node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _loadOptions() {
    _options = getMovementOptions(widget.appState, widget.l10n);
    _syncControllers();
    _userOverrodeIcon = List.generate(_options.length, (_) => false);
  }

  void _syncControllers() {
    // Dispose old controllers
    for (final controller in _controllers) {
      controller.dispose();
    }
    for (final node in _focusNodes) {
      node.dispose();
    }
    _controllers.clear();
    _focusNodes.clear();

    // Create new controllers
    for (final option in _options) {
      _controllers.add(TextEditingController(text: option.text));
      _focusNodes.add(FocusNode());
    }
  }

  void _saveOptions() {
    final json = movementOptionsToJson(_options);
    widget.appState.updateSettings((s) {
      s.setModuleSetting(BaselineModuleId.movement, 'options_v2', json);
    });
  }

  void _updateText(int index, String text) {
    setState(() {
      _options[index] = MovementOption(
        text: text,
        iconName: _options[index].iconName,
      );

      // Auto-suggest icon if user hasn't manually overridden
      if (!_userOverrodeIcon[index] && text.isNotEmpty) {
        final suggested = suggestIconForMovement(text, widget.l10n);
        if (suggested != _options[index].iconName) {
          _options[index] = MovementOption(
            text: text,
            iconName: suggested,
          );
        }
      }
    });
    _saveOptions();
  }

  void _updateIcon(int index, String iconName) {
    setState(() {
      _userOverrodeIcon[index] = true;
      _options[index] = MovementOption(
        text: _options[index].text,
        iconName: iconName,
      );
    });
    _saveOptions();
  }

  void _deleteOption(int index) {
    setState(() {
      _lastDeleted = _options[index];
      _lastDeletedIndex = index;

      _options.removeAt(index);
      _controllers[index].dispose();
      _controllers.removeAt(index);
      _focusNodes[index].dispose();
      _focusNodes.removeAt(index);
      _userOverrodeIcon.removeAt(index);
    });
    _saveOptions();
    _showUndoSnackbar();
  }

  void _showUndoSnackbar() {
    final l10n = widget.l10n;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.movementItemDeleted),
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: l10n.dialogCancel, // Use "Cancel" as "Undo"
          onPressed: () {
            if (_lastDeleted != null && _lastDeletedIndex != null) {
              setState(() {
                final index = _lastDeletedIndex!;
                _options.insert(index, _lastDeleted!);
                _controllers.insert(
                  index,
                  TextEditingController(text: _lastDeleted!.text),
                );
                _focusNodes.insert(index, FocusNode());
                _userOverrodeIcon.insert(index, false);
                _lastDeleted = null;
                _lastDeletedIndex = null;
              });
              _saveOptions();
            }
          },
        ),
      ),
    );
  }

  void _addNewItem() {
    _isAddingNewItem = true;
    setState(() {
      _options.add(const MovementOption(text: '', iconName: 'fitness_center'));
      _controllers.add(TextEditingController());
      _focusNodes.add(FocusNode());
      _userOverrodeIcon.add(false);
    });

    // Focus the new field after frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_focusNodes.isNotEmpty) {
        _focusNodes.last.requestFocus();
      }
      // Reset flag after the focus change settles
      _isAddingNewItem = false;
    });
  }

  void _commitNewItem(int index) {
    // Skip if we're explicitly adding a new item (prevents double-add)
    if (_isAddingNewItem) return;

    final text = _controllers[index].text.trim();
    if (text.isEmpty) {
      // Remove empty row if it loses focus and has no text
      if (_options.length > 1 || _options[index].text.isNotEmpty) {
        setState(() {
          _options.removeAt(index);
          _controllers[index].dispose();
          _controllers.removeAt(index);
          _focusNodes[index].dispose();
          _focusNodes.removeAt(index);
          _userOverrodeIcon.removeAt(index);
        });
        _saveOptions();
      }
    } else {
      _updateText(index, text);
      // Add another empty row if this was the last one
      if (index == _options.length - 1) {
        _addNewItem();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l10n = widget.l10n;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.movementChoicesLabel,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: scheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        // List of existing items
        ...List.generate(_options.length, (index) {
          return _buildOptionRow(index, theme, scheme);
        }),
        // Add new item button
        _buildNewItemRow(theme, scheme, l10n),
      ],
    );
  }

  Widget _buildOptionRow(int index, ThemeData theme, ColorScheme scheme) {
    final option = _options[index];

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          // Icon dropdown
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: scheme.outlineVariant),
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: option.iconName,
                icon: const SizedBox.shrink(),
                isDense: true,
                items: availableMovementIconNames.map((name) {
                  return DropdownMenuItem<String>(
                    value: name,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Icon(
                        getMovementIconByName(name),
                        size: 20,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    _updateIcon(index, value);
                  }
                },
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Text field
          Expanded(
            child: TextField(
              controller: _controllers[index],
              focusNode: _focusNodes[index],
              decoration: InputDecoration(
                hintText: widget.l10n.movementItemHint,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: scheme.outlineVariant),
                ),
              ),
              onChanged: (value) => _updateText(index, value),
              onSubmitted: (value) {
                _commitNewItem(index);
              },
              onTapOutside: (_) => _commitNewItem(index),
            ),
          ),
          const SizedBox(width: 8),
          // Delete button
          IconButton(
            icon: Icon(Icons.delete_outline, color: scheme.error, size: 20),
            onPressed: () => _deleteOption(index),
            tooltip: widget.l10n.dialogDelete,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            padding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }

  Widget _buildNewItemRow(
    ThemeData theme,
    ColorScheme scheme,
    AppLocalizations l10n,
  ) {
    return InkWell(
      onTap: _addNewItem,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          border: Border.all(color: scheme.outlineVariant, style: BorderStyle.solid),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(Icons.add, color: scheme.primary, size: 20),
            const SizedBox(width: 8),
            Text(
              l10n.movementAddNewItem,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
