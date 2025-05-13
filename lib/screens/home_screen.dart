import 'package:flutter/material.dart';
import 'package:grocery_vendor_app/widgets/drawers_menu_widget.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);
  static const String id = 'home-screen';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: const Center(
          child: Text("HomeScreen"),
        ),
        appBar: AppBar(title: const Text('WELCOME')),
        drawer: const DrawerWidget());
  }
}
