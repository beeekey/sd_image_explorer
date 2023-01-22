import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../helpers/search_files.dart';

class ImageGridScreen extends StatefulWidget {
  static const routeName = "/image/grid";
  const ImageGridScreen({super.key});

  @override
  State<ImageGridScreen> createState() => _ImageGridScreenState();
}

class _ImageGridScreenState extends State<ImageGridScreen> {
  bool _init = true;
  bool _loading = true;
  List<File>? _files;
  List<File>? _origFiles;
  File? _selectedFile;
  Map? _exifData;
  int _selectedIndex = 0;
  ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();
  String? selectedDirectory;
  double scrollTo = 0;
  final _txtSearchController = TextEditingController();
  String searchStr = "";
  GlobalKey _keySize = GlobalKey();
  double newImgBoxWidth = 200;
  double newImgBoxHeight = 200;

  void _handleKeyEvent(RawKeyEvent event) async {
    var offset = _scrollController.offset;
    if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
      setState(() {
        if (kReleaseMode) {
          _scrollController.animateTo(offset - 200,
              duration: const Duration(milliseconds: 30), curve: Curves.ease);
        } else {
          _scrollController.animateTo(offset - 200,
              duration: const Duration(milliseconds: 30), curve: Curves.ease);
        }
      });
    } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
      setState(() {
        if (kReleaseMode) {
          _scrollController.animateTo(offset + 200,
              duration: const Duration(milliseconds: 30), curve: Curves.ease);
        } else {
          _scrollController.animateTo(offset + 200,
              duration: const Duration(milliseconds: 30), curve: Curves.ease);
        }
      });
    } else if (event.isKeyPressed(LogicalKeyboardKey.arrowRight)) {
      setState(() {
        if (kReleaseMode) {
          if (_selectedIndex < _files!.length - 1) {
            _selectedIndex += 1;
            _scrollController.jumpTo(scrollTo);
          }
        } else {
          if (_selectedIndex < _files!.length - 1) {
            _selectedIndex += 1;
            _scrollController.jumpTo(scrollTo);
          }
        }
      });
      readImageData(_files![_selectedIndex]);
    } else if (event.isKeyPressed(LogicalKeyboardKey.arrowLeft)) {
      setState(() {
        if (kReleaseMode) {
          if (_selectedIndex < _files!.length - 1) {
            _selectedIndex -= 1;
            _scrollController.jumpTo(scrollTo);
          }
        } else {
          if (_selectedIndex >= 1) {
            _selectedIndex -= 1;
            _scrollController.jumpTo(scrollTo);
          }
        }
      });
      await readImageData(_files![_selectedIndex]);
    }
  }

  @override
  void didChangeDependencies() async {
    if (_init = true) {
      final prefs = await SharedPreferences.getInstance();
      selectedDirectory = prefs.getString('selected_path');

      if (selectedDirectory != null) {
        _origFiles = await getFiles(selectedDirectory!);
        if (searchStr == "") {
          _files = _origFiles;
        }
        _loading = false;
        // print(_files!.length);
      }
      _init = false;
    }
    setState(() {});

    super.didChangeDependencies();
  }

  Future<void> readImageData(File file) async {
    var data;
    final image = await img.decodePngFile(file.path);

    // print("-----------------------");
    // print(image?.hasExif);
    // print(image?.textData);
    // print(image?.exif.getDataSize());
    // var ex = img.ExifData.fromInputBuffer(
    //     img.InputBuffer(File(file.path).readAsBytesSync()));
    // print(ex.imageIfd.imageWidth);

    // if (image?.exif.keys != null) {
    //   for (var element in image!.exif.keys) {
    //     print("el: ${element}");
    //   }
    // }

    if (image?.textData != null) {
      data = {"data": image?.textData};
    } else {
      data = {
        "data":
            "Could not load EXIF data ... only *.png is currently supported."
      };
    }

    setState(() {
      _selectedFile = file;
      _exifData = data;
    });
    // print(_exifData.toString());
  }

  Future<void> _launchUrl(url) async {
    if (!await launchUrl(url)) {
      throw 'Could not launch $url';
    }
  }

  Widget generateTextfieldsForData(Map data) {
    final dataList =
        data.toString().replaceAll("{", "").replaceAll("}", "").split("\n");

    String parameters = "";
    String negativePrompt = "";

    if (dataList.length >= 3) {
      negativePrompt = dataList[1];
      parameters = dataList[2];
    } else if (dataList.length == 2) {
      parameters = dataList[1];
    }
    parameters = parameters
        .replaceAll(
            "fdcf65e7", "fdcf65e7 - dreamlike-photoreal-2.0.safetensors")
        .replaceAll("ddc6edf2", "ddc6edf2 - mdjrny-v4.ckpt")
        .replaceAll("06c50424", "06c50424 - model-v1.2-full.ckpt")
        .replaceAll("06c50424", "06c50424 - model-v1.4-full.ckpt")
        .replaceAll("b895edc4", "b895edc4 - openjourney-v2-unpruned.ckpt.ckpt")
        .replaceAll("e5ed66c6", "e5ed66c6 - openjourney-v2.ckpt")
        .replaceAll(
            "d0b457ae", "d0b457ae - protogenX53Photorealism_10.safetensors")
        .replaceAll("d0522d12",
            "d0522d12 - stable-diffusion-2-depth-512-depth-ema.ckpt")
        .replaceAll("81761151", "81761151 - v1-5-pruned-emaonly.ckpt")
        .replaceAll("a9263745", "a9263745 - v1-5-pruned.ckpt")
        .replaceAll("47c8ec7d", "47c8ec7d - v2-1_512-ema-pruned.ckpt")
        .replaceAll("4bdfc29c", "4bdfc29c - v2-1_768-ema-pruned.ckpt")
        .replaceAll("09dd2ae4", "09dd2ae4 - v2-512-base-ema.ckpt");
    return Column(
      children: [
        TextFormField(
          decoration: const InputDecoration(
            labelText: 'Prompt:',
            labelStyle: TextStyle(
                color: Colors.black87, fontSize: 17, fontFamily: 'AvenirLight'),
          ),
          key: Key(dataList[0]), // <- Magic!
          initialValue: dataList[0],
          minLines: 2,
          maxLines: 10,
          readOnly: true,
        ),
        if (negativePrompt != "")
          TextFormField(
            decoration: const InputDecoration(
              labelText: 'Negative prompt:',
              labelStyle: TextStyle(
                  color: Colors.black87,
                  fontSize: 17,
                  fontFamily: 'AvenirLight'),
            ),
            key: Key(negativePrompt), // <- Magic!
            initialValue: negativePrompt,
            minLines: 2,
            maxLines: 10,
            readOnly: true,
          ),
        TextFormField(
          decoration: const InputDecoration(
            labelText: 'Parameters:',
            labelStyle: TextStyle(
                color: Colors.black87, fontSize: 17, fontFamily: 'AvenirLight'),
          ),
          key: Key(parameters), // <- Magic!
          initialValue: parameters,
          minLines: 2,
          maxLines: 10,
          readOnly: true,
        ),
      ],
    );
  }

  void _txtSearch(BuildContext context) {
    final searchStrIntern = _txtSearchController.text;

    setState(() {
      if (_origFiles != null) {
        _files = _origFiles!
            .where((f) => f.path
                .toString()
                .toLowerCase()
                .contains(searchStrIntern.toLowerCase()))
            .toList();
      } else {
        _files = _origFiles;
      }

      searchStr = searchStrIntern;
    });
  }

  void postFrameCallback(_) {
    var context = _keySize.currentContext;
    if (context == null) return;

    newImgBoxWidth = context.size!.width;
    newImgBoxHeight = context.size!.height;
  }

  @override
  Widget build(BuildContext context) {
    SchedulerBinding.instance.addPostFrameCallback(postFrameCallback);
    int detailBoxWidth = 600;

    if (!_loading && _files != null && _files!.isNotEmpty) {
      double windowWidth = MediaQuery.of(context).size.width;

      int cols = (windowWidth - detailBoxWidth) ~/ newImgBoxWidth;
      int rows = (_files!.length) ~/ cols;

      scrollTo = ((_selectedIndex ~/ cols) * (newImgBoxHeight + 20));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("$selectedDirectory"),
      ),
      body: _loading || _files == null || _files!.isEmpty
          ? searchStr != ""
              ? const Center(
                  child: Text(
                      "No results found for the search in the filenames\n\nCurrently we are only searching in the filenames."),
                )
              : const Center(
                  child: Text("No directory selected or no files found"),
                )
          : RawKeyboardListener(
              autofocus: true,
              focusNode: _focusNode,
              onKey: _handleKeyEvent,
              child: Center(
                  child: Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Scrollbar(
                        trackVisibility: true,
                        thumbVisibility: true,
                        controller: _scrollController,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(0, 0, 16.0, 0),
                          child: GridView.builder(
                              controller: _scrollController,
                              scrollDirection: Axis.vertical,
                              shrinkWrap: true,
                              gridDelegate:
                                  const SliverGridDelegateWithMaxCrossAxisExtent(
                                      maxCrossAxisExtent: 200,
                                      childAspectRatio: 1 / 1,
                                      crossAxisSpacing: 20,
                                      mainAxisSpacing: 20),
                              itemCount: _files!.length,
                              itemBuilder: (BuildContext ctx, index) {
                                return InkWell(
                                  key: index == 0 ? _keySize : null,
                                  onTap: () async {
                                    await readImageData(_files![index]);
                                    setState(() {
                                      _selectedIndex = index;
                                    });
                                  },
                                  child: Container(
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                        border: index == _selectedIndex
                                            ? Border.all(
                                                color: Colors.amber, width: 4)
                                            : Border.all(
                                                color: const Color.fromARGB(
                                                    0, 68, 137, 255),
                                                width: 0,
                                              ),
                                        image: DecorationImage(
                                          image: FileImage(_files![index]),
                                          fit: BoxFit.cover,
                                        ),
                                        color: Colors.amber,
                                        borderRadius:
                                            BorderRadius.circular(15)),
                                  ),
                                );
                              }),
                        ),
                      ),
                    ),
                  ),
                  SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: SizedBox(
                        width: detailBoxWidth.toDouble(),
                        child: _selectedFile != null
                            ? Column(
                                children: [
                                  Image.file(
                                    _selectedFile!,
                                    width: detailBoxWidth.toDouble(),
                                    fit: BoxFit.scaleDown,
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      ElevatedButton(
                                          onPressed: () {
                                            _launchUrl(Uri.directory(
                                                _selectedFile!.parent.path));
                                          },
                                          child: const Text("Open Folder")),
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      ElevatedButton(
                                          onPressed: () {
                                            _launchUrl(
                                                Uri.file(_selectedFile!.path));
                                          },
                                          child: const Text("Open File")),
                                    ],
                                  ),
                                  ..._exifData!.entries!.map((element) {
                                    return element.key == "data" &&
                                            element.value is Map
                                        ? generateTextfieldsForData(
                                            element.value)
                                        : Text(
                                            "${element.key} : ${element.value}",
                                            softWrap: true,
                                          );
                                  }).toList()
                                ],
                              )
                            : Container(),
                      ),
                    ),
                  )
                ],
              )),
            ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.black54,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 200,
                child: TextField(
                  style: const TextStyle(color: Colors.white),
                  controller: _txtSearchController,
                  decoration: InputDecoration(
                    enabledBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                    focusedBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                    border: const UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                    hintStyle: const TextStyle(color: Colors.white),
                    hintText: "Text search:",
                    suffixIcon: IconButton(
                      onPressed: () {
                        _txtSearchController.clear();
                        _txtSearch(context);
                      },
                      icon: const Icon(
                        Icons.clear,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  keyboardType: TextInputType.text,
                  onSubmitted: (_) => _txtSearch(context),
                ),
              ),
              IconButton(
                onPressed: () {
                  _txtSearch(context);
                },
                icon: const Icon(
                  Icons.search,
                  size: 30,
                  color: Colors.white,
                ),
              ),
              const SizedBox(
                width: 10,
              ),
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _files = _files!.reversed.toList();
                  });
                },
                icon: const Icon(Icons.filter_list),
                label: const Text("Change order"),
              ),
              const SizedBox(
                width: 10,
              ),
              ElevatedButton.icon(
                onPressed: () async {
                  List<File> newFiles = await getFiles(selectedDirectory!);
                  setState(() {
                    _origFiles = newFiles;
                    _files = newFiles;
                  });
                },
                icon: const Icon(Icons.refresh),
                label: const Text("Reload from disk"),
              ),
              const SizedBox(
                width: 10,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
