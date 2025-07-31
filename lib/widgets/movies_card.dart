import 'package:flutter/material.dart';

class MovieCard extends StatelessWidget {
  final Movie movie;
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
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: InkWell(
        onTap: onEdit,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              _buildStatusIndicator(colorScheme),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      movie.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Released: ${movie.releaseYear}',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.star,
                          color: Colors.amber,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${movie.rating}/10',
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: onDelete,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusIndicator(ColorScheme colorScheme) {
    final isWatched = movie.status == 'Watched';
    return Container(
      width: 8,
      height: 60,
      decoration: BoxDecoration(
        color: isWatched ? Colors.green : colorScheme.primary,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}