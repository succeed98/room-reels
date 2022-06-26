// ignore_for_file: prefer_const_constructors, sized_box_for_whitespace

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../core/models/property_model.dart';
import '../../core/providers/auth_provider.dart';
import '../../utils/constants.dart';

/// [PropertyCard] custom card to display brief information about property
class PropertyCard extends ConsumerWidget {
  final PropertyModel property;

  const PropertyCard({
    Key? key,
    required this.property,
  });

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final currentUser = watch(currentUserProvider);
    return Card(
      elevation: 1.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 160.0,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              image: DecorationImage(
                fit: BoxFit.cover,
                image: CachedNetworkImageProvider(property.displayPic),
              ),
            ),
            child: Stack(
              children: [
                Positioned(
                  top: 10.0,
                  left: 20,
                  right: 10,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      PropertyPill(text: property.type),
                      IconButton(
                        icon: Icon(Icons.favorite_outlined),
                        color: property.likes.contains(currentUser!.uid)
                            ? Colors.red
                            : Colors.black,
                        onPressed: () {},
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            title: Text(
              property.title,
              style: TextStyle(fontSize: 19.0, fontFamily: 'Futura'),
            ),
            subtitle: Text(
              'GH₵ ${property.price}',
              style: TextStyle(
                  fontSize: 17.0,
                  color: Colors.grey,
                  fontWeight: FontWeight.bold),
            ),
            trailing: Container(
              width: 50,
              child: Row(
                children: [
                  Icon(
                    Icons.star,
                    color: Colors.amber,
                    size: 18,
                  ),
                  Text(property.ratings.toStringAsFixed(1)),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
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
                          Text(
                            property.bedrooms,
                          )
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
                          Text(
                            property.bathrooms,
                          )
                        ],
                      ),
                    ),
                    Container(
                      width: 50,
                      child: Row(
                        // ignore: prefer_const_literals_to_create_immutables
                        children: [
                          Icon(
                            Icons.kitchen,
                            size: 18,
                            color: SECONDARY_COLOR,
                          ),
                          SizedBox(width: 5),
                          Text(property.kitchens)
                        ],
                      ),
                    ),
                  ],
                ),
                PropertyPill(text: property.status),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class PropertyPill extends StatelessWidget {
  const PropertyPill({
    Key? key,
    required this.text,
  }) : super(key: key);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: SECONDARY_COLOR,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(15.0),
          bottomRight: Radius.circular(15.0),
        ),
      ),
      padding: EdgeInsets.all(8.0),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.white,
          fontSize: 12.0,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
