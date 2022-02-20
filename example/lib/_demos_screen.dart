import 'dart:io';
import 'dart:ui';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/cupertino.dart' hide Image;
import 'package:flutter/material.dart' hide Image;
import 'package:flutter_processing/flutter_processing.dart';
import 'package:flutter_processing_example/io/_files.dart';
import 'package:patterns_canvas/patterns_canvas.dart';
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
  final _exampleDemoListItem = DemoMenuItem(
    title: 'Empty Sketch',
    builder: (context, sketchController) {
      return EmptySketchDemo(
        sketchDemoController: sketchController,
      );
    },
  );

  final _saveScreenshotButtonKey = GlobalKey();
  final _saveGifButtonKey = GlobalKey();
  final _saveFramesButtonKey = GlobalKey();

  final _drawerWidth = 250.0;
  late AnimationController _drawerController;
  late Animation _drawerAnimation;

  final _sketchDemoController = SketchDemoController();
  late DemoMenuItem _menuItem;

  @override
  void initState() {
    super.initState();

    _drawerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _drawerAnimation = CurvedAnimation(
      parent: _drawerController,
      curve: Curves.easeOut,
      reverseCurve: Curves.easeIn,
    );

    _menuItem = _exampleDemoListItem;
  }

  @override
  void dispose() {
    _drawerController.dispose();

    super.dispose();
  }

  void _openDemoDrawer() {
    _drawerController.forward();
  }

  void _closeDemoDrawer() {
    _drawerController.reverse();
  }

  void _promptToSaveScreenshot() {
    showPopover(
      context: _saveScreenshotButtonKey.currentContext!,
      direction: PopoverDirection.right,
      width: 200,
      bodyBuilder: (context) {
        return _TakeScreenshotPrompt(
          sketchDemoController: _sketchDemoController,
        );
      },
    );
  }

  void _promptToSaveGif() {
    showPopover(
      context: _saveGifButtonKey.currentContext!,
      direction: PopoverDirection.right,
      width: 200,
      bodyBuilder: (context) {
        return _GenerateGifPrompt(
          sketchDemoController: _sketchDemoController,
        );
      },
    );
  }

  void _promptToSaveFrames() {
    showPopover(
      context: _saveFramesButtonKey.currentContext!,
      direction: PopoverDirection.right,
      width: 200,
      bodyBuilder: (context) {
        return _GenerateScreenshotFramesPrompt(
          sketchDemoController: _sketchDemoController,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        _menuItem.builder(context, _sketchDemoController),
        _buildDrawer(),
        _buildLeftToolbar(),
        _buildSketchSelectionToolbar(),
        _buildRightToolbar(),
      ],
    );
  }

  Widget _buildDrawer() {
    return AnimatedBuilder(
        animation: _drawerController,
        builder: (context, child) {
          return Stack(children: [
            if (_drawerAnimation.value > 0)
              GestureDetector(
                onTap: _closeDemoDrawer,
                child: Container(
                  width: double.infinity,
                  height: double.infinity,
                  color: Colors.transparent,
                ),
              ),
            Positioned(
              top: 0,
              bottom: 0,
              left: (1 - _drawerAnimation.value) * -_drawerWidth,
              child: Theme(
                data: ThemeData.dark(),
                child: Material(
                  child: CustomPaint(
                    painter: _DrawerPatternPainter(),
                    child: Container(
                      width: _drawerWidth,
                      child: Center(
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              for (final group in widget.demos) ...[
                                _menuGroupHeader(title: group.title),
                                for (var i = 0; i < group.items.length; i += 1) ...[
                                  Container(
                                    color: const Color(0xFF303030),
                                    child: ListTile(
                                      title: Text(
                                        group.items[i].title,
                                        style: TextStyle(
                                          fontSize: 14,
                                        ),
                                      ),
                                      onTap: () {
                                        setState(() {
                                          _menuItem = group.items[i];
                                        });
                                      },
                                    ),
                                  ),
                                  Divider(
                                    height: 1,
                                    color: const Color(0xFF2A2A2A),
                                  ),
                                  if (i == group.items.length - 1)
                                    Container(
                                      height: 24,
                                      color: const Color(0xFF303030),
                                    ),
                                ],
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ]);
        });
  }

  Widget _menuGroupHeader({
    required String title,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      color: const Color(0xFF202020),
      child: Text(
        title,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: const Color(0xFFAAAAAA),
          fontSize: 10,
        ),
      ),
    );
  }

  Widget _buildLeftToolbar() {
    return AnimatedBuilder(
        animation: _drawerController,
        builder: (context, child) {
          return Positioned(
            top: 0,
            bottom: 0,
            left: _drawerAnimation.value * _drawerWidth,
            child: IconTheme(
              data: IconThemeData(
                color: Colors.white,
              ),
              child: Material(
                color: Color(0xFF333333),
                child: SizedBox(
                  width: 54,
                  child: Column(
                    children: [
                      Spacer(),
                      IconButton(
                        onPressed: _drawerAnimation.value > 0 ? _closeDemoDrawer : _openDemoDrawer,
                        icon: Icon(_drawerAnimation.value > 0 ? Icons.arrow_back_ios : Icons.arrow_forward_ios),
                      ),
                      Spacer(),
                    ],
                  ),
                ),
              ),
            ),
          );
        });
  }

  Widget _buildSketchSelectionToolbar() {
    return Align(
      alignment: Alignment(-1.0, -0.1),
      child: IconTheme(
        data: IconThemeData(
          color: Colors.white,
        ),
        child: Padding(
          padding: const EdgeInsets.only(left: 72.0),
          child: Material(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            color: Color(0xFF333333),
            child: SizedBox(
              width: 54,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 8),
                  IconButton(
                    onPressed: () {},
                    icon: Icon(Icons.insert_drive_file),
                    tooltip: 'Your Sketch',
                  ),
                  const SizedBox(height: 24),
                  IconButton(
                    onPressed: () {},
                    icon: Icon(Icons.color_lens),
                    tooltip: 'Generative Art',
                  ),
                  const SizedBox(height: 24),
                  IconButton(
                    onPressed: () {},
                    icon: Icon(Icons.train),
                    tooltip: 'The Coding Train',
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
                  color: Color(0xFF333333),
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
                          tooltip: 'Screenshot',
                        ),
                        const SizedBox(height: 24),
                        IconButton(
                          key: _saveFramesButtonKey,
                          onPressed: _sketchDemoController.hasDemoClient ? _promptToSaveFrames : null,
                          icon: Icon(Icons.style),
                          tooltip: 'Image Frames',
                        ),
                        const SizedBox(height: 24),
                        IconButton(
                          key: _saveGifButtonKey,
                          onPressed: _sketchDemoController.hasDemoClient ? _promptToSaveGif : null,
                          icon: Icon(Icons.videocam),
                          tooltip: 'GIF',
                        ),
                        const SizedBox(height: 24),
                        IconButton(
                          onPressed: () {},
                          icon: Icon(Icons.refresh),
                          tooltip: 'Restart',
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        });
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
                color: Colors.black.withOpacity(0.5),
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
                  color: Colors.black.withOpacity(0.5),
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
                  color: Colors.black.withOpacity(0.5),
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

class _DrawerPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    DiagonalStripesThick(
      bgColor: const Color(0xFF2A2A2A),
      fgColor: const Color(0xFF303030),
      featuresCount: 100,
    ).paintOnRect(canvas, size, Offset.zero & size);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
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
