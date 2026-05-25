import 'package:go_router/go_router.dart';
import 'package:premade/presentation/pages/auth/login_page.dart';
import 'package:premade/presentation/pages/auth/register_page.dart';
import 'package:premade/presentation/pages/auth/splash_page.dart';
import 'package:premade/presentation/pages/auth/forgot_password_page.dart';
import 'package:premade/presentation/pages/profile/profile_setup_page.dart';
import 'package:premade/presentation/pages/profile/game_selection_page.dart';
import 'package:premade/presentation/pages/main_shell.dart';
import 'package:premade/presentation/pages/chat/chat_detail_page.dart';
import 'package:premade/presentation/pages/profile/edit_profile_page.dart';
import 'package:premade/presentation/pages/profile/my_games_page.dart';
import 'package:premade/presentation/pages/profile/settings_page.dart';
import 'package:premade/presentation/pages/profile/public_profile_page.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    // Splash (inicio)
    GoRoute(
      path: '/',
      builder: (context, state) => const SplashPage(),
    ),

    // Auth routes (sin bottom nav)
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterPage(),
    ),
    GoRoute(
      path: '/forgot-password',
      builder: (context, state) => const ForgotPasswordPage(),
    ),

    // Profile setup routes (sin bottom nav)
    GoRoute(
      path: '/profile-setup',
      builder: (context, state) => const ProfileSetupPage(),
    ),
    GoRoute(
      path: '/game-selection',
      builder: (context, state) => const GameSelectionPage(),
    ),

    // Main app (con bottom nav bar)
    GoRoute(
      path: '/home',
      builder: (context, state) => const MainShell(),
    ),

    // Chat detail (sin bottom nav, pantalla completa)
    GoRoute(
      path: '/chat/:conversationId',
      builder: (context, state) {
        final conversationId = state.pathParameters['conversationId']!;
        return ChatDetailPage(conversationId: conversationId);
      },
    ),

    // Profile internal routes
    GoRoute(
      path: '/edit-profile',
      builder: (context, state) => const EditProfilePage(),
    ),
    GoRoute(
      path: '/my-games',
      builder: (context, state) => const MyGamesPage(),
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsPage(),
    ),
    GoRoute(
      path: '/public-profile/:profileId',
      builder: (context, state) {
        final profileId = state.pathParameters['profileId']!;
        final user = state.extra is Map<String, dynamic>
            ? state.extra as Map<String, dynamic>
            : null;
        return PublicProfilePage(profileId: profileId, user: user);
      },
    ),
  ],
);
