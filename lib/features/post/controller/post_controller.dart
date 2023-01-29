import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:social_media/core/provider/storage_repository_provider.dart';
import 'package:social_media/core/utils.dart';
import 'package:social_media/features/auth/controller/auth_controller.dart';
import 'package:social_media/features/post/respository/post_repository.dart';
import 'package:social_media/models/comment_model.dart';
import 'package:social_media/models/post_model.dart';
import 'package:uuid/uuid.dart';

final postControllerProvider =
    StateNotifierProvider<PostController, bool>((ref) {
  return PostController(
      postRepository: ref.watch(postRepositoryProvider),
      ref: ref,
      storageRepository: ref.watch(storageRepositoryProvider));
});

final userPostProvider = StreamProvider((ref) {
  final postController = ref.watch(postControllerProvider.notifier);
  return postController.fetchUserPosts();
});
final getPostCommentsProvider = StreamProvider.family((ref, String postId) {
  final postController = ref.watch(postControllerProvider.notifier);
  return postController.fetchPostComments(postId);
});

class PostController extends StateNotifier<bool> {
  final PostRepository _postRepository;
  final Ref _ref;
  final StorageRepository _storageRepository;

  PostController({
    required PostRepository postRepository,
    required Ref ref,
    required StorageRepository storageRepository,
  })  : _postRepository = postRepository,
        _storageRepository = storageRepository,
        _ref = ref,
        super(false);

  void shareImagePost({
    required BuildContext context,
    required String? description,
    required List<Uint8List> images,
  }) async {
    state = true;

    String postId = const Uuid().v1();
    final user = _ref.watch(userProvider)!;

    // uploading all file to firebase storage
    final res = await _storageRepository.uploadMultipalImagesToStorage(
        path: 'posts/${user.name}', id: postId, images: images);

    // adding post to firebae database
    res.fold((l) => showSnackBar(context, 'Facing problem uploading images.'),
        (r) async {
      final Post post = Post(
        id: postId,
        commentCount: 0,
        userName: user.name,
        uid: user.uid,
        createdAt: DateTime.now(),
        description: description ?? '',
        likeCount: [],
        image: r,
        userProfile: user.profilePic,
      );

      final result = await _postRepository.addPost(post);

      result.fold((l) => showSnackBar(context, l.message), (r) {
        showSnackBar(context, 'Posted Successfully');
      });
    });
    state = false;
  }

  void deletePost(
      String postId, BuildContext context, List<ImageX> images) async {
    final resFromFireStorage = await _storageRepository.deleteFile(
        urls: images.map((e) => e.imageUrl).toList());
    final resFromFirestore = await _postRepository.deletePost(postId);
    deleteCommentsbyPostId(postId);
    resFromFirestore.fold((l) => showSnackBar(context, l.message), (r) {
      resFromFireStorage.fold((l) => showSnackBar(context, l.message),
          (r) => showSnackBar(context, 'Post Deleted Successfully'));
    });
  }

  void addComment(BuildContext context,
      {required String text, required String postId}) async {
    final user = _ref.read(userProvider)!;
    String commentId = const Uuid().v1();
    final Comment comment = Comment(
        id: commentId,
        text: text,
        createdAt: DateTime.now(),
        postId: postId,
        username: user.name,
        profilePic: user.profilePic);
    final res = await _postRepository.addComment(comment);
    res.fold((l) => showSnackBar(context, l.message), (r) => null);
  }

  Future<void> likePost(String postId, List<String> likeCount) async {
    final uid = _ref.read(userProvider)!.uid;
    await _postRepository.likePost(postId, uid, likeCount);
  }

  Stream<List<Post>> fetchUserPosts() {
    return _postRepository.fetchUserPosts();
  }

  Stream<List<Comment>> fetchPostComments(String postId) {
    return _postRepository.getCommentbyPostId(postId);
  }

  void deleteCommentsbyPostId(String postId) async {
    await _postRepository.deleteCommentsbyPostId(postId);
  }

  void deleteComment(String commentId) async {
    _postRepository.deleteComment(commentId);
  }
}
