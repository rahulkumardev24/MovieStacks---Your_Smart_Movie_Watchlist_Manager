class MovieModel {
  final int? id;
  final String title;
  final String releaseYear;
  final double? rating;
  final String status;

  MovieModel({
    this.id,
    required this.title,
    required this.rating,
    required this.releaseYear,
    required this.status,
  });

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "title": title,
      "rating": rating,
      "releaseYear": releaseYear,
      "status": status,
    };
  }

  factory MovieModel.fromJson(Map<String, dynamic> json) {
    return MovieModel(
      title: json['title'] as String,
      rating: json['rating'] as double,
      releaseYear: json['releaseYear'] as String,
      status: json['status'] as String,
    );
  }
}
