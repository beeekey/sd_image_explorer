import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../image_grid_screen/image_grid_screen.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key, required this.title});

  final String title;

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  String? _path;
  List<String> _lastUsedPaths = [];

  @override
  void didChangeDependencies() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      _lastUsedPaths = prefs.getStringList('selected_paths') ?? [];

      _path = prefs.getString("selected_path");
    });

    super.didChangeDependencies();
  }

  Future<void> selectPath() async {
    String? selectedDirectory = await FilePicker.platform.getDirectoryPath();

    if (selectedDirectory == null) {
      // User canceled the picker
      return;
    }
    print(selectedDirectory);
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('selected_path', selectedDirectory);

    if (!_lastUsedPaths!.contains(selectedDirectory)) {
      _lastUsedPaths!.add(selectedDirectory);

      await prefs.setStringList(
          'selected_paths', _lastUsedPaths!.cast<String>());
    }

    setState(() {
      _path = selectedDirectory;
    });
    print(_path);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'Simple Imageviewer',
                style: Theme.of(context).textTheme.headline4,
              ),
              const SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                      onPressed: () async {
                        await selectPath();

                        if (_path != null) {
                          Navigator.of(context)
                              .pushNamed(ImageGridScreen.routeName);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                          primary: Colors.amberAccent,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 50, vertical: 20),
                          textStyle: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold)),
                      child: const Text("Select Path")),
                  const SizedBox(
                    width: 20,
                  ),
                  _path != null
                      ? ElevatedButton(
                          onPressed: () async {
                            Navigator.of(context)
                                .pushNamed(ImageGridScreen.routeName);
                          },
                          style: ElevatedButton.styleFrom(
                              primary: Colors.amberAccent,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 50, vertical: 20),
                              textStyle: const TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold)),
                          child: const Text("View Files"),
                        )
                      : Container(),
                ],
              ),
              const SizedBox(
                height: 50,
              ),
              if (_lastUsedPaths != [] && _lastUsedPaths!.length > 0)
                ..._lastUsedPaths!
                    .map((e) => Column(
                          children: [
                            ElevatedButton(
                                onLongPress: () async {
                                  // remove entry
                                  final prefs =
                                      await SharedPreferences.getInstance();
                                  _lastUsedPaths!.remove(e);
                                  String? newVal = null;
                                  if (_lastUsedPaths.length > 1) {
                                    final newVal = _lastUsedPaths[0];
                                  }
                                  if (newVal != null) {
                                    await prefs.setString(
                                        'selected_path', newVal);
                                  }
                                  setState(() {
                                    _path = newVal;
                                  });
                                },
                                onPressed: () async {
                                  final prefs =
                                      await SharedPreferences.getInstance();
                                  await prefs.setString('selected_path', e);
                                  setState(() {
                                    _path = e;
                                  });
                                  Navigator.of(context)
                                      .pushNamed(ImageGridScreen.routeName);
                                },
                                child: Text(e)),
                            const SizedBox(
                              height: 5,
                            )
                          ],
                        ))
                    .toList()
            ],
          ),
        ),
      ),
    );
  }
}
