import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:grocery_vendor_app/services/firebase_services.dart';

import '../screens/edit_view_product.dart';

class UnPublishedProducts extends StatelessWidget {
  const UnPublishedProducts({super.key});

  @override
  Widget build(BuildContext context) {
    FirebaseService service = FirebaseService();
    return StreamBuilder<QuerySnapshot>(
      stream: service.products.where('published', isEqualTo: false).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Text("Something Went Wrong..");
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        return SingleChildScrollView(
          child: FittedBox(
            child: DataTable(
              showBottomBorder: true,
              dataRowHeight: 100,
              headingRowColor: MaterialStateProperty.all(Colors.grey[200]),
              columns: const [
                DataColumn(
                  label: Expanded(child: Text("Product",style: TextStyle(fontSize: 20),)),
                ),
                DataColumn(
                  label: Text("Image",style: TextStyle(fontSize: 20)),
                ),
                DataColumn(
                  label: Text("Info",style: TextStyle(fontSize: 20)),
                ),
                DataColumn(
                  label: Text("Actions",style: TextStyle(fontSize: 20)),
                ),
              ],
              rows: productDetails(snapshot.data, context),
            ),
          ),
        );
      },
    );
  }

  List<DataRow> productDetails(QuerySnapshot? snapshot, context) {
    List<DataRow> newList = snapshot!.docs.map(
      (DocumentSnapshot documentSnapshot) {
        return DataRow(
          cells: [
            DataCell(ListTile(
                title: Row(
                  children: [
                    const Expanded(
                        child: Text(
                      "Name:  ",
                      style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18),
                    )),
                    Expanded(
                      child: Text(
                        documentSnapshot['productName'],style: const TextStyle(fontSize: 20)
                      ),
                    ),
                  ],
                ),
                subtitle: Row(
                  children: [
                    const Expanded(
                      child: Text(
                        "SKU: ",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                    ),
                    Expanded(
                        child: Text(
                      documentSnapshot['sku'],
                      style: const TextStyle(fontSize: 15),
                    )),
                  ],
                ))),
            DataCell(
              Padding(
                padding: const EdgeInsets.only(top: 3.0, bottom: 3.0),
                child: Row(
                  children: [
                    Image.network(
                      documentSnapshot['productImage'],
                      width: 50,
                    )
                  ],
                ),
              ),
            ),
            DataCell(
              Padding(
                padding: const EdgeInsets.only(top: 3.0, bottom: 3.0),
                child: IconButton(
                  icon: const Icon(Icons.info_outline),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditViewProduct(
                          productId: documentSnapshot['productId'],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            DataCell(
              popUpButton(documentSnapshot),
            ),
          ],
        );
      },
    ).toList();
    return newList;
  }

  Widget popUpButton(data) {
    FirebaseService _services = FirebaseService();
    return PopupMenuButton<String>(
      onSelected: (value) {
        if (value == 'publish') {
          _services.publishProduct(id: data['productId']);
        }
        if (value == 'delete') {
          _services.deleteProduct(id: data['productId']);
        }
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        const PopupMenuItem<String>(
          value: 'publish',
          child: ListTile(
            leading: Icon(Icons.check),
            title: Text("Publish"),
          ),
        ),
        const PopupMenuItem<String>(
          value: 'delete',
          child: ListTile(
            leading: Icon(Icons.delete_outline),
            title: Text("Delete"),
          ),
        ),
      ],
    );
  }
}
