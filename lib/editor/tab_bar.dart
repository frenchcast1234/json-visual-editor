import 'package:flutter/material.dart';
import 'package:json_visual_editor/editor/editor.dart';
import 'package:json_visual_editor/editor/node_clipboard.dart';
import 'package:json_visual_editor/model/document.dart';
import 'package:json_visual_editor/storage/json_file.dart';
import 'package:json_visual_editor/theme/color.dart';

enum CloseChoice { save, discard, cancel }

class TabBarEditor extends StatefulWidget {
  final Future<String?> Function(String? p, dynamic cont) saveRef;

  final NodeClipboard clipboard;

  const TabBarEditor({super.key, required this.saveRef, required this.clipboard});

  @override
  State<TabBarEditor> createState() => TabBarEditorState();
}

class TabBarEditorState extends State<TabBarEditor> with TickerProviderStateMixin {
  late TabController tabController = _makeController(0);

  final List<Document> documents = [];

  bool get hasTabs => documents.isNotEmpty;
  bool get hasUnsaved => documents.any((d) => !d.saved);

  Document? get current => hasTabs ? documents[tabController.index] : null;

  TabController _makeController(int index) {
    return TabController(
      length: documents.length,
      initialIndex: index,
      vsync: this,
    )..addListener(_onIndexChanged);
  }

  void _onIndexChanged() => setState(() {});

  void _onDocumentChanged() => setState(() {});

  @override
  void dispose() {
    for (final d in documents) {
      d.removeListener(_onDocumentChanged);
      d.dispose();
    }
    tabController.dispose();
    super.dispose();
  }

  Future<bool> saveAll() async {
    for (final d in documents) {
      if (d.saved) continue;
      final path = await widget.saveRef(d.path, d.toJson());
      if (path == null) return false;
      d.markSaved(path);
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: documents.isEmpty
          ? null
          : AppBar(
              title: null,
              bottom: TabBar(
                controller: tabController,
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                splashFactory: NoSplash.splashFactory,
                overlayColor: WidgetStateProperty.all(Colors.transparent),
                tabs: [for (final d in documents) tab(d)],
              ),
              toolbarHeight: 0,
            ),
      body: documents.isEmpty
          ? Container(
              color: Coolors.getSurfaceColor(context),
              child: Center(child: Text("Open a JSON file")),
            )
          : IndexedStack(
              index: tabController.index,
              children: [for (final d in documents) Editor(document: d, clipboard: widget.clipboard)],
            ),
    );
  }

  void addTab(Document document) {
    setState(() {
      document.addListener(_onDocumentChanged);
      documents.add(document);

      if (documents.length != tabController.length) {
        final oldIndex = tabController.index;

        final newIndex = oldIndex >= documents.length
            ? documents.length - 1
            : oldIndex;

        tabController.removeListener(_onIndexChanged);
        tabController.dispose();
        tabController = _makeController(newIndex);
      }
    });
  }

  Tab tab(Document document) {
    final path = document.path;
    final name = path == null || path == "" ? "Unsaved" : nameOf(path);

    return Tab(
      child: Row(
        children: [
          const SizedBox(width: 12.0),
          Text(document.saved ? name : "$name*"),
          IconButton(
            onPressed: () => closeTab(document),
            icon: const Icon(Icons.close),
            iconSize: 24.0,
          ),
        ],
      ),
    );
  }

  Future<void> closeTab(Document document) async {
    if (!document.saved) {
      final choice = await _askSave();

      if (choice == null || choice == CloseChoice.cancel) return;

      if (choice == CloseChoice.save) {
        final path = await widget.saveRef(document.path, document.toJson());
        if (path == null) return;
        document.markSaved(path);
      }
    }

    if (!mounted) return;

    final i = documents.indexOf(document);
    if (i == -1) return;

    setState(() {
      var index = tabController.index;

      documents.removeAt(i);
      document.removeListener(_onDocumentChanged);
      document.dispose();

      if (i < index) index -= 1;
      if (index > documents.length - 1) index = documents.length - 1;
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
}
