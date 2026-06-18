import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../modules/meds_module.dart';
import '../../state/app_state.dart';

class MedsListEditor extends StatefulWidget {
  final AppState appState;
  final AppLocalizations l10n;

  const MedsListEditor({
    super.key,
    required this.appState,
    required this.l10n,
  });

  @override
  State<MedsListEditor> createState() => _MedsListEditorState();
}

class _PendingDeletion {
  final String medName;
  final int originalIndex;

  _PendingDeletion({required this.medName, required this.originalIndex});
}

class _MedsListEditorState extends State<MedsListEditor> {
  late List<String> _meds;
  final List<TextEditingController> _controllers = [];
  final List<FocusNode> _focusNodes = [];
  bool _isAddingNewItem = false;
  final List<_PendingDeletion> _pendingDeletions = [];
  ScaffoldMessengerState? _scaffoldMessenger;

  @override
  void initState() {
    super.initState();
    _loadMeds();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _scaffoldMessenger = ScaffoldMessenger.maybeOf(context);
  }

  @override
  void dispose() {
    _scaffoldMessenger?.clearSnackBars();
    _saveMeds();
    for (final c in _controllers) {
      c.dispose();
    }
    for (final n in _focusNodes) {
      n.dispose();
    }
    super.dispose();
  }

  void _loadMeds() {
    _meds = getMedsList(widget.appState, widget.l10n);
    _syncControllers();
  }

  void _syncControllers() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final n in _focusNodes) {
      n.dispose();
    }
    _controllers.clear();
    _focusNodes.clear();
    for (final med in _meds) {
      _controllers.add(TextEditingController(text: med));
      _focusNodes.add(FocusNode());
    }
  }

  void _saveMeds() {
    setMedsList(widget.appState, _meds);
    syncMedsChecksWithList(widget.appState, _meds);
  }

  void _commitItem(int index) {
    if (_isAddingNewItem) return;

    final text = _controllers[index].text.trim();
    if (text.isEmpty) {
      if (_meds.length > 1 || _meds[index].isNotEmpty) {
        setState(() {
          _meds.removeAt(index);
          _controllers[index].dispose();
          _controllers.removeAt(index);
          _focusNodes[index].dispose();
          _focusNodes.removeAt(index);
        });
        _saveMeds();
      }
    } else {
      if (_meds[index] != text) {
        setState(() {
          _meds[index] = text;
        });
        _saveMeds();
      }
      if (index == _meds.length - 1) {
        _addNewItem();
      }
    }
  }

  void _deleteMed(int index) {
    final deletedName = _meds[index];
    final deletedIndex = index;

    setState(() {
      _meds.removeAt(index);
      _controllers[index].dispose();
      _controllers.removeAt(index);
      _focusNodes[index].dispose();
      _focusNodes.removeAt(index);
    });
    _saveMeds();

    final pending = _PendingDeletion(
      medName: deletedName,
      originalIndex: deletedIndex,
    );
    _pendingDeletions.add(pending);
    _showUndoSnackbar(pending);
  }

  void _showUndoSnackbar(_PendingDeletion pending) {
    final l10n = widget.l10n;
    (_scaffoldMessenger ?? ScaffoldMessenger.of(context)).showSnackBar(
      SnackBar(
        content: Text(l10n.medsItemDeleted),
        behavior: SnackBarBehavior.floating,
        dismissDirection: DismissDirection.horizontal,
        action: SnackBarAction(
          label: l10n.dialogCancel,
          onPressed: () => _undoDeletion(pending),
        ),
      ),
    );
  }

  void _undoDeletion(_PendingDeletion pending) {
    if (!_pendingDeletions.contains(pending)) return;
    setState(() {
      _pendingDeletions.remove(pending);
      final index = pending.originalIndex.clamp(0, _meds.length);
      _meds.insert(index, pending.medName);
      _controllers.insert(
        index,
        TextEditingController(text: pending.medName),
      );
      _focusNodes.insert(index, FocusNode());
    });
    _saveMeds();
  }

  void _addNewItem() {
    _isAddingNewItem = true;
    setState(() {
      _meds.add('');
      _controllers.add(TextEditingController());
      _focusNodes.add(FocusNode());
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_focusNodes.isNotEmpty) {
        _focusNodes.last.requestFocus();
      }
      _isAddingNewItem = false;
    });
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
          l10n.medsListSettingsLabel,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: scheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        ...List.generate(
          _meds.length,
          (index) => _buildMedRow(index, theme, scheme),
        ),
        _buildAddRow(theme, scheme, l10n),
      ],
    );
  }

  Widget _buildMedRow(int index, ThemeData theme, ColorScheme scheme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controllers[index],
              focusNode: _focusNodes[index],
              decoration: InputDecoration(
                hintText: widget.l10n.medsItemHint,
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
              onChanged: (value) {
                _meds[index] = value;
              },
              onSubmitted: (_) => _commitItem(index),
              onTapOutside: (_) => _commitItem(index),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: Icon(Icons.delete_outline, color: scheme.error, size: 20),
            onPressed: () => _deleteMed(index),
            tooltip: widget.l10n.dialogDelete,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            padding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }

  Widget _buildAddRow(
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
          border: Border.all(
            color: scheme.outlineVariant,
            style: BorderStyle.solid,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(Icons.add, color: scheme.primary, size: 20),
            const SizedBox(width: 8),
            Text(
              l10n.medsAddButtonLabel,
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
