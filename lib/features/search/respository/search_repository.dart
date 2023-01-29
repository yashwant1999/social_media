import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:social_media/core/constants/firebase_constants.dart';
import 'package:social_media/core/provider/firebase_provider.dart';
import 'package:social_media/models/user_model.dart';

/// The provider for [SearchRepository].
final searchRepositoryProvider = Provider<SearchRepository>((ref) {
  return SearchRepository(firebaseFirestore: ref.read(firestoreProvider));
});

class SearchRepository {
  /// Search Repository class related to all serach functionality.
  SearchRepository({required FirebaseFirestore firebaseFirestore})
      : _firebaseFirestore = firebaseFirestore;

  /// Private instance of [FirebaseFirestore] so no one alter or mutate the class and it member.
  final FirebaseFirestore _firebaseFirestore;

  /// Getter fot retriving location of collection  [CollectionReference] in firestore
  ///  so we can filtered data accordingly to that.
  CollectionReference get _user =>
      _firebaseFirestore.collection(FirebaseConstants.usersCollection);

  // Search function which based upon query return the list of [User].
  Stream<List<UserModel>> searchUser(String query) {
    return _user
        .where(
          'name',
          isGreaterThanOrEqualTo: query,
        )
        .snapshots()
        .map(
          (event) => event.docs
              .map(
                (e) => UserModel.fromMap(e.data() as Map<String, dynamic>),
              )
              .toList(),
        );
  }
}
