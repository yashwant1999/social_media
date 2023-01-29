import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:social_media/core/common/error.dart';
import 'package:social_media/core/common/loader.dart';
import 'package:social_media/features/post/controller/post_controller.dart';
import 'package:social_media/features/search/controller/search_controller.dart';

class SearchScren extends ConsumerStatefulWidget {
  const SearchScren({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _SearchScrenState();
}

class _SearchScrenState extends ConsumerState<SearchScren> {
  /// Text controller for searching query
  final TextEditingController _textEditingController = TextEditingController();

  /// bool for whether to show users or posts when do searching.
  bool isShowUser = false;

  /// Focus node to remove the focus from texfield when user tap somewhere outside of it.
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (_focusNode.hasFocus) {
          _focusNode.unfocus();
        }
      },
      child: Scaffold(
        extendBody: false,
        appBar: AppBar(
          actions: [
            if (isShowUser)
              IconButton(
                onPressed: () {
                  _textEditingController.clear();
                  _focusNode.unfocus();
                  setState(() {
                    isShowUser = false;
                  });
                },
                icon: const Icon(Icons.clear),
              )
          ],
          title: TextFormField(
            focusNode: _focusNode,
            controller: _textEditingController,
            decoration: InputDecoration(
                hintStyle: GoogleFonts.corben(
                  letterSpacing: 2,
                  fontWeight: FontWeight.w700,
                  fontSize: 24,
                ),
                border: InputBorder.none,
                hintText: 'Search'),
            onChanged: (value) => setState(() {
              isShowUser = value.isNotEmpty;
            }),
          ),
        ),
        body: isShowUser ? _buildUserListView() : _buildCustomGridView(),
      ),
    );
  }

  Widget _buildUserListView() {
    return ref.watch(searchUserProvider(_textEditingController.text)).when(
        data: (data) {
          return ListView(
              children: data
                  .map((e) => ListTile(
                        leading: CircleAvatar(
                          backgroundImage: NetworkImage(e.profilePic),
                        ),
                        trailing: Text(e.name),
                      ))
                  .toList());
        },
        error: (error, stackTrace) =>
            ErrorText(error: error, stackTrace: stackTrace),
        loading: () => const Loader());
  }

  Widget _buildCustomGridView() {
    return ref.watch(userPostProvider).when(
          data: (data) {
            final itemCount = data
                .map((e) => e.image)
                .toList()
                .expand((element) => element)
                .toList();
            return GridView.custom(
              physics: const BouncingScrollPhysics(),
              gridDelegate: SliverQuiltedGridDelegate(
                  crossAxisCount: 3,
                  mainAxisSpacing: 8.0,
                  crossAxisSpacing: 8.0,
                  repeatPattern: QuiltedGridRepeatPattern.inverted,
                  pattern: [
                    const QuiltedGridTile(2, 2),
                    const QuiltedGridTile(1, 1),
                    const QuiltedGridTile(1, 1),
                    // const QuiltedGridTile(1, 2)
                  ]),
              padding:
                  const EdgeInsets.symmetric(horizontal: 5).copyWith(top: 10),
              childrenDelegate: SliverChildBuilderDelegate(
                childCount: itemCount.length,
                (context, index) => ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: CachedNetworkImage(
                    memCacheHeight: 500,
                    placeholder: (context, url) => const Center(
                      child: CupertinoActivityIndicator(),
                    ),
                    imageUrl: itemCount[index].imageUrl,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            );
          },
          error: (error, stackTrace) =>
              ErrorText(error: error, stackTrace: stackTrace),
          loading: () => const Loader(),
        );
  }
}






 // staggeredTileBuilder: (index) => MediaQuery.of(context)
              //             .size
              //             .width >
              //         webScreenSize
              //     ? StaggeredTile.count(
              //         (index % 7 == 0) ? 1 : 1, (index % 7 == 0) ? 1 : 1)
              //     : StaggeredTile.count(
              //         (index % 7 == 0) ? 2 : 1, (index % 7 == 0) ? 2 : 1),
           