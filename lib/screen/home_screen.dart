import 'package:flutter/material.dart';
import 'package:moviestacks/model/movie_model.dart';
import 'package:moviestacks/database/database_helper.dart';
import 'package:moviestacks/widgets/movies_card.dart';
import 'package:moviestacks/widgets/search_bar.dart';
import 'package:shimmer/shimmer.dart';

import '../helper/app_colors.dart';
import '../helper/app_style.dart';
import 'add_movies_screen.dart';
import 'edit_movies_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<MovieModel>> _moviesFuture;
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  String _searchQuery = '';
  String _filterStatus = 'All';
  bool _isRefreshing = false;
  final ScrollController _scrollController = ScrollController();
  double _elevation = 0;

  @override
  void initState() {
    super.initState();
    _refreshMovies();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    setState(() {
      _elevation = _scrollController.offset > 10 ? 4 : 0;
    });
  }

  Future<void> _refreshMovies() async {
    setState(() => _isRefreshing = true);

    final movies = _searchQuery.isNotEmpty
        ? await _dbHelper.searchMovies(_searchQuery)
        : _filterStatus != 'All'
        ? await _dbHelper.getMoviesByStatus(_filterStatus)
        : await _dbHelper.getAllMovies();

    if (mounted) {
      setState(() {
        _moviesFuture = Future.value(movies);
        _isRefreshing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: NestedScrollView(
        controller: _scrollController,
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              title: Text('MovieStacks', style: AppStyles.appBarTitle),
              centerTitle: true,
              backgroundColor: AppColors.background,
              elevation: _elevation,
              pinned: true,
              floating: true,
              snap: true,
              actions: [
                IconButton(
                  icon: _isRefreshing
                      ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.primary,
                    ),
                  )
                      : const Icon(Icons.refresh, color: AppColors.primary),
                  onPressed: _isRefreshing ? null : _refreshMovies,
                ),
              ],
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(110),
                child: Column(
                  children: [
                    // Search Bar
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                      child: Hero(
                        tag: 'search-bar',
                        child: Material(
                          color: Colors.transparent,
                          child: SearchBarWidget(
                            onChanged: (query) {
                              setState(() {
                                _searchQuery = query;
                                _refreshMovies();
                              });
                            },
                          ),
                        ),
                      ),
                    ),

                    // Filter Chips
                    _buildFilterChips(),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
          ];
        },
        body: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: _refreshMovies,
          child: FutureBuilder<List<MovieModel>>(
            future: _moviesFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting &&
                  !_isRefreshing) {
                return _buildShimmerLoading();
              } else if (snapshot.hasError) {
                return _buildErrorState(snapshot.error.toString());
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return _buildEmptyState();
              }

              return CustomScrollView(
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.all(16),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                            (context, index) {
                          final movie = snapshot.data![index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: MovieCard(
                              movie: movie,
                              onEdit: () => _navigateToEditScreen(movie),
                              onDelete: () => _deleteMovie(movie.id!),
                            ),
                          );
                        },
                        childCount: snapshot.data!.length,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        onPressed: _navigateToAddScreen,
        child: const Icon(Icons.add, size: 28, color: Colors.white),
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 6,
        itemBuilder: (context, index) {
          return Container(
            height: 120,
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: ['All', 'Watched', 'Want to Watch'].map((status) {
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
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

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/images/empty_state.png',
            height: 180,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 24),
          Text('Your Movie Stack is Empty',
              style: AppStyles.headlineMedium.copyWith(
                fontSize: 22,
                fontWeight: FontWeight.w700,
              )),
          const SizedBox(height: 8),
          Text('Start building your watchlist',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
              )),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _navigateToAddScreen,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
            ),
            child: const Text('Add First Movie',
                style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.red[400]),
            const SizedBox(height: 16),
            Text('Something went wrong',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                )),
            const SizedBox(height: 8),
            Text(error,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[600])),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _refreshMovies,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _navigateToAddScreen() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddMovieScreen(),
        fullscreenDialog: true,
      ),
    );
    if (result == true) _refreshMovies();
  }

  Future<void> _navigateToEditScreen(MovieModel movie) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EditMovieScreen(movie: movie)),
    );
    if (result == true) _refreshMovies();
  }

  Future<void> _deleteMovie(int id) async {
    final confirmed = await showDialog<bool>(
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
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _dbHelper.deleteMovie(id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Movie deleted'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            action: SnackBarAction(
              label: 'Undo',
              textColor: AppColors.primary,
              onPressed: () async {
                // Implement undo functionality
              },
            ),
          ),
        );
        _refreshMovies();
      }
    }
  }
}

class ChoiceChip extends StatelessWidget {
  final Widget label;
  final bool selected;
  final ValueChanged<bool> onSelected;

  const ChoiceChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: label,
      selected: selected,
      onSelected: onSelected,
      selectedColor: AppColors.primary.withOpacity(0.2),
      backgroundColor: Colors.grey[200],
      labelStyle: TextStyle(
        color: selected ? AppColors.primary : Colors.grey[800],
        fontWeight: FontWeight.w500,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: selected ? AppColors.primary : Colors.grey[300]!,
          width: 1,
        ),
      ),
      elevation: 0,
      showCheckmark: false,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    );
  }
}