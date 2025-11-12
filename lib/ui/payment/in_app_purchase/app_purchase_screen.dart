import 'package:flutter/material.dart';

import 'app_purchase.dart';


class AppPurchaseScreen extends StatefulWidget {
  final String profilePackageID;

  const AppPurchaseScreen({Key? key, required this.profilePackageID}) : super(key: key);

  @override
  _AppPurchaseScreenState createState() => _AppPurchaseScreenState();
}

class _AppPurchaseScreenState extends State<AppPurchaseScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        backgroundColor: const Color(0xff292929),
        title: const Text(
          "Pay Now",
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontFamily: "Roboto",
            fontWeight: FontWeight.w900,
          ),
        ),
        centerTitle: true,
      ),
      body: AppPurchase(
        profilePackageID: widget.profilePackageID,
      ),
    );
  }
}
