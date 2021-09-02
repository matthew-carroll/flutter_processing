import 'package:flutter/material.dart' hide Image;
import 'package:flutter_processing_example/demos/perlin_noise_demo.dart';
import 'package:flutter_processing_example/the_coding_train/coding_challenges/001_starfield.dart';
import 'package:flutter_processing_example/the_coding_train/coding_challenges/006_mitosis_simulation.dart';
import 'package:flutter_processing_example/the_coding_train/coding_challenges/028_metaballs.dart';
import 'package:flutter_processing_example/the_coding_train/coding_challenges/030_phyllotaxis.dart';
import 'package:flutter_processing_example/the_coding_train/coding_challenges/050_circle-packing-with-text.dart';
import 'package:flutter_processing_example/the_coding_train/coding_challenges/052_random_walker.dart';

import 'app_screen.dart';
import 'demos/_hacking_demo.dart';
import 'the_coding_train/coding_challenges/004_purple-rain.dart';
import 'the_coding_train/coding_challenges/050_circle-packing.dart';

void main() {
  runApp(FlutterProcessingExampleApp());
}

class FlutterProcessingExampleApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final menu = _createMenu();

    return MaterialApp(
      title: 'Flutter Processing Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: AppScreen(
        menu: menu,
        initialActiveMenuItem: menu.first.items.first,
      ),
    );
  }

  List<DemoMenuGroup> _createMenu() {
    return [
      DemoMenuGroup(
        title: 'SuperDeclarative!',
        items: [
          DemoMenuItem(
            title: 'Hacking Demo',
            pageBuilder: (_) => HackingDemo(),
          ),
          DemoMenuItem(
            title: 'Perlin Noise',
            pageBuilder: (_) => PerlinNoiseDemo(),
          ),
        ],
      ),
      DemoMenuGroup(
        title: 'The Coding Train',
        items: [
          DemoMenuItem(
            title: '001: Starfield',
            pageBuilder: (_) => CodingTrainStarfieldDemo(),
          ),
          DemoMenuItem(
            title: '004: Purple Rain',
            pageBuilder: (_) => CodingTrainPurpleRainDemo(),
          ),
          DemoMenuItem(
            title: '006: Mitosis Simulation',
            pageBuilder: (_) => CodingTrainMitosisSimulationDemo(),
          ),
          DemoMenuItem(
            title: '028: Metaballs',
            pageBuilder: (_) => CodingTrainMetaballsDemo(),
          ),
          DemoMenuItem(
            title: '030: Phyllotaxis',
            pageBuilder: (_) => CodingTrainPhyllotaxisDemo(),
          ),
          DemoMenuItem(
            title: '050: Circle Packing',
            pageBuilder: (_) => CodingTrainCirclePackingDemo(),
          ),
          DemoMenuItem(
            title: '050: Circle Packing (text)',
            pageBuilder: (_) => CodingTrainCirclePackingTextDemo(),
          ),
          DemoMenuItem(
            title: '052: Random Walker',
            pageBuilder: (_) => CodingTrainRandomWalker(),
          ),
        ],
      ),
    ];
  }
}
