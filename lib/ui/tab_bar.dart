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
      editors.add(Editor(key: k, content: ValueNotifier<String?>(content), path: path));
      names.add(Tab(text: name));

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

  dynamic save() {
    return editorKeys[_tabController.index].currentState!.save();
  }

  String? path() {
    return editorKeys[_tabController.index].currentState!.path();
  }

  /// Rattache l'onglet courant a [path] et met son titre a jour.
  void rename(String name, String path) {
    setState(() {
      final i = _tabController.index;
      editorKeys[i].currentState!.setPath(path);
      names[i] = Tab(text: name);
    });
  }
}