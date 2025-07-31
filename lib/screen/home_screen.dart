// screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:movie_watchlist/database/database_helper.dart';
import 'package:movie_watchlist/models/movie_model.dart';
import 'package:movie_watchlist/screens/add_movie_screen.dart';
import 'package:movie_watchlist/screens/edit_movie_screen.dart';
import 'package:movie_watchlist/widgets/movie_card.dart';
import 'package:movie_watchlist/widgets/search_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<Movie>> _moviesFuture;
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  String _searchQuery = '';
  String _filterStatus = 'All';

  @override
  void initState() {
    super.initState();
    _refreshMovies();
  }

  void _refreshMovies() {
    setState(() {
      if (_searchQuery.isNotEmpty) {
        _moviesFuture = _dbHelper.searchMovies(_searchQuery);
      } else if (_filterStatus != 'All') {
        _moviesFuture = _dbHelper.getMoviesByStatus(_filterStatus);
      } else {
        _moviesFuture = _dbHelper.getAllMovies();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Movie Watchlist'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshMovies,
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
                  _refreshMovies();
                });
              },
            ),
          ),
          _buildFilterChips(),
          Expanded(
            child: FutureBuilder<List<Movie>>(
              future: _moviesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text(
                      'No movies found\nAdd some movies to your watchlist!',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 18),
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    final movie = snapshot.data![index];
                    return MovieCard(
                      movie: movie,
                      onEdit: () => _navigateToEditScreen(movie),
                      onDelete: () => _deleteMovie(movie.id!),
                    );
                  },
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
                  _refreshMovies();
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
    _refreshMovies();
  }

  void _navigateToEditScreen(Movie movie) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditMovieScreen(movie: movie),
      ),
    );
    _refreshMovies();
  }

  void _deleteMovie(int id) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Movie'),
        content: const Text('Are you sure you want to delete this movie?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (shouldDelete == true) {
      await _dbHelper.deleteMovie(id);
      _refreshMovies();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Movie deleted successfully')),
      );
    }
  }
}