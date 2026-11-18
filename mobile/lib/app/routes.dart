import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:task_mobile/features/auth/screens/splash_screen.dart';
import 'package:task_mobile/features/auth/screens/login_screen.dart';
import 'package:task_mobile/features/dashboard/screens/dashboard_screen.dart';
import 'package:task_mobile/features/meetings/screens/meetings_screen.dart';
import 'package:task_mobile/features/meetings/screens/create_meeting_screen.dart';
import 'package:task_mobile/features/meetings/screens/meeting_detail_screen.dart';
import 'package:task_mobile/features/profile/screens/profile_screen.dart';
import 'package:task_mobile/features/tasks/screens/tasks_screen.dart';
import 'package:task_mobile/features/tasks/screens/task_detail_screen.dart';

CustomTransitionPage<void> _buildFadeTransitionPage({
  required BuildContext context,
  required GoRouterState state,
  required Widget child,
}) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 240),
    reverseTransitionDuration: const Duration(milliseconds: 200),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: CurvedAnimation(
          parent: animation,
          curve: Curves.easeInOutCubic,
        ),
        child: child,
      );
    },
  );
}

CustomTransitionPage<void> _buildSlideFadeTransitionPage({
  required BuildContext context,
  required GoRouterState state,
  required Widget child,
}) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 280),
    reverseTransitionDuration: const Duration(milliseconds: 240),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final slide = Tween<Offset>(
        begin: const Offset(0.06, 0),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
      ));
      final fade = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
        parent: animation,
        curve: Curves.easeIn,
      ));
      return SlideTransition(
        position: slide,
        child: FadeTransition(opacity: fade, child: child),
      );
    },
  );
}

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      pageBuilder: (context, state) => _buildFadeTransitionPage(
        context: context,
        state: state,
        child: const SplashScreen(),
      ),
    ),
    GoRoute(
      path: '/login',
      pageBuilder: (context, state) => _buildFadeTransitionPage(
        context: context,
        state: state,
        child: const LoginScreen(),
      ),
    ),
    GoRoute(
      path: '/dashboard',
      pageBuilder: (context, state) => _buildFadeTransitionPage(
        context: context,
        state: state,
        child: const DashboardScreen(),
      ),
    ),
    GoRoute(
      path: '/tasks',
      pageBuilder: (context, state) => _buildFadeTransitionPage(
        context: context,
        state: state,
        child: const TasksScreen(),
      ),
    ),
    GoRoute(
      path: '/tasks/:id',
      pageBuilder: (context, state) {
        final id = int.parse(state.pathParameters['id']!);
        return _buildSlideFadeTransitionPage(
          context: context,
          state: state,
          child: TaskDetailScreen(taskId: id),
        );
      },
    ),
    GoRoute(
      path: '/meetings',
      pageBuilder: (context, state) => _buildFadeTransitionPage(
        context: context,
        state: state,
        child: const MeetingsScreen(),
      ),
    ),
    GoRoute(
      path: '/meetings/create',
      pageBuilder: (context, state) => _buildSlideFadeTransitionPage(
        context: context,
        state: state,
        child: const CreateMeetingScreen(),
      ),
    ),
    GoRoute(
      path: '/meetings/:id',
      pageBuilder: (context, state) {
        final id = int.parse(state.pathParameters['id']!);
        return _buildSlideFadeTransitionPage(
          context: context,
          state: state,
          child: MeetingDetailScreen(meetingId: id),
        );
      },
    ),
    GoRoute(
      path: '/profile',
      pageBuilder: (context, state) => _buildSlideFadeTransitionPage(
        context: context,
        state: state,
        child: const ProfileScreen(),
      ),
    ),
  ],
);
