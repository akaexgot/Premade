import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:premade/application/providers/auth_providers.dart';
import 'package:premade/application/providers/matching_providers.dart';
import 'package:premade/application/providers/profile_providers.dart';
import 'package:premade/core/network/supabase_service.dart';
import 'package:premade/core/theme/app_colors.dart';
import 'package:premade/domain/entities/matching_entity.dart';
import 'package:premade/presentation/widgets/match_card_widget.dart';

/// Premium duo discovery cards.
class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage>
    with TickerProviderStateMixin {
  late AnimationController _swipeController;
  Offset _dragOffset = Offset.zero;
  double _dragAngle = 0;
  Offset _animationStartOffset = Offset.zero;
  Offset _animationEndOffset = Offset.zero;

  @override
  void initState() {
    super.initState();
    _swipeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    )..addListener(() {
        setState(() {
          _dragOffset = Offset.lerp(
            _animationStartOffset,
            _animationEndOffset,
            _swipeController.value,
          )!;
          _dragAngle = _dragOffset.dx * 0.001;
        });
      });
    Future.microtask(() {
      final authUser = ref.read(authUserProvider);
      if (authUser != null) {
        ref.read(userProfileProvider.notifier).loadProfile(authUser.id);
      }
      ref.read(matchCandidatesProvider.notifier).loadCandidates();
      ref.read(userMatchesProvider.notifier).loadMatches();
    });
  }

  @override
  void dispose() {
    _swipeController.dispose();
    super.dispose();
  }

  void _onPanStart(DragStartDetails details) {
    _swipeController.stop();
  }

  void _onPanUpdate(DragUpdateDetails details) {
    setState(() {
      _dragOffset += details.delta;
      _dragAngle = _dragOffset.dx * 0.001;
    });
  }

  void _onPanEnd(DragEndDetails details, String userId) {
    final screenWidth = MediaQuery.of(context).size.width;
    final threshold = screenWidth * 0.3;

    if (_dragOffset.dx > threshold) {
      _animateSwipe(screenWidth * 1.5, userId, true);
    } else if (_dragOffset.dx < -threshold) {
      _animateSwipe(-screenWidth * 1.5, userId, false);
    } else {
      setState(() {
        _dragOffset = Offset.zero;
        _dragAngle = 0;
      });
    }
  }

  void _animateSwipe(double targetX, String userId, bool isLike) {
    _animationStartOffset = _dragOffset;
    _animationEndOffset = Offset(targetX, _dragOffset.dy);
    _swipeController.reset();
    _swipeController.forward().then((_) {
      _handleSwipe(userId, isLike);
      setState(() {
        _dragOffset = Offset.zero;
        _dragAngle = 0;
      });
    });
  }

  void _onLikePressed(String userId) {
    final screenWidth = MediaQuery.of(context).size.width;
    _animateSwipe(screenWidth * 1.5, userId, true);
  }

  void _onPassPressed(String userId) {
    final screenWidth = MediaQuery.of(context).size.width;
    _animateSwipe(-screenWidth * 1.5, userId, false);
  }

  Future<void> _handleSwipe(String toUserId, bool isLike) async {
    try {
      final createSwipeUseCase = ref.read(createSwipeUseCaseProvider);
      final result = await createSwipeUseCase(
        CreateSwipeParams(
          toUserId: toUserId,
          action: isLike ? SwipeAction.like : SwipeAction.dislike,
        ),
      );

      result.fold(
        (failure) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(failure.message)),
            );
          }
        },
        (swipeResult) async {
          ref.read(matchCandidatesProvider.notifier).removeCandidate(toUserId);
          if (swipeResult.matchCreated != null) {
            ref
                .read(userMatchesProvider.notifier)
                .addMatch(swipeResult.matchCreated!);
            if (mounted) await _showMatchAndOpenChat(toUserId);
          }
        },
      );
    } catch (_) {
      // Keep discovery smooth if swipe persistence fails transiently.
    }
  }

  Future<void> _showMatchAndOpenChat(String otherUserId) async {
    String? conversationId;
    var shouldAutoOpen = true;

    try {
      final supabase = ref.read(supabaseServiceProvider);
      conversationId = await supabase.getOrCreateConversation(otherUserId);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Duo creado, pero no se pudo abrir chat: $e'),
          ),
        );
      }
    }

    if (!mounted) return;

    showGeneralDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierLabel: 'Duo',
      barrierColor: Colors.black.withAlpha(150),
      transitionDuration: const Duration(milliseconds: 450),
      pageBuilder: (dialogContext, animation, secondaryAnimation) {
        return Center(
          child: _MatchDialogCard(
            onKeepSwiping: () {
              shouldAutoOpen = false;
              Navigator.pop(dialogContext);
            },
            onOpenChat: conversationId == null
                ? null
                : () {
                    shouldAutoOpen = false;
                    Navigator.pop(dialogContext);
                    context.push('/chat/$conversationId');
                  },
          ),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.elasticOut,
          reverseCurve: Curves.easeIn,
        );
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(scale: curved, child: child),
        );
      },
    );

    if (conversationId == null) return;
    await Future<void>.delayed(const Duration(milliseconds: 1500));
    if (!mounted || !shouldAutoOpen) return;

    final navigator = Navigator.of(context, rootNavigator: true);
    if (navigator.canPop()) {
      navigator.pop();
      context.push('/chat/$conversationId');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authUser = ref.watch(authUserProvider);
    final candidates = ref.watch(matchCandidatesProvider);
    final theme = Theme.of(context);

    if (authUser == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          context.go('/login');
        }
      });
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.heroGradient),
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 10),
                child: Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: AppColors.primaryShadow,
                      ),
                      child: const Icon(
                        Icons.sports_esports_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'PREMADE',
                          style: TextStyle(
                            color: theme.colorScheme.onSurface,
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0,
                            height: 1,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Gaming squad finder',
                          style: TextStyle(
                            color: theme.textTheme.bodySmall?.color,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.glass,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.divider),
                      ),
                      child: const Icon(
                        Icons.tune_rounded,
                        color: AppColors.primary,
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: candidates.isEmpty
                    ? _buildEmptyState(theme)
                    : Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            if (candidates.length > 1)
                              Positioned.fill(
                                child: Transform.translate(
                                  offset: const Offset(0, 14),
                                  child: Transform.scale(
                                    scale: 0.94,
                                    child: Opacity(
                                      opacity: 0.46,
                                      child: MatchCardWidget(
                                        candidate: candidates[1],
                                        onLike: () {},
                                        onPass: () {},
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            GestureDetector(
                              onPanStart: _onPanStart,
                              onPanUpdate: _onPanUpdate,
                              onPanEnd: (d) =>
                                  _onPanEnd(d, candidates.first.userId),
                              child: Transform.translate(
                                offset: _dragOffset,
                                child: Transform.rotate(
                                  angle: _dragAngle,
                                  child: Stack(
                                    children: [
                                      MatchCardWidget(
                                        candidate: candidates.first,
                                        onLike: () => _onLikePressed(
                                          candidates.first.userId,
                                        ),
                                        onPass: () => _onPassPressed(
                                          candidates.first.userId,
                                        ),
                                      ),
                                      if (_dragOffset.dx > 40)
                                        const Positioned(
                                          top: 58,
                                          left: 28,
                                          child: _DecisionBadge(
                                            label: 'TEAM UP',
                                            color: AppColors.swipeLike,
                                            angle: -0.34,
                                          ),
                                        ),
                                      if (_dragOffset.dx < -40)
                                        const Positioned(
                                          top: 58,
                                          right: 28,
                                          child: _DecisionBadge(
                                            label: 'SKIP',
                                            color: AppColors.swipeNope,
                                            angle: 0.34,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
              ),
              if (candidates.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 90, top: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _ActionButton(
                        icon: Icons.close_rounded,
                        color: AppColors.swipeNope,
                        size: 58,
                        iconSize: 28,
                        onTap: () => _onPassPressed(candidates.first.userId),
                      ),
                      const SizedBox(width: 18),
                      _ActionButton(
                        icon: Icons.bolt_rounded,
                        color: AppColors.swipeSuperLike,
                        size: 50,
                        iconSize: 25,
                        onTap: () => _onLikePressed(candidates.first.userId),
                      ),
                      const SizedBox(width: 18),
                      _ActionButton(
                        icon: Icons.sports_esports_rounded,
                        color: AppColors.swipeLike,
                        size: 58,
                        iconSize: 28,
                        onTap: () => _onLikePressed(candidates.first.userId),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 98,
              height: 98,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(8),
                boxShadow: AppColors.primaryShadow,
              ),
              child: const Icon(
                Icons.sports_esports_rounded,
                size: 48,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Sin jugadores nuevos',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: theme.colorScheme.onSurface,
                letterSpacing: 0,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Vuelve mas tarde para encontrar\nnuevos companeros de equipo',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: theme.textTheme.bodyMedium?.color,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DecisionBadge extends StatelessWidget {
  final String label;
  final Color color;
  final double angle;

  const _DecisionBadge({
    required this.label,
    required this.color,
    required this.angle,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: angle,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: color.withAlpha(34),
          border: Border.all(color: color, width: 3),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 30,
            fontWeight: FontWeight.w900,
            letterSpacing: 0,
          ),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final double size;
  final double iconSize;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.color,
    required this.size,
    required this.iconSize,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF1A1A2E) : AppColors.glass;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: bgColor,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: color.withAlpha(48),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
          border: Border.all(color: color.withAlpha(58), width: 1.2),
        ),
        child: Icon(icon, color: color, size: iconSize),
      ),
    );
  }
}

class _MatchDialogCard extends StatelessWidget {
  final VoidCallback onKeepSwiping;
  final VoidCallback? onOpenChat;

  const _MatchDialogCard({
    required this.onKeepSwiping,
    required this.onOpenChat,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        width: 300,
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(8),
          boxShadow: AppColors.primaryShadow,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 82,
              height: 82,
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(35),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.white.withAlpha(90)),
              ),
              child: const Icon(
                Icons.groups_rounded,
                color: Colors.white,
                size: 48,
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'Duo listo',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.w800,
                letterSpacing: 0,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Abriendo chat...',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onKeepSwiping,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white54),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Seguir'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onOpenChat,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.primary,
                      disabledBackgroundColor: Colors.white54,
                      disabledForegroundColor: AppColors.primary.withAlpha(130),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Chat'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
