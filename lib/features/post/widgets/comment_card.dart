import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:social_media/core/common/animated_button.dart';
import 'package:social_media/features/post/controller/post_controller.dart';

class CommentCard extends ConsumerWidget {
  final String profileUrl;
  final String commentId;
  final String userName;
  final String description;
  final DateTime createdAt;

  const CommentCard(
      {Key? key,
      required this.profileUrl,
      required this.commentId,
      required this.userName,
      required this.description,
      required this.createdAt})
      : super(key: key);

  void deleteComment(WidgetRef ref) {
    ref.read(postControllerProvider.notifier).deleteComment(commentId);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      child: Row(
        children: [
          CircleAvatar(
            backgroundImage: NetworkImage(profileUrl),
            radius: 18,
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                            text: userName,
                            style: Theme.of(context).textTheme.bodyLarge),
                        TextSpan(
                            text: ' $description',
                            style: Theme.of(context).textTheme.bodyMedium),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      DateFormat.yMMMd().format(createdAt),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
          const SizedBox(
            width: 8,
          ),
          Bounceable2(
              onTap: () => deleteComment(ref),
              child: const Icon(
                Icons.delete,
                size: 20,
              ))
        ],
      ),
    );
  }
}
