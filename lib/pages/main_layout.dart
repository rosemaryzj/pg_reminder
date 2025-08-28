import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../services/app_state.dart';

class MainLayout extends ConsumerStatefulWidget {
  final Widget child;

  const MainLayout({super.key, required this.child});

  @override
  ConsumerState<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends ConsumerState<MainLayout> {
  final List<NavigationItem> _navigationItems = [
    NavigationItem(
      icon: Icons.dashboard_outlined,
      selectedIcon: Icons.dashboard,
      label: '项目',
      route: '/projects',
    ),
    NavigationItem(
      icon: Icons.analytics_outlined,
      selectedIcon: Icons.analytics,
      label: '分析',
      route: '/analytics',
    ),
    NavigationItem(
      icon: Icons.settings_outlined,
      selectedIcon: Icons.settings,
      label: '设置',
      route: '/settings',
    ),
  ];

  int _getCurrentIndex() {
    final location = GoRouterState.of(context).matchedLocation;
    
    // 根据当前路由确定选中的tab索引
    if (location.startsWith('/projects') || location.startsWith('/project')) {
      return 0;
    } else if (location.startsWith('/analytics')) {
      return 1;
    } else if (location.startsWith('/settings')) {
      return 2;
    }
    return 0; // 默认选中项目tab
  }

  void _onItemTapped(int index) {
    context.go(_navigationItems[index].route);
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(appStateProvider);
    final currentIndex = _getCurrentIndex();

    return Scaffold(
      body: widget.child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: _onItemTapped,
        destinations: _navigationItems
            .map(
              (item) => NavigationDestination(
                icon: Icon(item.icon),
                selectedIcon: Icon(item.selectedIcon),
                label: item.label,
              ),
            )
            .toList(),
      ),
    );
  }
}

class NavigationItem {
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final String route;

  NavigationItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.route,
  });
}
