// Logout Route
// Logged in Route

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:routemaster/routemaster.dart';
import 'package:social_media/features/auth/controller/auth_controller.dart';
import 'package:social_media/features/auth/screens/login_screen.dart';
import 'package:social_media/features/auth/screens/singup_screen.dart';
import 'package:social_media/features/home/screens/home_screen.dart';
import 'package:social_media/features/post/screens/add_post_screen.dart';
import 'package:social_media/features/post/screens/comment_screen.dart';
import 'package:social_media/features/user_profile/screens/edit_profile_sreen.dart';

import 'features/user_profile/screens/user_profile_screen.dart';

final routeProvider = FutureProvider.autoDispose<RouteMap>((ref) async {
  final data = await ref.watch(authStateChangeProvider.future);

  if (data != null) {
    final userModel = await ref
        .watch(autheControllerProvider.notifier)
        .getUserData(data.uid)
        .first;
    ref.read(userProvider.notifier).update((state) => userModel);
    return loggedInRoute;
  }

  return loggedOutRoute;
});

final loggedOutRoute = RouteMap(
  routes: {
    '/': (_) => const MaterialPage(
          child: LoginScreen(),
        ),
    '/sign-up': (routeData) => const MaterialPage(
          child: SignupScreen(),
        ),
  },
);

final loggedInRoute = RouteMap(
  routes: {
    '/': (routeData) => const MaterialPage(
          child: HomeScreen(),
        ),
    '/u/:uid': (routeData) => MaterialPage(
            child: UserProfileScreen(
          uid: routeData.pathParameters['uid']!,
        )),
    '/edit-profile/:uid': (routeData) => MaterialPage(
            child: EditProfileScreen(
          uid: routeData.pathParameters['uid']!,
        )),
    '/post/:postId/comments': (routeData) => MaterialPage(
          child: CommentsScreen(postId: routeData.pathParameters['postId']!),
        ),
    '/add-post': (routeData) => const MaterialPage(
          child: AddPostScreen(),
        ),
  },
);
