import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:social_media/core/common/loader.dart';
import 'package:social_media/core/common/sign_in_button.dart';
import 'package:social_media/core/common/text_field_input.dart';
import 'package:social_media/features/auth/controller/auth_controller.dart';

import 'package:social_media/theme/pallete.dart';
import 'package:routemaster/routemaster.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends ConsumerState<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    _emailController.dispose();
    _passwordController.dispose();
  }

  void loginUser(
    BuildContext context,
  ) async {
    ref.read(autheControllerProvider.notifier).signInWithEmailAndPassword(
        context,
        email: _emailController.text.trim(),
        password: _passwordController.text.trim());
  }

  void navigateToSignUpScreen(BuildContext context) {
    Routemaster.of(context).push('/sign-up');
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(autheControllerProvider);
    return Scaffold(
      body: CustomScrollView(slivers: [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Padding(
            padding: const EdgeInsets.all(30.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Spacer(),
                const SizedBox(
                  height: 44,
                ),
                Text('Space',
                    style: GoogleFonts.corben(
                      letterSpacing: 2,
                      fontWeight: FontWeight.w700,
                      fontSize: 50,
                    )),
                const SizedBox(
                  height: 50,
                ),
                TextFieldInput(
                  hintText: 'Enter your email',
                  textInputType: TextInputType.emailAddress,
                  textEditingController: _emailController,
                ),
                const SizedBox(
                  height: 24,
                ),
                TextFieldInput(
                  hintText: 'Enter your password',
                  textInputType: TextInputType.text,
                  textEditingController: _passwordController,
                  isPass: true,
                ),
                const SizedBox(
                  height: 24,
                ),
                InkWell(
                  onTap: () => loginUser(context),
                  child: Container(
                    width: double.infinity,
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: ShapeDecoration(
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(4)),
                      ),
                      color: Pallete.blueColor,
                    ),
                    child: !isLoading
                        ? const Text(
                            'Log in',
                          )
                        : const Loader(),
                  ),
                ),
                const SizedBox(
                  height: 12,
                ),
                const SignInButton(),
                // const SignInButton(),
                // Flexible(
                //   flex: 2,
                //   child: Container(),
                // ),
                const Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Dont have an account?',
                    ),
                    TextButton(
                      onPressed: () => navigateToSignUpScreen(context),
                      child: const Text(
                        'Signup.',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ]),
    );
  }
}
