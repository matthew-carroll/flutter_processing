import 'dart:ui';

import 'package:flutter/material.dart' hide Image;
import 'package:flutter_processing_example/demos/_hacking.dart';
import 'package:patterns_canvas/patterns_canvas.dart';
import 'package:popover/popover.dart';

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
      title: 'Example',
      builder: (_, __) {
        return HackingDemo(sketchDemoController: SketchDemoController());
      });

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
    )..addListener(() {
        setState(() {});
      });
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
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Save a screenshot'),
              TextButton(
                onPressed: () {},
                child: Text('Save Image'),
              ),
            ],
          ),
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
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Save GIF'),
              TextButton(
                onPressed: () {},
                child: Text('Save GIF'),
              ),
            ],
          ),
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
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Save Frames'),
              TextButton(
                onPressed: () {},
                child: Text('Save Frames'),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        _menuItem.builder(context, _sketchDemoController),
        ..._buildDrawer(),
        _buildLeftToolbar(),
        _buildRightToolbar(),
      ],
    );
  }

  List<Widget> _buildDrawer() {
    return [
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
    ];
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
  }

  Widget _buildRightToolbar() {
    return Positioned(
      top: 0,
      bottom: 0,
      right: 0,
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
                Spacer(flex: 10),
                IconButton(
                  key: _saveScreenshotButtonKey,
                  onPressed: _promptToSaveScreenshot,
                  icon: Icon(Icons.image),
                  tooltip: 'Screenshot',
                ),
                Spacer(flex: 2),
                IconButton(
                  key: _saveGifButtonKey,
                  onPressed: _promptToSaveGif,
                  icon: Icon(Icons.videocam),
                  tooltip: 'GIF',
                ),
                Spacer(flex: 2),
                IconButton(
                  key: _saveFramesButtonKey,
                  onPressed: _promptToSaveFrames,
                  icon: Icon(Icons.style),
                  tooltip: 'Image Frames',
                ),
                Spacer(flex: 10),
              ],
            ),
          ),
        ),
      ),
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
}

/// A Processing sketch demo, which is capable of generating various
/// screenshots.
abstract class SketchDemo {
  Future<Image> takeScreenshot();

  Future<List<int>> createGif();

  Stream<Image> startTakingScreenshotFrames();
}

class ScreenshotsInProgressException {}
