import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:premade/application/providers/auth_providers.dart';
import 'package:premade/application/providers/profile_providers.dart';
import 'package:premade/core/network/supabase_service.dart';
import 'package:premade/core/theme/app_colors.dart';
import 'package:premade/core/widgets/safe_network_avatar.dart';

class EditProfilePage extends ConsumerStatefulWidget {
  const EditProfilePage({Key? key}) : super(key: key);

  @override
  ConsumerState<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends ConsumerState<EditProfilePage> {
  late TextEditingController _nicknameController;
  late TextEditingController _bioController;
  late TextEditingController _ageController;
  late TextEditingController _countryController;
  late TextEditingController _discordController;
  bool _isLoading = false;
  bool _isUploadingAvatar = false;

  @override
  void initState() {
    super.initState();
    final profile = ref.read(userProfileProvider);
    _nicknameController = TextEditingController(text: profile?.nickname ?? '');
    _bioController = TextEditingController(text: profile?.bio ?? '');
    _ageController = TextEditingController(
        text: profile == null ? '' : profile.age.toString());
    _countryController = TextEditingController(text: profile?.country ?? '');
    _discordController =
        TextEditingController(text: profile?.discordUsername ?? '');
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    _bioController.dispose();
    _ageController.dispose();
    _countryController.dispose();
    _discordController.dispose();
    super.dispose();
  }

  Future<void> _pickAndUploadAvatar() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(
        source: ImageSource.gallery, maxWidth: 512, maxHeight: 512);
    if (image == null) return;

    setState(() => _isUploadingAvatar = true);
    try {
      final supabase = ref.read(supabaseServiceProvider);
      final avatarUrl = await supabase.uploadAvatar(filePath: image.path);

      // Actualizar en BD
      final userId = supabase.currentUserId;
      if (userId != null) {
        await supabase.client
            .from('users')
            .update({'avatar_url': avatarUrl}).eq('auth_id', userId);
      }

      // Recargar perfil
      final authUser = ref.read(authUserProvider);
      if (authUser != null) {
        await ref.read(userProfileProvider.notifier).loadProfile(authUser.id);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Avatar actualizado')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al subir avatar: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploadingAvatar = false);
    }
  }

  Future<void> _saveProfile() async {
    if (_nicknameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El nickname no puede estar vacío')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final supabase = ref.read(supabaseServiceProvider);
      final userId = supabase.currentUserId;
      if (userId == null) throw Exception('No session');

      final updateData = <String, dynamic>{
        'nickname': _nicknameController.text.trim(),
        'bio': _bioController.text.trim(),
        'age': int.tryParse(_ageController.text),
        'country': _countryController.text.trim(),
        'discord_username': _discordController.text.trim().isNotEmpty
            ? _discordController.text.trim()
            : null,
      };

      await supabase.client
          .from('users')
          .update(updateData)
          .eq('auth_id', userId);

      // Recargar perfil
      final authUser = ref.read(authUserProvider);
      if (authUser != null) {
        await ref.read(userProfileProvider.notifier).loadProfile(authUser.id);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Perfil guardado exitosamente')),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(userProfileProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cardColor = theme.colorScheme.surface;
    final textPrimary = theme.colorScheme.onSurface;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: textPrimary),
          onPressed: () => context.pop(),
        ),
        title: Text('Editar Perfil',
            style: TextStyle(color: textPrimary, fontWeight: FontWeight.bold)),
        actions: [
          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.only(right: 16),
                child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2)),
              ),
            )
          else
            TextButton(
              onPressed: _saveProfile,
              child: const Text('Guardar',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // ── Avatar ──
            GestureDetector(
              onTap: _isUploadingAvatar ? null : _pickAndUploadAvatar,
              child: Stack(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color:
                          isDark ? const Color(0xFF2A2A45) : AppColors.grey200,
                      border: Border.all(color: AppColors.primary, width: 3),
                    ),
                    child: ClipOval(
                      child: _isUploadingAvatar
                          ? const Center(
                              child: CircularProgressIndicator(strokeWidth: 2))
                          : SafeNetworkAvatar(
                              radius: 50,
                              imageUrl: profile?.avatarUrl,
                              backgroundColor: isDark
                                  ? const Color(0xFF2A2A45)
                                  : AppColors.grey200,
                              iconColor: textPrimary,
                            ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: theme.scaffoldBackgroundColor, width: 2),
                      ),
                      child: const Icon(Icons.camera_alt_rounded,
                          color: Colors.white, size: 16),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text('Toca para cambiar',
                style: TextStyle(
                    fontSize: 13, color: theme.textTheme.bodySmall?.color)),
            const SizedBox(height: 28),

            // ── Fields ──
            _buildTextField(
                'Nickname *', _nicknameController, theme, isDark, cardColor,
                icon: Icons.person_rounded),
            const SizedBox(height: 20),
            _buildTextField(
                'Biografía', _bioController, theme, isDark, cardColor,
                maxLines: 4, icon: Icons.edit_note_rounded),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                    child: _buildTextField(
                        'Edad', _ageController, theme, isDark, cardColor,
                        keyboardType: TextInputType.number,
                        icon: Icons.cake_rounded)),
                const SizedBox(width: 16),
                Expanded(
                    child: _buildTextField(
                        'País', _countryController, theme, isDark, cardColor,
                        icon: Icons.flag_rounded)),
              ],
            ),
            const SizedBox(height: 20),
            _buildTextField(
                'Discord', _discordController, theme, isDark, cardColor,
                icon: Icons.discord, hint: 'usuario#1234'),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      ThemeData theme, bool isDark, Color cardColor,
      {int maxLines = 1,
      TextInputType? keyboardType,
      IconData? icon,
      String? hint}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(
                fontWeight: FontWeight.w600,
                color: theme.textTheme.bodySmall?.color,
                fontSize: 14)),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
                color: isDark ? const Color(0xFF2A2A45) : AppColors.grey200),
          ),
          child: TextField(
            controller: controller,
            maxLines: maxLines,
            keyboardType: keyboardType,
            style: TextStyle(color: theme.colorScheme.onSurface),
            decoration: InputDecoration(
              prefixIcon: icon != null
                  ? Icon(icon, color: AppColors.primary, size: 20)
                  : null,
              hintText: hint,
              border: InputBorder.none,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
        ),
      ],
    );
  }
}
