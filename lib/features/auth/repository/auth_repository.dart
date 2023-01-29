import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:social_media/core/constants/constants.dart';
import 'package:social_media/core/constants/firebase_constants.dart';
import 'package:social_media/core/failure.dart';
import 'package:social_media/core/provider/firebase_provider.dart';
import 'package:social_media/core/provider/storage_repository_provider.dart';
import 'package:social_media/core/type_defs.dart';
import 'package:social_media/models/user_model.dart';

/// Provider to access the firestore auth and googlesignIn we will create the provider.
final autheRepositoryProvider = Provider(
  (ref) => AuthRespository(
      firestore: ref.read(firestoreProvider),
      auth: ref.read(authProvider),
      googleSignIn: ref.read(googleSignInProvider),
      ref: ref),
);

abstract class AuthRepositoryBase {
  // get the current User.
  Future<User?> currentUser();

  // Getter for getting the state User [`authState`] when user come back to app after disconnecting.
  Stream<User?> get authStateChange;

  // Getter for getting the collection ref from firebaseStorage since we need to save the info from user to firebase databse.
  CollectionReference get userCollection;

  // Sign in method with googleSignIn
  FutureEither<UserModel> signInWithGoogle();

  // create the user or singup User  with email and password.
  FutureEither<UserModel> createUserWithEmailAndPassword(
      {required String email,
      required String password,
      required String username,
      required String bio,
      Uint8List? file});

  // Sign in the user with email and password.
  FutureEither<UserModel> signInWithEmailAndPassword(
      {required String email, required String password});

  // Logout Method
  Future<void> logOut();
}

class AuthRespository implements AuthRepositoryBase {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn;
  final Ref _ref;

  AuthRespository({
    required Ref ref,
    required FirebaseFirestore firestore,
    required FirebaseAuth auth,
    required GoogleSignIn googleSignIn,
  })  : _auth = auth,
        _firestore = firestore,
        _ref = ref,
        _googleSignIn = googleSignIn;

  @override
  Stream<User?> get authStateChange => _auth.authStateChanges();

  @override
  CollectionReference get userCollection =>
      _firestore.collection(FirebaseConstants.usersCollection);
  @override
  FutureEither<UserModel> signInWithGoogle() async {
    try {
      UserCredential userCredential;
      if (kIsWeb) {
        GoogleAuthProvider googleProvider = GoogleAuthProvider();
        googleProvider
            .addScope('https://www.googleapis.com/auth/contacts.readonly');
        userCredential = await _auth.signInWithPopup(googleProvider);
      } else {
        final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
        final googleAuth = await googleUser?.authentication;
        // To get credential extracting google account such as email , name and profile picture etc.
        final credential = GoogleAuthProvider.credential(
            accessToken: googleAuth?.accessToken, idToken: googleAuth?.idToken);

        /// To store we use in firebase we will use firebaseAuth
        ///
        userCredential = await _auth.signInWithCredential(credential);
      }
      UserModel userModel;

      /// How to check if the user is new or not
      if (userCredential.additionalUserInfo!.isNewUser) {
        userModel = UserModel(
          name: userCredential.user!.displayName ?? '',
          profilePic: userCredential.user!.photoURL ?? Constants.avatarDefault,
          banner: Constants.bannerDefault,
          uid: userCredential.user!.uid,
          isAuthenticated: true,
          bio: 'No bio yet',
          followers: [],
          following: [],
        );
        await userCollection
            .doc(userCredential.user!.uid)
            .set(userModel.toMap());
      } else {
        userModel = await getUserData(userCredential.user!.uid).first;
      }

      return Right(userModel);
    } on FirebaseAuthException catch (e) {
      return left(
        Failure(
          e.message.toString(),
        ),
      );
    } catch (e) {
      return left(
        Failure(
          e.toString(),
        ),
      );
    }
  }

  Stream<UserModel> getUserData(String uid) {
    return userCollection.doc(uid).snapshots().map(
        (event) => UserModel.fromMap(event.data() as Map<String, dynamic>));
  }

  @override
  Future<void> logOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  @override
  Future<User?> currentUser() async {
    return _auth.currentUser;
  }

  @override
  FutureEither<UserModel> createUserWithEmailAndPassword(
      {required String email,
      required String password,
      required String username,
      required String bio,
      Uint8List? file}) async {
    try {
      if (email.isNotEmpty &&
          password.isNotEmpty &&
          username.isNotEmpty &&
          bio.isNotEmpty) {
        final UserCredential userCredential = await _auth
            .createUserWithEmailAndPassword(email: email, password: password);

        // get the download url of profile pic by storing the photo ( in Uint8List formate) to firebase storage.
        String? photoUrl;
        if (file != null) {
          final res = await _ref.read(storageRepositoryProvider).storeFile(
              path: 'users/profile', id: userCredential.user!.uid, file: file);
          res.fold((l) => throw (l.message), (r) {
            photoUrl = r;
          });
        }

        UserModel userModel = UserModel(
          name: username,
          profilePic: photoUrl ?? Constants.avatarDefault,
          banner: Constants.bannerDefault,
          uid: userCredential.user!.uid,
          isAuthenticated: true,
          bio: bio,
          followers: [],
          following: [],
        );

        await userCollection
            .doc(userCredential.user!.uid)
            .set(userModel.toMap());

        return Right(userModel);
      }
      throw Exception('Fill Up the all required field');
    } catch (e) {
      return left(
        Failure(
          e.toString(),
        ),
      );
    }
  }

  @override
  FutureEither<UserModel> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final UserCredential userCredential = await _auth
          .signInWithEmailAndPassword(email: email, password: password);

      UserModel userModel = await getUserData(userCredential.user!.uid).first;

      return Right(userModel);
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }
}
