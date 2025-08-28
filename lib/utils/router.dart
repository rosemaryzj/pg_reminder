import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../pages/login_page.dart';
import '../pages/main_layout.dart';
import '../pages/projects_page.dart';
import '../pages/analytics_page.dart';
import '../pages/settings_page.dart';
import '../pages/project_detail_page.dart';
import '../pages/module_detail_page.dart';
import '../services/app_state.dart';

// 自定义页面过渡动画类
class CustomTransitionPage<T> extends Page<T> {
  const CustomTransitionPage({
    required this.child,
    this.transitionDuration = const Duration(milliseconds: 300),
    this.transitionsBuilder,
    super.key,
    super.name,
    super.arguments,
    super.restorationId,
  });

  final Widget child;
  final Duration transitionDuration;
  final Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)? transitionsBuilder;

  @override
  Route<T> createRoute(BuildContext context) {
    return PageRouteBuilder<T>(
      settings: this,
      transitionDuration: transitionDuration,
      pageBuilder: (context, animation, _) => child,
      transitionsBuilder: transitionsBuilder ?? _defaultTransitionsBuilder,
    );
  }

  Widget _defaultTransitionsBuilder(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return FadeTransition(
      opacity: animation,
      child: child,
    );
  }
}

final router = GoRouter(
  initialLocation: '/login',
  redirect: (context, state) {
    final isLoggedIn = ProviderScope.containerOf(
      context,
    ).read(appStateProvider).isLoggedIn;

    final isLoginPage = state.matchedLocation == '/login';

    if (!isLoggedIn && !isLoginPage) {
      return '/login';
    }

    if (isLoggedIn && isLoginPage) {
      return '/';
    }

    return null;
  },
  routes: [
    GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
    ShellRoute(
      builder: (context, state, child) => MainLayout(child: child),
      routes: [
        GoRoute(path: '/', redirect: (context, state) => '/projects'),
        GoRoute(
          path: '/projects',
          pageBuilder: (context, state) => CustomTransitionPage(
            key: state.pageKey,
            child: const ProjectsPage(),
            transitionDuration: const Duration(milliseconds: 200),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
          ),
        ),
        GoRoute(
          path: '/project/:projectId',
          builder: (context, state) {
            final projectId = state.pathParameters['projectId']!;
            return ProjectDetailPage(projectId: projectId);
          },
          routes: [
            GoRoute(
              path: 'module/:moduleId',
              builder: (context, state) {
                final projectId = state.pathParameters['projectId']!;
                final moduleId = state.pathParameters['moduleId']!;
                return ModuleDetailPage(
                  projectId: projectId,
                  moduleId: moduleId,
                );
              },
            ),
          ],
        ),
        GoRoute(
          path: '/analytics',
          pageBuilder: (context, state) => CustomTransitionPage(
            key: state.pageKey,
            child: const AnalyticsPage(),
            transitionDuration: const Duration(milliseconds: 200),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
          ),
        ),
        GoRoute(
          path: '/settings',
          pageBuilder: (context, state) => CustomTransitionPage(
            key: state.pageKey,
            child: const SettingsPage(),
            transitionDuration: const Duration(milliseconds: 200),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
          ),
        ),
      ],
    ),
  ],
);
