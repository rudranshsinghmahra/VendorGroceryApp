import 'package:chips_choice/chips_choice.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:grocery_vendor_app/widgets/drawers_menu_widget.dart';
import 'package:provider/provider.dart';
import 'package:grocery_vendor_app/services/order_services.dart';
import 'package:grocery_vendor_app/widgets/order_summary_card.dart';
import '../providers/orders_provider.dart';

class OrderScreen extends StatefulWidget {
  const OrderScreen({super.key});

  static const String id = "order-screen";

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  final OrderService _orderServices = OrderService();
  User? user = FirebaseAuth.instance.currentUser;
  int tag = 0;
  List<String> options = [
    "All Orders",
    "Ordered",
    "Accepted",
    "Rejected",
    "Picked-Up",
    "On the Way",
    "Delivered",
  ];

  @override
  Widget build(BuildContext context) {
    var orderProvider = Provider.of<OrderProvider>(context);
    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        title: const Text("Received Orders"),
        centerTitle: true,
      ),
      drawer: DrawerWidget(),
      body: Column(
        children: [
          SizedBox(
            height: 56,
            width: MediaQuery.of(context).size.width,
            child: ChipsChoice<int>.single(
              value: tag,
              onChanged: (val) {
                if (val == 0) {
                  setState(() {
                    orderProvider.status = null;
                  });
                } else {
                  setState(() {
                    tag = val;
                    orderProvider.status = options[val];
                  });
                }
              },
              choiceItems: C2Choice.listFrom<int, String>(
                  source: options, value: (i, v) => i, label: (i, v) => v
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _orderServices.orders
                  .where('seller.sellerId', isEqualTo: user?.uid)
                  .where('orderStatus',
                  isEqualTo: tag > 0 ? orderProvider.status : null)
                  .snapshots(),
              builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError) {
                  return const Center(child: Text('Something went wrong'));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.data?.size == 0) {
                  return Center(
                    child: Text(tag > 0
                        ? "No ${options[tag]} orders"
                        : "No Orders received from customers"),
                  );
                }
                return ListView(
                  shrinkWrap: true,
                  children: snapshot.data!.docs.map((DocumentSnapshot document) {
                    return OrderSummaryCard(documentSnapshot: document);
                  }).toList(),
                );
              },
            ),
          ),
        ],
      ),

    );
  }
}
