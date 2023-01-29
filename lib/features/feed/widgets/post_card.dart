import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:social_media/core/common/animated_button.dart';
import 'package:social_media/features/auth/controller/auth_controller.dart';
import 'package:social_media/features/feed/widgets/custom_page_view.dart';
import 'package:social_media/features/feed/widgets/like_animation.dart';
import 'package:social_media/features/post/controller/post_controller.dart';
import 'package:social_media/models/post_model.dart';
import 'package:routemaster/routemaster.dart';

class PostCard extends ConsumerStatefulWidget {
  final String profileUrl;
  final String id;
  final String uid;
  final String userName;
  final List<ImageX> imagex;
  final List<String> likes;
  final String description;
  final DateTime createdAt;
  final int comments;
  const PostCard(
      {Key? key,
      required this.uid,
      required this.imagex,
      required this.id,
      required this.profileUrl,
      required this.userName,
      required this.likes,
      required this.description,
      required this.createdAt,
      required this.comments})
      : super(key: key);

  @override
  ConsumerState<PostCard> createState() => _PostCardState();
}

class _PostCardState extends ConsumerState<PostCard>
    with AutomaticKeepAliveClientMixin {
  // Bool for providing animation when user tap to like the photo.
  bool isLikeAnimating = false;

  /// Delete functionality for post. So when  PostId [id] is equal to [userid]
  /// it show delete option otherwise not.
  void deletePost(WidgetRef ref, BuildContext context, List<ImageX> images) {
    ref
        .read(postControllerProvider.notifier)
        .deletePost(widget.id, context, images);
  }

  // like the post.
  Future<void> likePost() async {
    await ref
        .read(postControllerProvider.notifier)
        .likePost(widget.id, widget.likes);
  }

  // Navigate to the comment screen.
  void navigateToCommentScreen(BuildContext context) {
    Routemaster.of(context).push('/post/${widget.id}/comments');
  }

  // Navigate to the user profile.
  void navigateToUser(BuildContext context) {
    Routemaster.of(context).push('/u/${widget.uid}');
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Padding(
      padding: const EdgeInsets.all(3.0),
      child: Card(
        // padding: const EdgeInsets.symmetric(vertical: 10),
        child: Column(children: [
          _buildHeader(context),
          _buildMedia(context),
          _buildDescription(context),
        ]),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16)
          .copyWith(right: 0),
      child: Row(
        children: [
          Bounceable2(
            onTap: () => navigateToUser(context),
            child: CircleAvatar(
              radius: 16,
              backgroundImage: NetworkImage(widget.profileUrl),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.userName,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
          IconButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => Dialog(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shrinkWrap: true,
                    children: const [
                      'Delete',
                    ]
                        .map((e) => InkWell(
                              onTap: () {
                                deletePost(ref, context, widget.imagex);
                                Routemaster.of(context).pop();
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 12, horizontal: 16),
                                child: Text(e),
                              ),
                            ))
                        .toList(),
                  ),
                ),
              );
            },
            icon: const Icon(Icons.more_vert),
          )
        ],
      ),
    );
  }

  Widget _buildMedia(BuildContext context) {
    return GestureDetector(
      onDoubleTap: () async {
        await likePost();

        setState(() {
          isLikeAnimating = true;
        });
      },
      child: AspectRatio(
        aspectRatio: _getLargestAspectRatio(),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: CusomPageView(widget: widget),
              ),
            ),
            AnimatedOpacity(
              duration: const Duration(milliseconds: 200),
              opacity: isLikeAnimating ? 1 : 0,
              child: LikeAnimation(
                isAnimating: isLikeAnimating,
                duration: const Duration(milliseconds: 400),
                child: Icon(
                  Icons.favorite,
                  size: 120,
                  color: Theme.of(context).colorScheme.onBackground,
                ),
                onEnd: () {
                  setState(() {
                    isLikeAnimating = false;
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  _getLargestAspectRatio() {
    final aspectRatio = widget.imagex
        .map(
          (e) => e.width!.toInt() / e.height!.toInt(),
        )
        .toList();
    return aspectRatio.reduce(min);
  }

  Widget _buildDescription(BuildContext context) {
    final bool isContainedUid =
        widget.likes.contains(ref.watch(userProvider)!.uid);
    return Column(
      children: [
        Row(
          children: [
            LikeAnimation(
              isAnimating: isContainedUid,
              child: IconButton(
                onPressed: () async {
                  await likePost();
                },
                icon: isContainedUid
                    ? const Icon(
                        Icons.favorite,
                        color: Colors.red,
                      )
                    : const Icon(Icons.favorite_border),
              ),
            ),
            IconButton(
              onPressed: () => navigateToCommentScreen(context),
              icon: const Icon(
                Icons.comment_outlined,
              ),
            ),
            IconButton(
              onPressed: () {},
              icon: const Icon(
                Icons.send,
              ),
            ),
            Expanded(
              child: Align(
                alignment: Alignment.bottomRight,
                child: IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.bookmark),
                ),
              ),
            )
          ],
        ),
        _buildComment(context)
      ],
    );
  }

  Widget _buildComment(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DefaultTextStyle(
            style: Theme.of(context)
                .textTheme
                .subtitle2!
                .copyWith(fontWeight: FontWeight.bold),
            child: Text(
              '${widget.likes.length} likes',
              style: Theme.of(context).textTheme.bodyText2,
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(
              top: 8,
            ),
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: widget.userName,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  TextSpan(
                      text: ' ${widget.description}',
                      style: Theme.of(context).textTheme.bodyMedium),
                ],
              ),
            ),
          ),
          // TODO: Bounceable widget is not handling hotrealod properly will look into
          // TODO: what is reaseanble.
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Bounceable2(
                  onTap: () => navigateToCommentScreen(context),
                  child: Text(
                    'View all ${widget.comments} comments',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                ),
                Text(
                  DateFormat.yMMMd().format(widget.createdAt),
                  style: const TextStyle(
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
