import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:premade/application/providers/auth_providers.dart';
import 'package:premade/application/providers/theme_provider.dart';
import 'package:premade/core/theme/app_colors.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final themeMode = ref.watch(themeModeProvider);
    final cardColor = theme.colorScheme.surface;
    final textPrimary = theme.colorScheme.onSurface;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: textPrimary),
          onPressed: () => context.pop(),
        ),
        title: Text('Ajustes',
            style: TextStyle(color: textPrimary, fontWeight: FontWeight.bold)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── Apariencia ──
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: Text('Apariencia',
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: theme.textTheme.bodySmall?.color,
                    letterSpacing: 0.5)),
          ),
          Container(
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                _SettingsItem(
                  icon: Icons.dark_mode_rounded,
                  label: 'Modo oscuro',
                  trailing: Switch(
                    value: themeMode == ThemeMode.dark,
                    activeColor: AppColors.primary,
                    onChanged: (val) {
                      ref.read(themeModeProvider.notifier).setThemeMode(
                            val ? ThemeMode.dark : ThemeMode.light,
                          );
                    },
                  ),
                ),
                Divider(height: 0, indent: 52, color: theme.dividerColor),
                _SettingsItem(
                  icon: Icons.phone_android_rounded,
                  label: 'Usar tema del sistema',
                  trailing: Switch(
                    value: themeMode == ThemeMode.system,
                    activeColor: AppColors.primary,
                    onChanged: (val) {
                      if (val) {
                        ref
                            .read(themeModeProvider.notifier)
                            .setThemeMode(ThemeMode.system);
                      } else {
                        ref.read(themeModeProvider.notifier).setThemeMode(
                              isDark ? ThemeMode.dark : ThemeMode.light,
                            );
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // ── General ──
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: Text('General',
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: theme.textTheme.bodySmall?.color,
                    letterSpacing: 0.5)),
          ),
          Container(
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                _SettingsItem(
                  icon: Icons.notifications_rounded,
                  label: 'Notificaciones',
                  subtitle: 'Gestionar notificaciones push',
                  trailing: Icon(Icons.chevron_right_rounded,
                      color: theme.textTheme.bodySmall?.color),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Notificaciones: próximamente')),
                    );
                  },
                ),
                Divider(height: 0, indent: 52, color: theme.dividerColor),
                _SettingsItem(
                  icon: Icons.shield_rounded,
                  label: 'Privacidad',
                  subtitle: 'Visibilidad de perfil y bloqueos',
                  trailing: Icon(Icons.chevron_right_rounded,
                      color: theme.textTheme.bodySmall?.color),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Privacidad: próximamente')),
                    );
                  },
                ),
                Divider(height: 0, indent: 52, color: theme.dividerColor),
                _SettingsItem(
                  icon: Icons.info_outline_rounded,
                  label: 'Acerca de',
                  subtitle: 'Premade v1.0.0',
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),

          // ── Cerrar Sesión ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ElevatedButton.icon(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('¿Cerrar sesión?'),
                    actions: [
                      TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: const Text('Cancelar')),
                      TextButton(
                        onPressed: () {
                          ref.read(authUserProvider.notifier).signOut();
                          context.go('/login');
                        },
                        child: const Text('Salir',
                            style: TextStyle(color: AppColors.error)),
                      ),
                    ],
                  ),
                );
              },
              icon: const Icon(Icons.logout, color: Colors.white),
              label: const Text('Cerrar sesión',
                  style: TextStyle(color: Colors.white, fontSize: 16)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingsItem({
    required this.icon,
    required this.label,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textPrimary = theme.colorScheme.onSurface;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.primary.withAlpha(20),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: AppColors.primary, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: textPrimary)),
                  if (subtitle != null)
                    Text(subtitle!,
                        style: TextStyle(
                            fontSize: 13,
                            color: theme.textTheme.bodySmall?.color)),
                ],
              ),
            ),
            if (trailing != null) trailing!,
          ],
        ),
      ),
    );
  }
}
