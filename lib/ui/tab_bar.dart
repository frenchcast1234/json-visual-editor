import 'package:flutter/material.dart';
import 'package:json_visual_editor/pages/editor.dart';
import 'package:json_visual_editor/modules/color.dart';

class TabBarEditor extends StatefulWidget {
  const TabBarEditor({super.key});

  @override
  State<TabBarEditor> createState() => TabBarEditorState();
}

class TabBarEditorState extends State<TabBarEditor> with TickerProviderStateMixin {
  late TabController _tabController = _makeController(0);

  final List<GlobalKey<EditorState>> editorKeys = [];
  final List<Editor> editors = [];
  final List<Tab> names = [];
  final _fileName = RegExp(r'[^/\\]+$');

  TabController _makeController(int index) {
    // Duree par defaut : c'est elle qui anime le trait sous les onglets.
    return TabController(length: editors.length, initialIndex: index, vsync: this)
      ..addListener(_onIndexChanged);
  }

  // index change des le debut de l'animation : le contenu bascule d'un coup.
  void _onIndexChanged() => setState(() {});

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: editors.isEmpty
          ? null
          : AppBar(
            title: null,
            bottom: TabBar(
              controller: _tabController,
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              splashFactory: NoSplash.splashFactory,
              overlayColor: WidgetStateProperty.all(Colors.transparent),
              tabs: names,
            ),
            toolbarHeight: 0,
          ),
      body: editors.isEmpty 
          ? Container(color: Coolors.getSurfaceColor(context), child: Center(child: Text("Open a JSON file"))) 
          : IndexedStack(
            index: _tabController.index,
            children: editors,
          ),
    );
  }

  void addTab(String content, String name, String? path) {
    setState(() {
      var k = GlobalKey<EditorState>();
      editorKeys.add(k);
      editors.add(Editor(key: k, content: ValueNotifier<String?>(content), path: path, unsave: () => refresh(k)));
      names.add(_tab(k, path == null || path == "" ? "$name*" : name));

      if (editors.length != _tabController.length) {
        final oldIndex = _tabController.index;

        final newIndex = oldIndex >= editors.length
            ? editors.length - 1
            : oldIndex;

        _tabController.removeListener(_onIndexChanged);
        _tabController.dispose();
        _tabController = _makeController(newIndex);
      }
    });
  }

  /// Onglet : le libelle, puis le bouton de fermeture a sa droite.
  Tab _tab(GlobalKey<EditorState> key, String label) {
    return Tab(
      child: Row(
        children: [
          const SizedBox(width: 12.0),
          Text(label),
          IconButton(
            onPressed: () => closeTab(key),
            icon: const Icon(Icons.close),
            iconSize: 24.0,
          ),
        ],
      ),
    );
  }

  /// Ferme l'onglet porte par [key]. Un TabController ne pouvant pas changer de
  /// longueur, il est recree a chaque fermeture, comme dans [addTab].
  void closeTab(GlobalKey<EditorState> key) {
    final i = editorKeys.indexOf(key);
    if (i == -1) return;

    setState(() {
      var index = _tabController.index;

      editorKeys.removeAt(i);
      editors.removeAt(i);
      names.removeAt(i);

      if (i < index) index -= 1;                                  // les onglets a droite se decalent
      if (index > editors.length - 1) index = editors.length - 1; // l'onglet ferme etait le dernier
      if (index < 0) index = 0;                                   // plus aucun onglet

      _tabController.removeListener(_onIndexChanged);
      _tabController.dispose();
      _tabController = _makeController(index);
    });
  }

  dynamic save() {
    return editorKeys[_tabController.index].currentState!.save();
  }

  String? path() {
    return editorKeys[_tabController.index].currentState!.path();
  }

  void refresh(GlobalKey<EditorState> key) {
    final i = editorKeys.indexOf(key);
    if (i == -1) return;

    final editor = key.currentState!;
    final path = editor.path();
    final name = path == null ? "Unsaved" : (_fileName.firstMatch(path)?.group(0) ?? path);

    setState(() => names[i] = _tab(key, editor.saved ? name : "$name*"));
  }

  void markSaved(String path) {
    final key = editorKeys[_tabController.index];
    key.currentState!
      ..setPath(path)
      ..setSaved();
    refresh(key);
  }
}
