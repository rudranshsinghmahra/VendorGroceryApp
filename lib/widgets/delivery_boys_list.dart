import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:geolocator/geolocator.dart';
import 'package:grocery_vendor_app/services/firebase_services.dart';
import 'package:grocery_vendor_app/services/order_services.dart';

class DeliveryBoysList extends StatefulWidget {
  const DeliveryBoysList({super.key, this.documentSnapshot});

  final DocumentSnapshot? documentSnapshot;

  @override
  State<DeliveryBoysList> createState() => _DeliveryBoysListState();
}

class _DeliveryBoysListState extends State<DeliveryBoysList> {
  final FirebaseService _services = FirebaseService();
  final OrderService _orderService = OrderService();
  GeoPoint? shopLocation;
  double? shopLatitude = 0.0;
  double? shopLongitude = 0.0;

  @override
  void initState() {
    _services.getShopDetails().then((value) {
      if (mounted) {
        setState(() {
          shopLocation = value['location'];
          shopLatitude = shopLocation?.latitude;
          shopLongitude = shopLocation?.longitude;
        });
      }
    });
    super.initState();
  }

  @override
  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppBar(
            automaticallyImplyLeading: false,
            backgroundColor: Theme.of(context).primaryColor,
            title: const Text(
              "Select Delivery Boy",
              style: TextStyle(color: Colors.white),
            ),
            iconTheme: const IconThemeData(color: Colors.white),
          ),
          if (shopLatitude == null || shopLongitude == null)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(),
            )
          else
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.6,
              child: StreamBuilder<QuerySnapshot>(
                stream: _services.deliveryBoys
                    .where('accVerified', isEqualTo: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const Center(child: Text('Something went wrong'));
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final docs = snapshot.data?.docs ?? [];

                  final nearbyDocs = docs.where((doc) {
                    final location = doc['location'] as GeoPoint;
                    final distance = Geolocator.distanceBetween(
                            shopLatitude!,
                            shopLongitude!,
                            location.latitude,
                            location.longitude) /
                        100;
                    return distance <= 10;
                  }).toList();

                  if (nearbyDocs.isEmpty) {
                    return const Center(
                        child: Text("No nearby delivery boys available."));
                  }

                  return ListView.builder(
                    itemCount: nearbyDocs.length,
                    itemBuilder: (context, index) {
                      final document = nearbyDocs[index];
                      final data = document.data() as Map<String, dynamic>;
                      final location = document['location'] as GeoPoint;
                      final distance = Geolocator.distanceBetween(
                              shopLatitude!,
                              shopLongitude!,
                              location.latitude,
                              location.longitude) /
                          100;
                      return Column(
                        children: [
                          ListTile(
                            onTap: () {
                              EasyLoading.show();
                              _orderService
                                  .selectBoys(
                                widget.documentSnapshot?.id,
                                location,
                                data['name'],
                                data['imageUrl'],
                                data['mobile'],
                                data['email'],
                              )
                                  .then((value) {
                                EasyLoading.showSuccess(
                                    "Delivery Boy Assigned");
                                Navigator.pop(context);
                              });
                            },
                            leading: CircleAvatar(
                              backgroundColor: Colors.white,
                              child: Image.network(
                                data['imageUrl'],
                                width: 40,
                                fit: BoxFit.cover,
                              ),
                            ),
                            title: Text(data['name']),
                            subtitle: Text("${distance.toStringAsFixed(0)} Km"),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.map),
                                  onPressed: () {
                                    _orderService.launchMap(location,
                                        "${location.latitude}, ${location.longitude}");
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.phone),
                                  onPressed: () {
                                    FlutterPhoneDirectCaller.callNumber(data['mobile']);
                                  },
                                ),
                              ],
                            ),
                          ),
                          const Divider(height: 1),
                        ],
                      );
                    },
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
