// ignore_for_file: prefer_const_constructors

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/property_model.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/providers/property_provider.dart';
import '../../utils/constants.dart';
import '../components/loading.dart';
import 'property_details.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final acquiredProperties = watch(acquiredPropertiesProvider);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0.0,
        backgroundColor: Colors.transparent,
        title: Text('Notification', style: F_24_MEDIUM),
      ),
      body: acquiredProperties.when(
        data: (propertyModelList) => propertyModelList.isEmpty
            ? Center(child: Text('No notification yet.'))
            : ListView.builder(
                padding: EdgeInsets.symmetric(vertical: 20, horizontal: 15),
                itemCount: propertyModelList.length,
                itemBuilder: (_, index) => GestureDetector(
                  onTap: () {
                    context.read(selectedPropertyProvider).state =
                        propertyModelList.elementAt(index);
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => PropertyDetailsScreen()));
                  },
                  child: buildNotificationCard(
                      propertyModel: propertyModelList.elementAt(index)),
                ),
              ),
        loading: () => Loading(),
        error: (error, stack) => TextButton(
          child: Text('oops failed to load data...Tap to refresh screen.'),
          onPressed: () => context.refresh(acquiredPropertiesProvider),
        ),
      ),
    );
  }

  Widget buildNotificationCard({required PropertyModel propertyModel}) {
    final acquiredState = propertyModel.status == 'Rent' ? 'rented' : 'bought';

    return Consumer(
      builder: (context, watch, child) {
        final userProperty =
            watch(userStreamProvider(propertyModel.acquiredBy));

        return userProperty.when(
          data: (user) => ListTile(
            leading: Container(
              width: 40,
              height: 40,
              padding: EdgeInsets.all(5),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFF2A3736).withOpacity(0.1),
                image: user.photoURL!.isNotEmpty
                    ? DecorationImage(
                        image: CachedNetworkImageProvider(user.photoURL ?? ''),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
            ),
            title: Text(
              '${user.name} has $acquiredState ${propertyModel.title} located at ${propertyModel.location}',
              maxLines: 2,
              style: F_15_BOLD,
            ),
          ),
          loading: () => Loading(),
          error: (error, stack) => TextButton(
            child: Text('oops failed to load data...Tap to refresh screen.'),
            onPressed: () =>
                context.refresh(userStreamProvider(propertyModel.acquiredBy)),
          ),
        );
      },
    );
  }
}
