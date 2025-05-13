import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:grocery_vendor_app/providers/products_provider.dart';
import 'package:grocery_vendor_app/screens/add_edit_coupon_screen.dart';
import 'package:grocery_vendor_app/screens/banners_screen.dart';
import 'package:grocery_vendor_app/screens/coupon_screen.dart';
import 'package:grocery_vendor_app/screens/login_screen.dart';
import 'package:grocery_vendor_app/screens/order_screen.dart';
import 'package:grocery_vendor_app/screens/products_screen.dart';

class DrawerWidget extends StatefulWidget {
  const DrawerWidget({super.key});

  @override
  State<DrawerWidget> createState() => _DrawerWidgetState();
}

class _DrawerWidgetState extends State<DrawerWidget> {
  User? user = FirebaseAuth.instance.currentUser;
  var vendorsData;

  @override
  void initState() {
    getVendorsData();
    super.initState();
  }

  Future<void> getVendorsData() async {
    var result = await FirebaseFirestore.instance
        .collection('vendors')
        .doc(user?.uid)
        .get();
    setState(() {
      vendorsData = result;
    });

    if (mounted) {
      Provider.of<ProductProvider>(context, listen: false)
          .getShopName(vendorsData['shopName']);
    }
  }


  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: const EdgeInsets.all(0.0),
        children: <Widget>[
          UserAccountsDrawerHeader(
            accountName: Text(
              vendorsData != null ? vendorsData['shopName'] : 'ShopName',
              style: const TextStyle(color: Colors.white),
            ),
            accountEmail: Text(
              vendorsData != null ? vendorsData['email'] : 'abc@gmail.com',
              style: const TextStyle(color: Colors.white),
            ),
            currentAccountPicture: CircleAvatar(
              backgroundImage: vendorsData != null
                  ? NetworkImage(vendorsData['imageUrl'])
                  : null,
            ),
            onDetailsPressed: () {},
          ),
          ListTile(
            onTap: () {
              Navigator.pushNamed(context, ProductScreen.id);
            },
            title: Text('Products'),
            leading: Icon(Icons.shopping_bag_outlined),
          ),
          ListTile(
            onTap: () {
              Navigator.pushNamed(context, BannerScreen.id);
            },
            title: Text('Banners'),
            leading: Icon(Icons.photo),
          ),
          ListTile(
            title: const Text('Coupons'),
            leading: const Icon(CupertinoIcons.gift),
            onTap: () {
              Navigator.pushNamed(context, CouponScreen.id);
            },
          ),
          ListTile(
            title: const Text('Orders'),
            leading: const Icon(Icons.list_alt_outlined),
            onTap: () {
              Navigator.pushNamed(context, OrderScreen.id);
            },
          ),
          ListTile(
            title: Text('Reports'),
            leading: Icon(Icons.stacked_bar_chart),
            onTap: () {},
          ),
          ListTile(
            title: Text('Settings'),
            leading: Icon(Icons.settings_outlined),
            onTap: () {},
          ),
          ListTile(
            title: Text('Logout'),
            leading: Icon(Icons.arrow_back),
            onTap: () {
              FirebaseAuth.instance.signOut().then((value) {
                Navigator.pushReplacementNamed(context, LoginScreen.id);
              });
            },
          ),
        ],
      ),
    );
  }
}
