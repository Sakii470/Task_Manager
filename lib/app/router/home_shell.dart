import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'bottom_nav.dart';

class HomeShell extends StatelessWidget {
  final Widget child;
  final String location;
  const HomeShell({Key? key, required this.child, required this.location}) : super(key: key);

  int _indexForLocation() {
    if (location.startsWith('/statistics')) return 1;
    return 0;
  }

  void _onTap(BuildContext context, int i) {
    switch (i) {
      case 0:
        if (!location.startsWith('/tasks')) context.go('/tasks');
        break;
      case 1:
        if (!location.startsWith('/statistics')) context.go('/statistics');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final idx = _indexForLocation();
    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNav(currentIndex: idx, onTap: (i) => _onTap(context, i)),
    );
  }
}
