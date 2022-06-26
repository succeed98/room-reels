import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geocoding/geocoding.dart';
import 'package:location/location.dart' as loc;

import '../models/coordinates.dart';

final locationProvider = Provider<loc.Location>((ref) => loc.Location());

final getLocationFutureProvider = FutureProvider<loc.LocationData>((ref) async {
  final location = ref.watch(locationProvider);

  bool isServiceEnabled = await location.serviceEnabled();
  while (!isServiceEnabled) {
    isServiceEnabled = await location.requestService();
  }

  loc.PermissionStatus permissionGranted = await location.hasPermission();
  while (permissionGranted == loc.PermissionStatus.denied) {
    permissionGranted = await location.requestPermission();
  }

  return await ref.watch(locationProvider).getLocation();
});

final getUserCoordinatesProvider = Provider<Coordinates>((ref) {
  final getLocationFuture = ref.watch(getLocationFutureProvider);

  return getLocationFuture.maybeWhen(
    data: (data) => Coordinates(
      lat: data.latitude.toString(),
      lon: data.longitude.toString(),
    ),
    orElse: () => const Coordinates(lat: '', lon: ''),
  );
});

final locationAddressProvider = FutureProvider<String?>((ref) async {
  final getUserCoordinates = ref.watch(getUserCoordinatesProvider);

  if (getUserCoordinates == const Coordinates(lat: '', lon: '')) return '';

  List<Placemark> newPlace = await placemarkFromCoordinates(
      getUserCoordinates.numLat, getUserCoordinates.numLon);
  Placemark placeMark = newPlace.first;

  return placeMark.subLocality;
});
