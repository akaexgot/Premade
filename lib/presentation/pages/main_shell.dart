import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:premade/core/network/supabase_service.dart';
import 'package:premade/core/theme/app_colors.dart';
import 'package:premade/presentation/pages/home/home_page.dart';
import 'package:premade/presentation/pages/profile/my_profile_page.dart';
import 'package:premade/presentation/pages/social/social_page.dart';

class MainShell extends ConsumerStatefulWidget {
  const MainShell({super.key});

  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell> {
  int _currentIndex = 0;
  int _pendingRequestsCount = 0;
  int _unreadChatsCount = 0;

  @override
  void initState() {
    super.initState();
    _loadPendingRequestsCount();
    _loadUnreadChatsCount();
  }

  Future<void> _loadPendingRequestsCount() async {
    try {
      final requests =
          await ref.read(supabaseServiceProvider).getPendingRequests();
      if (mounted) {
        setState(() => _pendingRequestsCount = requests.length);
      }
    } catch (_) {
      if (mounted) {
        setState(() => _pendingRequestsCount = 0);
      }
    }
  }

  Future<void> _loadUnreadChatsCount() async {
    try {
      final count =
          await ref.read(supabaseServiceProvider).getUnreadConversationsCount();
      if (mounted) {
        setState(() => _unreadChatsCount = count);
      }
    } catch (_) {
      if (mounted) {
        setState(() => _unreadChatsCount = 0);
      }
    }
  }

  void _selectTab(int index) {
    setState(() => _currentIndex = index);
    if (index == 1) {
      _loadPendingRequestsCount();
      _loadUnreadChatsCount();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final navBg = isDark ? const Color(0xFF12121F) : AppColors.glass;
    final borderColor =
        isDark ? Colors.white.withAlpha(15) : AppColors.grey200.withAlpha(128);
    final inactiveColor =
        isDark ? const Color(0xFF6B7280) : AppColors.navBarInactive;
    final pages = [
      const HomePage(),
      SocialPage(
        onPendingRequestsChanged: (count) {
          if (mounted && count != _pendingRequestsCount) {
            setState(() => _pendingRequestsCount = count);
          }
        },
        onUnreadChatsChanged: (count) {
          if (mounted && count != _unreadChatsCount) {
            setState(() => _unreadChatsCount = count);
          }
        },
      ),
      const MyProfilePage(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: pages,
      ),
      extendBody: true,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: navBg.withAlpha(235),
          border: Border(
            top: BorderSide(color: borderColor, width: 0.5),
          ),
        ),
        child: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _NavItem(
                      icon: Icons.home_rounded,
                      label: 'Inicio',
                      isActive: _currentIndex == 0,
                      onTap: () => _selectTab(0),
                      activeColor: AppColors.primary,
                      inactiveColor: inactiveColor,
                    ),
                    _NavItem(
                      icon: Icons.people_rounded,
                      label: 'Social',
                      isActive: _currentIndex == 1,
                      badgeCount: _pendingRequestsCount + _unreadChatsCount,
                      onTap: () => _selectTab(1),
                      activeColor: AppColors.primary,
                      inactiveColor: inactiveColor,
                    ),
                    _NavItem(
                      icon: Icons.person_rounded,
                      label: 'Perfil',
                      isActive: _currentIndex == 2,
                      onTap: () => _selectTab(2),
                      activeColor: AppColors.primary,
                      inactiveColor: inactiveColor,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;
  final Color activeColor;
  final Color inactiveColor;
  final int badgeCount;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
    required this.activeColor,
    required this.inactiveColor,
    this.badgeCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  width: 38,
                  height: 30,
                  decoration: BoxDecoration(
                    gradient: isActive ? AppColors.primaryGradient : null,
                    color: isActive ? null : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: isActive ? AppColors.primaryShadow : null,
                  ),
                  child: Icon(
                    icon,
                    color: isActive ? Colors.white : inactiveColor,
                    size: 21,
                  ),
                ),
                if (badgeCount > 0)
                  Positioned(
                    top: -7,
                    right: -7,
                    child: _NavBadge(count: badgeCount),
                  ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                color: isActive ? activeColor : inactiveColor,
                letterSpacing: 0.1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavBadge extends StatelessWidget {
  final int count;

  const _NavBadge({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.error,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white, width: 1.5),
      ),
      alignment: Alignment.center,
      child: Text(
        count > 99 ? '99+' : count.toString(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w900,
          height: 1,
        ),
      ),
    );
  }
}
