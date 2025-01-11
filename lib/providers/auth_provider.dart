import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart' as loc;
import 'package:geocoding/geocoding.dart' as geocoding;
import 'package:image_picker/image_picker.dart';

class AuthProvider extends ChangeNotifier {
  File? image;
  bool isPictureAvailable = false;
  double shopLatitude = 0.0;
  double shopLongitude = 0.0;
  String? shopAddress;
  String? placeName;
  String email = "";
  String mobileNumber = "";

  Future<File?> getImage() async {
    final ImagePicker _picker = ImagePicker();
    final pickedImage = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      image = File(pickedImage.path);
      isPictureAvailable = true;
      notifyListeners();
    } else {
      print("No Image Selected");
    }
    return image;
  }

  Future getCurrentAddress() async {
    loc.Location location = loc.Location();

    bool serviceEnabled;
    loc.PermissionStatus permissionGranted;
    loc.LocationData locationData;

    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        return;
      }
    }

    permissionGranted = await location.hasPermission();
    if (permissionGranted == loc.PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != loc.PermissionStatus.granted) {
        return;
      }
    }

    locationData = await location.getLocation();
    double shopLatitude = locationData.latitude!;
    double shopLongitude = locationData.longitude!;
    notifyListeners();

    List<geocoding.Placemark> placemarks =
        await geocoding.placemarkFromCoordinates(shopLatitude, shopLongitude);
    geocoding.Placemark place = placemarks.first;

    this.shopAddress =
        '${place.street}, ${place.locality}, ${place.postalCode}, ${place.country}';
    String placeName = place.name ?? '';
    notifyListeners();

    return place;
  }

  // Email Registration
  Future<UserCredential?> registerVendor(
      String email, String password, String mobile) async {
    this.email = email;
    mobileNumber = mobile;
    notifyListeners();
    UserCredential? userCredential;
    try {
      userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        print('The password provided is too weak.');
        notifyListeners();
      } else if (e.code == 'email-already-in-use') {
        print('The account already exists for that email.');
        notifyListeners();
      }
    } catch (e) {
      print(e.toString());
      notifyListeners();
    }
    return userCredential;
  }

  //Reset Password
  Future<void> authDataResetPassword(String email) async {
    this.email = email;
    notifyListeners();
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
    } catch (e) {
      print(e.toString());
      notifyListeners();
    }
  }

  //Login Vendor
  Future<UserCredential?> loginVendor(String email, String password) async {
    this.email = email;
    notifyListeners();
    UserCredential? userCredential;
    try {
      userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        print('The password provided is too weak.');
        notifyListeners();
      } else if (e.code == 'email-already-in-use') {
        print('The account already exists for that email.');
        notifyListeners();
      }
    } catch (e) {
      print(e.toString());
      notifyListeners();
    }
    return userCredential;
  }

  // Save Vendor Data to Firestore
  Future<void> saveVendorDataToDatabase(
      {required String url,
      required String shopName,
      required String mobile,
      required String dialog}) async {
    User? user = FirebaseAuth.instance.currentUser;
    DocumentReference<Map<String, dynamic>> _vendors =
        FirebaseFirestore.instance.collection('vendors').doc(user?.uid);
    _vendors.set({
      'uid': user?.uid,
      'shopName': shopName,
      'email': email,
      'mobile': mobileNumber,
      'dialog': dialog,
      'address': '$placeName:$shopAddress',
      'location': GeoPoint(shopLatitude, shopLongitude),
      'shopOpen': true,
      'rating': 0.0,
      'totalRating': 0,
      'isTopPicked': false,
      'imageUrl': url,
      'accVerified': false // only verified vendors can sell their products
    });
  }
}
