import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

void showSnackBar(BuildContext context, String text) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(text),
      ),
    );
}

Future<FilePickerResult?> pickFile() async {
  final image = await FilePicker.platform.pickFiles(type: FileType.image);
  return image;
}

pickImage(ImageSource source) async {
  final ImagePicker imagePicker = ImagePicker();
  XFile? file = await imagePicker.pickImage(source: source);

  if (file != null) {
    return await file.readAsBytes();
  }
}

pickMultipeImage() async {
  final ImagePicker imagePicker = ImagePicker();
  final files = await imagePicker.pickMultiImage();
  List<Uint8List> filebyte = [];
  if (files.isNotEmpty) {
    for (var e in files) {
      filebyte.add(await e.readAsBytes());
    }
  }

  return filebyte;
}

extension Switcher on Widget {
  Widget customSwticher(BuildContext context,
      {required bool toggle, required Widget secondChild}) {
    return AnimatedSwitcher(
      switchInCurve: Curves.fastOutSlowIn,
      switchOutCurve: Curves.fastOutSlowIn,
      duration: const Duration(milliseconds: 200),
      transitionBuilder: (child, animation) => ScaleTransition(
        scale: animation,
        child: child,
      ),
      child: toggle ? secondChild : this,
    );
  }
}

class CustomSwitcher extends StatelessWidget {
  final Widget firstChild;
  final Widget secondChild;
  final bool _toggle;
  const CustomSwitcher({
    Key? key,
    required bool toggle,
    required this.firstChild,
    required this.secondChild,
  })  : _toggle = toggle,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      switchInCurve: Curves.fastOutSlowIn,
      switchOutCurve: Curves.fastOutSlowIn,
      duration: const Duration(milliseconds: 200),
      transitionBuilder: (child, animation) => ScaleTransition(
        scale: animation,
        child: child,
      ),
      child: _toggle ? secondChild : firstChild,
    );
  }
}
