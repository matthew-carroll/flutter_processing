import 'dart:ui';

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
  final _stars = <Star>[];
  Image? _assetImage;

  @override
  void reassemble() {
    super.reassemble();
    _stars.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.yellow,
      body: Center(
        child: Processing(
          sketch: Sketch.simple(
            setup: (s) async {
              s.randomSeed(53245234);

              s
                ..size(width: 1600, height: 900)
                ..background(color: Colors.black);

              for (int i = 0; i < 100; ++i) {
                _stars.add(
                  Star(
                    x: s.random(-s.width / 2, s.width / 2),
                    y: s.random(-s.height / 2, s.height / 2),
                    z: s.random(s.width),
                  ),
                );
              }

              _assetImage = await s.loadImage('assets/photo.jpeg');
            },
            draw: (s) async {
              s.background(color: Colors.black);

              for (final star in _stars) {
                star.update(s);
              }

              for (final star in _stars) {
                star.paintStreak(s);
              }

              for (final star in _stars) {
                star.paintStar(s);
              }

              await s.loadPixels();

              //
              // final leftHalf = await s.getRegion(origin: Offset.zero, size: Size(s.width / 2, s.height.toDouble()));
              // s.image(image: leftHalf, origin: Offset(s.width / 2, 0.0));
              //
              // final rightHalf =
              //     await s.getRegion(origin: Offset(s.width / 2, 0), size: Size(s.width / 2, s.height.toDouble()));
              // s.image(image: rightHalf, origin: Offset.zero);

              for (int i = 0; i < s.width / 2; ++i) {
                for (int j = 0; j < s.height; ++j) {
                  s.set(
                    pixel: Offset(i.toDouble(), j.toDouble()),
                    color: Color(0xFF0000FF),
                  );
                }
              }

              final color = Color(0xFFFF0000);
              print('Color value: ${((color.value & 0x00FFFFFF) << 8) | ((color.value & 0xFF000000) >> 24)}, color '
                  'value: '
                  '${color.value.toRadixString(16)}');
              print('First shift: ${((color.value & 0x00FFFFFF) << 8).toRadixString(16)}');
              print('Second shift: ${((color.value & 0xFF000000) >> 24).toRadixString(16)}');
              print(
                  'Combined: ${(((color.value & 0x00FFFFFF) << 8) | ((color.value & 0xFF000000) >> 24)).toRadixString(16)}');
              await s.updatePixels();

              s.image(
                image: _assetImage!,
                origin: Offset(
                  (s.width - _assetImage!.width) / 2,
                  (s.height - _assetImage!.height) / 2,
                ),
              );

              await s.loadPixels();

              final photoCopy = await s.getRegion(
                  origin: Offset(
                    (s.width - _assetImage!.width) / 2,
                    (s.height - _assetImage!.height) / 2,
                  ),
                  size: Size(
                    _assetImage!.width.toDouble(),
                    _assetImage!.height.toDouble(),
                  ));
              s.image(image: photoCopy);
              s.image(
                  image: photoCopy,
                  origin: Offset(
                    s.width - _assetImage!.width.toDouble(),
                    s.height - _assetImage!.height.toDouble(),
                  ));

              print('Frame ${s.frameCount}');
              print('Frame rate: ${s.frameRate}');
              print('');

              s.noLoop();
            },
          ),
        ),
      ),
    );
  }
}

class Star {
  Star({
    required this.x,
    required this.y,
    required this.z,
  }) : originalZ = 0 {
    originalZ = z;
  }

  double x;
  double y;
  double z;
  double originalZ;

  void update(Sketch s) {
    z -= 30;
    originalZ -= 10;

    if (z <= 0) {
      x = s.random(-s.width / 2, s.width / 2);
      y = s.random(-s.height / 2, s.height / 2);
      z = s.random(s.width);
      originalZ = z;
    }
  }

  void paintStreak(Sketch s) {
    final center = Offset(s.width / 2, s.height / 2);

    final perspectiveOrigin = Offset(
      lerpDouble(0, s.width, x / originalZ)!,
      lerpDouble(0, s.height, y / originalZ)!,
    );
    final perspectivePosition = Offset(
      lerpDouble(0, s.width, x / z)!,
      lerpDouble(0, s.height, y / z)!,
    );

    s
      ..stroke(color: Colors.white.withOpacity(0.3))
      ..line(perspectiveOrigin + center, perspectivePosition + center);
  }

  void paintStar(Sketch s) {
    final center = Offset(s.width / 2, s.height / 2);

    final perspectiveOffset = Offset(
      lerpDouble(0, s.width, x / z)!,
      lerpDouble(0, s.height, y / z)!,
    );
    final diameter = lerpDouble(12, 0, z / s.width)!;

    s
      ..noStroke()
      ..fill(color: Colors.white)
      ..circle(center: perspectiveOffset + center, diameter: diameter);
  }
}
