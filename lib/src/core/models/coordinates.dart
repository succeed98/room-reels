import 'dart:math';

import 'package:equatable/equatable.dart';

/// Represents a generic set of GPS coordinates
class Coordinates extends Equatable {
  /// Latitude as a `String`
  final String lat;

  /// Longitude as a `String`
  final String lon;

  /// Latitude as a `double`
  double get numLat => double.parse(lat);

  /// Longitude as a `double`
  double get numLon => double.parse(lon);

  const Coordinates({required this.lat, required this.lon});

  Coordinates.from(Coordinates location)
      : lat = location.lat,
        lon = location.lon;

  Coordinates.fromMap(Map<String, dynamic> json)
      : lat = json['lat'],
        lon = json['lon'];

  /// Convert [this] to a Json `Map<String, String>`.
  Map<String, String> toMap() => {
        'lat': lat,
        'lon': lon,
      };

  /// Calculate the distance between this [Coordinates] and [other] in a specific [unit]
  /// Source adapted from: `https://www.geodatasource.com/developers/javascript`
  double distanceTo(Coordinates other, DistanceUnit unit) {
    if ((lat == other.lat) && (lon == other.lon)) {
      return 0;
    } else {
      var radlat1 = pi * numLat / 180;
      var radlat2 = pi * other.numLat / 180;
      var theta = numLon - other.numLon;
      var radtheta = pi * theta / 180;
      var dist = sin(radlat1) * sin(radlat2) +
          cos(radlat1) * cos(radlat2) * cos(radtheta);
      if (dist > 1) {
        dist = 1;
      }
      dist = acos(dist);
      dist = dist * 180 / pi;
      dist = dist * 60 * 1.1515;
      if (unit == DistanceUnit.kilometers) {
        dist = dist * 1.609344;
      }
      if (unit == DistanceUnit.nMiles) {
        dist = dist * 0.8684;
      }
      return dist;
    }
  }

  @override
  List<Object?> get props => [lat, lon];
}

/// The unit in which distance is measured.
enum DistanceUnit { miles, nMiles, kilometers }
