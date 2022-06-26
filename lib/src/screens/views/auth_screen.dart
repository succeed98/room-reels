// ignore_for_file: prefer_const_constructors, use_build_context_synchronously, prefer_const_literals_to_create_immutables

import 'dart:async';

import 'package:email_validator/email_validator.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/auth_provider.dart';
import '../../core/providers/text_input_providers.dart';
import '../../utils/constants.dart';
import '../../utils/dialog.dart';
import '../components/custom_radio_grouped_button.dart';
import '../components/h_button.dart';
import '../components/h_text_form_field.dart';

class ScreensNotifier extends ChangeNotifier {
  bool _isHideSignInScreen = false;
  bool _isHideSignUpScreen = true;
  bool _isHideProceedScreen = true;

  bool get isHideSignInScreen => _isHideSignInScreen;
  bool get isHideSignUpScreen => _isHideSignUpScreen;
  bool get isHideProceedScreen => _isHideProceedScreen;

  void showSignInScreen() {
    _isHideSignInScreen = false;
    _isHideSignUpScreen = true;
    _isHideProceedScreen = true;
    notifyListeners();
  }

  void showSignUpScreen() {
    _isHideSignInScreen = true;
    _isHideSignUpScreen = false;
    _isHideProceedScreen = true;
    notifyListeners();
  }

  void showProceedScreen() {
    _isHideSignInScreen = true;
    _isHideSignUpScreen = true;
    _isHideProceedScreen = false;
    notifyListeners();
  }
}

final screensNotifierProvider =
    ChangeNotifierProvider((ref) => ScreensNotifier());

class AuthScreen extends ConsumerWidget {
  AuthScreen({Key? key}) : super(key: key);

  final _signInFormKey = GlobalKey<FormState>();
  final _signUpFormKey = GlobalKey<FormState>();
  final _proceedFormKey = GlobalKey<FormState>();

  final emailCtrl = TextEditingController(text: '');
  final pwdCtrl = TextEditingController(text: '');
  final nameCtrl = TextEditingController(text: '');
  final addressCtrl = TextEditingController(text: '');
  final phoneNumberCtrl = TextEditingController(text: '');
  final photoURLCtrl = TextEditingController(text: '');

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    final screensNofitier = watch(screensNotifierProvider);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        width: screenWidth,
        height: screenHeight,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/sign-in-bg.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              bottom: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    height: screenHeight / 2.5,
                    width: screenWidth / 2.5,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage("assets/images/lady-with-laptop.png"),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  SizedBox(height: 35),
                  screensNofitier.isHideProceedScreen
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            TextButton(
                              onPressed: () {
                                screensNofitier.showSignInScreen();
                              },
                              child: Text(
                                "Sign in",
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w500,
                                  color: !screensNofitier.isHideSignInScreen
                                      ? PRIMARY_COLOR
                                      : DARK,
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                context.read(appLoginStateProvider).state =
                                    ApplicationLoginState.loggedOut;
                                screensNofitier.showSignUpScreen();
                              },
                              child: Text(
                                "Sign up",
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w500,
                                  color: !screensNofitier.isHideSignUpScreen
                                      ? PRIMARY_COLOR
                                      : DARK,
                                ),
                              ),
                            ),
                          ],
                        )
                      : Text(
                          "Efiewura",
                          style: TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.w500,
                            color: DARK,
                          ),
                        ),
                  SizedBox(height: 70),
                  screensNofitier.isHideProceedScreen
                      ? Text(
                          "Welcome!",
                          style: TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.w500,
                            color: DARK,
                          ),
                        )
                      : Text(
                          "Finishing account setup",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w500,
                            color: DARK,
                          ),
                        ),
                  // Sign in Form
                  Offstage(
                    offstage: screensNofitier.isHideSignInScreen,
                    child: Padding(
                      padding: const EdgeInsets.all(30.0),
                      child: buildSignInForm(context),
                    ),
                  ),
                  // Sign up From
                  Offstage(
                    offstage: screensNofitier.isHideSignUpScreen,
                    child: Padding(
                      padding: const EdgeInsets.all(30.0),
                      child: buildSignUpForm(context),
                    ),
                  ),
                  // Proceed with account setup Form
                  Offstage(
                    offstage: screensNofitier.isHideProceedScreen,
                    child: Padding(
                      padding: const EdgeInsets.all(30.0),
                      child: buildProceedForm(context),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildProceedForm(BuildContext context) {
    return Form(
      key: _proceedFormKey,
      child: Column(
        children: [
          HTextFormField(
            controller: nameCtrl,
            iconData: Icons.person,
            hintText: 'Name',
            validator: (value) => value!.isEmpty ? 'name field required' : null,
          ),
          SizedBox(height: 20),
          HTextFormField(
            controller: addressCtrl,
            iconData: Icons.location_on,
            hintText: 'Address',
            validator: (value) =>
                value!.isEmpty ? 'address field required' : null,
          ),
          SizedBox(height: 20),
          HTextFormField(
            controller: phoneNumberCtrl,
            iconData: Icons.phone,
            hintText: 'Phone number',
            validator: (value) =>
                value!.isEmpty ? 'phone number field required' : null,
          ),
          SizedBox(height: 20),
          Consumer(builder: (context, watch, child) {
            final userType = watch(userTypeProvider);

            return CustomRadioGroupedButton(
              value: userType.state,
              options: ["seller", "buyer"],
              onChanged: (String value) {
                userType.state = value;
              },
            );
          }),
          SizedBox(height: 20),
          HButton(
            width: 150,
            onPressed: () async {
              final auth = context.read(authServiceProvider);
              final userType = context.read(userTypeProvider);
              final completer = Completer();

              showBlockDialog(
                context,
                dismissCompleter: completer,
              );

              // register user
              final String? uid = await auth.signUp(
                email: emailCtrl.text.toString().trim(),
                password: pwdCtrl.text.toString().trim(),
              );

              if (uid == null && uid == 'ERROR') {
                showToast(
                  context,
                  message: 'An error occured during account registration',
                );
                return;
              }

              // account registration was a success
              final appLoginState = context.read(appLoginStateProvider);

              appLoginState.state = ApplicationLoginState.signedUp;

              // setup user account
              await auth
                  .setUpAccount(
                uid: uid,
                digitalAddr: addressCtrl.text,
                phoneNumber: phoneNumberCtrl.text,
                name: nameCtrl.text,
                userType: userType.state,
              )
                  .then((value) {
                // dismiss loading
                completer.complete();
                // set email and password to empty string
                _signUpFormKey.currentState?.reset();
                // reset account setup fields
                _proceedFormKey.currentState?.reset();
                context.refresh(userTypeProvider);
                // login user to home page
                appLoginState.state = ApplicationLoginState.signedIn;
              });
            },
            text: "Sign up",
          ),
        ],
      ),
    );
  }

  Form buildForm(BuildContext context, GlobalKey<FormState> formKey) {
    return Form(
      key: formKey,
      child: Column(
        children: [
          HTextFormField(
            controller: emailCtrl,
            iconData: Icons.mail,
            hintText: 'email',
            validator: (value) => EmailValidator.validate(value!)
                ? null
                : "Please enter a valid email",
          ),
          SizedBox(height: 20),
          HTextFormField(
            controller: pwdCtrl,
            iconData: Icons.lock,
            hintText: 'password',
            obscureText: true,
            validator: (value) => value!.length > 7
                ? null
                : "Password has to be more than 6 characters",
          ),
        ],
      ),
    );
  }

  buildSignUpForm(BuildContext context) {
    final screensNofitier = context.read(screensNotifierProvider);

    return Column(
      children: [
        buildForm(context, _signUpFormKey),
        SizedBox(height: 20),
        HButton(
          width: 150,
          text: 'Proceed',
          onPressed: () async {
            if (_signUpFormKey.currentState!.validate()) {
              // display proceed account setup
              screensNofitier.showProceedScreen();
            }
          },
        ),
        SizedBox(height: 20),
        buildRichText(
          text: "Already have an account? ",
          textBtn: "Sign in",
          onTap: () {
            screensNofitier.showSignInScreen();
          },
        ),
      ],
    );
  }

  buildSignInForm(BuildContext context) {
    final screensNofitier = context.read(screensNotifierProvider);
    final auth = context.read(authServiceProvider);

    return Column(
      children: [
        buildForm(context, _signInFormKey),
        SizedBox(height: 20),
        HButton(
          width: 150,
          text: 'Sign in',
          onPressed: () async {
            if (_signInFormKey.currentState!.validate()) {
              final completer = Completer();
              showBlockDialog(context, dismissCompleter: completer);
              final appLoginState = context.read(appLoginStateProvider);
              // login user
              await auth
                  .signIn(email: emailCtrl.text, password: pwdCtrl.text)
                  .then((value) {
                // dismiss loading
                completer.complete();
                // reset email and password state
                _signInFormKey.currentState?.reset();
                // login user to home page
                appLoginState.state = ApplicationLoginState.signedIn;
              });
            }
          },
        ),
        SizedBox(height: 20),
        /* buildRichText(
          text: "Forgot password? ",
          textBtn: 'Reset',
          onTap: () {},
        ), */
        // SizedBox(height: 10),
        buildRichText(
          text: "Don't have an account? ",
          textBtn: "Sign up",
          onTap: () {
            context.read(appLoginStateProvider).state =
                ApplicationLoginState.loggedOut;
            screensNofitier.showSignUpScreen();
          },
        ),
      ],
    );
  }

  RichText buildRichText(
      {required String text,
      required String textBtn,
      required VoidCallback? onTap}) {
    return RichText(
      text: TextSpan(
        text: text,
        style: TextStyle(
          fontSize: 18,
          color: DARK,
        ),
        children: [
          TextSpan(
            text: textBtn,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: PRIMARY_COLOR,
            ),
            recognizer: TapGestureRecognizer()..onTap = onTap,
          )
        ],
      ),
    );
  }
}
