import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:uber_clone_driver_app/global/global_var.dart';
import 'package:uber_clone_driver_app/methods/common_methods.dart';
import 'package:uber_clone_driver_app/models/trip_details.dart';

import 'loading_dialog.dart';

class NotificationDialog extends StatefulWidget {
  TripDetails? tripDetailsInfo;

  NotificationDialog({Key? key, this.tripDetailsInfo}) : super(key: key);

  @override
  State<NotificationDialog> createState() => _NotificationDialogState();
}

class _NotificationDialogState extends State<NotificationDialog> {
  String tripRequestStatus = '';
  CommonMethods cMethods=CommonMethods();

  cancelNotificationDialogAfter20Sec() {
    const oneTickPerSecond = Duration(seconds: 1);
    var timerCountDown = Timer.periodic(oneTickPerSecond, (timer) {
      driverTripRequestTimeout = driverTripRequestTimeout - 1;
      if (tripRequestStatus == 'accepted') {
        timer.cancel();
        driverTripRequestTimeout = 20;
      }
      if (driverTripRequestTimeout == 0) {
        Navigator.pop(context);
        timer.cancel();
        driverTripRequestTimeout = 20;
        player1.stop();
      }
    });
  }

  @override
  void initState() {
    super.initState();
    cancelNotificationDialogAfter20Sec();
  }

  checkAvailabilityOfTripRequest(BuildContext context) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) => LoadingDialog(messageText: 'please wait...'),
    );
    DatabaseReference driverTripStatusRef = FirebaseDatabase.instance
        .ref()
        .child('drivers')
        .child(FirebaseAuth.instance.currentUser!.uid)
        .child('newTripStatus');
    driverTripStatusRef.once().then((snap) {
      Navigator.pop(context);
      Navigator.pop(context);
      String newTripStatusValue='';
      if(snap.snapshot.value!=null){
        newTripStatusValue=snap.snapshot.value!.toString();
      }else{
        cMethods.displaySnackBar('Trip Request Not Found', context);
      }
      if(newTripStatusValue==widget.tripDetailsInfo!.tripID){
        driverTripStatusRef.set('accepted');
        //disable homepage location updates
        cMethods.tu

      }else if(newTripStatusValue=='cancelled'){
        cMethods.displaySnackBar('Trip Request has been cancelled by user', context);
      }else if(newTripStatusValue=='timeout'){
        cMethods.displaySnackBar('Trip Request timed out', context);
      }else{
        cMethods.displaySnackBar('Trip Request removed. Not found', context);
      }

    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      backgroundColor: Colors.black54,
      child: Container(
        margin: EdgeInsets.all(5),
        width: double.infinity,
        decoration: BoxDecoration(
            color: Colors.black54, borderRadius: BorderRadius.circular(4)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 30,
            ),
            Image.asset(
              'assets/images/uberexec.png',
              width: 140,
            ),
            SizedBox(
              height: 16,
            ),
            Text(
              'NEW TRIP REQUEST',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.grey),
            ),
            SizedBox(
              height: 20,
            ),
            Divider(
              height: 1,
              color: Colors.white,
              thickness: 1,
            ),
            SizedBox(
              height: 10,
            ),
            //pick - dropoff
            Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  //pickup
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Image.asset(
                        'assets/images/initial.png',
                        height: 16,
                        width: 16,
                      ),
                      SizedBox(
                        width: 18,
                      ),
                      Expanded(
                          child: Text(
                        widget.tripDetailsInfo!.pickUpAddress.toString(),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 18,
                        ),
                      ))
                    ],
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  //dropoff
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Image.asset(
                        'assets/images/final.png',
                        height: 16,
                        width: 16,
                      ),
                      SizedBox(
                        width: 18,
                      ),
                      Expanded(
                          child: Text(
                        widget.tripDetailsInfo!.dropOffAddress.toString(),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 18,
                        ),
                      ))
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Divider(
              height: 1,
              color: Colors.white,
              thickness: 1,
            ),
            SizedBox(height: 8),
            //decline btn-accept btn
            Padding(
              padding: EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.pink,
                      ),
                      child: Text(
                        'DECLINE',
                        style: TextStyle(color: Colors.white),
                      ),
                      onPressed: () async {
                        Navigator.pop(context);
                        await player1.stop();
                      },
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                      child: Text(
                        'ACCEPT',
                        style: TextStyle(color: Colors.white),
                      ),
                      onPressed: () async {
                        await player1.stop();
                        setState(() {
                          tripRequestStatus = 'accepted';
                        });
                        checkAvailabilityOfTripRequest(context);
                      },
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
