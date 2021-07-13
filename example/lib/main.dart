import 'dart:io';
import 'dart:ui';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart' hide Image;
import 'package:flutter_processing/flutter_processing.dart';

void main() {
  runApp(FlutterProcessingExampleApp());
}

class FlutterProcessingExampleApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Processing Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Image _loadedImage;

  File? _fileToSaveImage;

  Directory? _dirToSaveFrames;
  int _remainingFrames = 0;

  Future<void> _saveImage() async {
    final imageFormat = ImageFileFormat.targa;
    late String extension;
    late String mimeType;
    switch (imageFormat) {
      case ImageFileFormat.png:
        extension = 'png';
        mimeType = 'image/png';
        break;
      case ImageFileFormat.jpeg:
        extension = 'jpg';
        mimeType = 'image/jpeg';
        break;
      case ImageFileFormat.tiff:
        extension = 'tif';
        mimeType = 'image/tiff';
        break;
      case ImageFileFormat.targa:
        extension = 'tga';
        mimeType = 'image/targa';
        break;
    }

    final filePath = await getSavePath(
      acceptedTypeGroups: [
        XTypeGroup(
          extensions: [extension],
          mimeTypes: [mimeType],
        ),
      ],
    );
    if (filePath == null) {
      print('User cancelled the file selection');
      return;
    }

    _fileToSaveImage = File(filePath);
  }

  Future<void> _saveImageFrame() async {
    final filePath = await getSavePath();
    if (filePath == null) {
      print('User cancelled the file selection');
      return;
    }

    _dirToSaveFrames = File(filePath).parent;
    _remainingFrames = 10;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.yellow,
      body: Center(
        child: Processing(
          sketch: Sketch.simple(
            setup: (s) async {
              s.size(width: 500, height: 500);

              _loadedImage = await s.loadImage('assets/audio-mixer.png');
            },
            draw: (s) async {
              s.image(
                image: _loadedImage,
              );

              final subImage = await s.getRegion(
                x: 0,
                y: 0,
                width: (s.width / 2).round(),
                height: (s.height / 2).round(),
              );
              // s.image(image: subImage, origin: Offset(s.width / 2, s.height / 2));

              await s.loadPixels();

              for (int col = 0; col < 400; ++col) {
                for (int row = 0; row < 400; ++row) {
                  s.set(x: col, y: row, color: Color(0xFF00FF00));
                }
              }
              await s.setRegion(image: subImage);

              await s.updatePixels();

              final pixelColor = await s.get(s.mouseX, s.mouseY);
              s
                // ..noStroke()
                ..fill(color: pixelColor)
                ..circle(
                  center: Offset(s.mouseX + 50, s.mouseY + 50),
                  diameter: 100,
                );

              await s.loadPixels();

              if (_fileToSaveImage != null) {
                s.save(file: _fileToSaveImage!);

                _fileToSaveImage = null;
              } else if (_dirToSaveFrames != null && _remainingFrames > 0) {
                s.saveFrame(
                  directory: _dirToSaveFrames!,
                  namingPattern: 'testname_##.jpg',
                );

                _remainingFrames -= 1;
                if (_remainingFrames == 0) {
                  _dirToSaveFrames = null;
                }
              }
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _saveImageFrame,
        child: Icon(Icons.save),
      ),
    );
  }
}
