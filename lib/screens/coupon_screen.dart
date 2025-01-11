import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:grocery_vendor_app/screens/add_edit_coupon_screen.dart';
import 'package:grocery_vendor_app/services/firebase_services.dart';

class CouponScreen extends StatelessWidget {
  const CouponScreen({Key? key}) : super(key: key);
  static const id = 'coupon-screen';

  @override
  Widget build(BuildContext context) {
    FirebaseService _services = FirebaseService();
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "ADD NEW COUPON",
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _services.coupons
            .where('sellerId', isEqualTo: _services.user?.uid)
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return const Text('Something went wrong');
          }
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pushNamed(context, AddEditCoupon.id);
                        },
                        child: Text(
                          "Add New Coupon",
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ),
                    )
                  ],
                ),
                if (snapshot.data!.size > 0)
                  FittedBox(
                    child: DataTable(columns: const <DataColumn>[
                      DataColumn(
                        label: Text("Title"),
                      ),
                      DataColumn(
                        label: Text("Rate"),
                      ),
                      DataColumn(
                        label: Text("Status"),
                      ),
                      DataColumn(
                        label: Text("Info"),
                      ),
                      DataColumn(
                        label: Text("Expiry"),
                      ),
                    ], rows: _couponList(snapshot.data, context)),
                  )
              ],
            ),
          );
        },
      ),
    );
  }

  List<DataRow> _couponList(QuerySnapshot? snapshot, context) {
    List<DataRow> newList =
        snapshot!.docs.map((DocumentSnapshot documentSnapshot) {
      var date = documentSnapshot['expiry'];
      var expiry = DateFormat.yMMMd().add_jm().format(date.toDate());
      return DataRow(cells: [
        DataCell(
          Text(documentSnapshot['title']),
        ),
        DataCell(
          Text(documentSnapshot['discountRate'].toString()),
        ),
        DataCell(
          Text(documentSnapshot['active'] ? 'Active' : 'Inactive'),
        ),
        DataCell(Text(expiry.toString())),
        DataCell(IconButton(
          icon: const Icon(Icons.info_outline_rounded),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AddEditCoupon(
                  documentSnapshot: documentSnapshot,
                ),
              ),
            );
          },
        ))
      ]);
    }).toList();
    return newList;
  }
}
