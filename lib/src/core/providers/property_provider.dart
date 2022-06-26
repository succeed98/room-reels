import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

import '../datasources/property_datasource.dart';
import '../models/property_filter.dart';
import '../models/property_model.dart';
import 'firebase_providers.dart';

final propertyDataSourceProvider = Provider<PropertyDataSourceImpl>(
    (ref) => PropertyDataSourceImpl(ref.watch(firestoreProvider)));

/// provides [PropertyFilter] entity
final propertyFilterProvider = StateProvider<PropertyFilter>((ref) {
  final location = ref.watch(fpLocationProvider);
  final propertyType = ref.watch(fpTypeProvider);
  final priceRange = ref.watch(fpPriceProvider);
  final rating = ref.watch(fpRatingProvider);
  final bedrooms = ref.watch(fpBedroomsProvider);
  final bathrooms = ref.watch(fpBathroomsProvider);
  final kitchen = ref.watch(fpKitchenProvider);

  var minPrice = priceRange.state.start;
  var maxPrice = priceRange.state.end;

  var ratingResult = double.tryParse(rating.state);


  return PropertyFilter(
    location: location.state,
    propertyType: propertyType.state,
    minPrice: minPrice,
    maxPrice: maxPrice,
    rating: ratingResult ?? 5.0,
    bedrooms: bedrooms.state,
    bathrooms: bathrooms.state,
    kitchens: kitchen.state,
  );
});

// fp => property filter provider options
final fpTypeProvider = StateProvider<String>((ref) => 'All');

final fpLocationProvider = StateProvider<String>((ref) => '');

final fpPriceProvider =
    StateProvider<RangeValues>((ref) => const RangeValues(1, 1000));

final fpPriceLabelProvider = StateProvider<RangeLabels>((ref) {
  final priceRange = ref.watch(fpPriceProvider);

  return RangeLabels(
      priceRange.state.start.toString(), priceRange.state.end.toString());
});

final fpRatingProvider = StateProvider<String>((ref) => '5.0');

final fpBedroomsProvider = StateProvider<String>((ref) => 'All');

final fpBathroomsProvider = StateProvider<String>((ref) => 'All');

final fpKitchenProvider = StateProvider<String>((ref) => 'All');
// end property filter options

final propertyDpProvider =
    StateProvider.autoDispose<List<AssetEntity>>((ref) => []);

final propertyPicsProvider =
    StateProvider.autoDispose<List<AssetEntity>>((ref) => []);

updateProviderState(BuildContext context,
    {required dynamic value, required StateProvider provider}) {
  context.read(provider).state = value;
}

final searchTitleProvider = StateProvider<String>((ref) => '');

final filterSearchPropertiesProvider =
    FutureProvider<List<PropertyModel>>((ref) {
  final searchTitle = ref.watch(searchTitleProvider);
  final propertyDataSource = ref.watch(propertyDataSourceProvider);
  final propertyFilter = ref.watch(propertyFilterProvider);

  return propertyDataSource.filterSearchProperties(
      searchTitle.state, propertyFilter.state);
});

final selectedPropertyProvider = StateProvider<PropertyModel>(
  (ref) => const PropertyModel(
    uid: '',
    title: '',
    price: 0,
    location: '',
    description: '',
    status: '',
    type: '',
    bedrooms: '',
    bathrooms: '',
    ratings: 0,
    displayPic: '',
    featuredPics: [],
    likes: [],
    kitchens: '',
    userDeviceToken: '',
  ),
);

final acquiredPropertiesProvider = StreamProvider<List<PropertyModel>>(
    (ref) => ref.watch(propertyDataSourceProvider).getAcquiredProperties());
