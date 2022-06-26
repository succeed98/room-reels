import 'package:firebase_auth/firebase_auth.dart';

import '../datasources/user_datasource.dart';
import '../models/user_model.dart';

class AuthenticationService {
  final FirebaseAuth _firebaseAuth;
  final UserDataSource _userDataSource;

  AuthenticationService(this._firebaseAuth, this._userDataSource);

  /// [authStateChanges] gets the state of the [User] whether signed in or out
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  /// Sign in with user [email] and [password]
  Future<String?> signIn(
      {required String email, required String password}) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
          email: email, password: password);
      return 'Signed in';
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  /// Sign up with user [email] and [password]
  Future<String?> signUp(
      {required String email, required String password}) async {
    try {
      final UserCredential userCredential = await _firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password);

      userCredential.user!.sendEmailVerification();

      return userCredential.user!.uid;
    } on FirebaseAuthException catch (e) {
      print(e);
      return 'ERROR';
    }
  }

  /// set up currently logged in user account
  Future<void> setUpAccount(
      {required uid,
      required String name,
      required String digitalAddr,
      required String phoneNumber,
      required String userType}) async {
    final user = _firebaseAuth.currentUser;

    final userModel = UserModel(
      uid: user!.uid,
      email: user.email,
      name: name,
      digitalAddress: digitalAddr,
      phoneNumber: phoneNumber,
      userType: userType,
    );

    await _userDataSource.addUser(userModel);
  }

  /// Sign out user
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }
}
