import 'package:equatable/equatable.dart';

class PropertyFilter extends Equatable {
  final String location;
  final String propertyType;
  final double minPrice;
  final double maxPrice;
  final double rating;
  final String bedrooms;
  final String bathrooms;
  final String kitchens;

  const PropertyFilter({
    required this.location,
    this.propertyType = 'All',
    this.minPrice = 1,
    this.maxPrice = 1000,
    this.rating = 5.0,
    this.bedrooms = 'All',
    this.bathrooms = 'All',
    this.kitchens = 'All',
  });

  factory PropertyFilter.fromJson(Map<String, dynamic> json) {
    return PropertyFilter(
      location: json['location'],
      propertyType: json['propertyType'],
      minPrice: json['minPrice'],
      maxPrice: json['maxPrice'],
      rating: json['rating'],
      bedrooms: json['bedrooms'],
      bathrooms: json['bathrooms'],
      kitchens: json['kitchens'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'location': location,
      'propertyType': propertyType,
      'minPrice': minPrice,
      'maxPrice': maxPrice,
      'rating': rating,
      'bedrooms': bedrooms,
      'bathrooms': bathrooms,
      'kitchens': kitchens,
    };
  }

  @override
  List<Object?> get props => [
        location,
        propertyType,
        minPrice,
        maxPrice,
        rating,
        bedrooms,
        bathrooms,
        kitchens,
      ];
}
