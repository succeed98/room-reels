// ignore_for_file: sort_child_properties_last, prefer_const_constructors, prefer_const_literals_to_create_immutables, use_build_context_synchronously, sized_box_for_whitespace

import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:image_viewer/image_viewer.dart';

import '../../core/models/chat_model.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/providers/property_provider.dart';
import '../../utils/constants.dart';
import '../../utils/dialog.dart';
import '../components/h_button.dart';
import '../components/loading.dart';
import 'chat_history.dart';

final featuresProvider = StateProvider.autoDispose<double>((ref) => 0.0);
final characterProvider = StateProvider.autoDispose<double>((ref) => 0.0);
final surroundingsProvider = StateProvider.autoDispose<double>((ref) => 0.0);

class PropertyDetailsScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final selectedProperty = watch(selectedPropertyProvider);
    final currentUser = watch(currentUserProvider);
    final userProperty = watch(userStreamProvider(selectedProperty.state.uid));

    return Scaffold(
      appBar: AppBar(
        actions: [
          PopupMenuButton(
              itemBuilder: (_) => <PopupMenuItem<String>>[
                    PopupMenuItem<String>(
                      child: const Text('Rate'),
                      value: 'Rate',
                    ),
                    if (selectedProperty.state.uid == currentUser!.uid) ...[
                      PopupMenuItem<String>(
                        child: const Text('Delete'),
                        value: 'Delete',
                      ),
                    ],
                  ],
              onSelected: (value) {
                switch (value) {
                  case 'Rate':
                    showCustomDialog(
                      context,
                      titleBuilder: (context, controller, setState) =>
                          Text('Rate Property'),
                      messageBuilder: (context, controller, setState) =>
                          Consumer(
                        builder: (context, watch, child) {
                          final features = watch(featuresProvider);
                          final character = watch(characterProvider);
                          final surroundings = watch(surroundingsProvider);

                          return Column(children: [
                            Row(children: [Text('Features')]),
                            SizedBox(height: 5),
                            buildRatingBarIndicator(features),
                            SizedBox(height: 20.0),
                            Row(children: [Text('Owner\'s character')]),
                            SizedBox(height: 5),
                            buildRatingBarIndicator(character),
                            SizedBox(height: 20.0),
                            Row(children: [Text('Surroundings')]),
                            SizedBox(height: 5),
                            buildRatingBarIndicator(surroundings),
                            SizedBox(height: 20.0),
                          ]);
                        },
                      ),
                      negativeAction: (context, controller, setState) =>
                          TextButton(
                        child: Text('Cancel'),
                        onPressed: () => controller.dismiss(),
                      ),
                      positiveAction: (context, controller, setState) =>
                          TextButton(
                        child: Text('Submit'),
                        onPressed: () async {
                          final features = context.read(featuresProvider);
                          final character = context.read(characterProvider);
                          final surroundings =
                              context.read(surroundingsProvider);

                          final propertyDataSource =
                              context.read(propertyDataSourceProvider);

                          double ratings = (features.state +
                                  character.state +
                                  surroundings.state) /
                              3;

                          ratings += selectedProperty.state.ratings;
                          ratings /= 2;

                          final newProperty =
                              selectedProperty.state.copyWith(ratings: ratings);

                          await propertyDataSource
                              .updateProperty(newProperty)
                              .then((updatedProperty) {
                            selectedProperty.state = updatedProperty;

                            showToast(context,
                                message: 'Rated property', color: Colors.green);
                          });

                          controller.dismiss();
                        },
                      ),
                    );
                    break;
                  case 'Delete':
                    showCustomDialog(context,
                        titleBuilder: (context, controller, setState) =>
                            Text('Delete?'),
                        messageBuilder: (context, controller, setState) => Text(
                            'Are you sure you want to remove this property?'),
                        positiveAction: (context, controller, setState) =>
                            TextButton(
                                child: Text('YES'),
                                onPressed: () async {
                                  final propertyDataSource =
                                      context.read(propertyDataSourceProvider);

                                  await propertyDataSource
                                      .deleteProperty(selectedProperty.state)
                                      .then((value) {
                                    controller.dismiss();
                                    Navigator.pop(context);
                                  });
                                }),
                        negativeAction: (context, controller, setState) =>
                            TextButton(
                                child: Text('NO'),
                                onPressed: () => controller.dismiss()));
                    break;
                }
              }),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 250.0,
              child: Stack(
                children: [
                  GestureDetector(
                    onTap: () {
                      ImageViewer.showImageSlider(
                        images: [selectedProperty.state.displayPic],
                      );
                    },
                    child: Container(
                      height: 220,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          fit: BoxFit.cover,
                          image: CachedNetworkImageProvider(
                            selectedProperty.state.displayPic,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 10.0,
                    left: 20,
                    right: 10,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: SECONDARY_COLOR,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(15.0),
                              bottomRight: Radius.circular(15.0),
                            ),
                          ),
                          padding: EdgeInsets.all(10.0),
                          child: Text(
                            selectedProperty.state.type,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10.0,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.favorite_outlined,
                            color: selectedProperty.state.likes
                                    .contains(currentUser!.uid)
                                ? Colors.red
                                : Colors.black,
                          ),
                          onPressed: () async {
                            final propertyDataSource =
                                context.read(propertyDataSourceProvider);

                            final property =
                                context.read(selectedPropertyProvider);

                            var message = '';

                            if (selectedProperty.state.likes
                                .contains(currentUser.uid)) {
                              selectedProperty.state.likes
                                  .remove(currentUser.uid);
                              message = 'Unliked property';
                            } else {
                              selectedProperty.state.likes.add(currentUser.uid);
                              message = 'Liked property';
                            }

                            await propertyDataSource
                                .updateProperty(selectedProperty.state)
                                .then((updatedProperty) {
                              property.state = updatedProperty;

                              showToast(context,
                                  message: message, color: Colors.green);
                            });
                          },
                        )
                      ],
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10.0),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                        child: Container(
                          width: 300,
                          child: userProperty.when(
                            data: (user) {
                              return ListTile(
                                leading: Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color: Color(0xFF2A3736).withOpacity(0.5),
                                    borderRadius: BorderRadius.circular(50),
                                    image: currentUser.photoURL != null 
                                        ? DecorationImage(
                                            fit: BoxFit.cover,
                                            image: CachedNetworkImageProvider(
                                              user.photoURL ?? '',
                                            ),
                                          )
                                        : null,
                                  ),
                                ),
                                title: Text(
                                  user.name ?? '',
                                  style: F_18_BOLD,
                                ),
                                trailing: currentUser.uid != user.uid
                                    ? IconButton(
                                        onPressed: () async {
                                          final completer = Completer();
                                          showBlockDialog(context,
                                              dismissCompleter: completer);

                                          // check whether buyer and seller have been intact before
                                          final chatDataSource = context
                                              .read(chatDataSourceProvider);
                                          final userDataSource = context
                                              .read(userDataSourceProvider);
                                          try {
                                            await chatDataSource
                                                .getChatBySellerAndBuyer(
                                              seller:
                                                  selectedProperty.state.uid,
                                              buyer: currentUser.uid,
                                            )
                                                .then((chat) {
                                              completer.complete();
                                              // if true then navigate to their chatview
                                              final selectedChat = context
                                                  .read(selectedChatProvider);
                                              selectedChat.state = chat;
                                              final otherUser = context
                                                  .read(otherUserProvider);
                                              otherUser.state = user;

                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (_) => Chat()));
                                            });
                                          } catch (e) {
                                            // else create new chat and then navigate to chatview
                                            print(e);

                                            var currentUser =
                                                context.read(userProvider);

                                            final chat = ChatModel(
                                              buyer: currentUser.uid ?? '',
                                              seller:
                                                  selectedProperty.state.uid,
                                              messages: <Message>[],
                                            );

                                            final newChat = await chatDataSource
                                                .addChat(chat);
                                            currentUser.chats
                                                .add(newChat.id ?? '');
                                            user.chats.add(newChat.id ?? '');
                                            await userDataSource
                                                .updateUser(user);
                                            await userDataSource
                                                .updateUser(currentUser)
                                                .then((value) =>
                                                    completer.complete());

                                            final selectedChat = context
                                                .read(selectedChatProvider);
                                            selectedChat.state = newChat;
                                            final otherUser =
                                                context.read(otherUserProvider);
                                            otherUser.state = user;

                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (_) => Chat()));
                                          }
                                        },
                                        icon: Icon(
                                          Icons.message,
                                          size: 30,
                                          color: Theme.of(context).primaryColor,
                                        ),
                                      )
                                    : null,
                              );
                            },
                            loading: () => Loading(),
                            error: (error, stack) {
                              print(error);
                              print(stack);
                              return Text('');
                            },
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Text(selectedProperty.state.title, style: F_18_BOLD),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Text(selectedProperty.state.location, style: F_15),
            ),
            SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                children: [
                  Container(
                    width: 50,
                    child: Row(
                      children: [
                        Icon(
                          Icons.king_bed,
                          size: 18,
                          color: SECONDARY_COLOR,
                        ),
                        SizedBox(width: 5),
                        Text(selectedProperty.state.bedrooms),
                      ],
                    ),
                  ),
                  Container(
                    width: 50,
                    child: Row(
                      children: [
                        Icon(
                          Icons.bathtub,
                          size: 18,
                          color: SECONDARY_COLOR,
                        ),
                        SizedBox(width: 5),
                        Text(selectedProperty.state.bathrooms)
                      ],
                    ),
                  ),
                  Container(
                    width: 50,
                    child: Row(
                      children: [
                        Icon(
                          Icons.kitchen,
                          size: 18,
                          color: SECONDARY_COLOR,
                        ),
                        SizedBox(width: 5),
                        Text(selectedProperty.state.kitchens)
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Text(
                selectedProperty.state.description,
                style: F_15,
              ),
            ),
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Text('Gallery', style: F_18_BOLD),
            ),
            SizedBox(height: 20),
            SingleChildScrollView(
              padding: const EdgeInsets.only(left: 20.0),
              scrollDirection: Axis.horizontal,
              child: Row(
                children: selectedProperty.state.featuredPics
                    .map((imageURL) => buildGalleryCard(imageURL))
                    .toList(),
              ),
            ),
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Price', style: F_18),
                      RichText(
                        text: TextSpan(
                          text: selectedProperty.state.price.toString(),
                          style: F_18_BOLD,
                          children: [TextSpan(text: '/month', style: F_15)],
                        ),
                      )
                    ],
                  ),
                  if (selectedProperty.state.uid != currentUser.uid) ...[
                    HButton(
                      text: selectedProperty.state.status,
                      width: 100,
                      onPressed: () async {
                        showCustomDialog(
                          context,
                          titleBuilder: (context, controller, setState) => Text(
                              '${selectedProperty.state.status} Property?'),
                          messageBuilder: (context, controller, setState) =>
                              Consumer(
                            builder: (context, watch, child) {
                              return Column(children: [
                                Row(children: [
                                  Text('Do you want to acquire this property?')
                                ]),
                                SizedBox(height: 20.0),
                              ]);
                            },
                          ),
                          negativeAction: (context, controller, setState) =>
                              TextButton(
                            child: Text('Cancel'),
                            onPressed: () => controller.dismiss(),
                          ),
                          positiveAction: (context, controller, setState) =>
                              TextButton(
                            child: Text('YES'),
                            onPressed: () async {
                              final propertyDataSource =
                                  context.read(propertyDataSourceProvider);

                              final newProperty = selectedProperty.state
                                  .copyWith(acquiredBy: currentUser.uid);

                              String message =
                                  selectedProperty.state.status == 'Rent'
                                      ? 'rented'
                                      : 'bought';

                              await propertyDataSource
                                  .updateProperty(newProperty)
                                  .then((updatedProperty) async {
                                selectedProperty.state = updatedProperty;

                                // send notification
                                await sendPushMessage(
                                  context,
                                  selectedProperty.state.userDeviceToken,
                                );

                                controller.dismiss();
                                showToast(context,
                                    message: '$message property',
                                    color: Colors.green);
                              });
                            },
                          ),
                        );
                      },
                    )
                  ],
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Future<void> sendPushMessage(BuildContext context, String? token) async {
    if (token == null) {
      showToast(
        context,
        message: 'Unable to send notification message, no token exists.',
      );
      return;
    }

    try {
      await http
          .post(Uri.parse('https://fcm.googleapis.com/fcm/send'),
              headers: <String, String>{
                'Content-Type': 'application/json; charset=UTF-8',
                'Authorization':
                    'Bearer AAAALmsecQ8:APA91bH5nlRoMg-cpOQrBbKMyZcIQRwrgCu5o-Muy-JIHLV_WYpnz_yE4rU7DsDeyA9DmCVo0qwC0ziKAtRZKg_nvAfRmu3ww6gEKW86yolVC-8HaAzDeAblItmKyhTQv9tJM6SVb9yH'
              },
              body: constructFCMPayload(token))
          .then((response) {
      });
    } catch (e) {
      print(e);
    }
  }

  /// The API endpoint here accepts a raw FCM payload for demonstration purposes.
  String constructFCMPayload(String token) {
    print(token);
    return jsonEncode({
      'token': token,
      'to': token,
      'data': {
        'message': 'The uploaded property has been acquired by someone',
        'click_action': "FLUTTER_NOTIFICATION_CLICK",
      },
      'notification': {
        'title': 'Property acquistion!',
        'body': 'The uploaded property has been acquired by someone.',
      },
    });
  }

  Widget buildRatingBarIndicator(StateController<double> stateController) {
    return RatingBarIndicator(
      rating: stateController.state,
      itemBuilder: (context, index) => GestureDetector(
        child: Icon(
          Icons.star,
          color: Colors.amber,
        ),
        onTap: () => stateController.state = index + 1,
      ),
      itemCount: 10,
      itemSize: 50.0,
      unratedColor: Colors.amber.withAlpha(50),
      direction: Axis.horizontal,
    );
  }

  Widget buildGalleryCard(String imageURL) {
    return GestureDetector(
      onTap: () {
        ImageViewer.showImageSlider(images: [imageURL]);
      },
      child: Container(
        width: 100,
        height: 100,
        margin: const EdgeInsets.only(right: 15.0),
        decoration: BoxDecoration(
          image: DecorationImage(
            image: CachedNetworkImageProvider(imageURL),
            fit: BoxFit.fill,
          ),
          borderRadius: BorderRadius.circular(15),
        ),
      ),
    );
  }
}
