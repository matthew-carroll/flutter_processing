import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:patterns_canvas/patterns_canvas.dart';

/// Screen that displays one of many demos.
///
/// Multiple demos are available in a drawer.
class AppScreen extends StatefulWidget {
  const AppScreen({
    Key? key,
    required this.menu,
    required this.initialActiveMenuItem,
  }) : super(key: key);

  final List<DemoMenuGroup> menu;
  final DemoMenuItem initialActiveMenuItem;

  @override
  _AppScreenState createState() => _AppScreenState();
}

class _AppScreenState extends State<AppScreen> with SingleTickerProviderStateMixin {
  final _drawerOverhangColor = const Color(0xFF333333);
  final _drawerOverhangWidth = 48.0;
  final _drawerWidth = 250.0;

  Color _backgroundColor = const Color(0xFF111111);

  late AnimationController _animationController;
  late CurvedAnimation _drawerAnimation;

  late DemoMenuItem _activeMenuItem;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _drawerAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    _activeMenuItem = widget.initialActiveMenuItem;
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _setBackgroundColor(Color newColor) {
    if (newColor != _backgroundColor) {
      setState(() {
        _backgroundColor = newColor;
      });
    }
  }

  void _toggleDrawer() {
    if (!_animationController.isAnimating) {
      if (_animationController.value > 0) {
        _closeDrawer();
      } else {
        _openDrawer();
      }
    }
  }

  void _openDrawer() {
    _animationController.forward();
  }

  void _closeDrawer() {
    _animationController.reverse();
  }

  void _showDemo(DemoMenuItem menuItem) {
    if (menuItem != _activeMenuItem) {
      setState(() {
        _activeMenuItem = menuItem;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: _backgroundColor,
      ),
      child: Stack(
        children: [
          _activeMenuItem.pageBuilder(context),
          _buildBackgroundColorChooser(),
          _buildDrawerTapToClose(),
          _buildDrawer(),
        ],
      ),
    );
  }

  Widget _buildBackgroundColorChooser() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 24),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildBackgroundColorDot(
              color: const Color(0xFF111111),
            ),
            SizedBox(width: 24),
            _buildBackgroundColorDot(
              color: const Color(0xFFFFFFFF),
            ),
            SizedBox(width: 24),
            _buildBackgroundColorDot(
              color: const Color(0xFFFFFF00),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackgroundColorDot({
    required Color color,
  }) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          _setBackgroundColor(color);
        },
        child: Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
            border: Border.all(color: Colors.white, width: 3),
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
    );
  }

  Widget _buildDrawerTapToClose() {
    return AnimatedBuilder(
      animation: _drawerAnimation,
      builder: (context, child) {
        return _drawerAnimation.value > 0
            ? GestureDetector(
                onTap: _closeDrawer,
                child: Container(
                  width: double.infinity,
                  height: double.infinity,
                  color: Colors.transparent,
                ),
              )
            : SizedBox();
      },
    );
  }

  Widget _buildDrawer() {
    return AnimatedBuilder(
      animation: _drawerAnimation,
      builder: (context, child) {
        return Positioned(
          top: 0,
          bottom: 0,
          left: (_drawerAnimation.value - 1) * _drawerWidth,
          child: Theme(
            data: ThemeData.dark(),
            child: Material(
              color: _drawerOverhangColor,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildDrawerContent(),
                  _buildDrawerOverhang(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDrawerOverhang() {
    return SizedBox(
      width: _drawerOverhangWidth,
      child: Center(
        child: IconButton(
          icon: Icon(_drawerAnimation.value > 0 ? Icons.chevron_left : Icons.chevron_right),
          onPressed: _toggleDrawer,
        ),
      ),
    );
  }

  Widget _buildDrawerContent() {
    return CustomPaint(
      painter: _DrawerPatternPainter(),
      child: SizedBox(
        width: _drawerWidth,
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final group in widget.menu) ...[
                  _buildMenuGroupHeader(title: group.title),
                  for (final item in group.items) ...[
                    _buildMenuItem(item),
                    Divider(
                      height: 1,
                      color: const Color(0xFF2A2A2A),
                    ),
                  ],
                  Container(
                    height: 24,
                    color: const Color(0xFF303030),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuGroupHeader({
    required String title,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      color: const Color(0xFF202020),
      child: Text(
        title,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: const Color(0xFFAAAAAA),
          fontSize: 10,
        ),
      ),
    );
  }

  Widget _buildMenuItem(DemoMenuItem item) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: const Color(0xFF303030),
      ),
      child: ListTile(
        title: Text(
          item.title,
          style: const TextStyle(
            fontSize: 14,
          ),
        ),
        onTap: () {
          _showDemo(item);
        },
      ),
    );
  }
}

class _DrawerPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Pattern pattern = DiagonalStripesThick(
      bgColor: const Color(0xFF2A2A2A),
      fgColor: const Color(0xFF303030),
      featuresCount: 100,
    );

    pattern.paintOnRect(canvas, size, Offset.zero & size);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

/// Group of demo menu items, with a title.
class DemoMenuGroup {
  const DemoMenuGroup({
    required this.title,
    required this.items,
  });

  /// Title of the group of demos.
  final String title;

  /// The menu items for each demo in the group.
  final List<DemoMenuItem> items;
}

/// Menu item for a single Processing demo.
class DemoMenuItem {
  const DemoMenuItem({
    this.icon,
    required this.title,
    this.subtitle,
    required this.pageBuilder,
  });

  /// Icon that represents the demo.
  final IconData? icon;

  /// Title of the demo.
  final String title;

  /// Secondary information about the demo.
  final String? subtitle;

  /// `WidgetBuilder` that creates the demo.
  final WidgetBuilder pageBuilder;
}
