import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:premade/application/providers/auth_providers.dart';
import 'package:premade/core/network/supabase_service.dart';
import 'package:premade/core/theme/app_colors.dart';
import 'package:premade/core/validators/validators.dart';
import 'package:premade/domain/entities/auth_entity.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  late FocusNode _emailFocus;
  late FocusNode _passwordFocus;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _emailFocus = FocusNode();
    _passwordFocus = FocusNode();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  Future<void> _handleSignIn() async {
    if (!_validateInputs()) return;

    ref.read(authLoadingProvider.notifier).setLoading(true);
    ref.read(authErrorProvider.notifier).clearError();

    try {
      final params = SignInParams(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      await ref.read(authUserProvider.notifier).signIn(params).timeout(
            const Duration(seconds: 60),
            onTimeout: () => throw Exception(
                'Tiempo de espera agotado. Revisa tu conexion.'),
          );

      if (mounted) {
        await _goToNextSetupStep();
      }
    } catch (e) {
      ref.read(authErrorProvider.notifier).setError(_parseError(e.toString()));
    } finally {
      ref.read(authLoadingProvider.notifier).setLoading(false);
    }
  }

  Future<void> _handleGoogleSignIn() async {
    ref.read(authLoadingProvider.notifier).setLoading(true);
    ref.read(authErrorProvider.notifier).clearError();

    try {
      await ref.read(authUserProvider.notifier).signInWithGoogle();
      if (mounted) await _goToNextSetupStep();
    } catch (e) {
      ref.read(authErrorProvider.notifier).setError(_parseError(e.toString()));
    } finally {
      ref.read(authLoadingProvider.notifier).setLoading(false);
    }
  }

  bool _validateInputs() {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty) {
      ref.read(authErrorProvider.notifier).setError('El email es requerido');
      return false;
    }

    if (!Validators.isValidEmail(email)) {
      ref.read(authErrorProvider.notifier).setError('Email invalido');
      return false;
    }

    if (password.isEmpty) {
      ref
          .read(authErrorProvider.notifier)
          .setError('La contrasena es requerida');
      return false;
    }

    if (password.length < 6) {
      ref
          .read(authErrorProvider.notifier)
          .setError('La contrasena debe tener al menos 6 caracteres');
      return false;
    }

    return true;
  }

  Future<void> _goToNextSetupStep() async {
    final supabase = ref.read(supabaseServiceProvider);
    final authId = supabase.currentUserId;
    final profile =
        authId == null ? null : await supabase.getUserProfile(authId);

    if (!mounted) return;
    if (profile == null) {
      context.go('/profile-setup');
      return;
    }

    final games = await supabase.getUserGames();
    if (!mounted) return;
    context.go(games.isEmpty ? '/game-selection' : '/home');
  }

  String _parseError(String error) {
    if (error.contains('Invalid login credentials')) {
      return 'Email o contrasena incorrectos';
    } else if (error.contains('User not found')) {
      return 'Usuario no registrado';
    } else if (error.contains('Email not confirmed')) {
      return 'Email no verificado. Revisa tu bandeja de entrada';
    }
    return 'Error al iniciar sesion. Intenta de nuevo';
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(authLoadingProvider);
    final error = ref.watch(authErrorProvider);
    final topInset = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        child: Column(
          children: [
            _PremiumHero(topInset: topInset),
            Transform.translate(
              offset: const Offset(0, -26),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _LoginSheet(
                  emailController: _emailController,
                  passwordController: _passwordController,
                  emailFocus: _emailFocus,
                  passwordFocus: _passwordFocus,
                  obscurePassword: _obscurePassword,
                  isLoading: isLoading,
                  error: error,
                  onTogglePassword: () => setState(
                    () => _obscurePassword = !_obscurePassword,
                  ),
                  onForgotPassword: () => context.push('/forgot-password'),
                  onSignIn: _handleSignIn,
                  onGoogleSignIn: _handleGoogleSignIn,
                ),
              ),
            ),
            Transform.translate(
              offset: const Offset(0, -10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Nuevo en Premade?',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  TextButton(
                    onPressed:
                        isLoading ? null : () => context.push('/register'),
                    child: const Text('Crear cuenta'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
          ],
        ),
      ),
    );
  }
}

class _PremiumHero extends StatelessWidget {
  final double topInset;

  const _PremiumHero({required this.topInset});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 302 + topInset,
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF07111F),
            Color(0xFF0D2B4D),
            Color(0xFF006F83),
          ],
        ),
      ),
      child: Stack(
        children: [
          Positioned.fill(child: CustomPaint(painter: _HeroLinesPainter())),
          Positioned(
            left: 24,
            right: 24,
            top: topInset + 28,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 54,
                      height: 54,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.22),
                        ),
                      ),
                      child: const Icon(
                        Icons.sports_esports_rounded,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                    const Spacer(),
                    const Icon(
                      Icons.auto_awesome_rounded,
                      color: AppColors.neonGreen,
                      size: 24,
                    ),
                  ],
                ),
                const SizedBox(height: 34),
                const Text(
                  'PREMADE',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 44,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0,
                    height: 0.92,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Tu squad empieza aqui.',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.74),
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0,
                  ),
                ),
                const SizedBox(height: 22),
                const Row(
                  children: [
                    _HeroIconTile(icon: Icons.headset_mic_rounded),
                    SizedBox(width: 10),
                    _HeroIconTile(icon: Icons.bolt_rounded),
                    SizedBox(width: 10),
                    _HeroIconTile(icon: Icons.groups_rounded),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LoginSheet extends StatelessWidget {
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final FocusNode emailFocus;
  final FocusNode passwordFocus;
  final bool obscurePassword;
  final bool isLoading;
  final String? error;
  final VoidCallback onTogglePassword;
  final VoidCallback onForgotPassword;
  final VoidCallback onSignIn;
  final VoidCallback onGoogleSignIn;

  const _LoginSheet({
    required this.emailController,
    required this.passwordController,
    required this.emailFocus,
    required this.passwordFocus,
    required this.obscurePassword,
    required this.isLoading,
    required this.error,
    required this.onTogglePassword,
    required this.onForgotPassword,
    required this.onSignIn,
    required this.onGoogleSignIn,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.divider),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Entrar',
            style: theme.textTheme.headlineLarge?.copyWith(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              letterSpacing: 0,
            ),
          ),
          const SizedBox(height: 20),
          _LoginInput(
            label: 'Email',
            controller: emailController,
            focusNode: emailFocus,
            enabled: !isLoading,
            keyboardType: TextInputType.emailAddress,
            icon: Icons.alternate_email_rounded,
            hint: 'correo@ejemplo.com',
          ),
          const SizedBox(height: 14),
          _LoginInput(
            label: 'Contrasena',
            controller: passwordController,
            focusNode: passwordFocus,
            enabled: !isLoading,
            obscureText: obscurePassword,
            icon: Icons.lock_outline_rounded,
            hint: '••••••••',
            suffix: IconButton(
              icon: Icon(
                obscurePassword
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
              ),
              onPressed: onTogglePassword,
            ),
          ),
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: isLoading ? null : onForgotPassword,
              child: const Text('Recuperar acceso'),
            ),
          ),
          if (error != null) ...[
            const SizedBox(height: 8),
            _ErrorBanner(message: error!),
          ],
          const SizedBox(height: 18),
          _PrimaryAuthButton(
            isLoading: isLoading,
            label: 'Iniciar sesion',
            onPressed: onSignIn,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Expanded(child: Divider()),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text('o continua con', style: theme.textTheme.bodySmall),
              ),
              const Expanded(child: Divider()),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 52,
            child: OutlinedButton.icon(
              onPressed: isLoading ? null : onGoogleSignIn,
              icon: const Icon(Icons.g_mobiledata_rounded, size: 30),
              label: const Text('Google'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.textPrimary,
                backgroundColor: AppColors.surfaceElevated,
                side: const BorderSide(color: AppColors.divider, width: 1.2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LoginInput extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool enabled;
  final bool obscureText;
  final TextInputType keyboardType;
  final IconData icon;
  final String hint;
  final Widget? suffix;

  const _LoginInput({
    required this.label,
    required this.controller,
    required this.focusNode,
    required this.enabled,
    required this.icon,
    required this.hint,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 13,
            fontWeight: FontWeight.w800,
            letterSpacing: 0,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          focusNode: focusNode,
          enabled: enabled,
          obscureText: obscureText,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon),
            suffixIcon: suffix,
          ),
        ),
      ],
    );
  }
}

class _HeroIconTile extends StatelessWidget {
  final IconData icon;

  const _HeroIconTile({required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
      ),
      child: Icon(icon, color: Colors.white, size: 22),
    );
  }
}

class _PrimaryAuthButton extends StatelessWidget {
  final bool isLoading;
  final String label;
  final VoidCallback onPressed;

  const _PrimaryAuthButton({
    required this.isLoading,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 54,
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(8),
        boxShadow: AppColors.primaryShadow,
      ),
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          disabledBackgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: isLoading
            ? const SizedBox(
                height: 22,
                width: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Text(label),
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  final String message;

  const _ErrorBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.10),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.25)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded, color: AppColors.error),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: AppColors.error,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroLinesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final thinLine = Paint()
      ..color = Colors.white.withValues(alpha: 0.07)
      ..strokeWidth = 1;
    final accentLine = Paint()
      ..color = AppColors.accent.withValues(alpha: 0.28)
      ..strokeWidth = 2;

    for (var x = -size.height; x < size.width; x += 42) {
      canvas.drawLine(
        Offset(x.toDouble(), size.height),
        Offset(x + size.height, 0),
        thinLine,
      );
    }

    canvas.drawLine(
      Offset(size.width * 0.56, 0),
      Offset(size.width, size.height * 0.48),
      accentLine,
    );
    canvas.drawLine(
      Offset(size.width * 0.74, 0),
      Offset(size.width, size.height * 0.28),
      accentLine,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
