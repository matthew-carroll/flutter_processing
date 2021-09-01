import 'package:flutter/material.dart' hide Image;
import 'package:flutter_processing_example/demos/_hacking.dart';
import 'package:flutter_processing_example/demos/main_perlin_noise_demo.dart';
import 'package:flutter_processing_example/the_coding_train/coding_challenges/001_starfield.dart';
import 'package:flutter_processing_example/the_coding_train/coding_challenges/004_purple-rain.dart';
import 'package:flutter_processing_example/the_coding_train/coding_challenges/006_mitosis_simulation.dart';
import 'package:flutter_processing_example/the_coding_train/coding_challenges/028_metaballs.dart';
import 'package:flutter_processing_example/the_coding_train/coding_challenges/030_phyllotaxis.dart';
import 'package:flutter_processing_example/the_coding_train/coding_challenges/050_circle-packing.dart';
import 'package:flutter_processing_example/the_coding_train/coding_challenges/052_random_walker.dart';

import '_demos_screen.dart';

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
      home: ProcessingDemosScreen(
        demos: [
          DemoMenuGroup(title: 'Example', items: [
            DemoMenuItem(
              title: 'Hacking Demo',
              builder: (context, sketchController) {
                return HackingDemo(
                  sketchDemoController: SketchDemoController(),
                );
              },
            ),
          ]),
          DemoMenuGroup(
            title: 'SuperDeclarative',
            items: [
              DemoMenuItem(
                title: 'Perlin Noise',
                builder: (_, __) {
                  return PerlinNoiseScreen();
                },
              ),
            ],
          ),
          DemoMenuGroup(
            title: 'The Coding Train',
            items: [
              DemoMenuItem(
                title: '001: Starfield',
                builder: (_, __) {
                  return CodingTrainStarfieldScreen();
                },
              ),
              DemoMenuItem(
                title: '004: Purple Rain',
                builder: (_, __) {
                  return CodingTrainPurpleRainScreen();
                },
              ),
              DemoMenuItem(
                title: '006: Mitosis Simulation',
                builder: (_, __) {
                  return CodingTrainMitosisScreen();
                },
              ),
              DemoMenuItem(
                title: '028: Metaballs',
                builder: (_, __) {
                  return CodingTrainMetaballsScreen();
                },
              ),
              DemoMenuItem(
                title: '030: Phyllotaxis',
                builder: (_, __) {
                  return CodingTrainPhyllotaxisScreen();
                },
              ),
              DemoMenuItem(
                title: '050: Circle Packing',
                builder: (_, __) {
                  return CodingTrainCirclePackingScreen();
                },
              ),
              DemoMenuItem(
                title: '052: Random Walker',
                builder: (_, __) {
                  return CodingTrainRandomWalkerScreen();
                },
              ),
              DemoMenuItem(
                title: '052: Random Walker',
                builder: (_, __) {
                  return CodingTrainRandomWalkerScreen();
                },
              ),
              DemoMenuItem(
                title: '052: Random Walker',
                builder: (_, __) {
                  return CodingTrainRandomWalkerScreen();
                },
              ),
            ],
          ),
        ],
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}
