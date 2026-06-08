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
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();
  bool _obscurePassword = true;

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
      await ref.read(authUserProvider.notifier).signIn(
            SignInParams(
              email: _emailController.text.trim(),
              password: _passwordController.text,
            ),
          );

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

  String _parseError(String error) {
    if (error.contains('baneada') || error.contains('banned')) {
      return error.replaceFirst('Exception: ', '');
    }
    if (error.contains('Invalid login credentials')) {
      return 'Email o contrasena incorrectos';
    }
    if (error.contains('User not found')) {
      return 'Usuario no registrado';
    }
    if (error.contains('Email not confirmed')) {
      return 'Email no verificado. Revisa tu bandeja de entrada';
    }
    return 'Error al iniciar sesion. Intenta de nuevo';
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

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(authLoadingProvider);
    final error = ref.watch(authErrorProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textPrimary = theme.colorScheme.onSurface;
    final textSecondary =
        theme.textTheme.bodyMedium?.color ?? AppColors.textSecondary;
    final surface = theme.colorScheme.surface;
    final fieldColor = isDark ? const Color(0xFF1E1E36) : AppColors.grey100;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(22, 20, 22, 28),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _LoginHero(
                        textPrimary: textPrimary, textSecondary: textSecondary),
                    const SizedBox(height: 30),
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: surface,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: isDark
                              ? const Color(0xFF2A2A45)
                              : AppColors.grey200,
                        ),
                        boxShadow: isDark ? null : AppColors.softShadow,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Inicia sesion',
                            style: TextStyle(
                              color: textPrimary,
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Vuelve a tu equipo, chats y matches.',
                            style: TextStyle(
                              color: textSecondary,
                              fontSize: 14,
                              height: 1.35,
                            ),
                          ),
                          const SizedBox(height: 22),
                          _AuthField(
                            controller: _emailController,
                            focusNode: _emailFocus,
                            enabled: !isLoading,
                            keyboardType: TextInputType.emailAddress,
                            label: 'Email',
                            hint: 'correo@ejemplo.com',
                            icon: Icons.alternate_email_rounded,
                            fillColor: fieldColor,
                          ),
                          const SizedBox(height: 14),
                          _AuthField(
                            controller: _passwordController,
                            focusNode: _passwordFocus,
                            enabled: !isLoading,
                            label: 'Contrasena',
                            hint: 'Minimo 6 caracteres',
                            icon: Icons.lock_rounded,
                            fillColor: fieldColor,
                            obscureText: _obscurePassword,
                            suffix: IconButton(
                              tooltip: _obscurePassword
                                  ? 'Mostrar contrasena'
                                  : 'Ocultar contrasena',
                              onPressed: () => setState(
                                () => _obscurePassword = !_obscurePassword,
                              ),
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_rounded
                                    : Icons.visibility_off_rounded,
                              ),
                            ),
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: isLoading
                                  ? null
                                  : () => context.push('/forgot-password'),
                              child: const Text('He olvidado mi contrasena'),
                            ),
                          ),
                          if (error != null) ...[
                            const SizedBox(height: 4),
                            _ErrorBanner(message: error),
                          ],
                          const SizedBox(height: 18),
                          SizedBox(
                            height: 52,
                            child: ElevatedButton.icon(
                              onPressed: isLoading ? null : _handleSignIn,
                              icon: isLoading
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Icon(Icons.login_rounded),
                              label: Text(
                                isLoading ? 'Entrando...' : 'Entrar',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 16,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                elevation: 0,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'No tienes cuenta?',
                          style: TextStyle(color: textSecondary),
                        ),
                        TextButton(
                          onPressed: isLoading
                              ? null
                              : () => context.push('/register'),
                          child: const Text('Registrate'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _LoginHero extends StatelessWidget {
  final Color textPrimary;
  final Color textSecondary;

  const _LoginHero({
    required this.textPrimary,
    required this.textSecondary,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 68,
          height: 68,
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(20),
            boxShadow: AppColors.primaryShadow,
          ),
          child: const Icon(
            Icons.sports_esports_rounded,
            color: Colors.white,
            size: 34,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'PREMADE',
          style: TextStyle(
            color: textPrimary,
            fontSize: 34,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Encuentra duo, crea equipo y habla con jugadores que encajan contigo.',
          style: TextStyle(
            color: textSecondary,
            fontSize: 15,
            height: 1.4,
          ),
        ),
      ],
    );
  }
}

class _AuthField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool enabled;
  final String label;
  final String hint;
  final IconData icon;
  final Color fillColor;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Widget? suffix;

  const _AuthField({
    required this.controller,
    required this.focusNode,
    required this.enabled,
    required this.label,
    required this.hint,
    required this.icon,
    required this.fillColor,
    this.keyboardType,
    this.obscureText = false,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      enabled: enabled,
      keyboardType: keyboardType,
      obscureText: obscureText,
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
        suffixIcon: suffix,
        filled: true,
        fillColor: fillColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.4),
        ),
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
        color: AppColors.error.withAlpha(20),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.error.withAlpha(70)),
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
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
