import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:social_media/core/common/error.dart';
import 'package:social_media/features/auth/controller/auth_controller.dart';
import 'package:social_media/features/feed/widgets/post_card.dart';
import 'package:social_media/features/post/controller/post_controller.dart';
import 'package:social_media/theme/pallete.dart';

import '../../../core/common/loader.dart';

class FeedScreen extends ConsumerStatefulWidget {
  const FeedScreen({super.key});

  @override
  ConsumerState<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends ConsumerState<FeedScreen> {
  bool keepAlive = false;

  // function to show color picker dialog.
  void showColorPickerDialog(BuildContext parentContext) {
    final color = ref.watch(colorProvider);
    Color? localColor;
    showDialog(
        context: parentContext,
        builder: (context) {
          return AlertDialog(
            actions: [
              ElevatedButton(
                  onPressed: () {
                    if (localColor != null) {
                      ref
                          .read(colorProvider.notifier)
                          .setValue(localColor!.value);
                      Navigator.of(context).pop();
                    }
                  },
                  child: const Icon(Icons.done))
            ],
            title: const Text('Color Picker'),
            content: SingleChildScrollView(
              child: ColorPicker(
                pickerAreaHeightPercent: 0.6,
                pickerAreaBorderRadius: BorderRadius.circular(18),
                pickerColor: color,
                onColorChanged: ((value) => localColor = value),
              ),
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    final post = ref.watch(userPostProvider);
    final user = ref.watch(userProvider)!;
    return Scaffold(
      body: SafeArea(
        child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            SliverAppBar(
              actions: [
                IconButton(
                    onPressed: () => showColorPickerDialog(context),
                    icon: const Icon(Icons.color_lens))
                // Padding(
                //   padding: const EdgeInsets.all(8.0),
                //   child: CupertinoSwitch(
                //       onChanged: (bool value) {
                //         setState(() {
                //           keepAlive = value;
                //         });
                //       },
                //       value: keepAlive),
                // ),
              ],
              scrolledUnderElevation: 0,
              floating: true,
              snap: true,
              stretch: true,
              centerTitle: true,
              title: Text('Space',
                  style: GoogleFonts.corben(
                    letterSpacing: 2,
                    fontWeight: FontWeight.w700,
                    fontSize: 24,
                  )),
            ),

            // This is swtich to toggle the keepAlive functionality in [ListView.builder].
          ],
          body: post.when(
              data: (data) {
                return ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    addAutomaticKeepAlives: keepAlive,
                    cacheExtent: MediaQuery.of(context).size.height * 3,
                    itemCount: data.length,
                    itemBuilder: (context, index) {
                      final post = data[index];
                      return PostCard(
                        uid: post.uid,
                        id: post.id,
                        profileUrl: user.uid == post.uid
                            ? user.profilePic
                            : post.userProfile,
                        userName: post.userName,
                        likes: post.likeCount,
                        description: post.description!,
                        createdAt: post.createdAt,
                        comments: post.commentCount,
                        imagex: post.image,
                      );
                    });
              },
              error: ((error, stackTrace) => SingleChildScrollView(
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      children: [
                        ErrorText(
                          error: error,
                          stackTrace: stackTrace,
                        ),
                        Text(stackTrace.toString())
                      ],
                    ),
                  )),
              loading: () => const Loader()),
        ),
      ),
    );
  }
}
