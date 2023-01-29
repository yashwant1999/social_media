import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:social_media/core/constants/firebase_constants.dart';
import 'package:social_media/core/failure.dart';
import 'package:social_media/core/provider/firebase_provider.dart';
import 'package:social_media/core/type_defs.dart';
import 'package:social_media/models/user_model.dart';

final userProfileRepositoryProvider = Provider<UserProfileRepository>((ref) {
  return UserProfileRepository(firebaseFirestore: ref.watch(firestoreProvider));
});

class UserProfileRepository {
  final FirebaseFirestore _firebaseFirestore;

  UserProfileRepository({required FirebaseFirestore firebaseFirestore})
      : _firebaseFirestore = firebaseFirestore;

  // Get the refrence of collection.
  CollectionReference get _user =>
      _firebaseFirestore.collection(FirebaseConstants.usersCollection);

  // Edit fucntion for profile
  FutureVoid editProfile(UserModel user) async {
    try {
      return right(
        _user.doc(user.uid).update(
              user.toMap(),
            ),
      );
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(
        Failure(
          e.toString(),
        ),
      );
    }
  }
}
