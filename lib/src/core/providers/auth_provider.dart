import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../datasources/chat_datasource.dart';
import '../datasources/user_datasource.dart';
import '../models/chat_model.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import 'firebase_providers.dart';

final authServiceProvider = Provider<AuthenticationService>((ref) =>
    AuthenticationService(
        ref.watch(firebaseAuthProvider), ref.watch(userDataSourceProvider)));

final authStateProvider = StreamProvider<User?>((ref) {
  return ref.read(authServiceProvider).authStateChanges;
});

final currentUserProvider =
    Provider<User?>((ref) => ref.watch(firebaseAuthProvider).currentUser);

final appLoginStateProvider = StateProvider<ApplicationLoginState>(
    (ref) => ApplicationLoginState.signedIn);

enum ApplicationLoginState { signedIn, signedUp, loggedOut }

final userDataSourceProvider = Provider<UserDataSourceImpl>(
    (ref) => UserDataSourceImpl(ref.watch(firestoreProvider)));

final userStreamProvider =
    StreamProvider.family.autoDispose<UserModel, String>((ref, uid) {
  final userDataSource = ref.watch(userDataSourceProvider);

  return userDataSource.getUserStream(uid);
});

final userProvider = Provider.autoDispose<UserModel>((ref) {
  final currentUser = ref.watch(currentUserProvider);
  final userFuture = ref.watch(userStreamProvider(currentUser!.uid));

  return userFuture.maybeWhen(
      data: (userModel) => userModel, orElse: () => const UserModel());
});

final imagePickerProvider = Provider<ImagePicker>((ref) => ImagePicker());

final chatDataSourceProvider = Provider<ChatDataSource>(
    (ref) => ChatDataSource(ref.watch(firestoreProvider)));

final getChatStreamProvider =
    FutureProvider.family.autoDispose<ChatModel, String>((ref, chatId) {
  final chatDataSource = ref.watch(chatDataSourceProvider);

  return  chatDataSource.getChat(chatId);
});