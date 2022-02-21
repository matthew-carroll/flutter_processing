import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart' hide Image;
import 'package:flutter_processing/flutter_processing.dart';
import 'package:flutter_processing_example/_demos_screen.dart';
import 'package:flutter_processing_example/io/gif.dart';
import 'package:image/image.dart' as imageFormats;
import 'package:path/path.dart' as path;

/// Controller that connects [ProcessingDemosScreen] to a [SketchDemo]
/// so that the screen can request that the demo take screenshots.
class SketchDemoController with ChangeNotifier {
  bool get hasDemoClient => _client != null;

  SketchDemo? _client;
  SketchDemo? get client => _client;
  set client(SketchDemo? demo) {
    if (demo != _client) {
      _client = demo;
      notifyListeners();
    }
  }

  // This method was added to deal with an issue in AnimatedBuilder.
  // The `client` is set in various widget methods, e.g., initState(),
  // didUpdateWidget(), and dispose(). AnimatedBuilder immediately invokes
  // setState() without checking whether that's a legal call, and it's
  // not a legal call during lifecycle methods, which results in an
  // error. Therefore, this method allows setting the client without
  // notifying listeners so that this error doesn't come up.
  void setClientWithoutNotifications(SketchDemo? demo) {
    if (demo != _client) {
      _client = demo;
    }
  }
}

/// A Processing sketch demo, which is capable of generating various
/// screenshots.
abstract class SketchDemo {
  set background(Color color);

  void restartSketch();

  Future<void> takeScreenshot(File file);

  Future<void> createGif({
    required File file,
    required Duration duration,
    required int fps,
  });

  Future<void> startTakingScreenshotFrames({
    required Directory directory,
    required String nameTemplate,
    required ImageFileFormat format,
    required int frameCount,
  });
}

class ScreenshotsInProgressException {}

class ProcessingDemo extends StatefulWidget {
  ProcessingDemo({
    Key? key,
    this.sketchFocusNode,
    required this.createSketch,
    required this.sketchDemoController,
  }) : super(key: key ?? ObjectKey(createSketch));

  final FocusNode? sketchFocusNode;
  final SketchFactory createSketch;
  final SketchDemoController sketchDemoController;

  @override
  ProcessingDemoState createState() => ProcessingDemoState();
}

class ProcessingDemoState extends State<ProcessingDemo> with SingleTickerProviderStateMixin implements SketchDemo {
  late _CountdownController _screenshotCountdown;

  Completer<void>? _screenshotCompleter;
  File? _fileToSaveImage;

  Completer<void>? _gifCompleter;
  GifGenerator? _gifGenerator;
  File? _gifFile;

  Completer<void>? _screenshotFrameCompleter;
  Directory? _dirToSaveFrames;
  String? _frameNameTemplate;
  ImageFileFormat? _frameFormat;
  int _remainingFrames = 0;

  Sketch? _sketch;

  Color _backgroundColor = const Color(0xFFFFFFFF);

  @override
  void initState() {
    super.initState();
    _initSketch();

    widget.sketchDemoController.setClientWithoutNotifications(this);

    _screenshotCountdown = _CountdownController(vsync: this);
  }

  @override
  void didUpdateWidget(ProcessingDemo oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.sketchDemoController != oldWidget.sketchDemoController) {
      oldWidget.sketchDemoController.setClientWithoutNotifications(null);
      widget.sketchDemoController.setClientWithoutNotifications(this);
    }
  }

  @override
  void dispose() {
    // Before null'ing the sketch demo client, make sure that we're
    // still the client so that we don't inadvertently interfere with
    // another sketch demo.
    if (widget.sketchDemoController.client == this) {
      widget.sketchDemoController.setClientWithoutNotifications(null);
    }

    _screenshotCountdown.dispose();

    _disposeSketch();
    super.dispose();
  }

  @override
  set background(Color color) {
    setState(() {
      _backgroundColor = color;
    });
  }

  @override
  void restartSketch() {
    setState(() {
      if (_sketch != null) {
        _sketch!.dispose();
        _sketch = null;
      }

      _initSketch();
    });
  }

  @override
  Future<void> takeScreenshot(File file) {
    print('Starting screenshot countdown');

    final completer = Completer();

    _screenshotCountdown.start(
      countdownTotal: const Duration(seconds: 3),
      onComplete: () {
        _doTakeScreenshot(file, completer);
      },
    );

    return completer.future;
  }

  Future<void> _doTakeScreenshot(File file, Completer<void> completer) {
    print('Taking a screenshot');
    _ensureScreenshotsNotInProgress();

    _fileToSaveImage = file;
    _screenshotCompleter = completer;

    if (!_sketch!.isLooping) {
      if (_sketch!.publishedFrame == null) {
        print("Can't take screenshot because the Sketch isn't looping and frame is available.");
        _screenshotCompleter!.complete();
      } else {
        _onSketchFrameAvailable(_sketch!.publishedFrame!);
      }
    }

    return _screenshotCompleter!.future;
  }

  @override
  Future<void> createGif({
    required File file,
    required Duration duration,
    required int fps,
  }) {
    print('Starting GIF countdown');

    final completer = Completer();

    _screenshotCountdown.start(
      countdownTotal: const Duration(seconds: 3),
      onComplete: () {
        _doCreateGif(
          file: file,
          duration: duration,
          fps: fps,
          completer: completer,
        );
      },
    );

    return completer.future;
  }

  Future<void> _doCreateGif({
    required File file,
    required Duration duration,
    required int fps,
    required Completer<void> completer,
  }) {
    print('Creating GIF');
    _ensureScreenshotsNotInProgress();

    if (!_sketch!.isLooping) {
      print("Can't generate a GIF because the Sketch isn't looping");
      return Future.value();
    }

    _gifFile = file;
    _gifGenerator = GifGenerator(
      totalDesiredFrameCount: fps * duration.inSeconds,
      gifFrameRateFps: fps,
    );

    _gifCompleter = completer;
    return completer.future;
  }

  @override
  Future<void> startTakingScreenshotFrames({
    required Directory directory,
    required String nameTemplate,
    required ImageFileFormat format,
    required int frameCount,
  }) {
    print('Starting screenshot frames countdown');

    final completer = Completer();

    _screenshotCountdown.start(
      countdownTotal: const Duration(seconds: 3),
      onComplete: () {
        _doStartTakingScreenshotFrames(
          directory: directory,
          nameTemplate: nameTemplate,
          format: format,
          frameCount: frameCount,
          completer: completer,
        );
      },
    );

    return completer.future;
  }

  Future<void> _doStartTakingScreenshotFrames({
    required Directory directory,
    required String nameTemplate,
    required ImageFileFormat format,
    required int frameCount,
    required Completer<void> completer,
  }) {
    print('Taking screenshot frames');
    _ensureScreenshotsNotInProgress();

    if (!_sketch!.isLooping) {
      print("Can't generate frames because the Sketch isn't looping");
      return Future.value();
    }

    _dirToSaveFrames = directory;
    _frameNameTemplate = nameTemplate.endsWith(format.extension) ? nameTemplate : '$nameTemplate.${format.extension}';
    _frameFormat = format;
    _remainingFrames = frameCount;
    _screenshotFrameCompleter = completer;
    return completer.future;
  }

  void _ensureScreenshotsNotInProgress() {
    if (_screenshotCompleter != null || _gifCompleter != null || _screenshotFrameCompleter != null) {
      throw ScreenshotsInProgressException();
    }
  }

  Future<void> _onSketchFrameAvailable(Image frame) async {
    if (_screenshotCompleter != null) {
      // TODO: can we improve the timing here? We collect the needed info
      //       so that we null out the _screenshotCompleter, so that this
      //       method doesn't try to save yet another screenshot on the next
      //       frame.
      final fileToSaveImage = _fileToSaveImage!;
      _fileToSaveImage = null;

      final screenshotCompleter = _screenshotCompleter!;
      _screenshotCompleter = null;

      await _save(file: fileToSaveImage, image: frame);
      screenshotCompleter.complete();
    } else if (_screenshotFrameCompleter != null && _remainingFrames > 0) {
      await _saveFrame(
        directory: _dirToSaveFrames!,
        namingPattern: _frameNameTemplate!,
        format: _frameFormat!,
        image: frame,
      );

      _remainingFrames -= 1;

      // Note: If the sketch is no longer looping then we won't get
      // another opportunity to add to the GIF. We need to complete it early.
      final timeToSave = _remainingFrames == 0 || !_sketch!.isLooping;

      if (timeToSave) {
        _screenshotFrameCompleter!.complete();
        _dirToSaveFrames = null;
        _screenshotFrameCompleter = null;
      }
    } else if (_gifCompleter != null) {
      print('Adding GIF frame');
      await _gifGenerator!.addFrame(frame);

      // Note: If the sketch is no longer looping then we won't get
      // another opportunity to add to the GIF. We need to complete it early.
      final timeToSave = (_gifGenerator!.isDoneAddingFrames || !_sketch!.isLooping) && !_gifGenerator!.hasSavedToFile;

      if (timeToSave) {
        print('Completing GIF and saving');
        await _gifGenerator!.saveGif(
          _gifFile!,
        );

        _gifCompleter!.complete();
        _gifGenerator = null;
        _gifCompleter = null;
      }
    }
  }

  Future<void> _save({
    required File file,
    ImageFileFormat? format,
    required Image image,
  }) async {
    late ImageFileFormat imageFormat;
    if (format != null) {
      imageFormat = format;
    } else {
      final imageFormatFromFile = _getImageFileFormatFromFilePath(file.path);
      if (imageFormatFromFile == null) {
        throw Exception('Cannot save image to file with invalid extension and no explicit image type: ${file.path}');
      }
      imageFormat = imageFormatFromFile;
    }

    // Retrieve the pixel data for the current sketch painting.
    final frameBytes = await image.toByteData();
    final rawImageData = frameBytes!.buffer.asUint8List();

    // Convert the pixel data to the desired format.
    late List<int> formattedImageData;
    switch (imageFormat) {
      case ImageFileFormat.png:
        formattedImageData = imageFormats.encodePng(
          imageFormats.Image.fromBytes(image.width, image.height, rawImageData),
        );
        break;
      case ImageFileFormat.jpeg:
        formattedImageData = imageFormats.encodeJpg(
          imageFormats.Image.fromBytes(image.width, image.height, rawImageData),
        );
        break;
      case ImageFileFormat.tiff:
        throw UnimplementedError('Tiff images are not supported in save()');
      case ImageFileFormat.targa:
        formattedImageData = imageFormats.encodeTga(
          imageFormats.Image.fromBytes(image.width, image.height, rawImageData),
        );
        break;
    }

    // Write the formatted pixels to the given file.
    await file.writeAsBytes(formattedImageData);
  }

  Future<void> _saveFrame({
    required Directory directory,
    String namingPattern = 'screen-####.png',
    ImageFileFormat? format,
    required Image image,
  }) async {
    late ImageFileFormat imageFormat;
    if (format != null) {
      imageFormat = format;
    } else {
      final imageFormatFromFile = _getImageFileFormatFromFilePath(namingPattern);
      if (imageFormatFromFile == null) {
        throw Exception('Cannot save image to file with invalid extension and no explicit image type: $namingPattern');
      }
      imageFormat = imageFormatFromFile;
    }

    final hashMatcher = RegExp('(#)+');
    final hashMatches = hashMatcher.allMatches(namingPattern);
    if (hashMatches.isEmpty) {
      throw Exception('namingPattern is missing a hash pattern');
    } else if (hashMatches.length > 1) {
      throw Exception(
          'namingPattern has too many hash patterns in it. There must be exactly one series of hashes in namingPattern.');
    }

    final digitCount = hashMatches.first.end - hashMatches.first.start;

    int index = 0;
    late File file;
    do {
      final fileName = namingPattern.replaceAll(hashMatcher, '$index'.padLeft(digitCount, '0'));
      file = File('${directory.path}${Platform.pathSeparator}$fileName');
      index += 1;
    } while (file.existsSync());

    await _save(file: file, format: imageFormat, image: image);
  }

  ImageFileFormat? _getImageFileFormatFromFilePath(String filePath) {
    final fileExtension = path.extension(filePath);
    switch (fileExtension) {
      case '.png':
        return ImageFileFormat.png;
      case '.jpg':
        return ImageFileFormat.jpeg;
      case '.tif':
        return ImageFileFormat.tiff;
      case '.tga':
        return ImageFileFormat.targa;
      default:
        return null;
    }
  }

  void _initSketch() {
    if (_sketch == null) {
      _sketch = widget.createSketch();
      _sketch!.addOnFrameAvailableCallback(_onSketchFrameAvailable);
    }

    // Give focus to the sketch so that keyboard keys flow to it.
    widget.sketchFocusNode?.requestFocus();
  }

  void _disposeSketch() {
    _sketch?.removeOnFrameAvailableCallback(_onSketchFrameAvailable);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      body: Stack(
        children: [
          Center(
            child: Processing(
              focusNode: widget.sketchFocusNode,
              sketch: _sketch!,
            ),
          ),
          _buildCountdownDisplay(),
        ],
      ),
    );
  }

  Widget _buildCountdownDisplay() {
    return AnimatedBuilder(
      animation: _screenshotCountdown,
      builder: (context, child) {
        return AnimatedAlign(
          alignment: _screenshotCountdown.isCountingDown ? Alignment.topCenter : Alignment(0.0, -1.4),
          duration: const Duration(milliseconds: 150),
          child: child,
        );
      },
      child: Padding(
        padding: const EdgeInsets.only(top: 24.0),
        child: _CountdownDisplay(
          controller: _screenshotCountdown,
        ),
      ),
    );
  }
}

typedef SketchFactory = Sketch Function();

class _CountdownDisplay extends StatefulWidget {
  const _CountdownDisplay({
    Key? key,
    required this.controller,
  }) : super(key: key);

  final _CountdownController controller;

  @override
  _CountdownDisplayState createState() => _CountdownDisplayState();
}

class _CountdownDisplayState extends State<_CountdownDisplay> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 300,
      height: 48,
      child: Material(
        color: const Color(0xFF333333),
        borderRadius: BorderRadius.circular(8),
        elevation: 5,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: AnimatedBuilder(
              animation: widget.controller,
              builder: (context, child) {
                return LinearProgressIndicator(
                  value: widget.controller.countdownPercent,
                  color: Colors.yellow,
                  backgroundColor: Colors.black,
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _CountdownController with ChangeNotifier {
  _CountdownController({
    required TickerProvider vsync,
  }) : _timerController = AnimationController(vsync: vsync) {
    _timerController
      ..addListener(() {
        notifyListeners();
      })
      ..addStatusListener(_onAnimationStatusChange);
  }

  @override
  void dispose() {
    _timerController.dispose();
    super.dispose();
  }

  AnimationController _timerController;
  VoidCallback? _onComplete;

  bool get isCountingDown => _timerController.isAnimating;

  Duration get countdownDuration => _countdownTotal != null
      ? Duration(milliseconds: (_countdownTotal!.inMilliseconds * countdownPercent).round())
      : Duration.zero;

  double get countdownPercent => _countdownTotal != null ? _timerController.value : 0.0;

  Duration? _countdownTotal;
  Duration? get countdownTotal => _countdownTotal;

  void _onAnimationStatusChange(newStatus) {
    if (newStatus == AnimationStatus.completed) {
      _onComplete?.call();
    }
  }

  void start({
    required Duration countdownTotal,
    required VoidCallback onComplete,
  }) {
    _countdownTotal = countdownTotal;
    _onComplete = onComplete;

    _timerController
      ..duration = _countdownTotal
      ..forward(from: 0);
  }

  void cancel() {
    _timerController.stop();
  }
}
