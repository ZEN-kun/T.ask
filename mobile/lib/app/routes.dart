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

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/dashboard',
      builder: (context, state) => const DashboardScreen(),
    ),
    GoRoute(
      path: '/meetings',
      builder: (context, state) => const MeetingsScreen(),
    ),
    GoRoute(
      path: '/meetings/create',
      builder: (context, state) => const CreateMeetingScreen(),
    ),
    GoRoute(
      path: '/meetings/:id',
      builder: (context, state) {
        final id = int.parse(state.pathParameters['id']!);
        return MeetingDetailScreen(meetingId: id);
      },
    ),
    GoRoute(
      path: '/tasks',
      builder: (context, state) => const TasksScreen(),
    ),
    GoRoute(
      path: '/tasks/:id',
      builder: (context, state) {
        final id = int.parse(state.pathParameters['id']!);
        return TaskDetailScreen(taskId: id);
      },
    ),
    GoRoute(
      path: '/profile',
      builder: (context, state) => const ProfileScreen(),
    ),
  ],
);
