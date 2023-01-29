import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:social_media/core/common/error.dart';
import 'package:social_media/core/common/loader.dart';
import 'package:social_media/core/constants/constants.dart';
import 'package:social_media/core/utils.dart';
import 'package:social_media/features/auth/controller/auth_controller.dart';
import 'package:social_media/features/user_profile/controller/user_profile_controller.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  final String uid;
  const EditProfileScreen({super.key, required this.uid});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  Uint8List? bannerFile;
  Uint8List? profileFile;
  // Uint8List? profileWebFile;
  // Uint8List? bannerWebFile;
  late TextEditingController nameController;

  void selectBannerImage() async {
    final res = await pickImage(ImageSource.gallery);

    if (res != null) {
      // if (kIsWeb) {
      //   bannerWebFile = res.files.first.bytes;
      // } else {
      setState(() {
        bannerFile = res;
      });
    }
  }

  void selectProfileImage() async {
    final res = await pickImage(ImageSource.gallery);
    if (res != null) {
      // if (kIsWeb) {
      //   profileWebFile = res.files.first.bytes;
      // } else {
      setState(() {
        profileFile = res;
      });
    }
  }

  void save() {
    ref.read(userProfileControllerProvider.notifier).editProfile(
        profileFile: profileFile,
        bannerFile: bannerFile,
        context: context,
        name: nameController.text.trim());
  }

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: ref.read(userProvider)!.name);
  }

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(userProfileControllerProvider);
    return ref.watch(getUserDataProvider(widget.uid)).when(
        data: (user) => Scaffold(
            appBar: AppBar(
              title: const Text('Edit Profile'),
              actions: [
                TextButton(
                  onPressed: save,
                  child: const Text('Save'),
                ),
              ],
            ),
            body: isLoading
                ? const Loader()
                : Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            GestureDetector(
                              onTap: selectBannerImage,
                              child: DottedBorder(
                                borderType: BorderType.RRect,
                                radius: const Radius.circular(10),
                                dashPattern: const [10, 4],
                                strokeCap: StrokeCap.round,
                                child: Container(
                                    width: double.infinity,
                                    height: 150,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: bannerFile != null
                                        ? Image.memory(bannerFile!)
                                        : user.banner.isEmpty ||
                                                user.banner ==
                                                    Constants.bannerDefault
                                            ? const Center(
                                                child: Icon(
                                                  Icons.camera_alt_outlined,
                                                  size: 40,
                                                ),
                                              )
                                            : Image.network(user.banner)
                                    //  bannerWebFile != null
                                    //     ? Image.memory(bannerWebFile!)
                                    //     : bannerFile != null
                                    //         ? Image.file(bannerFile!)
                                    //         : user.banner.isEmpty ||
                                    //                 user.banner ==
                                    //                     Constants.bannerDefault
                                    //             ? const Center(
                                    //                 child: Icon(
                                    //                   Icons.camera_alt_outlined,
                                    //                   size: 40,
                                    //                 ),
                                    //               )
                                    //             : Image.network(user
                                    //                 .banner) // there come condition what show if there is default banner ( we show camera icon) or user previously set another profile (previous banner)
                                    ),
                              ),
                            ),
                            Positioned(
                              bottom: -20,
                              left: 20,
                              child: GestureDetector(
                                onTap: selectProfileImage,
                                child:
                                    // profileWebFile != null
                                    //     ? CircleAvatar(
                                    //         radius: 32,
                                    //         backgroundImage:
                                    //             MemoryImage(profileWebFile!),
                                    //       )
                                    profileFile != null
                                        ? CircleAvatar(
                                            radius: 32,
                                            backgroundImage:
                                                MemoryImage(profileFile!),
                                          )
                                        : CircleAvatar(
                                            radius: 32,
                                            backgroundImage:
                                                NetworkImage(user.profilePic),
                                          ),
                              ),
                            )
                          ],
                        ),
                        const SizedBox(
                          height: 30,
                        ),
                        TextField(
                          controller: nameController,
                          decoration: InputDecoration(
                            filled: true,
                            hintText: 'Name',
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(color: Colors.blue),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.all(18),
                          ),
                        ),
                      ],
                    ),
                  )),
        error: (error, stackTrace) => ErrorText(
              error: error,
              stackTrace: stackTrace,
            ),
        loading: () => const Loader());
  }
}
