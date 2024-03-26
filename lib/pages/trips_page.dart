import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:uber_clone_driver_app/pages/trips_history_page.dart';

class TripsPage extends StatefulWidget {
  const TripsPage({Key? key}) : super(key: key);

  @override
  State<TripsPage> createState() => _TripsPageState();
}

class _TripsPageState extends State<TripsPage> {
  String currentDriverTotalTripsCompleted = '';

  getTotalDriverNumberOfTripsComplete() async {
    DatabaseReference tripsRef =
        FirebaseDatabase.instance.ref().child('tripRequests');
    await tripsRef.once().then((snap) {
      if (snap.snapshot.value != null) {
        Map<dynamic, dynamic> allTripsMap = snap.snapshot.value as Map;
        List<String> tripCompleteByCurrentDriver = [];
        allTripsMap.forEach((key, value) {
          if (value['status'] != null) {
            if (value['status'] == 'ended') {
              if (value['driverID'] == FirebaseAuth.instance.currentUser!.uid) {
                tripCompleteByCurrentDriver.add(key);
              }
            }
          }
        });
        setState(() {
          currentDriverTotalTripsCompleted =
              tripCompleteByCurrentDriver.length.toString();
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
    getTotalDriverNumberOfTripsComplete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          //Total Trips
          Center(
            child: Container(
              color: Colors.indigo,
              width: 300,
              child: Padding(
                padding: EdgeInsets.all(18),
                child: Column(
                  children: [
                    Image.asset(
                      'assets/images/totaltrips.png',
                      width: 120,
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      'Total Trips',
                      style: TextStyle(color: Colors.white),
                    ),
                    Text(
                      currentDriverTotalTripsCompleted,
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(
            height: 20,
          ),
          //check trip history
          GestureDetector(
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (c) => TripsHistoryPage()));
            },
            child: Center(
              child: Container(
                color: Colors.indigo,
                width: 300,
                child: Padding(
                  padding: EdgeInsets.all(18),
                  child: Column(
                    children: [
                      Image.asset(
                        'assets/images/tripscompleted.png',
                        width: 150,
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        'Check Trips History',
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
