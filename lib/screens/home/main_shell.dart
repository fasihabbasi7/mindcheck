import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../widgets/bottom_navigation.dart';

/// Frame around the four main tabs: shows the current tab and the
/// floating bottom navigation bar.
class MainShell extends StatelessWidget {
  const MainShell({super.key, required this.navigationShell});

  /// Provided by GoRouter's StatefulShellRoute. Knows which tab is open.
  final StatefulNavigationShell navigationShell;

  void _onTabSelected(int index) {
    navigationShell.goBranch(
      index,
      // Tapping the tab you are already on takes you back to its first page.
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Lets tab content scroll behind the floating navigation bar.
      extendBody: true,
      body: navigationShell,
      bottomNavigationBar: MindBottomNav(
        currentIndex: navigationShell.currentIndex,
        onTap: _onTabSelected,
      ),
    );
  }
}
