import 'package:flutter/material.dart';
import 'package:json_visual_editor/pages/editor.dart';
import 'package:json_visual_editor/modules/color.dart';

enum CloseChoice { save, discard, cancel }

class TabBarEditor extends StatefulWidget {
  final Future<String?> Function(String? p, dynamic cont) saveRef;

  const TabBarEditor({super.key, required this.saveRef});

  @override
  State<TabBarEditor> createState() => TabBarEditorState();
}

class TabBarEditorState extends State<TabBarEditor> with TickerProviderStateMixin {
  late TabController tabController = _makeController(0);

  final List<GlobalKey<EditorState>> editorKeys = [];
  final List<Editor> editors = [];
  final List<Tab> names = [];
  final _fileName = RegExp(r'[^/\\]+$');

  bool get hasTabs => editors.isNotEmpty;

  TabController _makeController(int index) {
    return TabController(
      length: editors.length,
      initialIndex: index,
      vsync: this,
    )..addListener(_onIndexChanged);
  }

  void _onIndexChanged() => setState(() {});

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  bool get hasUnsaved => editorKeys.any((k) => k.currentState?.saved == false);

  Future<bool> saveAll() async {
    for (final k in editorKeys) {
      final e = k.currentState;
      if (e == null || e.saved) continue;
      if (await widget.saveRef(e.path(), e.save()) == null) return false;  // annulé → on n'quitte pas
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: editors.isEmpty
          ? null
          : AppBar(
              title: null,
              bottom: TabBar(
                controller: tabController,
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                splashFactory: NoSplash.splashFactory,
                overlayColor: WidgetStateProperty.all(Colors.transparent),
                tabs: names,
              ),
              toolbarHeight: 0,
            ),
      body: editors.isEmpty
          ? Container(
              color: Coolors.getSurfaceColor(context),
              child: Center(child: Text("Open a JSON file")),
            )
          : IndexedStack(index: tabController.index, children: editors),
    );
  }

  void addTab(String content, String name, String? path) {
    setState(() {
      var k = GlobalKey<EditorState>();
      editorKeys.add(k);
      editors.add(
        Editor(
          key: k,
          content: ValueNotifier<String>(content),
          path: path,
          unsave: () => refresh(k),
        ),
      );
      names.add(tab(k, path == "" || path == null ? "$name*" : name));

      if (editors.length != tabController.length) {
        final oldIndex = tabController.index;

        final newIndex = oldIndex >= editors.length
            ? editors.length - 1
            : oldIndex;

        tabController.removeListener(_onIndexChanged);
        tabController.dispose();
        tabController = _makeController(newIndex);
      }
    });
  }

  Tab tab(GlobalKey<EditorState> k, String text) {
    return Tab(
      child: Row(
        children: [
          const SizedBox(width: 12.0),
          Text(text),
          IconButton(
            onPressed: () => closeTab(k),
            icon: const Icon(Icons.close),
            iconSize: 24.0,
          ),
        ],
      ),
    );
  }

  Future<void> closeTab(GlobalKey<EditorState> k) async {
    final editor = k.currentState;

    if (editor != null && !editor.saved) {
      final choice = await _askSave();

      if (choice == null || choice == CloseChoice.cancel) return;

      if (choice == CloseChoice.save &&
          await widget.saveRef(editor.path(), editor.save()) == null) {
        return;
      }
    }

    if (!mounted) return;

    final i = editorKeys.indexOf(k);
    if (i == -1) return;

    setState(() {
      var index = tabController.index;

      editorKeys.removeAt(i);
      editors.removeAt(i);
      names.removeAt(i);

      if (i < index) index -= 1;
      if (index > editors.length - 1) index = editors.length - 1;
      if (index < 0) index = 0;

      tabController.removeListener(_onIndexChanged);
      tabController.dispose();
      tabController = _makeController(index);
    });
  }

  Future<CloseChoice?> _askSave() {
    return showDialog<CloseChoice>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text("Warning", style: TextStyle(color: Coolors.getDarkColor(context))),
          content: Text("Save the file ?", style: TextStyle(color: Coolors.getDarkColor(context))),
          icon: const Icon(Icons.warning),
          backgroundColor: Coolors.getSurfaceColor(context),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(CloseChoice.cancel),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(CloseChoice.discard),
              child: const Text("Don't save"),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(CloseChoice.save),
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }

  dynamic save() {
    return editorKeys[tabController.index].currentState!.save();
  }

  String? path() {
    return editorKeys[tabController.index].currentState!.path();
  }

  void refresh(GlobalKey<EditorState> key) {
    final i = editorKeys.indexOf(key);
    if (i == -1) return;

    final editor = key.currentState!;
    final path = editor.path();
    final name = path == null
        ? "Unsaved"
        : (_fileName.firstMatch(path)?.group(0) ?? path);

    setState(() => names[i] = tab(key, editor.saved ? name : "$name*"));
  }

  void markSaved(String path) {
    final key = editorKeys[tabController.index];
    key.currentState!
      ..setPath(path)
      ..setSaved();
    refresh(key);
  }
}
