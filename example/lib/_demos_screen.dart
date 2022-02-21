import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/cupertino.dart' hide Image;
import 'package:flutter/material.dart' hide Image;
import 'package:flutter/widgets.dart';
import 'package:flutter_processing/flutter_processing.dart';
import 'package:flutter_processing_example/api_demos/_image_blending_sketch.dart';
import 'package:flutter_processing_example/api_demos/_image_mask_sketch.dart';
import 'package:flutter_processing_example/api_demos/_image_resize_sketch.dart';
import 'package:flutter_processing_example/demos/_blend_modes_sketch.dart';
import 'package:flutter_processing_example/demos/_filters_sketch.dart';
import 'package:flutter_processing_example/demos/_hacking.dart';
import 'package:flutter_processing_example/demos/colored_circles.dart';
import 'package:flutter_processing_example/demos/perlin_noise_demo.dart';
import 'package:flutter_processing_example/io/_files.dart';
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
import 'package:popover/popover.dart';

import '_processing_demo_sketch_display.dart';
import 'demos/_empty_sketch.dart';

/// Screen that displays all example app demos.
class ProcessingDemosScreen extends StatefulWidget {
  const ProcessingDemosScreen({
    Key? key,
    required this.demos,
  }) : super(key: key);

  final List<DemoMenuGroup> demos;

  @override
  _ProcessingDemosScreenState createState() => _ProcessingDemosScreenState();
}

class _ProcessingDemosScreenState extends State<ProcessingDemosScreen> with SingleTickerProviderStateMixin {
  static const _toolbarColor = Color(0xFF333333);
  static const _popoverColor = Color(0xFF3F3F3F);

  final _exampleDemoListItem = DemoMenuItem(
    title: 'Empty Sketch',
    builder: (context, sketchController) {
      return EmptySketchDemo(
        sketchDemoController: sketchController,
      );
    },
  );

  final _generativeArtButtonKey = GlobalKey();
  final _codingTrainButtonKey = GlobalKey();
  final _experimentsButtonKey = GlobalKey();
  final _apiDemosButtonKey = GlobalKey();

  final _saveScreenshotButtonKey = GlobalKey();
  final _saveGifButtonKey = GlobalKey();
  final _saveFramesButtonKey = GlobalKey();

  final _sketchDemoController = SketchDemoController();
  late ValueNotifier<DemoMenuItem> _menuItem;

  @override
  void initState() {
    super.initState();

    _menuItem = ValueNotifier(_exampleDemoListItem);
  }

  void _promptToSelectGenerativeArtDemo() {
    _showPopover(
      tapTargetContext: _generativeArtButtonKey.currentContext!,
      direction: PopoverDirection.left,
      contentBuilder: (context) {
        return _DemoSelectionList(
          selectedItem: _menuItem,
          demoList: [
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
          ],
        );
      },
    );
  }

  void _promptToSelectCodingTrainDemo() {
    _showPopover(
      tapTargetContext: _codingTrainButtonKey.currentContext!,
      direction: PopoverDirection.left,
      contentBuilder: (context) {
        return _DemoSelectionList(
          selectedItem: _menuItem,
          demoList: [
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
        );
      },
    );
  }

  void _promptToSelectExperimentDemo() {
    _showPopover(
      tapTargetContext: _experimentsButtonKey.currentContext!,
      direction: PopoverDirection.left,
      contentBuilder: (context) {
        return _DemoSelectionList(
          selectedItem: _menuItem,
          demoList: [
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
            DemoMenuItem(
              title: 'Hacking Demo',
              builder: (context, sketchController) {
                return HackingDemo(
                  sketchDemoController: sketchController,
                );
              },
            ),
          ],
        );
      },
    );
  }

  void _promptToSelectApiDemo() {
    _showPopover(
      tapTargetContext: _apiDemosButtonKey.currentContext!,
      direction: PopoverDirection.left,
      contentBuilder: (context) {
        return _DemoSelectionList(
          selectedItem: _menuItem,
          demoList: [
            DemoMenuItem(
              title: 'Image Masks',
              builder: (context, sketchController) {
                return ImageMaskSketchDemo(
                  sketchDemoController: sketchController,
                );
              },
            ),
            DemoMenuItem(
              title: 'Image Resize',
              builder: (context, sketchController) {
                return ImageResizeSketchDemo(
                  sketchDemoController: sketchController,
                );
              },
            ),
            DemoMenuItem(
              title: 'Image Blend',
              builder: (context, sketchController) {
                return ImageBlendSketchDemo(
                  sketchDemoController: sketchController,
                );
              },
            ),
            DemoMenuItem(
              title: 'Image Filters',
              builder: (context, sketchController) {
                return PImageFiltersSketchDemo(
                  sketchDemoController: sketchController,
                );
              },
            ),
            DemoMenuItem(
              title: 'Image Blend Modes',
              builder: (context, sketchController) {
                return PImageBlendModesSketchDemo(
                  sketchDemoController: sketchController,
                );
              },
            ),
          ],
        );
      },
    );
  }

  void _promptToSaveScreenshot() {
    _showPopover(
      tapTargetContext: _saveScreenshotButtonKey.currentContext!,
      direction: PopoverDirection.right,
      contentBuilder: (context) {
        return _TakeScreenshotPrompt(
          sketchDemoController: _sketchDemoController,
        );
      },
    );
  }

  void _promptToSaveGif() {
    _showPopover(
      tapTargetContext: _saveGifButtonKey.currentContext!,
      direction: PopoverDirection.right,
      contentBuilder: (context) {
        return _GenerateGifPrompt(
          sketchDemoController: _sketchDemoController,
        );
      },
    );
  }

  void _promptToSaveFrames() {
    _showPopover(
      tapTargetContext: _saveFramesButtonKey.currentContext!,
      direction: PopoverDirection.right,
      contentBuilder: (context) {
        return _GenerateScreenshotFramesPrompt(
          sketchDemoController: _sketchDemoController,
        );
      },
    );
  }

  void _showPopover({
    required BuildContext tapTargetContext,
    required PopoverDirection direction,
    required WidgetBuilder contentBuilder,
  }) {
    showPopover(
      context: tapTargetContext,
      direction: direction,
      width: 200,
      backgroundColor: _popoverColor,
      barrierColor: const Color(0x00000000),
      transitionDuration: const Duration(milliseconds: 100),
      bodyBuilder: (context) {
        return Builder(
          builder: (contentContext) {
            return contentBuilder(contentContext);
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ValueListenableBuilder<DemoMenuItem>(
          valueListenable: _menuItem,
          builder: (context, menuItem, child) {
            return menuItem.builder(context, _sketchDemoController);
          },
        ),
        _buildLeftToolbar(),
        _buildRightToolbar(),
      ],
    );
  }

  Widget _buildLeftToolbar() {
    return Align(
      alignment: Alignment(-1.0, -0.1),
      child: IconTheme(
        data: IconThemeData(
          color: Colors.white,
        ),
        child: Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: Material(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            color: _toolbarColor,
            child: SizedBox(
              width: 54,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 8),
                  SizedBox(
                    width: 28,
                    child: Image.asset("assets/logo_128.png"),
                  ),
                  Divider(),
                  IconButton(
                    onPressed: () {
                      _menuItem.value = _exampleDemoListItem;
                    },
                    icon: Icon(Icons.insert_drive_file),
                    tooltip: 'Your Sketch',
                  ),
                  const SizedBox(height: 16),
                  IconButton(
                    key: _generativeArtButtonKey,
                    onPressed: _promptToSelectGenerativeArtDemo,
                    icon: Icon(Icons.color_lens),
                    tooltip: 'Generative Art',
                  ),
                  const SizedBox(height: 16),
                  IconButton(
                    key: _codingTrainButtonKey,
                    onPressed: _promptToSelectCodingTrainDemo,
                    icon: Icon(Icons.train),
                    tooltip: 'The Coding Train',
                  ),
                  const SizedBox(height: 16),
                  IconButton(
                    key: _experimentsButtonKey,
                    onPressed: _promptToSelectExperimentDemo,
                    icon: Icon(Icons.science),
                    tooltip: 'Experiments',
                  ),
                  const SizedBox(height: 16),
                  IconButton(
                    key: _apiDemosButtonKey,
                    onPressed: _promptToSelectApiDemo,
                    icon: Icon(Icons.extension),
                    tooltip: 'API Demos',
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRightToolbar() {
    return AnimatedBuilder(
      animation: _sketchDemoController,
      builder: (context, child) {
        return Align(
          alignment: Alignment(1.0, -0.1),
          child: IconTheme(
            data: IconThemeData(
              color: Colors.white,
            ),
            child: Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Material(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                color: _toolbarColor,
                child: SizedBox(
                  width: 54,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 8),
                      IconButton(
                        key: _saveScreenshotButtonKey,
                        onPressed: _sketchDemoController.hasDemoClient ? _promptToSaveScreenshot : null,
                        icon: Icon(Icons.camera),
                        tooltip: 'Take Screenshot',
                      ),
                      const SizedBox(height: 16),
                      IconButton(
                        key: _saveFramesButtonKey,
                        onPressed: _sketchDemoController.hasDemoClient ? _promptToSaveFrames : null,
                        icon: Icon(Icons.style),
                        tooltip: 'Record Image Frames',
                      ),
                      const SizedBox(height: 16),
                      IconButton(
                        key: _saveGifButtonKey,
                        onPressed: _sketchDemoController.hasDemoClient ? _promptToSaveGif : null,
                        icon: Icon(Icons.videocam),
                        tooltip: 'Record GIF',
                      ),
                      Divider(),
                      IconButton(
                        onPressed: () => _sketchDemoController.client?.restartSketch(),
                        icon: Icon(Icons.refresh),
                        tooltip: 'Restart Sketch',
                      ),
                      Divider(),
                      const SizedBox(height: 8),
                      _buildColorDot(const Color(0xFFFFFFFF), "Background - White"),
                      const SizedBox(height: 12),
                      _buildColorDot(const Color(0xFF222222), "Background - Dark Grey"),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildColorDot(Color color, String colorDescription) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          _sketchDemoController.client?.background = color;
        },
        child: Tooltip(
          message: colorDescription,
          child: Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
              border: Border.all(color: Colors.white, width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.4),
                  blurRadius: 5,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DemoSelectionList extends StatelessWidget {
  const _DemoSelectionList({
    Key? key,
    required this.demoList,
    required this.selectedItem,
  }) : super(key: key);

  final List<DemoMenuItem> demoList;
  final ValueNotifier<DemoMenuItem> selectedItem;

  @override
  Widget build(BuildContext context) {
    if (demoList.isEmpty) {
      return ListTile(
        title: Text("Empty"),
        enabled: false,
      );
    }

    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: 400),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final demo in demoList) ...[
              ListTile(
                title: Text(
                  demo.title,
                  style: TextStyle(
                    fontSize: 14,
                  ),
                ),
                onTap: () {
                  selectedItem.value = demo;
                },
              ),
              Divider(
                height: 1,
                color: const Color(0xFF2A2A2A),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _TakeScreenshotPrompt extends StatefulWidget {
  const _TakeScreenshotPrompt({
    Key? key,
    required this.sketchDemoController,
  }) : super(key: key);

  final SketchDemoController sketchDemoController;

  @override
  _TakeScreenshotPromptState createState() => _TakeScreenshotPromptState();
}

class _TakeScreenshotPromptState extends State<_TakeScreenshotPrompt> {
  ImageFileFormat _imageFormat = ImageFileFormat.png;
  String? _selectedPath;

  Future<void> _selectFilePath() async {
    final filePath = await getSavePath(
      acceptedTypeGroups: [
        XTypeGroup(
          extensions: [_imageFormat.extension],
          mimeTypes: [_imageFormat.mimeType],
        ),
      ],
      suggestedName: 'screenshot',
      confirmButtonText: 'Select',
    );

    if (mounted) {
      setState(() {
        _selectedPath = filePath;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Screenshot',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: _ImageFormatSelector(
              imageFormat: _imageFormat,
              onFormatSelected: (format) {
                setState(() {
                  _imageFormat = format;
                });
              },
            ),
          ),
          SizedBox(height: 16),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.05),
              borderRadius: BorderRadius.circular(4),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Text(
              _selectedPath == null ? 'No file path selected' : _selectedPath!,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                fontSize: 12,
              ),
            ),
          ),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _selectFilePath,
              child: Text('Select Destination'),
            ),
          ),
          SizedBox(height: 16),
          TextButton(
            onPressed: _selectedPath != null
                ? () {
                    widget.sketchDemoController.client?.takeScreenshot(
                      File(_selectedPath!),
                    );
                  }
                : null,
            child: Text('Take Screenshot'),
          ),
        ],
      ),
    );
  }
}

class _GenerateGifPrompt extends StatefulWidget {
  const _GenerateGifPrompt({
    Key? key,
    required this.sketchDemoController,
  }) : super(key: key);

  final SketchDemoController sketchDemoController;

  @override
  _GenerateGifPromptState createState() => _GenerateGifPromptState();
}

class _GenerateGifPromptState extends State<_GenerateGifPrompt> {
  String? _selectedPath;
  int _durationInSeconds = 10;
  int _fps = 30;

  Future<void> _selectFilePath() async {
    final filePath = await getSavePath(
      acceptedTypeGroups: [
        XTypeGroup(
          extensions: ['gif'],
          mimeTypes: ['image/gif'],
        ),
      ],
      suggestedName: 'demo',
      confirmButtonText: 'Select',
    );

    if (mounted) {
      setState(() {
        _selectedPath = filePath;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'GIF',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.05),
                borderRadius: BorderRadius.circular(4),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Text(
                _selectedPath == null ? 'No file path selected' : _selectedPath!,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                  fontSize: 12,
                ),
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _selectFilePath,
                child: Text('Select Destination'),
              ),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Text(
                  'Duration',
                  style: const TextStyle(
                    fontSize: 10,
                  ),
                ),
                Spacer(),
                Text(
                  '${_durationInSeconds}s',
                  style: const TextStyle(
                    fontSize: 10,
                  ),
                ),
              ],
            ),
            Slider.adaptive(
              value: _durationInSeconds.toDouble(),
              min: 1.0,
              max: 60.0,
              onChanged: (newValue) {
                setState(() {
                  _durationInSeconds = newValue.round();
                });
              },
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Text(
                  'Frame Rate',
                  style: const TextStyle(
                    fontSize: 10,
                  ),
                ),
                Spacer(),
                Text(
                  '$_fps FPS',
                  style: const TextStyle(
                    fontSize: 10,
                  ),
                ),
              ],
            ),
            Slider.adaptive(
              value: _fps.toDouble(),
              min: 1,
              max: 120,
              onChanged: (newValue) {
                setState(() {
                  _fps = newValue.round();
                });
              },
            ),
            SizedBox(height: 16),
            TextButton(
              onPressed: _selectedPath != null
                  ? () {
                      widget.sketchDemoController.client?.createGif(
                        file: File(_selectedPath!),
                        duration: Duration(seconds: _durationInSeconds),
                        fps: _fps,
                      );
                    }
                  : null,
              child: Text('Generate GIF'),
            ),
          ],
        ),
      ),
    );
  }
}

class _GenerateScreenshotFramesPrompt extends StatefulWidget {
  const _GenerateScreenshotFramesPrompt({
    Key? key,
    required this.sketchDemoController,
  }) : super(key: key);

  final SketchDemoController sketchDemoController;

  @override
  _GenerateScreenshotFramesPromptState createState() => _GenerateScreenshotFramesPromptState();
}

class _GenerateScreenshotFramesPromptState extends State<_GenerateScreenshotFramesPrompt> {
  ImageFileFormat _imageFormat = ImageFileFormat.png;
  Directory? _selectedDirectory;
  String _titleTemplate = 'frame_###';
  String? _templatePath;
  int _frameCount = 10;

  Future<void> _selectFilePath() async {
    final filePath = await getSavePath(
      acceptedTypeGroups: [
        XTypeGroup(
          extensions: [_imageFormat.extension],
          mimeTypes: [_imageFormat.mimeType],
        ),
      ],
      suggestedName: _titleTemplate,
      confirmButtonText: 'Select',
    );

    if (mounted) {
      setState(() {
        _selectedDirectory = filePath != null ? File(filePath).parent : null;

        if (filePath != null) {
          final fileName = FileName.fromFilePath(filePath);
          _titleTemplate = fileName.name.endsWith('#') ? fileName.name : fileName.name + '_###';
          _templatePath = filePath;
        } else {
          _titleTemplate = 'frame_###';
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Frames',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: _ImageFormatSelector(
                imageFormat: _imageFormat,
                onFormatSelected: (format) {
                  setState(() {
                    _imageFormat = format;
                  });
                },
              ),
            ),
            SizedBox(height: 32),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.05),
                borderRadius: BorderRadius.circular(4),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Text(
                _templatePath == null ? 'No file path selected' : _templatePath!,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                  fontSize: 12,
                ),
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _selectFilePath,
                child: Text('Select Destination'),
              ),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Text(
                  'Frames',
                  style: const TextStyle(
                    fontSize: 10,
                  ),
                ),
                Spacer(),
                Text(
                  '$_frameCount',
                  style: const TextStyle(
                    fontSize: 10,
                  ),
                ),
              ],
            ),
            Slider.adaptive(
              value: _frameCount.toDouble(),
              min: 1,
              max: 60,
              onChanged: (newValue) {
                setState(() {
                  _frameCount = newValue.round();
                });
              },
            ),
            SizedBox(height: 16),
            TextButton(
              onPressed: _templatePath != null
                  ? () {
                      widget.sketchDemoController.client?.startTakingScreenshotFrames(
                        directory: _selectedDirectory!,
                        nameTemplate: _titleTemplate,
                        format: _imageFormat,
                        frameCount: _frameCount,
                      );
                    }
                  : null,
              child: Text('Generate Frames'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ImageFormatSelector extends StatelessWidget {
  const _ImageFormatSelector({
    Key? key,
    required this.imageFormat,
    required this.onFormatSelected,
  }) : super(key: key);

  final ImageFileFormat imageFormat;
  final void Function(ImageFileFormat) onFormatSelected;

  @override
  Widget build(BuildContext context) {
    return CupertinoSegmentedControl(
      padding: EdgeInsets.zero,
      groupValue: imageFormat,
      onValueChanged: onFormatSelected,
      children: {
        ImageFileFormat.png: Text(
          'PNG',
          style: const TextStyle(
            fontSize: 8,
          ),
        ),
        ImageFileFormat.jpeg: Text(
          'JPEG',
          style: const TextStyle(
            fontSize: 8,
          ),
        ),
        ImageFileFormat.tiff: Text(
          'TIFF',
          style: const TextStyle(
            fontSize: 8,
          ),
        ),
        ImageFileFormat.targa: Text(
          'TARGA',
          style: const TextStyle(
            fontSize: 8,
          ),
        ),
      },
    );
  }
}

/// A group of demos.
class DemoMenuGroup {
  const DemoMenuGroup({
    required this.title,
    required this.items,
  });

  /// Title of the group of demos.
  final String title;

  /// List items of the demos in the group.
  final List<DemoMenuItem> items;
}

/// An item in a list of demos within [ProcessingDemosScreen].
class DemoMenuItem {
  const DemoMenuItem({
    this.icon,
    required this.title,
    this.subtitle,
    required this.builder,
  });

  final IconData? icon;
  final String title;
  final String? subtitle;
  final Widget Function(BuildContext, SketchDemoController) builder;
}
