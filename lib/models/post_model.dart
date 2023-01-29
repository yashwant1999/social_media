class Post {
  final String id;
  final List<ImageX> image;
  final String userProfile;
  final List<String> likeCount;
  final String? description;
  final int commentCount;
  final String userName;
  final String uid;
  final DateTime createdAt;

  Post({
    required this.id,
    required this.image,
    required this.likeCount,
    required this.userProfile,
    this.description,
    required this.commentCount,
    required this.userName,
    required this.uid,
    required this.createdAt,
  });

  Post copyWith({
    String? id,
    List<ImageX>? image,
    String? userProfile,
    List<String>? likeCount,
    String? description,
    int? commentCount,
    String? userName,
    String? uid,
    DateTime? createdAt,
  }) {
    return Post(
      image: image ?? this.image,
      id: id ?? this.id,
      userProfile: userProfile ?? this.userProfile,
      likeCount: likeCount ?? this.likeCount,
      description: description ?? this.description,
      commentCount: commentCount ?? this.commentCount,
      userName: userName ?? this.userName,
      uid: uid ?? this.uid,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    List<Map<String, dynamic>> images = [];
    for (var image in this.image) {
      images.add(image.toMap());
    }
    return {
      'id': id,
      'image': images,
      'description': description,
      'commentCount': commentCount,
      'userName': userName,
      'uid': uid,
      'userProfile': userProfile,
      'likeCount': likeCount,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }

  factory Post.fromMap(Map<String, dynamic> map) {
    List<ImageX> images = [];
    for (var image in map['image']) {
      images.add(ImageX.fromMap(image));
    }
    return Post(
      image: images,
      id: map['id'] ?? '',
      description: map['description'] ?? '',
      commentCount: map['commentCount'] ?? 0,
      userName: map['userName'] ?? '',
      uid: map['uid'] ?? '',
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
      likeCount: List<String>.from(map['likeCount'] ?? []),
      userProfile: map['userProfile'] ?? '',
    );
  }
}

class ImageX {
  final String imageUrl;
  final int? height;
  final int? width;

  ImageX({required this.imageUrl, required this.height, required this.width});

  factory ImageX.fromMap(Map<String, dynamic> map) {
    return ImageX(
        imageUrl: map['imageUrl'] ?? '',
        height: map['height'] ?? 100,
        width: map['width'] ?? 100);
  }

  Map<String, dynamic> toMap() {
    return {
      'imageUrl': imageUrl,
      'height': height,
      'width': width,
    };
  }
}
