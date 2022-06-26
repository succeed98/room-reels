import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'location_provider.dart';
import 'property_provider.dart';

final emailProvider = StateProvider<String>((ref) => '');
final pwdProvider = StateProvider<String>((ref) => '');
final nameProvider = StateProvider<String>((ref) => '');
final userTypeProvider = StateProvider<String>((ref) => 'seller');

final digitalAddrProvider = StateProvider<TextEditingController>((ref) {
  final locationAddress = ref.watch(locationAddressProvider);

  return locationAddress.maybeWhen(
    data: (place) => place == null ? TextEditingController(text: '') : TextEditingController(text: place),
    error: (error, stack){
      return TextEditingController(text: '');
    },
    orElse: () => TextEditingController(text: ''),
  );
});

final phoneNumberProvider = StateProvider<String>((ref) => '');

resetEmailPwdInput(BuildContext context) {
  updateProviderState(context, value: '', provider: emailProvider);
  updateProviderState(context, value: '', provider: pwdProvider);
}

resetAccountSetupFields(BuildContext context) {
  updateProviderState(context, value: '', provider: nameProvider);
  updateProviderState(context, value: '', provider: digitalAddrProvider);
  updateProviderState(context, value: '', provider: phoneNumberProvider);
}

updateNameProvider(BuildContext context, String value) {
  context.read(nameProvider).state = value;
}


updateDigiAddrProvider(BuildContext context, String value) {
  context.read(digitalAddrProvider).state.text = value;
}

updatePhoneNumProvider(BuildContext context, String value) {
  context.read(phoneNumberProvider).state = value;
}
