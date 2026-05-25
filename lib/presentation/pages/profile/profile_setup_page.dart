import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:premade/application/providers/auth_providers.dart';
import 'package:premade/application/providers/profile_providers.dart';
import 'package:premade/core/theme/app_colors.dart';
import 'package:premade/domain/entities/user_profile_entity.dart';

class ProfileSetupPage extends ConsumerStatefulWidget {
  const ProfileSetupPage({Key? key}) : super(key: key);

  @override
  ConsumerState<ProfileSetupPage> createState() => _ProfileSetupPageState();
}

class _ProfileSetupPageState extends ConsumerState<ProfileSetupPage> {
  late TextEditingController _bioController;
  late TextEditingController _discordController;
  String? _avatarPath;
  int _currentStep = 0;

  @override
  void initState() {
    super.initState();
    _bioController = TextEditingController();
    _discordController = TextEditingController();
  }

  @override
  void dispose() {
    _bioController.dispose();
    _discordController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      
      if (image != null) {
        setState(() => _avatarPath = image.path);
      }
    } catch (e) {
      _showError('Error al seleccionar imagen');
    }
  }

  Future<void> _uploadAvatar() async {
    if (_avatarPath == null) return;

    ref.read(profileLoadingProvider.notifier).setLoading(true);
    try {
      final fileName = 'avatar_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final params = UploadAvatarParams(
        filePath: _avatarPath!,
        fileName: fileName,
      );

      await ref.read(userProfileProvider.notifier).uploadAvatar(params);
      
      if (mounted) {
        _showSuccess('Avatar subido exitosamente');
      }
    } catch (e) {
      _showError('Error al subir avatar: ${e.toString()}');
    } finally {
      ref.read(profileLoadingProvider.notifier).setLoading(false);
    }
  }

  Future<void> _updateProfile() async {
    if (_bioController.text.trim().isEmpty) {
      _showError('La bio es requerida');
      return;
    }

    ref.read(profileLoadingProvider.notifier).setLoading(true);
    ref.read(profileErrorProvider.notifier).clearError();

    try {
      final params = UpdateProfileParams(
        nickname: null,
        bio: _bioController.text.trim(),
        avatarUrl: null,
        discordUsername:
            _discordController.text.trim().isEmpty ? null : _discordController.text.trim(),
        autonomousRegion: null,
        province: null,
      );

      await ref.read(userProfileProvider.notifier).updateProfile(params);

      if (mounted) {
        context.go('/game-selection');
      }
    } catch (e) {
      _showError('Error al guardar perfil: ${e.toString()}');
    } finally {
      ref.read(profileLoadingProvider.notifier).setLoading(false);
    }
  }

  void _showError(String message) {
    ref.read(profileErrorProvider.notifier).setError(message);
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(profileLoadingProvider);
    final error = ref.watch(profileErrorProvider);
    final userProfile = ref.watch(userProfileProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Completa tu Perfil'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Stepper
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _StepIndicator(
                    step: 1,
                    label: 'Avatar',
                    isActive: _currentStep >= 0,
                  ),
                  Expanded(
                    child: Container(
                      height: 2,
                      color: _currentStep >= 1
                          ? AppColors.primary
                          : Colors.grey[300],
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                  ),
                  _StepIndicator(
                    step: 2,
                    label: 'Bio',
                    isActive: _currentStep >= 1,
                  ),
                  Expanded(
                    child: Container(
                      height: 2,
                      color: _currentStep >= 2
                          ? AppColors.primary
                          : Colors.grey[300],
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                  ),
                  _StepIndicator(
                    step: 3,
                    label: 'Juegos',
                    isActive: _currentStep >= 2,
                  ),
                ],
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

              // Step 1: Avatar
              if (_currentStep == 0) ...[
                Center(
                  child: Column(
                    children: [
                      Stack(
                        children: [
                          Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.grey[200],
                              image: _avatarPath != null
                                  ? DecorationImage(
                                      image: FileImage(
                                        File(_avatarPath!),
                                      ),
                                      fit: BoxFit.cover,
                                    )
                                  : null,
                            ),
                            child: _avatarPath == null
                                ? Icon(
                                    Icons.person_outline,
                                    size: 60,
                                    color: Colors.grey[400],
                                  )
                                : null,
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.primary,
                              ),
                              padding: const EdgeInsets.all(8),
                              child: Icon(
                                Icons.camera_alt,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: isLoading ? null : _pickImage,
                        icon: const Icon(Icons.image),
                        label: const Text('Seleccionar Foto'),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Recomendado: Foto clara de tu cara',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      if (_avatarPath != null) ...[
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: isLoading ? null : _uploadAvatar,
                          child: isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text('Subir Avatar'),
                        ),
                      ],
                    ],
                  ),
                ),
              ],

              // Step 2: Bio
              if (_currentStep == 1) ...[
                Text(
                  'Tu Bio',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _bioController,
                  enabled: !isLoading,
                  maxLines: 5,
                  maxLength: 500,
                  decoration: InputDecoration(
                    hintText: 'Cuéntanos sobre ti, tu estilo de juego...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    counterText: '',
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Discord (Opcional)',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _discordController,
                  enabled: !isLoading,
                  decoration: InputDecoration(
                    hintText: 'tu_usuario#1234',
                    prefixIcon: const Icon(Icons.group),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    border: Border.all(color: Colors.blue.shade200),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info, color: Colors.blue.shade700),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Una buena bio ayuda a otros a conocerte mejor',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.blue.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // Step 3: Games (Preview)
              if (_currentStep == 2) ...[
                Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.games,
                        size: 64,
                        color: AppColors.primary,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Selecciona tus Juegos',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'En el siguiente paso podrás seleccionar tus juegos favoritos,\nrangos y roles',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 32),

              // Navigation buttons
              Row(
                children: [
                  if (_currentStep > 0)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: isLoading
                            ? null
                            : () => setState(() => _currentStep--),
                        child: const Text('Atrás'),
                      ),
                    ),
                  if (_currentStep > 0) const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: isLoading
                          ? null
                          : () {
                              if (_currentStep < 2) {
                                setState(() => _currentStep++);
                              } else {
                                _updateProfile();
                              }
                            },
                      child: Text(_currentStep == 2 ? 'Continuar' : 'Siguiente'),
                    ),
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

class _StepIndicator extends StatelessWidget {
  final int step;
  final String label;
  final bool isActive;

  const _StepIndicator({
    required this.step,
    required this.label,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive ? AppColors.primary : Colors.grey[300],
          ),
          child: Center(
            child: Text(
              '$step',
              style: TextStyle(
                color: isActive ? Colors.white : Colors.grey[600],
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: isActive ? AppColors.primary : Colors.grey[400],
          ),
        ),
      ],
    );
  }
}
