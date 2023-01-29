import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:social_media/core/constants/firebase_constants.dart';
import 'package:social_media/core/failure.dart';
import 'package:social_media/core/provider/firebase_provider.dart';
import 'package:social_media/core/type_defs.dart';
import 'package:social_media/models/comment_model.dart';
import 'package:social_media/models/post_model.dart';

final postRepositoryProvider = Provider<PostRepository>((ref) {
  return PostRepository(firestore: ref.read(firestoreProvider));
});

class PostRepository {
  final FirebaseFirestore _firestore;

  PostRepository({
    required FirebaseFirestore firestore,
  }) : _firestore = firestore;

  CollectionReference<Object?> get postCollection =>
      _firestore.collection(FirebaseConstants.postsCollection);

  CollectionReference<Object?> get commentCollection =>
      _firestore.collection(FirebaseConstants.commentsCollection);

  FutureVoid addPost(Post post) async {
    try {
      return right(postCollection.doc(post.id).set(
            post.toMap(),
          ));
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  FutureVoid addComment(Comment comment) async {
    try {
      await commentCollection.doc(comment.id).set(comment.toMap());
      return right(
        postCollection.doc(comment.postId).update(
          {'commentCount': FieldValue.increment(1)},
        ),
      );
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  Stream<List<Comment>> getCommentbyPostId(String postId) {
    return commentCollection
        .where('postId', isEqualTo: postId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (event) => event.docs
              .map(
                (e) => Comment.fromMap(
                  e.data() as Map<String, dynamic>,
                ),
              )
              .toList(),
        );
  }

  FutureVoid deletePost(String postId) async {
    try {
      return right(postCollection.doc(postId).delete());
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  Stream<List<Post>> fetchUserPosts() {
    return postCollection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (event) => event.docs
              .map(
                (e) => Post.fromMap(e.data() as Map<String, dynamic>),
              )
              .toList(),
        );
  }

  FutureVoid deleteComment(String commentId) async {
    try {
      return right(commentCollection.doc(commentId).delete());
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  FutureVoid deleteCommentsbyPostId(String postId) async {
    try {
      final comments = commentCollection
          .where('postId', isEqualTo: postId)
          .orderBy('createdAt', descending: true)
          .snapshots();
      await for (var snapshot in comments) {
        for (var comment in snapshot.docs) {
          await comment.reference.delete();
        }
      }
      return right(null);
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  Future<void> likePost(
      String postId, String userid, List<String> likeCount) async {
    if (likeCount.contains(userid)) {
      await postCollection.doc(postId).update({
        'likeCount': FieldValue.arrayRemove([userid])
      });
    } else {
      await postCollection.doc(postId).update(
        {
          'likeCount': FieldValue.arrayUnion(
            [userid],
          ),
        },
      );
    }
  }
}
