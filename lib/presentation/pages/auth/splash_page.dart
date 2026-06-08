import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:premade/application/providers/auth_providers.dart';
import 'package:premade/core/theme/app_colors.dart';

class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    try {
      // Verificar si hay usuario autenticado
      final isAuthenticated =
          await ref.read(isUserAuthenticatedUseCaseProvider).call();

      isAuthenticated.fold(
        (failure) {
          // Error - ir a login
          if (mounted) context.go('/login');
        },
        (isAuth) {
          // Navegar según autenticación
          if (mounted) {
            if (isAuth) {
              // Verificar si perfil está completo
              context.go('/home');
            } else {
              context.go('/login');
            }
          }
        },
      );
    } catch (e) {
      if (mounted) context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo animado
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    AppColors.primary,
                    AppColors.secondary,
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.people,
                color: Colors.white,
                size: 48,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'PREMADE',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w900,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Find your perfect gaming squad',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 40),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
