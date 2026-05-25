import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:premade/application/providers/auth_providers.dart';
import 'package:premade/core/theme/app_colors.dart';
import 'package:premade/core/validators/validators.dart';
import 'package:premade/domain/entities/auth_entity.dart';

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  late TextEditingController _confirmPasswordController;
  late TextEditingController _nicknameController;
  late TextEditingController _ageController;

  late FocusNode _emailFocus;
  late FocusNode _passwordFocus;
  late FocusNode _confirmPasswordFocus;
  late FocusNode _nicknameFocus;
  late FocusNode _ageFocus;

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String? _selectedCountry;
  bool _agreeToTerms = false;
  int _currentStep = 0;

  final List<String> _countries = [
    'España',
    'México',
    'Colombia',
    'Argentina',
    'Chile',
    'Perú',
    'Venezuela',
    'Otros',
  ];

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
    _nicknameController = TextEditingController();
    _ageController = TextEditingController();

    _emailFocus = FocusNode();
    _passwordFocus = FocusNode();
    _confirmPasswordFocus = FocusNode();
    _nicknameFocus = FocusNode();
    _ageFocus = FocusNode();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nicknameController.dispose();
    _ageController.dispose();

    _emailFocus.dispose();
    _passwordFocus.dispose();
    _confirmPasswordFocus.dispose();
    _nicknameFocus.dispose();
    _ageFocus.dispose();
    super.dispose();
  }

  bool _validateStep0() {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      _showError('El email es requerido');
      return false;
    }
    if (!Validators.isValidEmail(email)) {
      _showError('Email inválido');
      return false;
    }
    return true;
  }

  bool _validateStep1() {
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (password.isEmpty) {
      _showError('La contraseña es requerida');
      return false;
    }
    if (password.length < 8) {
      _showError('La contraseña debe tener al menos 8 caracteres');
      return false;
    }
    if (!Validators.isValidPassword(password)) {
      _showError('La contraseña debe contener mayúscula, minúscula y número');
      return false;
    }
    if (password != confirmPassword) {
      _showError('Las contraseñas no coinciden');
      return false;
    }
    return true;
  }

  bool _validateStep2() {
    final nickname = _nicknameController.text.trim();
    final age = int.tryParse(_ageController.text);
    final country = _selectedCountry;

    if (nickname.isEmpty) {
      _showError('El nickname es requerido');
      return false;
    }
    if (nickname.length < 3) {
      _showError('El nickname debe tener al menos 3 caracteres');
      return false;
    }
    if (nickname.length > 20) {
      _showError('El nickname no puede exceder 20 caracteres');
      return false;
    }
    if (age == null || age < 13 || age > 120) {
      _showError('Debes tener entre 13 y 120 años');
      return false;
    }
    if (country == null) {
      _showError('Debes seleccionar un país');
      return false;
    }
    return true;
  }

  Future<void> _handleSignUp() async {
    if (!_agreeToTerms) {
      _showError('Debes aceptar los términos y condiciones');
      return;
    }

    ref.read(authLoadingProvider.notifier).setLoading(true);
    ref.read(authErrorProvider.notifier).clearError();

    try {
      print('DEBUG: Iniciando _handleSignUp...');
      final params = SignUpParams(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        nickname: _nicknameController.text.trim(),
        age: int.parse(_ageController.text),
        country: _selectedCountry!,
      );

      print('DEBUG: Llamando a signUp notifier con timeout de 15s...');
      await ref.read(authUserProvider.notifier).signUp(params).timeout(
            const Duration(seconds: 15),
            onTimeout: () => throw Exception(
                'Tiempo de espera agotado. Revisa tu conexión.'),
          );

      if (mounted) {
        context.go('/profile-setup');
      }
    } catch (e) {
      ref.read(authErrorProvider.notifier).setError(
            _parseError(e.toString()),
          );
    } finally {
      ref.read(authLoadingProvider.notifier).setLoading(false);
    }
  }

  void _showError(String message) {
    ref.read(authErrorProvider.notifier).setError(message);
  }

  String _parseError(String error) {
    if (error.contains('already registered')) {
      return 'Este email ya está registrado';
    } else if (error.contains('Weak password')) {
      return 'La contraseña es muy débil';
    } else if (error.contains('relation "users" does not exist')) {
      return 'Error de base de datos: La tabla "users" no existe';
    }
    return 'Error: ${error.replaceAll('Exception:', '').trim()}';
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(authLoadingProvider);
    final error = ref.watch(authErrorProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear Cuenta'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(
                  5,
                  (index) {
                    if (index % 2 == 0) {
                      final stepIndex = index ~/ 2;
                      return Column(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: stepIndex <= _currentStep
                                  ? AppColors.primary
                                  : Colors.grey[300],
                            ),
                            child: Center(
                              child: Text(
                                '${stepIndex + 1}',
                                style: TextStyle(
                                  color: stepIndex <= _currentStep
                                      ? Colors.white
                                      : Colors.grey[600],
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    } else {
                      final stepIndex = index ~/ 2;
                      return Expanded(
                        child: Container(
                          height: 2,
                          color: stepIndex < _currentStep
                              ? AppColors.primary
                              : Colors.grey[300],
                        ),
                      );
                    }
                  },
                ),
              ),
              const SizedBox(height: 32),

              // Error message
              if (error != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    border: Border.all(color: Colors.red.shade200),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline, color: Colors.red.shade700),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          error,
                          style: TextStyle(
                            color: Colors.red.shade700,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              // Step 0: Email
              if (_currentStep == 0) ...[
                Text(
                  'Email',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _emailController,
                  focusNode: _emailFocus,
                  enabled: !isLoading,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    hintText: 'correo@ejemplo.com',
                    prefixIcon: const Icon(Icons.email_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Tu email será tu usuario para iniciar sesión',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],

              // Step 1: Contraseña
              if (_currentStep == 1) ...[
                Text(
                  'Contraseña',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _passwordController,
                  focusNode: _passwordFocus,
                  enabled: !isLoading,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    hintText: '••••••••',
                    prefixIcon: const Icon(Icons.lock_outlined),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                      onPressed: () => setState(
                        () => _obscurePassword = !_obscurePassword,
                      ),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Confirmar Contraseña',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _confirmPasswordController,
                  focusNode: _confirmPasswordFocus,
                  enabled: !isLoading,
                  obscureText: _obscureConfirmPassword,
                  decoration: InputDecoration(
                    hintText: '••••••••',
                    prefixIcon: const Icon(Icons.lock_outlined),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmPassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                      onPressed: () => setState(
                        () =>
                            _obscureConfirmPassword = !_obscureConfirmPassword,
                      ),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    border: Border.all(color: Colors.blue.shade200),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Requisitos de contraseña:',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                          color: Colors.blue.shade700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _PasswordRequirement(
                          text: 'Mínimo 8 caracteres',
                          met: _passwordController.text.length >= 8),
                      const SizedBox(height: 4),
                      _PasswordRequirement(
                          text: 'Contiene mayúscula',
                          met: _passwordController.text
                              .contains(RegExp(r'[A-Z]'))),
                      const SizedBox(height: 4),
                      _PasswordRequirement(
                          text: 'Contiene minúscula',
                          met: _passwordController.text
                              .contains(RegExp(r'[a-z]'))),
                      const SizedBox(height: 4),
                      _PasswordRequirement(
                          text: 'Contiene número',
                          met: _passwordController.text
                              .contains(RegExp(r'[0-9]'))),
                    ],
                  ),
                ),
              ],

              // Step 2: Perfil
              if (_currentStep == 2) ...[
                Text(
                  'Nickname',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _nicknameController,
                  focusNode: _nicknameFocus,
                  enabled: !isLoading,
                  maxLength: 20,
                  decoration: InputDecoration(
                    hintText: 'Tu nickname en la plataforma',
                    prefixIcon: const Icon(Icons.person_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    counterText: '',
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Edad',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _ageController,
                  focusNode: _ageFocus,
                  enabled: !isLoading,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: '18',
                    prefixIcon: const Icon(Icons.cake_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'País',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _selectedCountry,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.public_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  items: _countries
                      .map((country) => DropdownMenuItem(
                            value: country,
                            child: Text(country),
                          ))
                      .toList(),
                  onChanged: isLoading
                      ? null
                      : (value) => setState(() => _selectedCountry = value),
                ),
                const SizedBox(height: 20),
                CheckboxListTile(
                  enabled: !isLoading,
                  value: _agreeToTerms,
                  onChanged: (value) =>
                      setState(() => _agreeToTerms = value ?? false),
                  title: const Text('Acepto los términos y condiciones'),
                  contentPadding: EdgeInsets.zero,
                ),
              ],

              const SizedBox(height: 32),

              // Buttons
              Row(
                children: [
                  if (_currentStep > 0)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: isLoading
                            ? null
                            : () {
                                ref
                                    .read(authErrorProvider.notifier)
                                    .clearError();
                                setState(() => _currentStep--);
                              },
                        child: const Text('Atrás'),
                      ),
                    ),
                  if (_currentStep > 0) const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: isLoading
                          ? null
                          : () {
                              bool isValid = false;
                              if (_currentStep == 0) {
                                isValid = _validateStep0();
                              } else if (_currentStep == 1) {
                                isValid = _validateStep1();
                              } else if (_currentStep == 2) {
                                isValid = _validateStep2();
                              }

                              if (isValid) {
                                ref
                                    .read(authErrorProvider.notifier)
                                    .clearError();
                                if (_currentStep < 2) {
                                  setState(() => _currentStep++);
                                } else {
                                  _handleSignUp();
                                }
                              }
                            },
                      child: isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              _currentStep == 2 ? 'Crear Cuenta' : 'Siguiente',
                            ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Login link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '¿Ya tienes cuenta? ',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  TextButton(
                    onPressed: isLoading
                        ? null
                        : () {
                            context.pop();
                          },
                    child: const Text('Inicia sesión'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PasswordRequirement extends StatelessWidget {
  final String text;
  final bool met;

  const _PasswordRequirement({
    required this.text,
    required this.met,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          met ? Icons.check_circle : Icons.circle_outlined,
          size: 16,
          color: met ? Colors.green : Colors.grey,
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(
            fontSize: 12,
            color: met ? Colors.green : Colors.grey[600],
          ),
        ),
      ],
    );
  }
}
