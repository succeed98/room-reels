// ignore_for_file: prefer_const_constructors

import 'dart:async';

import 'package:flash/flash.dart';
import 'package:flutter/material.dart';

void showToast(BuildContext context, {required String message, Color? color}) {
  showFlash(
    context: context,
    duration: const Duration(seconds: 3),
    builder: (context, controller) {
      return Flash(
        controller: controller,
        behavior: FlashBehavior.floating,
        position: FlashPosition.top,
        boxShadows: kElevationToShadow[4],
        horizontalDismissDirection: HorizontalDismissDirection.horizontal,
        backgroundColor: color ?? Colors.red,
        child: FlashBar(
          content: Text(message, style: TextStyle(color: Colors.white)),
        ),
      );
    },
  );
}

typedef ChildBuilder = Widget Function(BuildContext context,
    FlashController controller, void Function(void Function()) setState);

showCustomDialog(
  BuildContext context, {
  required ChildBuilder titleBuilder,
  required ChildBuilder messageBuilder,
  required ChildBuilder negativeAction,
  required ChildBuilder positiveAction,
}) {
  return showFlash(
    context: context,
    persistent: true,
    builder: (context, controller) {
      var theme = Theme.of(context);
      return StatefulBuilder(
        builder: (context, setState) {
          return Flash.dialog(
            controller: controller,
            boxShadows: kElevationToShadow[4],
            backgroundColor: theme.dialogBackgroundColor,
            margin: const EdgeInsets.only(left: 40.0, right: 40.0),
            borderRadius: const BorderRadius.all(Radius.circular(8.0)),
            child: FlashBar(
              title: DefaultTextStyle(
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 21.0,
                    fontWeight: FontWeight.w700),
                child: titleBuilder.call(context, controller, setState),
              ),
              actions: <Widget>[
                negativeAction(context, controller, setState),
                positiveAction(context, controller, setState),
              ],
              content: DefaultTextStyle(
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 15.0,
                    fontWeight: FontWeight.w400),
                child: messageBuilder.call(context, controller, setState),
              ),
            ),
          );
        },
      );
    },
  );
}

showBlockDialog(
  BuildContext context, {
  required Completer dismissCompleter,
}) {
  var controller = FlashController(
    context,
    builder: (context, FlashController controller) {
      return Flash.dialog(
        controller: controller,
        barrierDismissible: false,
        backgroundColor: Colors.black87,
        margin: const EdgeInsets.only(left: 40.0, right: 40.0),
        borderRadius: const BorderRadius.all(Radius.circular(8.0)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: const CircularProgressIndicator(strokeWidth: 2.0),
        ),
      );
    },
    persistent: true,
    onWillPop: () => Future.value(false),
  );
  dismissCompleter.future.then((value) => controller.dismiss(value));
  return controller.show();
}
