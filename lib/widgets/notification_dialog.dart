import 'dart:async';

import 'package:flutter/material.dart';
import 'package:uber_clone_driver_app/global/global_var.dart';
import 'package:uber_clone_driver_app/models/trip_details.dart';

class NotificationDialog extends StatefulWidget {
  TripDetails? tripDetailsInfo;
   NotificationDialog({Key? key,this.tripDetailsInfo}) : super(key: key);

  @override
  State<NotificationDialog> createState() => _NotificationDialogState();
}

class _NotificationDialogState extends State<NotificationDialog> {
String tripRequestStatus='';

  cancelNotificationDialogAfter20Sec(){
    const oneTickPerSecond=Duration(seconds: 1);
    var timerCountDown=Timer.periodic(oneTickPerSecond, (timer) {
      driverTripRequestTimeout=driverTripRequestTimeout-1;
      if(tripRequestStatus=='accepted'){
        timer.cancel();
        driverTripRequestTimeout=20;
      }
      if(driverTripRequestTimeout==0){
        Navigator.pop(context);
        timer.cancel();
        driverTripRequestTimeout=20;
      }

    });
  }

  @override
  void initState() {
    super.initState();
    cancelNotificationDialogAfter20Sec();
  }


  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12)
      ),
      backgroundColor: Colors.black54,
      child: Container(
        margin: EdgeInsets.all(5),
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.black54,
          borderRadius: BorderRadius.circular(4)
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 30,),
            Image.asset('assets/images/uberexec.png',width: 140,),
            SizedBox(height: 16,),
            Text('NEW TRIP REQUEST',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Colors.grey
            ),
            ),
            SizedBox(height: 20,),
            Divider(height: 1,color: Colors.white,thickness: 1,),
            SizedBox(height: 10,),
            //pick - dropoff
            Padding(
                padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  //pickup
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Image.asset('assets/images/initial.png',
                        height: 16,
                      width: 16,),
                      SizedBox(width: 18,),
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
                  SizedBox(height: 15,),
                  //dropoff
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Image.asset('assets/images/final.png',
                        height: 16,
                        width: 16,),
                      SizedBox(width: 18,),
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
            SizedBox(height: 20,),
            Divider(height: 1,color: Colors.white,thickness: 1,),
            SizedBox(height: 8),
            //decline btn-accept btn
            Padding(
                padding:EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.pink,
                        ),
                        child: Text('DECLINE',
                        style: TextStyle(
                          color: Colors.white
                        ),),
                        onPressed: (){
                          Navigator.pop(context);
                        },
                      ),),
                  SizedBox(width: 10,),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                      child: Text('ACCEPT',
                        style: TextStyle(
                            color: Colors.white
                        ),),
                      onPressed: (){
                        setState(() {
                          tripRequestStatus='accepted';
                        });
                      },
                    ),),

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


