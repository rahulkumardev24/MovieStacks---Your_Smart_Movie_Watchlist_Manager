import 'package:flutter/material.dart';
import '../widgets/movies_card.dart';
import '../widgets/search_bar.dart';
import 'add_movies_screen.dart';
import 'edit_movies_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _searchQuery = '';
  String _filterStatus = 'All';

  // Temporary mock data for UI testing
  final List<Map<String, dynamic>> mockMovies = [
    {
      'id': 1,
      'title': 'Inception',
      'releaseYear': '2010',
      'rating': 8.8,
      'status': 'Watched',
    },
    {
      'id': 2,
      'title': 'Interstellar',
      'releaseYear': '2014',
      'rating': 8.6,
      'status': 'Want to Watch',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final filteredMovies = mockMovies.where((movie) {
      final matchesSearch = movie['title']
          .toString()
          .toLowerCase()
          .contains(_searchQuery.toLowerCase());
      final matchesStatus = _filterStatus == 'All' || movie['status'] == _filterStatus;
      return matchesSearch && matchesStatus;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Movie Watchlist'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {}); // Just re-render
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SearchBarWidget(
              onChanged: (query) {
                setState(() {
                  _searchQuery = query;
                });
              },
            ),
          ),
          _buildFilterChips(),
          Expanded(
            child: filteredMovies.isEmpty
                ? const Center(
              child: Text(
                'No movies found\nAdd some movies to your watchlist!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18),
              ),
            )
                : ListView.builder(
              itemCount: filteredMovies.length,
              itemBuilder: (context, index) {
                final movie = filteredMovies[index];
                return MovieCard(
                  movie: movie,
                  onEdit: () => _navigateToEditScreen(movie),
                  onDelete: () => _deleteMovie(movie['id']),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddScreen,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: ['All', 'Watched', 'Want to Watch'].map((status) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: FilterChip(
              label: Text(status),
              selected: _filterStatus == status,
              onSelected: (selected) {
                setState(() {
                  _filterStatus = selected ? status : 'All';
                });
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  void _navigateToAddScreen() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddMovieScreen()),
    );
    setState(() {}); // Re-render after returning
  }

  void _navigateToEditScreen(Map<String, dynamic> movie) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditMovieScreen(movie: movie),
      ),
    );
    setState(() {});
  }

  void _deleteMovie(int id) {
    setState(() {
      mockMovies.removeWhere((movie) => movie['id'] == id);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Movie deleted successfully')),
    );
  }
}
