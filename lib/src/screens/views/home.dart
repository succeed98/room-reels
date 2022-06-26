// ignore_for_file: prefer_const_constructors, curly_braces_in_flow_control_structures, prefer_const_literals_to_create_immutables

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/property_model.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/providers/property_provider.dart';
import '../../utils/constants.dart';
import '../components/custom_radio_grouped_button.dart';
import '../components/h_button.dart';
import '../components/h_text_form_field.dart';
import '../components/loading.dart';
import '../components/property_card.dart';
import 'notifications.dart';
import 'property_details.dart';

final allPropertiesProvider = StreamProvider<List<PropertyModel>>(
    (ref) => ref.watch(propertyDataSourceProvider).getAllProperties());

final notAcquiredPropertiesProvider = StreamProvider<List<PropertyModel>>(
    (ref) => ref.watch(propertyDataSourceProvider).getNotAcquiredProperties());

final showFilterProvider = StateProvider.autoDispose<bool>((ref) => false);

class HomeScreen extends ConsumerWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    final notAcquiredProperties = watch(notAcquiredPropertiesProvider);
    final selectedProperty = watch(selectedPropertyProvider);
    final showFilter = watch(showFilterProvider);
    final searchTitle = watch(searchTitleProvider);
    final filterSearchProperties = watch(filterSearchPropertiesProvider);
    final currentUser = watch(userProvider);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          Container(
            width: screenWidth,
            height: screenHeight / 4.9,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/home-bg.png"),
                fit: BoxFit.fill,
              ),
            ),
          ),
          SingleChildScrollView(
            padding: EdgeInsets.all(20),
            child: Column(
              children: [
                SizedBox(height: 15),
                Row(
                  mainAxisAlignment: currentUser.userType == 'buyer'
                      ? MainAxisAlignment.end
                      : MainAxisAlignment.spaceBetween,
                  children: [
                    if (currentUser.userType == 'seller') ...[
                      GestureDetector(
                        child: Icon(Icons.notifications),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => NotificationsScreen()),
                        ),
                      ),
                    ],
                    Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        color: Color(0xFF2A3736).withOpacity(0.5),
                        borderRadius: BorderRadius.circular(50),
                        image: currentUser.photoURL != null 
                            ? DecorationImage(
                                fit: BoxFit.cover,
                                image: CachedNetworkImageProvider(
                                  currentUser.photoURL ?? '',
                                ),
                              )
                            : null,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      width: screenWidth - 105,
                      margin: EdgeInsets.only(right: 10),
                      child: HTextFormField(
                        onChanged: (value) => searchTitle.state = value,
                        iconData: Icons.search,
                        hintText: 'search property',
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(20),
                              topRight: Radius.circular(20),
                            ),
                          ),
                          builder: (_) {
                            return PropertyFilterWidget();
                          },
                        );
                      },
                      child: Container(
                        width: 55,
                        height: 55,
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          borderRadius: BorderRadius.circular(20),
                          image: DecorationImage(
                            image: AssetImage("assets/images/filter.png"),
                            fit: BoxFit.scaleDown,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                showFilter.state
                    // show filtered properies
                    ? SingleChildScrollView(
                        child: Column(
                          children: [
                            Text('Search result'),
                            SizedBox(height: 20),
                            filterSearchProperties.when(
                              data: (data) {
                                if (data.isEmpty)
                                  return Center(
                                    child: Text('No search marched yet.'),
                                  );
                                return Column(
                                    children: data.map((property) {
                                  return GestureDetector(
                                    onTap: () {
                                      selectedProperty.state = property;
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (_) =>
                                                  PropertyDetailsScreen()));
                                    },
                                    child: PropertyCard(property: property),
                                  );
                                }).toList());
                              },
                              error: (Object error, StackTrace? stackTrace) {
                                
                                return TextButton(
                                  child: Text('Failed to laod.Tap to refresh'),
                                  onPressed: () => context
                                      .refresh(filterSearchPropertiesProvider),
                                );
                              },
                              loading: () => Loading(),
                            ),
                          ],
                        ),
                      )
                    // show all properties
                    : SingleChildScrollView(
                        child: Column(
                          children: [
                            notAcquiredProperties.when(
                              data: (List<PropertyModel> properties) {
                                if (properties.isEmpty)
                                  return Center(
                                    child: Text(
                                        'No available property uploaded yet.'),
                                  );

                                return Column(
                                    children: properties.map((property) {
                                  return GestureDetector(
                                    onTap: () {
                                      selectedProperty.state = property;
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (_) =>
                                                  PropertyDetailsScreen()));
                                    },
                                    child: PropertyCard(property: property),
                                  );
                                }).toList());
                              },
                              error: (Object error, StackTrace? stackTrace) {
                                
                                return TextButton(
                                  child: Text('Failed to laod.Tap to refresh'),
                                  onPressed: () => context
                                      .refresh(filterSearchPropertiesProvider),
                                );
                              },
                              loading: () => Loading(),
                            ),
                          ],
                        ),
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class PropertyFilterWidget extends StatelessWidget {
  const PropertyFilterWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 20.0, right: 20.0, bottom: 20.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Icon(Icons.close),
              ),
              Text('Filter Property', style: F_18),
              TextButton(
                onPressed: () {
                  context.read(showFilterProvider).state = false;
                  Navigator.pop(context);
                },
                child: Text('Reset', style: F_18_PRIMARY_COLOR),
              ),
            ],
          ),
          Text('Location', style: F_18_BOLD),
          SizedBox(height: 7),
          Consumer(
            builder: (context, watch, child) {
              final location = watch(fpLocationProvider);

              return HTextFormField(
                hintText: 'location',
                onChanged: (value) => location.state = value,
              );
            },
          ),
          SizedBox(height: 15),
          Text('Property type', style: F_18_BOLD),
          SizedBox(height: 7),
          Consumer(
            builder: (context, watch, child) {
              final propertyType = watch(fpTypeProvider);

              return CustomRadioGroupedButton(
                value: propertyType.state,
                options: ["Apartment", "House", "All"],
                icons: [Icons.apartment, Icons.house, Icons.place],
                onChanged: (String value) {
                  propertyType.state = value;
                },
              );
            },
          ),
          SizedBox(height: 15),
          Text('Price range', style: F_18_BOLD),
          Consumer(
            builder: (context, watch, child) {
              final priceRange = watch(fpPriceProvider);
              final priceRangeLabel = watch(fpPriceLabelProvider);

              return RangeSlider(
                  divisions: 1000,
                  activeColor: SECONDARY_COLOR,
                  inactiveColor: SECONDARY_COLOR.withOpacity(0.3),
                  min: 0,
                  max: 1000,
                  values: priceRange.state,
                  labels: priceRangeLabel.state,
                  onChanged: (value) {
                    priceRange.state = value;
                  });
            },
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${context.read(fpPriceProvider).state.start}'),
              Text('${context.read(fpPriceProvider).state.end}'),
            ],
          ),
          SizedBox(height: 15),
          Text('Star range', style: F_18_BOLD),
          SizedBox(height: 7),
          Consumer(builder: (context, watch, child) {
            final rating = watch(fpRatingProvider);

            return CustomRadioGroupedButton(
              value: rating.state,
              options: ["5.0", "4.0", "3.0", "2.0"],
              defaultIcon: Icon(
                Icons.star,
                color: Colors.amber,
                size: 20,
              ),
              useCheckIcon: true,
              onChanged: (String value) {
                rating.state = value;
              },
            );
          }),
          SizedBox(height: 15),
          Text('Bed rooms', style: F_18_BOLD),
          SizedBox(height: 7),
          Consumer(builder: (context, watch, child) {
            final bedrooms = watch(fpBedroomsProvider);

            return CustomRadioGroupedButton(
              value: bedrooms.state,
              options: ["All", "1", "2", "3"],
              onChanged: (String value) {
                bedrooms.state = value;
              },
            );
          }),
          SizedBox(height: 10),
          Text('Bathrooms', style: F_18_BOLD),
          SizedBox(height: 7),
          Consumer(builder: (context, watch, child) {
            final bathrooms = watch(fpBathroomsProvider);

            return CustomRadioGroupedButton(
              value: bathrooms.state,
              options: ["All", "1", "2", "3"],
              onChanged: (String value) {
                bathrooms.state = value;
              },
            );
          }),
          SizedBox(height: 10),
          Text('Kitchen', style: F_18_BOLD),
          SizedBox(height: 7),
          Consumer(builder: (context, watch, child) {
            final kitchen = watch(fpKitchenProvider);

            return CustomRadioGroupedButton(
              value: kitchen.state,
              options: ["All", "1", "2", "3"],
              onChanged: (String value) {
                kitchen.state = value;
              },
            );
          }),
          SizedBox(height: 20),
          HButton(
            text: 'Apply Filter',
            onPressed: () {
              context.read(showFilterProvider).state = true;
              Navigator.pop(context);
            },
          )
        ],
      ),
    );
  }
}
