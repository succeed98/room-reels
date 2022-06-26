import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/property_filter.dart';
import '../models/property_model.dart';

abstract class PropertyDataSource {
  /// Make call to Firebase 'properties' collection for [PropertyModel]
  /// Throws [ServerException] if error occurs.
  Stream<List<PropertyModel>> getPropertiesByUserId(String uid);
  Future<List<PropertyModel>> filterSearchProperties(
      String title, PropertyFilter propertyFilter);
  Future<PropertyModel> getPropertyById(String id);
  Stream<List<PropertyModel>> getAllProperties();
  Stream<List<PropertyModel>> getNotAcquiredProperties();
  Stream<List<PropertyModel>> getAcquiredProperties();
  Future<PropertyModel> addProperty(PropertyModel property);
  Future<PropertyModel> updateProperty(PropertyModel property);
  Future<void> deleteProperty(PropertyModel property);
}

class PropertyDataSourceImpl implements PropertyDataSource {
  PropertyDataSourceImpl(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<PropertyModel> get propertyRef =>
      properties.withConverter<PropertyModel>(
        fromFirestore: (snapshot, _) =>
            PropertyModel.fromJson(snapshot.data()!),
        toFirestore: (property, _) => property.toJson(),
      );

  CollectionReference<Map<String, dynamic>> get properties =>
      _firestore.collection('properties');

  Stream<QuerySnapshot<Map<String, dynamic>>> get propertiesStream =>
      properties.snapshots();

  @override
  Future<PropertyModel> addProperty(PropertyModel property) async {
    final documentId = propertyRef.doc().id;
    property = property.copyWith(id: documentId);
    await propertyRef.doc(documentId).set(property);

    return property;
  }

  @override
  Future<void> deleteProperty(PropertyModel property) async {
    return await properties
        .where('id', isEqualTo: property.id)
        .get()
        .then((snapshot) {
      snapshot.docs.first.reference.delete();
    });
  }

  @override
  Future<PropertyModel> updateProperty(PropertyModel property) async {
    await properties.where('id', isEqualTo: property.id).get().then((snapshot) {
      snapshot.docs.first.reference.update(property.toJson());
    });

    return property;
  }

  @override
  Stream<List<PropertyModel>> getAllProperties() {
    return propertiesStream.map((querySnapshot) => querySnapshot.docs
        .map((queryDocumentSnapshot) =>
            PropertyModel.fromJson(queryDocumentSnapshot.data()))
        .toList());
  }

  @override
  Future<List<PropertyModel>> filterSearchProperties(
      String title, PropertyFilter propertyFilter) async {
    var userPropertiesQuery = propertyRef.where('acquiredBy', isEqualTo: '');

    if (propertyFilter.bathrooms != 'All') {
      userPropertiesQuery = userPropertiesQuery.where('bathrooms',
          isEqualTo: propertyFilter.bathrooms);
    }

    if (propertyFilter.bedrooms != 'All') {
      userPropertiesQuery = userPropertiesQuery.where('bedrooms',
          isEqualTo: propertyFilter.bedrooms);
    }

    if (propertyFilter.kitchens != 'All') {
      userPropertiesQuery = userPropertiesQuery.where('kitchens',
          isEqualTo: propertyFilter.kitchens);
    }

    if (propertyFilter.propertyType != 'All') {
      userPropertiesQuery = userPropertiesQuery.where('type',
          isEqualTo: propertyFilter.propertyType);
    }

    userPropertiesQuery = userPropertiesQuery.where('ratings',
        isGreaterThanOrEqualTo: propertyFilter.rating);

    return await userPropertiesQuery.get().then((snapshot) => snapshot.docs
        .where((queryDocumentSnapshot) =>
            queryDocumentSnapshot
                .data()
                .title
                .toLowerCase()
                .contains(title.toLowerCase()) &&
            queryDocumentSnapshot
                .data()
                .location
                .toLowerCase()
                .contains(propertyFilter.location.toLowerCase()) &&
            queryDocumentSnapshot.data().price >= propertyFilter.minPrice &&
            queryDocumentSnapshot.data().price <= propertyFilter.maxPrice)
        .map((queryDocumentSnapshot) => queryDocumentSnapshot.data())
        .toList());
  }

  @override
  Stream<List<PropertyModel>> getPropertiesByUserId(String uid) {
    final userPropertiesStream =
        propertyRef.where('uid', isEqualTo: uid).snapshots();

    return userPropertiesStream.map((querySnapshot) => querySnapshot.docs
        .map((queryDocumentSnapshot) => queryDocumentSnapshot.data())
        .toList());
  }

  @override
  Future<PropertyModel> getPropertyById(String id) async {
    final result = await propertyRef.where('id', isEqualTo: id).get();

    return result.docs.first.data();
  }

  @override
  Stream<List<PropertyModel>> getNotAcquiredProperties() {
    return propertyRef.where('acquiredBy', isEqualTo: '').snapshots().map(
        (querySnapshot) => querySnapshot.docs
            .map((queryDocumentSnapshot) => queryDocumentSnapshot.data())
            .toList());
  }

  @override
  Stream<List<PropertyModel>> getAcquiredProperties() {
    return propertyRef.where('acquiredBy', isNotEqualTo: '').snapshots().map(
        (querySnapshot) => querySnapshot.docs
            .map((queryDocumentSnapshot) => queryDocumentSnapshot.data())
            .toList());
  }
}
