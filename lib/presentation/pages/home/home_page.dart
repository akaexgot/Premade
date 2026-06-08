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

/// HomePage: Landing page después de setup completo
class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  @override
  void initState() {
    super.initState();
    // Cargar datos iniciales
    Future.microtask(() {
      ref.read(matchCandidatesProvider.notifier).loadCandidates();
      ref.read(userMatchesProvider.notifier).loadMatches();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authUser = ref.watch(authUserProvider);
    final userProfile = ref.watch(userProfileProvider);
    final candidates = ref.watch(matchCandidatesProvider);
    final matches = ref.watch(userMatchesProvider);

    // Si no está autenticado, redirigir a login
    if (authUser == null) {
      Future.microtask(() => context.go('/login'));
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header con saludo y perfil resumido
              _buildProfileHeader(context, userProfile),
              const SizedBox(height: 24),

              // Sección de matches nuevos
              if (matches.isNotEmpty) ...[
                _buildNewMatchesSection(context, matches),
                const SizedBox(height: 24),
              ],

              // Sección de candidatos para swipear
              _buildCandidatesSection(context, candidates),
            ],
          ),
        ),
      ),
    );
  }

  /// Header con información del usuario
  Widget _buildProfileHeader(BuildContext context, userProfile) {
    if (userProfile == null) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).primaryColor,
            Theme.of(context).primaryColor.withOpacity(0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '¡Hola, ${userProfile.nickname}!',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Encuentra jugadores en ${userProfile.country}',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white70,
                ),
          ),
        ],
      ),
    );
  }

  /// Sección de matches nuevos
  Widget _buildNewMatchesSection(BuildContext context, List matches) {
    final unlockedMatches = matches.where((m) => m.unlockedAt != null).toList();

    if (unlockedMatches.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Matches Nuevos 🎉',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: unlockedMatches.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: GestureDetector(
                  onTap: () {
                    // TODO: Ir a /chat/:matchId
                  },
                  child: Container(
                    width: 100,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Colors.pink, Colors.red],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.red.withOpacity(0.3),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.favorite,
                              color: Colors.white, size: 28),
                          const SizedBox(height: 8),
                          Text(
                            'Match',
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  /// Sección de candidatos para swipear
  Widget _buildCandidatesSection(BuildContext context, List candidates) {
    if (candidates.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.sentiment_satisfied, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              'No hay más candidatos por ahora',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Vuelve más tarde para más matches 😊',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey,
                  ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Candidatos de Duo',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 500,
          child: PageView.builder(
            scrollDirection: Axis.vertical,
            itemCount: candidates.length,
            itemBuilder: (context, index) {
              final candidate = candidates[index];
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: MatchCardWidget(
                  candidate: candidate,
                  onLike: () => _handleSwipe(context, candidate.userId, true),
                  onPass: () => _handleSwipe(context, candidate.userId, false),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  /// Manejar swipe (like/pass)
  Future<void> _handleSwipe(
      BuildContext context, String toUserId, bool isLike) async {
    ref.read(matchingLoadingProvider.notifier).state = true;

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
          ref.read(matchingErrorProvider.notifier).state = failure.message;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(failure.message)),
          );
        },
        (swipeResult) {
          // Remover candidato de la lista
          ref.read(matchCandidatesProvider.notifier).removeCandidate(toUserId);

          // Si hay match, agregarlo
          if (swipeResult.matchCreated != null) {
            ref
                .read(userMatchesProvider.notifier)
                .addMatch(swipeResult.matchCreated!);
            _showMatchDialog(context, toUserId);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(isLike ? 'Te gustó 💚' : 'Pasaste 👋'),
              ),
            );
          }
        },
      );
    } finally {
      ref.read(matchingLoadingProvider.notifier).state = false;
    }
  }

  Future<void> _showMatchDialog(
      BuildContext context, String otherUserId) async {
    if (!mounted) return;

    final pageContext = this.context;
    final router = GoRouter.of(pageContext);
    final messenger = ScaffoldMessenger.of(pageContext);

    final conversationId = await showDialog<String>(
      context: pageContext,
      barrierDismissible: true,
      builder: (dialogContext) {
        return Dialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 104,
                  height: 104,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: AppColors.primaryGradient,
                  ),
                  child: const Icon(
                    Icons.favorite_rounded,
                    color: Colors.white,
                    size: 58,
                  ),
                ),
                const SizedBox(height: 22),
                Text(
                  'Es un match',
                  textAlign: TextAlign.center,
                  style: Theme.of(dialogContext)
                      .textTheme
                      .headlineMedium
                      ?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: AppColors.primary,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Os habeis gustado mutuamente. Ya podeis empezar a hablar.',
                  textAlign: TextAlign.center,
                  style: Theme.of(dialogContext).textTheme.bodyMedium?.copyWith(
                        height: 1.35,
                      ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      try {
                        final supabase = ref.read(supabaseServiceProvider);
                        final conversationId =
                            await supabase.getOrCreateConversation(otherUserId);
                        if (dialogContext.mounted) {
                          Navigator.of(dialogContext).pop(conversationId);
                        }
                      } catch (e) {
                        if (dialogContext.mounted) {
                          messenger.showSnackBar(
                            SnackBar(
                              content: Text('Error al abrir el chat: $e'),
                            ),
                          );
                        }
                      }
                    },
                    icon: const Icon(Icons.chat_bubble_rounded),
                    label: const Text('Enviar mensaje'),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Seguir viendo perfiles'),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (conversationId != null && mounted) {
      router.push('/chat/$conversationId');
    }
  }
}
