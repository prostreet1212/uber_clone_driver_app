import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class EarningsPage extends StatefulWidget {
  const EarningsPage({Key? key}) : super(key: key);

  @override
  State<EarningsPage> createState() => _EarningsPageState();
}

class _EarningsPageState extends State<EarningsPage> {

  String driverEarnings = "";

  getTotalEarningsOfCurrentDriver() async
  {
    DatabaseReference driversRef = FirebaseDatabase.instance.ref().child("drivers");

    await driversRef.child(FirebaseAuth.instance.currentUser!.uid)
        .once()
        .then((snap) {
      if((snap.snapshot.value as Map)["earnings"] != null)
      {
        setState(() {
          driverEarnings = ((snap.snapshot.value as Map)["earnings"] as num).toStringAsFixed(2);
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
    getTotalEarningsOfCurrentDriver();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [

          Center(
            child: Container(
              color: Colors.indigo,
              width: 300,
              child: Padding(
                padding: EdgeInsets.all(18),
                child: Column(
                  children: [
                    Image.asset(
                      'assets/images/totalearnings.png',
                      width: 120,
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      'Total Earnings:',
                      style: TextStyle(color: Colors.white),
                    ),
                    Text(
                      '\$ '+driverEarnings,
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 30,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}