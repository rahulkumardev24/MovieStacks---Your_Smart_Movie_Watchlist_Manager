import 'package:flutter/material.dart';
import 'package:moviestacks/model/movie_model.dart';
import 'package:moviestacks/database/database_helper.dart';


class EditMovieScreen extends StatefulWidget {
  final MovieModel movie;

  const EditMovieScreen({super.key, required this.movie});

  @override
  State<EditMovieScreen> createState() => _EditMovieScreenState();
}

class _EditMovieScreenState extends State<EditMovieScreen> {
  late final _formKey = GlobalKey<FormState>();
  late final _titleController = TextEditingController(text: widget.movie.title);
  late final _yearController = TextEditingController(text: widget.movie.releaseYear);
  late final _ratingController = TextEditingController(text: widget.movie.rating.toString());
  late String _status = widget.movie.status;
  bool _isUpdating = false;

  @override
  void dispose() {
    _titleController.dispose();
    _yearController.dispose();
    _ratingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Movie', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Movie Poster Placeholder (could be implemented later)
                  _buildMovieHeader(),
                  const SizedBox(height: 20),

                  // Title Field
                  _buildTextField(
                    controller: _titleController,
                    label: 'Movie Title',
                    icon: Icons.movie_creation_outlined,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a movie title';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // Year and Rating Row
                  Row(
                    children: [
                      // Release Year
                      Expanded(
                        child: _buildTextField(
                          controller: _yearController,
                          label: 'Year',
                          icon: Icons.calendar_today,
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Enter year';
                            }
                            if (int.tryParse(value) == null) {
                              return 'Invalid year';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 16),

                      // Rating
                      Expanded(
                        child: _buildTextField(
                          controller: _ratingController,
                          label: 'Rating (0-10)',
                          icon: Icons.star_rate_rounded,
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Enter rating';
                            }
                            final rating = double.tryParse(value);
                            if (rating == null || rating < 0 || rating > 10) {
                              return '0-10 only';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Status Dropdown
                  _buildStatusDropdown(),
                  const SizedBox(height: 30),

                  // Update Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isUpdating ? null : _updateMovie,
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: _isUpdating
                          ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                          : const Text(
                        'UPDATE MOVIE',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  // Delete Button
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: _confirmDelete,
                    child: const Text(
                      'Delete Movie',
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMovieHeader() {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
        image: const DecorationImage(
          image: AssetImage('assets/images/movie_placeholder.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: Center(
        child: Icon(
          Icons.edit,
          size: 40,
          color: Colors.white.withOpacity(0.8),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String? Function(String?) validator,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.grey),
        prefixIcon: Icon(icon, color: Colors.grey),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
      ),
      validator: validator,
    );
  }

  Widget _buildStatusDropdown() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: DropdownButtonFormField<String>(
          value: _status,
          decoration: const InputDecoration(
            border: InputBorder.none,
            prefixIcon: Icon(Icons.visibility, color: Colors.grey),
            labelText: 'Status',
            labelStyle: TextStyle(color: Colors.grey),
          ),
          items: ['Want to Watch', 'Watched'].map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: (newValue) {
            setState(() {
              _status = newValue!;
            });
          },
          dropdownColor: Colors.white,
          icon: const Icon(Icons.arrow_drop_down, color: Colors.grey),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Future<void> _updateMovie() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isUpdating = true);

    final updatedMovie = MovieModel(
      id: widget.movie.id,
      title: _titleController.text,
      releaseYear: _yearController.text,
      rating: double.parse(_ratingController.text),
      status: _status,
    );

    try {
      await DatabaseHelper.instance.updateMovie(updatedMovie);
      if (!mounted) return;
      Navigator.pop(context, true); // Return success
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating movie: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isUpdating = false);
    }
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Movie?'),
        content: const Text('This action cannot be undone.'),
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

    if (confirmed == true) {
      try {
        await DatabaseHelper.instance.deleteMovie(widget.movie.id!);
        if (!mounted) return;
        Navigator.pop(context, true); // Return success
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting movie: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}