import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:social_media/core/failure.dart';
import 'package:social_media/core/provider/firebase_provider.dart';
import 'package:social_media/core/type_defs.dart';
import 'package:social_media/models/post_model.dart';
import 'package:image/image.dart' as img;

/// So to get the Access of StorageRepository we need the Provider
///
final storageRepositoryProvider = Provider<StorageRepository>((ref) {
  return StorageRepository(firebaseStorage: ref.watch(storageProvider));
});

class StorageRepository {
  final FirebaseStorage _firebaseStorage;

  StorageRepository({required FirebaseStorage firebaseStorage})
      : _firebaseStorage = firebaseStorage;

  FutureVoid deleteFile({required List<String> urls}) async {
    try {
      for (var url in urls) {
        _firebaseStorage.refFromURL(url).delete();
      }
      return right(null);
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  /// Function give us Download Url which we then
  /// 1. Use to store that url into the database with new url.
  /// 2. Also function `storeFile()` upload the file to firebase storage with uinique path.
  /// Below FutureEither is typedef which will return failur or sucess accordingly to result future.
  FutureEither<String> storeFile({
    required String path,
    required String id,
    required Uint8List file, // It is of Null type i dont know thought.
  }) async {
    // what to store
    // where to store
    // so to start with first we will use try catch since this future
    try {
      // Now we will we refering to the storage from the _private _firebaseStorage instance.
      final ref = _firebaseStorage
          // it will store in like --> user/banner/id <-- file name
          .ref()
          .child(path)
          .child(
              id); // If we did this then this store the file to the root bucket mean to root path but --> we will provide custom path.

      /// Now that we know the path. We need to upload it.
      UploadTask uploadTask = ref.putData(
          file); // <-- So put data required the file parametar so we need above in field.

      /// We will save this in snapshot varialbe and await the uploadTask;
      final snapshot = await uploadTask;
      return right(await snapshot.ref.getDownloadURL());
    } catch (e) {
      return left(
        // On Failure
        Failure(
          e.toString(),
        ),
      );
    }
  }

  /// Function to store multiple photo instead single photo.
  FutureEither<List<ImageX>> uploadMultipalImagesToStorage({
    required String path,
    required String id,
    required List<Uint8List> images,
  }) async {
    try {
      /// An empty error of string when in for loop will add the required
      /// download string.
      final List<ImageX> downloadUrls = [];

      /// Now for list of image we will implement the for loop
      /// which will download the image recursively.
      for (int i = 0; i < images.length; i++) {
        /// First we provide the path or [ref] to firbase storage where we want
        /// to store our images. For example something appropiate like
        /// "posts/user_name/post_id".
        final ref = _firebaseStorage.ref().child(path).child('$id--$i');

        UploadTask uploadTask = ref.putData(images[i]);

        final decodedImage = await compute(img.decodeImage, images[i]);
        final snapshot = await uploadTask;
        String downloadUrl = await snapshot.ref.getDownloadURL();
        downloadUrls.add(ImageX(
            imageUrl: downloadUrl,
            height: decodedImage?.height,
            width: decodedImage?.width));
      }

      return right(downloadUrls);
    } catch (e) {
      // Throw the exception when uploading process failed so
      // we can show the snakbar in ui.
      return left(
        Failure(
          e.toString(),
        ),
      );
    }
  }
}
