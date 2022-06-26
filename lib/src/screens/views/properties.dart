// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/property_model.dart';
import '../../core/providers/firebase_providers.dart';
import '../../core/providers/property_provider.dart';
import '../../utils/constants.dart';
import '../components/loading.dart';
import '../components/property_card.dart';
import 'property_details.dart';

final userPropertiesProvider = StreamProvider<List<PropertyModel>>((ref) {
  final firebaseAuth = ref.watch(firebaseAuthProvider);

  return ref
      .watch(propertyDataSourceProvider)
      .getPropertiesByUserId(firebaseAuth.currentUser!.uid);
});

class PropertiesScreen extends ConsumerWidget {
  const PropertiesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final getPropertiesByUserId = watch(userPropertiesProvider);
    final selectedProperty = watch(selectedPropertyProvider);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0.0,
        backgroundColor: Colors.transparent,
        title: Text('Properties', style: F_24_MEDIUM),
      ),
      body: getPropertiesByUserId.when(
          data: (List<PropertyModel> properties) {
            if (properties.isEmpty) {
              return Center(child: Text('No available property uploaded yet.'));
            }

            return ListView.builder(
              itemCount: properties.length,
              itemBuilder: (BuildContext context, int index) {
                return GestureDetector(
                  onTap: () {
                    selectedProperty.state = properties[index];
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => PropertyDetailsScreen()));
                  },
                  child: PropertyCard(property: properties[index]),
                );
              },
            );
          },
          error: (Object error, StackTrace? stackTrace) {
            return Text('oops reload page');
          },
          loading: () => Loading()),
    );
  }

  Container buildGalleryCard() {
    return Container(
      width: 100,
      height: 100,
      margin: const EdgeInsets.only(right: 15.0),
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage("assets/images/house-for-sale.jpg"),
          fit: BoxFit.fill,
        ),
        borderRadius: BorderRadius.circular(15),
      ),
    );
  }
}
