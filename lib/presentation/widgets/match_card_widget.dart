import 'package:flutter/material.dart';
import 'package:premade/domain/entities/matching_entity.dart';

/// Widget para mostrar una tarjeta de candidato para swipear
class MatchCardWidget extends StatelessWidget {
  final MatchCard candidate;
  final VoidCallback onLike;
  final VoidCallback onPass;

  const MatchCardWidget({
    super.key,
    required this.candidate,
    required this.onLike,
    required this.onPass,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background image
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              image: candidate.avatarUrl != null
                  ? DecorationImage(
                      image: NetworkImage(candidate.avatarUrl!),
                      fit: BoxFit.cover,
                    )
                  : null,
              color: Colors.grey[300],
            ),
            child: candidate.avatarUrl == null
                ? Center(
                    child: Icon(
                      Icons.person,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                  )
                : null,
          ),

          // Gradient overlay
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withOpacity(0.8),
                ],
              ),
            ),
          ),

          // Info section at bottom
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Name and age
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${candidate.nickname}, ${candidate.age}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.location_on, color: Colors.white70, size: 16),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    candidate.country,
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 14,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      // Online indicator
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: candidate.isOnline ? Colors.green : Colors.grey,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Bio
                  if (candidate.bio != null && candidate.bio!.isNotEmpty)
                    Text(
                      candidate.bio!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                  const SizedBox(height: 12),

                  // Games tags
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: candidate.games
                        .take(3) // Mostrar máximo 3 juegos
                        .map(
                          (game) => Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.4),
                              ),
                            ),
                            child: Text(
                              game,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),

                  // Show more games indicator
                  if (candidate.games.length > 3)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        '+${candidate.games.length - 3} más',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ),

                  const SizedBox(height: 16),

                  // Compatibility score
                  if (candidate.compatibilityScore != null)
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.amber.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.whatshot, color: Colors.amber, size: 16),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Compatibilidad: ${(candidate.compatibilityScore! * 100).toStringAsFixed(0)}%',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          LinearProgressIndicator(
                            value: candidate.compatibilityScore! / 100,
                            backgroundColor: Colors.white.withOpacity(0.2),
                            minHeight: 4,
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 16),

                  // Action buttons
                  Row(
                    children: [
                      // Pass button
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: onPass,
                          icon: const Icon(Icons.close),
                          label: const Text('Pasar'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey.withOpacity(0.7),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Like button
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: onLike,
                          icon: const Icon(Icons.favorite),
                          label: const Text('¡Me gusta!'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red.withOpacity(0.8),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
