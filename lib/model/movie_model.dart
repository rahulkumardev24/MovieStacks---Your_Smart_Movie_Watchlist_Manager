class MovieModel {
  final int? id;
  final String title;
  final String releaseYear;
  final double rating;
  final String status;

  MovieModel({
    this.id,
    required this.title,
    required this.releaseYear,
    required this.rating,
    required this.status,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'release_year': releaseYear,
      'rating': rating,
      'status': status,
    };
  }

  factory MovieModel.fromMap(Map<String, dynamic> map) {
    return MovieModel(
      id: map['id'] as int?,
      title: map['title'] as String,
      releaseYear: map['release_year'] as String,
      rating: map['rating'] as double,
      status: map['status'] as String,
    );
  }
}