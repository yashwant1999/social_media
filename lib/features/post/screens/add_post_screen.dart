import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:social_media/core/utils.dart';
import 'package:social_media/features/post/screens/edit_post_screen.dart';
import 'package:routemaster/routemaster.dart';

class AddPostScreen extends ConsumerStatefulWidget {
  const AddPostScreen({Key? key}) : super(key: key);

  @override
  AddPostScreenState createState() => AddPostScreenState();
}

class AddPostScreenState extends ConsumerState<AddPostScreen> {
  List<Uint8List> _listofImages = [];

  // navigate to the edit_post_screen when user select the images.
  void navaigateToEditPostScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => EditPostScreen(
                images: _listofImages,
              )),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: IconButton(
        onPressed: () => _selectImage(context),
        icon: const Icon(Icons.upload),
      ),
    );
  }

  void _selectImage(BuildContext parentContext) async {
    return showDialog(
      context: parentContext,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: const Text('Create a Post'),
          children: <Widget>[
            // Dialog to take picture on demand
            SimpleDialogOption(
                padding: const EdgeInsets.all(20),
                child: const Text('Take a photo'),
                onPressed: () async {
                  Routemaster.of(context).pop();
                  Uint8List? file = await pickImage(ImageSource.camera);
                  if (file != null) {
                    _listofImages.clear();
                    _listofImages.add(file);
                    navaigateToEditPostScreen();
                  }
                }),
            // Choosing images via Gallery.
            SimpleDialogOption(
                padding: const EdgeInsets.all(20),
                child: const Text('Choose Multiple Photo from Gallery'),
                onPressed: () async {
                  Routemaster.of(context).pop();
                  List<Uint8List> files = await pickMultipeImage();
                  if (files.isNotEmpty) {
                    _listofImages = files;
                    navaigateToEditPostScreen();
                  }
                }),
            SimpleDialogOption(
              padding: const EdgeInsets.all(20),
              child: const Text("Cancel"),
              onPressed: () {
                Routemaster.of(context).pop();
              },
            )
          ],
        );
      },
    );
  }
}
