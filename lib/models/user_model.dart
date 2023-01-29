class UserModel {
  final String name;
  final String profilePic;
  final String banner;
  final String uid;
  final bool isAuthenticated; // if guest or not
  final String bio;
  final List followers;
  final List following;

  UserModel({
    required this.name,
    required this.profilePic,
    required this.banner,
    required this.uid,
    required this.isAuthenticated,
    required this.bio,
    required this.following,
    required this.followers,
  });

  UserModel copyWith({
    String? name,
    String? profilePic,
    String? banner,
    String? uid,
    bool? isAuthenticated,
    String? bio,
    List? following,
    List? followers,
  }) {
    return UserModel(
        name: name ?? this.name,
        profilePic: profilePic ?? this.profilePic,
        banner: banner ?? this.banner,
        uid: uid ?? this.uid,
        isAuthenticated: isAuthenticated ?? this.isAuthenticated,
        bio: bio ?? this.bio,
        following: following ?? this.following,
        followers: followers ?? this.followers);
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'profilePic': profilePic,
      'banner': banner,
      'uid': uid,
      'isAuthenticated': isAuthenticated,
      'bio': bio,
      'following': following,
      'followers': followers,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      name: map['name'] ?? '',
      profilePic: map['profilePic'] ?? '',
      banner: map['banner'] ?? '',
      uid: map['uid'] ?? '',
      isAuthenticated: map['isAuthenticated'] ?? false,
      bio: map['bio'] ?? '',
      following: map['following'] ?? [],
      followers: map['followers'] ?? [],
    );
  }

  @override
  String toString() {
    return 'UserModel(name: $name, profilePic: $profilePic, banner: $banner, uid: $uid, isAuthenticated: $isAuthenticated, bio: $bio, followers : $followers,following : $following)';
  }
}
