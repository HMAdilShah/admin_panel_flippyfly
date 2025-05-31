class Post {
  final String description;
  final String formattedDateTime;
  final String imageUrl;
  final String postId;
  final String title;
  final String userEmail;
  final String userId;

  Post({
    required this.description,
    required this.formattedDateTime,
    required this.imageUrl,
    required this.postId,
    required this.title,
    required this.userEmail,
    required this.userId,
  });

  factory Post.fromMap(Map<String, dynamic> map) {
    return Post(
      description: map['description'] ?? '',
      formattedDateTime: map['formatted_date_time'] ?? '',
      imageUrl: map['image_url'] ?? '',
      postId: map['post_id'] ?? '',
      title: map['title'] ?? '',
      userEmail: map['user_email'] ?? '',
      userId: map['user_id'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'description': description,
      'formatted_date_time': formattedDateTime,
      'image_url': imageUrl,
      'post_id': postId,
      'title': title,
      'user_email': userEmail,
      'user_id': userId,
    };
  }

  Post copyWith({
    String? description,
    String? formattedDateTime,
    String? imageUrl,
    String? postId,
    String? title,
    String? userEmail,
    String? userId,
  }) {
    return Post(
      description: description ?? this.description,
      formattedDateTime: formattedDateTime ?? this.formattedDateTime,
      imageUrl: imageUrl ?? this.imageUrl,
      postId: postId ?? this.postId,
      title: title ?? this.title,
      userEmail: userEmail ?? this.userEmail,
      userId: userId ?? this.userId,
    );
  }
}
