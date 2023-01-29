import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:social_media/core/common/error.dart';
import 'package:social_media/core/utils.dart';
import 'package:social_media/features/auth/controller/auth_controller.dart';
import 'package:social_media/features/post/controller/post_controller.dart';
import 'package:social_media/features/post/widgets/comment_card.dart';

class CommentsScreen extends ConsumerStatefulWidget {
  final String postId;
  const CommentsScreen({Key? key, required this.postId}) : super(key: key);

  @override
  CommentsScreenState createState() => CommentsScreenState();
}

class CommentsScreenState extends ConsumerState<CommentsScreen> {
  final TextEditingController commentEditingController =
      TextEditingController();

  void postComment(String text) {
    if (commentEditingController.text.isNotEmpty) {
      ref
          .read(postControllerProvider.notifier)
          .addComment(context, text: text, postId: widget.postId);
      commentEditingController.clear();
    } else {
      showSnackBar(context, 'Field is empty');
    }
  }

  @override
  Widget build(BuildContext context) {
    final comment = ref.watch(getPostCommentsProvider(widget.postId));
    final user = ref.watch(userProvider)!;
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Comments',
        ),
        centerTitle: false,
      ),
      body: comment.when(
        data: (data) {
          return ListView.builder(
              itemCount: data.length,
              itemBuilder: (context, index) {
                final comment = data[index];

                return CommentCard(
                    commentId: comment.id,
                    profileUrl: comment.profilePic,
                    userName: comment.username,
                    description: comment.text,
                    createdAt: comment.createdAt);
              });
        },
        error: ((error, stackTrace) => ErrorText(
              error: error,
              stackTrace: stackTrace,
            )),
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
      ),
      // text input
      bottomNavigationBar: SafeArea(
        child: Container(
          height: kToolbarHeight,
          margin:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          padding: const EdgeInsets.only(left: 16, right: 8),
          child: Row(
            children: [
              CircleAvatar(
                backgroundImage: NetworkImage(user.profilePic),
                radius: 18,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 16, right: 8),
                  child: TextField(
                    controller: commentEditingController,
                    decoration: InputDecoration(
                      hintText: 'Comment as ${user.name}',
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
              InkWell(
                onTap: () =>
                    postComment(commentEditingController.value.text.trim()),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                  child: const Text(
                    'Post',
                    style: TextStyle(color: Colors.blue),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
