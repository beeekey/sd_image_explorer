import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'image_grid_screen/image_grid_screen.dart';

class MyAppDrawer extends StatefulWidget {
  const MyAppDrawer({super.key});

  @override
  State<MyAppDrawer> createState() => _MyAppDrawerState();
}

class _MyAppDrawerState extends State<MyAppDrawer> {
  int _counter = 0;
  bool loading = false;
  final ScrollController _scrollController = ScrollController();
  List<String> _lastUsedPaths = [];

  @override
  void didChangeDependencies() async {
    setState(() {
      loading = true;
    });
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      _lastUsedPaths = prefs.getStringList('selected_paths') ?? [];
    });
    super.didChangeDependencies();
    setState(() {
      loading = false;
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return loading
        ? const Center(
            child: CircularProgressIndicator(),
          )
        : Drawer(
            backgroundColor: Colors.amber,
            child: Scrollbar(
              controller: _scrollController,
              child: CustomScrollView(
                controller: _scrollController,
                slivers: [
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          AppBar(
                            title: const Text("pilzen.ch"),
                            automaticallyImplyLeading: false,
                          ),
                          const Divider(),
                          ElevatedButton(
                              onPressed: () {
                                Navigator.of(context).pushReplacementNamed("/");
                              },
                              child: Text("Home")),
                          const Divider(),
                          if (_lastUsedPaths != [] &&
                              _lastUsedPaths!.length > 0)
                            ..._lastUsedPaths!
                                .map((e) => Column(
                                      children: [
                                        ElevatedButton(
                                            onPressed: () async {
                                              final prefs =
                                                  await SharedPreferences
                                                      .getInstance();
                                              await prefs.setString(
                                                  'selected_path', e);

                                              await Navigator.of(context)
                                                  .pushReplacementNamed(
                                                      ImageGridScreen
                                                          .routeName);
                                            },
                                            child: Text(e)),
                                        const SizedBox(
                                          height: 5,
                                        )
                                      ],
                                    ))
                                .toList()
                        ]),
                  ),
                ],
              ),
            ),
          );
  }
}
