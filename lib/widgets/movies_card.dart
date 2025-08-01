import 'package:flutter/material.dart';
import 'package:moviestacks/model/movie_model.dart';
import '../helper/app_colors.dart';

class MovieCard extends StatelessWidget {
  final MovieModel movie;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const MovieCard({
    super.key,
    required this.movie,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isWatched = movie.status == 'Watched';

    return GestureDetector(
      onTap: onEdit,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Poster placeholder
    /*              Container(
                    width: 60,
                    height: 90,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                      image: movie.posterUrl != null
                          ? DecorationImage(
                        image: NetworkImage(movie.posterUrl!),
                        fit: BoxFit.cover,
                      )
                          : null,
                    ),
                    child: movie.posterUrl == null
                        ? const Icon(Icons.movie, color: Colors.grey, size: 32)
                        : null,
                  ),*/
                  const SizedBox(width: 16),

                  // Movie details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          movie.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${movie.releaseYear} }',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: isWatched
                                    ? Colors.green[50]
                                    : AppColors.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                movie.status,
                                style: TextStyle(
                                  color: isWatched
                                      ? Colors.green[800]
                                      : AppColors.primary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            const Spacer(),
                            Row(
                              children: [
                                const Icon(
                                  Icons.star,
                                  color: Colors.amber,
                                  size: 16,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${movie.rating}/10',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Delete button
            Positioned(
              top: 8,
              right: 8,
              child: IconButton(
                icon: const Icon(Icons.more_vert, size: 20),
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    builder: (context) {
                      return SafeArea(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ListTile(
                              leading: const Icon(Icons.edit),
                              title: const Text('Edit'),
                              onTap: () {
                                Navigator.pop(context);
                                onEdit();
                              },
                            ),
                            ListTile(
                              leading: const Icon(Icons.delete, color: Colors.red),
                              title: const Text('Delete', style: TextStyle(color: Colors.red)),
                              onTap: () {
                                Navigator.pop(context);
                                onDelete();
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}