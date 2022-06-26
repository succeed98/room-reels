import 'package:equatable/equatable.dart';

/// [PropertyModel] entity consists of the details of a user
class PropertyModel extends Equatable {
  /// Unique identification for [PropertyModel]
  final String? id;

  /// [UserModel] unique identification for [PropertyModel]
  final String uid;

  /// title
  final String title;

  /// price
  final double price;

  /// location
  final String location;

  ///  Short notes for the [PropertyModel]
  final String description;

  /// Indicates either the property is for Rent or Buy
  final String status;

  /// Indicates either the property is an Apartment or House
  final String type;

  /// the number of bedrooms available
  final String bedrooms;

  /// the number of bathrooms available
  final String bathrooms;

  /// the number of kitchens available
  final String kitchens;

  /// property ratings
  final double ratings;

  /// url of display picture
  final String displayPic;

  /// List of url of featured pictures
  final List<dynamic> featuredPics;

  /// List of uid of users who liked this property
  final List<dynamic> likes;

  /// the person who has bought or rented the property
  final String acquiredBy;

  /// the owner of a property mobile device token for notification alerts
  final String? userDeviceToken;

  const PropertyModel({
    this.id,
    required this.uid,
    required this.title,
    required this.price,
    required this.location,
    required this.description,
    required this.status,
    required this.type,
    required this.bedrooms,
    required this.bathrooms,
    required this.kitchens,
    this.ratings = 5,
    required this.displayPic,
    required this.featuredPics,
    this.likes = const [],
    this.acquiredBy = '',
    this.userDeviceToken,
  });

  factory PropertyModel.fromJson(Map<String, dynamic> json) {
    return PropertyModel(
      id: json['id'],
      uid: json['uid'],
      title: json['title'],
      price: json['price'],
      location: json['location'],
      description: json['description'],
      status: json['status'],
      type: json['type'],
      bedrooms: json['bedrooms'],
      bathrooms: json['bathrooms'],
      kitchens: json['kitchens'],
      ratings: json['ratings'],
      displayPic: json['displayPic'],
      featuredPics: json['featuredPics'],
      likes: json['likes'],
      acquiredBy: json['acquiredBy'],
      userDeviceToken: json['userDeviceToken'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'uid': uid,
      'title': title,
      'price': price,
      'location': location,
      'description': description,
      'status': status,
      'type': type,
      'bedrooms': bedrooms,
      'bathrooms': bathrooms,
      'kitchens': kitchens,
      'ratings': ratings,
      'featuredPics': featuredPics,
      'displayPic': displayPic,
      'likes': likes,
      'acquiredBy': acquiredBy,
      'userDeviceToken': userDeviceToken,
    };
  }

  PropertyModel copyWith({
    String? id,
    String? uid,
    String? title,
    double? price,
    String? location,
    String? description,
    String? status,
    String? type,
    String? bedrooms,
    String? bathrooms,
    String? kitchens,
    double? ratings,
    List<dynamic>? featuredPics,
    String? displayPic,
    List<dynamic>? likes,
    String? acquiredBy,
    String? userDeviceToken,
  }) {
    return PropertyModel(
      id: id ?? this.id,
      uid: uid ?? this.uid,
      title: title ?? this.title,
      price: price ?? this.price,
      location: location ?? this.location,
      description: description ?? this.description,
      status: status ?? this.status,
      type: type ?? this.type,
      bedrooms: bedrooms ?? this.bedrooms,
      bathrooms: bathrooms ?? this.bathrooms,
      kitchens: kitchens ?? this.kitchens,
      ratings: ratings ?? this.ratings,
      featuredPics: featuredPics ?? this.featuredPics,
      displayPic: displayPic ?? this.displayPic,
      likes: likes ?? this.likes,
      acquiredBy: acquiredBy ?? this.acquiredBy,
      userDeviceToken: userDeviceToken ?? this.userDeviceToken,
    );
  }

  @override
  List<Object?> get props => [
        id,
        uid,
        title,
        price,
        location,
        description,
        status,
        type,
        bedrooms,
        bathrooms,
        kitchens,
        ratings,
        featuredPics,
        displayPic,
        likes,
        acquiredBy,
        userDeviceToken,
      ];
}
