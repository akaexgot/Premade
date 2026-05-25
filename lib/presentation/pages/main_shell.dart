import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:premade/core/theme/app_colors.dart';
import 'package:premade/presentation/pages/home/home_page.dart';
import 'package:premade/presentation/pages/chat/chat_page.dart';
import 'package:premade/presentation/pages/friends/friends_page.dart';
import 'package:premade/presentation/pages/search/search_page.dart';
import 'package:premade/presentation/pages/profile/my_profile_page.dart';

class MainShell extends ConsumerStatefulWidget {
  const MainShell({super.key});

  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    HomePage(),
    SearchPage(),
    ChatPage(),
    FriendsPage(),
    MyProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final navBg = isDark ? const Color(0xFF12121F) : AppColors.glass;
    final borderColor =
        isDark ? Colors.white.withAlpha(15) : AppColors.grey200.withAlpha(128);
    final inactiveColor =
        isDark ? const Color(0xFF6B7280) : AppColors.navBarInactive;

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
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
                      icon: Icons.travel_explore_rounded,
                      label: 'Descubrir',
                      isActive: _currentIndex == 0,
                      onTap: () => setState(() => _currentIndex = 0),
                      activeColor: AppColors.primary,
                      inactiveColor: inactiveColor,
                    ),
                    _NavItem(
                      icon: Icons.search_rounded,
                      label: 'Buscar',
                      isActive: _currentIndex == 1,
                      onTap: () => setState(() => _currentIndex = 1),
                      activeColor: AppColors.primary,
                      inactiveColor: inactiveColor,
                    ),
                    _NavItem(
                      icon: Icons.chat_bubble_rounded,
                      label: 'Chat',
                      isActive: _currentIndex == 2,
                      onTap: () => setState(() => _currentIndex = 2),
                      activeColor: AppColors.primary,
                      inactiveColor: inactiveColor,
                    ),
                    _NavItem(
                      icon: Icons.people_rounded,
                      label: 'Social',
                      isActive: _currentIndex == 3,
                      onTap: () => setState(() => _currentIndex = 3),
                      activeColor: AppColors.primary,
                      inactiveColor: inactiveColor,
                    ),
                    _NavItem(
                      icon: Icons.person_rounded,
                      label: 'Perfil',
                      isActive: _currentIndex == 4,
                      onTap: () => setState(() => _currentIndex = 4),
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

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
    required this.activeColor,
    required this.inactiveColor,
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
