import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:routemaster/routemaster.dart';
import 'package:social_media/core/common/loader.dart';
import 'package:social_media/router.dart';
import 'package:social_media/theme/pallete.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations(
    [DeviceOrientation.portraitUp],
  ); //
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  @override
  Widget build(BuildContext context) {
    return ref.watch(routeProvider).when(
          data: (data) {
            return MaterialApp.router(
              debugShowCheckedModeBanner: false,
              title: 'Reddit Tutorial',
              theme: ThemeData(
                brightness: Brightness.dark,
                useMaterial3: true,
                colorSchemeSeed: ref.watch(colorProvider),
              ),
              routerDelegate:
                  RoutemasterDelegate(routesBuilder: (context) => data),
              routeInformationParser: const RoutemasterParser(),
            );
          },
          error: (error, stackTrace) => Directionality(
            textDirection: TextDirection.ltr,
            child: Text(stackTrace.toString()),
          ),
          loading: () => const Loader(),
        );
  }
}
