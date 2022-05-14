import 'package:flutter/material.dart' hide Image;
import 'package:flutter_processing_example/_processing_demo_sketch_display.dart';
import 'package:flutter_processing_example/demos/_blend_modes_sketch.dart';
import 'package:flutter_processing_example/demos/_empty_sketch.dart';
import 'package:flutter_processing_example/demos/_filters_sketch.dart';
import 'package:flutter_processing_example/demos/_hacking.dart';
import 'package:flutter_processing_example/generative_art/colored_circles.dart';
import 'package:flutter_processing_example/demos/perlin_noise_demo.dart';
import 'package:flutter_processing_example/the_coding_train/coding_challenges/001_starfield.dart';
import 'package:flutter_processing_example/the_coding_train/coding_challenges/003_snake_game.dart';
import 'package:flutter_processing_example/the_coding_train/coding_challenges/004_purple-rain.dart';
import 'package:flutter_processing_example/the_coding_train/coding_challenges/006_mitosis_simulation.dart';
import 'package:flutter_processing_example/the_coding_train/coding_challenges/028_metaballs.dart';
import 'package:flutter_processing_example/the_coding_train/coding_challenges/030_phyllotaxis.dart';
import 'package:flutter_processing_example/the_coding_train/coding_challenges/031_flappy_bird.dart';
import 'package:flutter_processing_example/the_coding_train/coding_challenges/036_blobby.dart';
import 'package:flutter_processing_example/the_coding_train/coding_challenges/050_circle-packing-with-text.dart';
import 'package:flutter_processing_example/the_coding_train/coding_challenges/050_circle-packing.dart';
import 'package:flutter_processing_example/the_coding_train/coding_challenges/052_random_walker.dart';
import 'package:flutter_processing_example/the_coding_train/coding_challenges/085_game_of_life.dart';
import 'package:flutter_processing_example/the_coding_train/coding_challenges/124_boids.dart';
import 'package:flutter_processing_example/verify_behaviors/_mouse_and_touch.dart';

import '_demos_screen.dart';

void main() {
  runApp(const FlutterProcessingExampleApp());
}

class FlutterProcessingExampleApp extends StatelessWidget {
  const FlutterProcessingExampleApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Processing Example',
      theme: ThemeData(
        brightness: Brightness.dark,
        colorScheme: const ColorScheme.dark(
          primary: Colors.purple,
          onPrimary: Colors.white,
        ),
      ),
      home: ProcessingDemosScreen(
        demos: [
          DemoMenuGroup(title: 'Example', items: [
            DemoMenuItem(
              title: 'Empty Sketch',
              builder: (context, sketchController) {
                return EmptySketchDemo(
                  sketchDemoController: sketchController,
                );
              },
            ),
            DemoMenuItem(
              title: 'PImage Filters',
              builder: (context, sketchController) {
                return PImageFiltersSketchDemo(
                  sketchDemoController: sketchController,
                );
              },
            ),
            DemoMenuItem(
              title: 'PImage Blend Modes',
              builder: (context, sketchController) {
                return PImageBlendModesSketchDemo(
                  sketchDemoController: sketchController,
                );
              },
            ),
            DemoMenuItem(
              title: 'Hacking Demo',
              builder: (context, sketchController) {
                return HackingDemo(
                  sketchDemoController: sketchController,
                );
              },
            ),
          ]),
          DemoMenuGroup(
            title: 'SuperDeclarative',
            items: [
              DemoMenuItem(
                title: 'Circle Art',
                builder: (_, sketchController) {
                  return ProcessingDemo(
                    createSketch: () => ColoredCirclesSketch(
                      width: 1600,
                      height: 600,
                    ),
                    sketchDemoController: sketchController,
                  );
                },
              ),
              DemoMenuItem(
                title: 'Perlin Noise',
                builder: (_, sketchController) {
                  return ProcessingDemo(
                    createSketch: () => PerlinNoiseDemoSketch(
                      width: 200,
                      height: 200,
                      animateZIndex: true,
                    ),
                    sketchDemoController: sketchController,
                  );
                },
              ),
            ],
          ),
          DemoMenuGroup(
            title: 'The Coding Train',
            items: [
              DemoMenuItem(
                title: '001: Starfield',
                builder: (_, sketchController) {
                  return CodingTrainStarfieldScreen(
                    sketchDemoController: sketchController,
                  );
                },
              ),
              DemoMenuItem(
                title: '003: Snake Game',
                builder: (_, sketchController) {
                  return CodingTrainSnakeGameScreen(
                    sketchDemoController: sketchController,
                  );
                },
              ),
              DemoMenuItem(
                title: '004: Purple Rain',
                builder: (_, sketchController) {
                  return CodingTrainPurpleRainScreen(
                    sketchDemoController: sketchController,
                  );
                },
              ),
              DemoMenuItem(
                title: '006: Mitosis Simulation',
                builder: (_, sketchController) {
                  return CodingTrainMitosisScreen(
                    sketchDemoController: sketchController,
                  );
                },
              ),
              DemoMenuItem(
                title: '028: Metaballs',
                builder: (_, sketchController) {
                  return ProcessingDemo(
                    createSketch: () => MetaBallsSketch(),
                    sketchDemoController: sketchController,
                  );
                },
              ),
              DemoMenuItem(
                title: '030: Phyllotaxis',
                builder: (_, sketchController) {
                  return ProcessingDemo(
                    createSketch: () => PhyllotaxisSketch(),
                    sketchDemoController: sketchController,
                  );
                },
              ),
              DemoMenuItem(
                title: '031: Flappy Bird',
                builder: (_, sketchController) {
                  return CodingTrainFlappyBirdScreen(
                    sketchDemoController: sketchController,
                  );
                },
              ),
              DemoMenuItem(
                title: '036: Blobby',
                builder: (_, sketchController) {
                  return CodingTrainBlobbyScreen(
                    sketchDemoController: sketchController,
                  );
                },
              ),
              DemoMenuItem(
                title: '050: Circle Packing',
                builder: (_, sketchController) {
                  return ProcessingDemo(
                    createSketch: () => CirclePackingSketch(),
                    sketchDemoController: sketchController,
                  );
                },
              ),
              DemoMenuItem(
                title: '050: Circle Packing with Text',
                builder: (_, sketchController) {
                  return ProcessingDemo(
                    createSketch: () => CirclePackingWithTextSketch(),
                    sketchDemoController: sketchController,
                  );
                },
              ),
              DemoMenuItem(
                title: '052: Random Walker',
                builder: (_, sketchController) {
                  return CodingTrainRandomWalkerScreen(
                    sketchDemoController: sketchController,
                  );
                },
              ),
              DemoMenuItem(
                title: '085: Game of Life',
                builder: (_, sketchController) {
                  return CodingTrainGameOfLifeScreen(
                    sketchDemoController: sketchController,
                  );
                },
              ),
              DemoMenuItem(
                title: '124: Boids',
                builder: (_, sketchController) {
                  return CodingTrainBoidsScreen(
                    sketchDemoController: sketchController,
                  );
                },
              ),
            ],
          ),
          DemoMenuGroup(
            title: 'Verifications',
            items: [
              DemoMenuItem(
                title: 'Mouse and Gestures',
                builder: (_, sketchController) {
                  return ProcessingDemo(
                    createSketch: () => MouseAndTouchSketch(
                      width: 500,
                      height: 500,
                    ),
                    sketchDemoController: sketchController,
                  );
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
