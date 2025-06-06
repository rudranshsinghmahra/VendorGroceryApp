import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:grocery_vendor_app/providers/auth_provider.dart';

class ShopPicCard extends StatefulWidget {
  const ShopPicCard({Key? key}) : super(key: key);

  @override
  State<ShopPicCard> createState() => _ShopPicCardState();
}

class _ShopPicCardState extends State<ShopPicCard> {
  File? image;

  @override
  Widget build(BuildContext context) {
    final authData = Provider.of<AuthProvider>(context);
    final Size size = MediaQuery.of(context).size;
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: InkWell(
        onTap: () {
          authData.getImage().then((value) {
            if (value != null) {
              setState(() {
                image = value;
                authData.isPictureAvailable = true;
              });
            }
          });
        },
        child: SizedBox(
          height: size.height / 3,
          width: size.width,
          child: Card(
            child: image != null
                ? Image.file(image!,
                    fit: BoxFit.cover)
                : const Center(
                    child: Text(
                      "Add Shop Image",
                      style: TextStyle(fontSize: 20, color: Colors.black45),
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
