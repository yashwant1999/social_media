import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:social_media/core/utils.dart';
import 'package:social_media/features/auth/repository/auth_repository.dart';
import 'package:social_media/models/user_model.dart';

final userProvider = StateProvider<UserModel?>((ref) => null);
// To create the autheController we will also need to create the provider for
// authRepository.
final autheControllerProvider = StateNotifierProvider<AuthController, bool>(
  (ref) => AuthController(
      authRespository: ref.watch(autheRepositoryProvider), ref: ref),
);

final authStateChangeProvider = StreamProvider.autoDispose((ref) {
  final authController = ref.watch(autheControllerProvider.notifier);
  return authController.authStateChange;
});

final getUserDataProvider = StreamProvider.family((ref, String uid) {
  final authController = ref.watch(autheControllerProvider.notifier);
  return authController.getUserData(uid);
});

class AuthController extends StateNotifier<bool> {
  final AuthRespository _authRespository;
  final Ref _ref;
  AuthController({required AuthRespository authRespository, required Ref ref})
      : _authRespository = authRespository,
        _ref = ref,
        super(false);

  Stream<User?> get authStateChange => _authRespository.authStateChange;

  // we will need to catch the error.
  void signInWithGoogle(BuildContext context) async {
    state = true;
    final user = await _authRespository.signInWithGoogle();
    state = false;
    user.fold(
        (l) => showSnackBar(context, l.message),
        (userModel) =>
            _ref.read(userProvider.notifier).update((state) => userModel));
  }

  void createUserWithEmailAndPassword(BuildContext context,
      {required String email,
      required String password,
      required String bio,
      required String username,
      Uint8List? file}) async {
    state = true;

    final user = await _authRespository.createUserWithEmailAndPassword(
        email: email,
        password: password,
        bio: bio,
        username: username,
        file: file);

    state = false;
    user.fold((l) => showSnackBar(context, l.message), (r) {
      _ref.read(userProvider.notifier).update((state) => r);
    });
  }

  void signInWithEmailAndPassword(BuildContext context,
      {required String email, required String password}) async {
    state = true;
    final user = await _authRespository.signInWithEmailAndPassword(
        email: email, password: password);
    state = false;
    user.fold((l) => showSnackBar(context, l.message),
        (r) => _ref.read(userProvider.notifier).update((state) => r));
  }

  Stream<UserModel> getUserData(String uid) {
    return _authRespository.getUserData(uid);
  }

  void logout() async {
    _authRespository.logOut();
  }
}
