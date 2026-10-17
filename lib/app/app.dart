import 'package:flutter/material.dart';
import 'component_gallery_page.dart';
import 'theme/app_theme.dart';

/// The root widget of the whole application.
class IsitiyaGardenApp extends StatelessWidget {
  const IsitiyaGardenApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'isitiyaGarden',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const ComponentGalleryPage(),
    );
  }
}
