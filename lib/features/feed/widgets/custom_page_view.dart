import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:social_media/features/feed/widgets/post_card.dart';

class CusomPageView extends StatefulWidget {
  const CusomPageView({
    Key? key,
    required this.widget,
  }) : super(key: key);

  final PostCard widget;

  @override
  State<CusomPageView> createState() => _CusomPageViewState();
}

class _CusomPageViewState extends State<CusomPageView> {
  /// Index regarding the in case user post multiple photo
  /// to handle the [PageView] count of pages and other functinality.
  int currentIndex = 1;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        PageView(
          onPageChanged: (value) => setState(() {
            currentIndex = value + 1;
          }),
          scrollDirection: Axis.horizontal,
          children: widget.widget.imagex
              .map(
                (e) => CachedNetworkImage(
                  placeholder: (context, url) => const Center(
                    child: CupertinoActivityIndicator(),
                  ),
                  imageUrl: e.imageUrl,
                  fit: BoxFit.cover,
                ),
              )
              .toList(),
        ),
        if (widget.widget.imagex.length > 1)
          Positioned(
            top: 5,
            right: 10,
            child: Chip(
              label: Text('$currentIndex/${widget.widget.imagex.length}'),
            ),
          ),
      ],
    );
  }
}
