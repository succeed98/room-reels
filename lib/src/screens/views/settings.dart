// ignore_for_file: use_key_in_widget_constructors, no_leading_underscores_for_local_identifiers, prefer_const_constructors, use_build_context_synchronously

import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

import '../../core/providers/auth_provider.dart';
import '../../core/providers/firebase_providers.dart';
import '../../utils/constants.dart';
import '../../utils/dialog.dart';
import '../components/h_button.dart';
import '../components/h_text_form_field.dart';
import 'auth_screen.dart';

final nameProvider = StateProvider.autoDispose<TextEditingController>((ref) {
  final user = ref.watch(userProvider);
  return TextEditingController(text: user.name);
});

final emailProvider = StateProvider.autoDispose<TextEditingController>((ref) {
  final user = ref.watch(userProvider);
  return TextEditingController(text: user.email);
});

final phoneNumberProvider =
    StateProvider.autoDispose<TextEditingController>((ref) {
  final user = ref.watch(userProvider);
  return TextEditingController(text: user.phoneNumber);
});

final addressProvider = StateProvider.autoDispose<TextEditingController>((ref) {
  final user = ref.watch(userProvider);
  return TextEditingController(text: user.digitalAddress);
});

final imagePathProvider = StateProvider.autoDispose<String>((ref) {
  final user = ref.watch(userProvider);
  return user.photoURL ?? '';
});

class SettingsScreen extends ConsumerWidget {
  Future getImage(BuildContext context,
      {required ImageSource imageSource}) async {
    final imagePicker = context.read(imagePickerProvider);
    // picks image from camera
    var pickedImage = await imagePicker.pickImage(source: imageSource);
    if (pickedImage == null) {
      return;
    }

    String externalStoragePath = (await getExternalStorageDirectory())!.path;
    var fileName = basename(pickedImage.path);

    // copy image file to a new path
    File newImage =
        await File(pickedImage.path).copy('$externalStoragePath/$fileName');
    // set image path
    context.read(imagePathProvider).state = newImage.path;
  }

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final _authService = watch(authServiceProvider);
    final name = watch(nameProvider);
    final email = watch(emailProvider);
    final phoneNumber = watch(phoneNumberProvider);
    final address = watch(addressProvider);
    final imagePath = watch(imagePathProvider);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        actions: [
          IconButton(
            icon: Icon(Icons.logout, color: Theme.of(context).primaryColor),
            onPressed: () async {
              // logged out user
              context.read(appLoginStateProvider).state =
                  ApplicationLoginState.loggedOut;
              context.refresh(screensNotifierProvider);
              await _authService.signOut();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.only(left: 10.0, right: 20.0, bottom: 20.0),
        child: Column(
          children: <Widget>[
            SizedBox(height: 20.0),
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
              ),
              height: 100.0,
              width: 100.0,
              child: Stack(
                children: <Widget>[
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFF2A3736).withOpacity(0.1),
                      image: imagePath.state.isNotEmpty
                          ? imagePath.state.contains('firebasestorage')
                              ? DecorationImage(
                                  image: CachedNetworkImageProvider(
                                    imagePath.state,
                                  ),
                                  fit: BoxFit.cover,
                                )
                              : DecorationImage(
                                  image: FileImage(File(imagePath.state)),
                                  fit: BoxFit.cover,
                                )
                          : null,
                    ),
                    height: 100.0,
                    width: 100.0,
                  ),
                  Positioned(
                    bottom: 0,
                    top: 70,
                    left: 65,
                    child: IconButton(
                      onPressed: () => showCustomDialog(
                        context,
                        titleBuilder: (context, controller, setState) =>
                            SizedBox(),
                        messageBuilder: (context, controller, setState) =>
                            Column(
                          children: [
                            TextButton(
                              onPressed: () async {
                                await getImage(
                                  context,
                                  imageSource: ImageSource.camera,
                                );
                                controller.dismiss();
                              },
                              child: Text('Camera', style: F_18_PRIMARY_COLOR),
                            ),
                            TextButton(
                              onPressed: () async {
                                await getImage(
                                  context,
                                  imageSource: ImageSource.gallery,
                                ).then((value) => controller.dismiss());
                              },
                              child: Text('Gallery', style: F_18_PRIMARY_COLOR),
                            )
                          ],
                        ),
                        negativeAction: (context, controller, setState) =>
                            SizedBox(),
                        positiveAction: (context, controller, setState) =>
                            SizedBox(),
                      ),
                      icon: Icon(
                        Icons.photo_camera,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20.0),
            HTextFormField(
              controller: name.state,
              iconData: Icons.person,
              hintText: 'Name',
            ),
            SizedBox(height: 20.0),
            HTextFormField(
              controller: email.state,
              iconData: Icons.message,
              hintText: 'Email',
            ),
            SizedBox(height: 20.0),
            HTextFormField(
              controller: phoneNumber.state,
              iconData: Icons.dialpad,
              hintText: 'Phone number',
            ),
            SizedBox(height: 20.0),
            HTextFormField(
              controller: address.state,
              iconData: Icons.location_on,
              hintText: 'Address',
            ),
            SizedBox(height: 20.0),
            HButton(
              text: 'Update',
              onPressed: () async {
                final completer = Completer();
                showBlockDialog(context, dismissCompleter: completer);

                final user = context.read(userProvider);
                final storage = context.read(storageProvider);
                final userDataSource = context.read(userDataSourceProvider);

                if (imagePath.state.isNotEmpty &&
                    !imagePath.state.contains('firebasestorage')) {
                  imagePath.state = await storage.uploadFile(
                    bucket: 'users/${user.uid}',
                    filePath: imagePath.state,
                  );
                }

                final userUpdate = user.copy(
                  name: name.state.text,
                  email: email.state.text,
                  phoneNumber: phoneNumber.state.text,
                  digitalAddress: address.state.text,
                  photoURL: imagePath.state,
                );
                await userDataSource.updateUser(userUpdate).then((value) {
                  completer.complete();
                  showToast(
                    context,
                    message: 'Success',
                    color: Colors.green,
                  );
                }).catchError((onError) {
                  completer.complete();
                  showToast(
                    context,
                    message: 'An error occured. Try again.',
                  );
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}
