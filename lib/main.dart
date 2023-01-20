import 'dart:io';

import 'package:sd_image_explorer/screens/landing_screen/landing_screen.dart';
import 'package:flutter/material.dart';

import 'screens/image_grid_screen/image_grid_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Image Viewer',
        theme: ThemeData(
          primarySwatch: Colors.amber,
          scaffoldBackgroundColor: Colors.grey,
          // textTheme:
        ),
        home: const LandingScreen(title: 'Image Viewer'),
        routes: {
          ImageGridScreen.routeName: (context) => const ImageGridScreen(),
        });
  }
}
