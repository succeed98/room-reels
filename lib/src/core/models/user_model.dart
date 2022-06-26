import 'package:equatable/equatable.dart';

/// [UserModel] entity consists of the details of a user
class UserModel extends Equatable {
  /// Unique identification
  final String? uid;

  /// email
  final String? email;

  /// password
  final String? password;

  /// display name
  final String? name;

  ///  digitalAddress
  final String? digitalAddress;

  /// url of display picture
  final String? photoURL;

  /// phone number of user
  final String? phoneNumber;

  /// type of user
  final String? userType;

  final List<String> chats;

  const UserModel({
    this.uid,
    this.email,
    this.password,
    this.name,
    this.digitalAddress,
    this.phoneNumber,
    this.photoURL,
    this.userType,
    this.chats = const [],
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'],
      email: json['email'],
      password: json['password'],
      name: json['name'],
      digitalAddress: json['digitalAddress'],
      phoneNumber: json['phoneNumber'],
      photoURL: json['photoURL'],
      userType: json['userType'],
      chats:  List<String>.from(json['chats']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'password': password,
      'name': name,
      'digitalAddress': digitalAddress,
      'phoneNumber': phoneNumber,
      'photoURL': photoURL,
      'userType': userType,
      'chats': chats,
    };
  }

  UserModel copy({
    String? uid,
    String? email,
    String? password,
    String? name,
    String? digitalAddress,
    String? phoneNumber,
    String? photoURL,
    String? userType,
    List<String>? chats,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      password: password ?? this.password,
      name: name ?? this.name,
      digitalAddress: digitalAddress ?? this.digitalAddress,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      photoURL: photoURL ?? this.photoURL,
      userType: userType ?? this.userType,
      chats: chats ?? this.chats,
    );
  }

  @override
  List<Object?> get props => [
        uid,
        email,
        password,
        name,
        digitalAddress,
        phoneNumber,
        photoURL,
        userType,
        chats,
      ];
}
