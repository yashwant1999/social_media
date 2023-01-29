import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:social_media/features/auth/controller/auth_controller.dart';
import 'package:social_media/features/post/controller/post_controller.dart';

class EditPostScreen extends ConsumerStatefulWidget {
  final List<Uint8List>? images;
  const EditPostScreen({Key? key, required this.images}) : super(key: key);

  @override
  EditPostScreenState createState() => EditPostScreenState();
}

class EditPostScreenState extends ConsumerState<EditPostScreen> {
  final TextEditingController _descriptionController = TextEditingController();

  // function to share the post and upload it on firebase.
  void _sharePostImage() {
    ref.read(postControllerProvider.notifier).shareImagePost(
          context: context,
          description: _descriptionController.text.trim(),
          images: widget.images!,
        );
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(postControllerProvider);

    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black,
          // we'll se if navigator solve this issue.
          // leading: IconButton(
          //   icon: const Icon(Icons.arrow_back),
          //   onPressed: clearImage,
          // ),
          title: const Text(
            'Post to',
          ),
          centerTitle: false,
          actions: <Widget>[
            TextButton(
              onPressed: () => _sharePostImage(),
              child: const Text(
                "Post",
                style: TextStyle(
                    color: Colors.blueAccent,
                    fontWeight: FontWeight.bold,
                    fontSize: 16.0),
              ),
            )
          ],
        ),
        body: Column(
          children: [
            isLoading
                ? const LinearProgressIndicator()
                : const Padding(padding: EdgeInsets.only(top: 0.0)),
            const Divider(),
            _buildContainer(),
            const Divider()
          ],
        ));
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Widget _buildContainer() {
    final user = ref.watch(userProvider)!;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Profile pic of user who is editing.
        CircleAvatar(
          backgroundImage: NetworkImage(user.profilePic),
        ),
        // Space for writing the description of the post
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.5,
          child: TextField(
            controller: _descriptionController,
            decoration: const InputDecoration(
                hintText: "Write a caption...", border: InputBorder.none),
            maxLines: 8,
          ),
        ),
        Column(
          children: _buildListViewofImages(),
        )
      ],
    );
  }

  List<Widget> _buildListViewofImages() {
    return widget.images!.map((Uint8List image) {
      return // Showing the preview of the file user is selected.
          SizedBox(
        height: 45.0,
        width: 45.0,
        child: AspectRatio(
          aspectRatio: 487 / 451,
          child: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                fit: BoxFit.fill,
                alignment: FractionalOffset.topCenter,
                image: MemoryImage(image),
              ),
            ),
          ),
        ),
      );
    }).toList();
  }
}
