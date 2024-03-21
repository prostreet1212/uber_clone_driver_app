import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:uber_clone_driver_app/global/global_var.dart';
import 'package:uber_clone_driver_app/methods/common_methods.dart';
import 'package:uber_clone_driver_app/models/trip_details.dart';
import 'package:uber_clone_driver_app/widgets/loading_dialog.dart';
import 'package:uber_clone_driver_app/widgets/payment_dialog.dart';
import 'package:url_launcher/url_launcher.dart';

class NewTripPage extends StatefulWidget {
  NewTripPage({Key? key, this.newTripDetailsInfo}) : super(key: key);
  TripDetails? newTripDetailsInfo;

  @override
  State<NewTripPage> createState() => _NewTripPageState();
}

class _NewTripPageState extends State<NewTripPage> {
  MapController osmMapController = MapController.withUserPosition(
    trackUserLocation: UserTrackingOption(
      enableTracking: true,
      unFollowUser: true,
    ),
  );
  GeoPoint? driverCurrentPosition;
  GeoPoint? firstDriverPosition;
  bool directionRequested = false;
  String statusOfTrip = 'accepted';
  String durationText = '';
  String distanceText = '';
  String buttonTitleText = 'ARRIVED';
  Color buttonColor = Colors.indigoAccent;
  CommonMethods commonMethods = CommonMethods();

  obtainDirectionAndDrawRoute(
      LatLng? sourceLocationLatLng, LatLng? destinationLocationLatLng) async {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) => LoadingDialog(messageText: 'Please wait...'));
    /*var tripDetailsInfo = await CommonMethods.getDirectionDetailsFromAPI(
        sourceLocationLatLng, destinationLocationLatLng, osmMapController);
    print('длительность: ${tripDetailsInfo!.durationTextString}');*/

    await osmMapController.addMarker(
        GeoPoint(
            latitude: sourceLocationLatLng!.latitude,
            longitude: sourceLocationLatLng!.longitude),
        markerIcon: const MarkerIcon(
          icon: Icon(
            CupertinoIcons.location_solid,
            size: 46,
            color: Colors.green,
          ),
        ),
        angle: pi / 3,
        iconAnchor: IconAnchor(
          anchor: Anchor.center,
        ));
    await osmMapController.addMarker(
        GeoPoint(
            latitude: destinationLocationLatLng!.latitude,
            longitude: destinationLocationLatLng!.longitude),
        markerIcon: const MarkerIcon(
          icon: Icon(
            CupertinoIcons.location_solid,
            size: 46,
            color: Colors.deepOrange,
          ),
        ),
        angle: pi / 3,
        iconAnchor: IconAnchor(
          anchor: Anchor.center,
        ));

    RoadInfo roadInfo = await osmMapController.drawRoad(
      GeoPoint(
          latitude: sourceLocationLatLng!.latitude,
          longitude: sourceLocationLatLng.longitude),
      GeoPoint(
          latitude: destinationLocationLatLng!.latitude,
          longitude: destinationLocationLatLng.longitude),
      roadType: RoadType.car,
    );

    Navigator.pop(context);
  }

  getLiveLocationUpdatesOfDriver() {
    LatLng lastPositionLatLng = LatLng(0, 0);
    positionStreamNewTripPage =
        Geolocator.getPositionStream().listen((Position position) {
      driverCurrentPosition =
          GeoPoint(latitude: position.latitude, longitude: position.longitude);
      //LatLng driverCurrentPositionLatLng=LatLng(driverCurrentPosition!.latitude, driverCurrentPosition!.longitude);

      //lastPositionLatLng = driverCurrentPositionLatLng;
      updateTripDetailsInformation();

      Map updatedLocationOfDriver = {
        "latitude": driverCurrentPosition!.latitude,
        "longitude": driverCurrentPosition!.longitude,
      };
      FirebaseDatabase.instance
          .ref()
          .child("tripRequests")
          .child(widget.newTripDetailsInfo!.tripID!)
          .child("driverLocation")
          .set(updatedLocationOfDriver);
    });
  }

  updateTripDetailsInformation() async {
    if (!directionRequested) {
      directionRequested = true;
      if (driverCurrentPosition == null) {
        return;
      }
      var driverLocationLatLng = LatLng(
          driverCurrentPosition!.latitude, driverCurrentPosition!.longitude);
      LatLng dropOffDestinationLatLng;
      if (statusOfTrip == 'accepted') {
        dropOffDestinationLatLng = widget.newTripDetailsInfo!.pickUpLatLng!;
      } else {
        dropOffDestinationLatLng = widget.newTripDetailsInfo!.dropOffLatLng!;
      }
      var directionDetailsInfo = await CommonMethods.getDirectionDetailsFromAPI(
          driverLocationLatLng, dropOffDestinationLatLng);
      if (directionDetailsInfo != null) {
        directionRequested = false;
        setState(() {
          durationText = directionDetailsInfo.durationTextString!;
          print('duration: ${durationText}');
          distanceText = directionDetailsInfo.distanceTextString!;
        });
      }
    }
  }

  endTripNow() async {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) => const LoadingDialog(messageText: 'Please wait...'));
    var driverCurrentLocationLatLng = LatLng(
        driverCurrentPosition!.latitude, driverCurrentPosition!.longitude);
    var directionDetailsEndTripInfo =
        await CommonMethods.getDirectionDetailsFromAPI(
            widget.newTripDetailsInfo!.pickUpLatLng!,
            driverCurrentLocationLatLng);
    Navigator.pop(context);
    String fareAmount =
        (commonMethods.calculateFareAmount(directionDetailsEndTripInfo!))
            .toString();
    await FirebaseDatabase.instance
        .ref()
        .child('tripRequests')
        .child(widget.newTripDetailsInfo!.tripID!)
        .child('fareAmount')
        .set(fareAmount);
    await FirebaseDatabase.instance
        .ref()
        .child('tripRequests')
        .child(widget.newTripDetailsInfo!.tripID!)
        .child('status')
        .set('ended');
    positionStreamNewTripPage!.cancel();
    //dialog for collecting fare amount
    displayPaymentDialog(fareAmount);
    //save fare amount to driver total earnings
    saveFareAmountToDriverTotalEarnings(fareAmount);
  }

  displayPaymentDialog(String fareAmount){
    showDialog(context: context,
        barrierDismissible: false,
        builder: (context)=>PaymentDialog(fareAmount: fareAmount));
  }

  saveFareAmountToDriverTotalEarnings(String fareAmount)async {
    DatabaseReference driverEarningsRef = await FirebaseDatabase.instance.ref()
        .child('drivers')
        .child(FirebaseAuth.instance.currentUser!.uid).child('earnings');
    await driverEarningsRef.once().then((snap) {
      if (snap.snapshot.value != null) {
        double previousTotalEarnings = double.parse(
            snap.snapshot.value.toString());
        double fareAmountForTrip = double.parse(fareAmount);
        double newTotalEarnings = previousTotalEarnings + fareAmountForTrip;
        driverEarningsRef.set(newTotalEarnings);
      } else {
        driverEarningsRef.set(fareAmount);
      }
    });
  }

   /* saveDriverDataToTripInfo()async{
    Map<String,dynamic> driverDataMap={
      "status": "accepted",
      "driverID": FirebaseAuth.instance.currentUser!.uid,
      "driverName": driverName,
      "driverPhone": driverPhone,
      "driverPhoto": driverPhoto,
      "carDetails": carColor + " - " + carModel + " - " + carNumber,
    };

    Map<String, dynamic> driverCurrentLocation =
    {
      'latitude': driverCurrentPosition!.latitude.toString(),
      'longitude': driverCurrentPosition!.longitude.toString(),
    };
     await FirebaseDatabase.instance.ref()
        .child("tripRequests")
        .child(widget.newTripDetailsInfo!.tripID!)
        .set(driverDataMap);

   await FirebaseDatabase.instance.ref()
        .child("tripRequests")
        .child(widget.newTripDetailsInfo!.tripID!)
        .child("driverLocation").update(driverCurrentLocation);
  }*/

  @override
  void initState() {
    super.initState();
    //saveDriverDataToTripInfo();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [

          OSMFlutter(
            controller: osmMapController,
            osmOption: OSMOption(
              enableRotationByGesture: false,
              zoomOption: ZoomOption(
                initZoom: 16,
                /* minZoomLevel: 4,
          maxZoomLevel: 14,*/
                stepZoom: 1,
              ),
              /* userTrackingOption: UserTrackingOption(
          enableTracking: true,
          unFollowUser: false,
        ),*/
              userLocationMarker: UserLocationMaker(
                personMarker: MarkerIcon(
                  icon: Icon(
                    Icons.personal_injury,
                    color: Colors.black,
                    size: 48,
                  ),
                ),
                directionArrowMarker: MarkerIcon(
                  icon: Icon(
                    Icons.location_on,
                    color: Colors.black,
                    size: 48,
                  ),
                ),
              ),
              roadConfiguration: RoadOption(
                roadColor: Colors.deepOrange,
                roadBorderWidth: 10,
              ),
            ),
            onLocationChanged: (GeoPoint geo) async {
              print('ИЗменить${geo.toString()}');
              await osmMapController.currentLocation();
              // osmMapController.initMapWithUserPosition;
            },
            onMapIsReady: (isReady) async {
              if (isReady) {
                await Future.delayed(Duration(seconds: 1), () async {
                  await osmMapController.currentLocation(); //???
                  await osmMapController.enableTracking(
                    enableStopFollow: false,
                    disableUserMarkerRotation: true,
                    // anchor: Anchor.left,  here anchor is testing you can put anchor that match with your need
                  );
                  driverCurrentPosition = await osmMapController.myLocation();
                  firstDriverPosition = driverCurrentPosition;
                  //driverCurrentPosition = GeoPoint(latitude: geo.longitude, longitude: geo.latitude);
                  var driverCurrentLocationLatLng = LatLng(
                      driverCurrentPosition!.latitude,
                      driverCurrentPosition!.longitude);
                  var userPickUpLocationLatLng =
                      widget.newTripDetailsInfo!.pickUpLatLng;

                  await obtainDirectionAndDrawRoute(
                      driverCurrentLocationLatLng, userPickUpLocationLatLng!);
                  getLiveLocationUpdatesOfDriver();
                });
              }
            },
            mapIsLoading: Center(child: CircularProgressIndicator()),
          ),
          ElevatedButton(onPressed: ()async{
            Map<String,dynamic> driverDataMap={
              "status": "accepted",

            };
            await FirebaseDatabase.instance.ref()
                .child("tripRequests")
                .child(widget.newTripDetailsInfo!.tripID!)
                .update(driverDataMap);
          },
              child: Text('aaaaaa')),
          //trip details
          Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                decoration: BoxDecoration(
                    color: Colors.black87,
                    borderRadius: BorderRadius.only(
                        topRight: Radius.circular(17),
                        topLeft: Radius.circular(17)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 17,
                        spreadRadius: 0.5,
                        offset: Offset(0.7, 0.7),
                      )
                    ]),
                height: 256,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                  child: Column(
                    children: [
                      //trip duration
                      Center(
                        child: Text(
                          durationText + ' - ' + distanceText,
                          style: TextStyle(
                            color: Colors.green,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      //user name-call user icon btn
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          //user name
                          Text(
                            widget.newTripDetailsInfo!.userName!,
                            style: TextStyle(
                              color: Colors.green,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          //call user icon btn
                          GestureDetector(
                            child: Padding(
                              padding: EdgeInsets.only(right: 10),
                              child: Icon(
                                Icons.phone_android_outlined,
                                color: Colors.grey,
                              ),
                            ),
                            onTap: () {
                              launchUrl(Uri.parse(
                                  'tel://${widget.newTripDetailsInfo!.userPhone.toString()}'));
                            },
                          )
                        ],
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      //pickup icon and location
                      Row(
                        children: [
                          Image.asset(
                            'assets/images/initial.png',
                            height: 16,
                            width: 16,
                          ),
                          Expanded(
                              child: Text(
                            widget.newTripDetailsInfo!.pickUpAddress.toString(),
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey,
                            ),
                          ))
                        ],
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      //dropoff icon and location
                      Row(
                        children: [
                          Image.asset(
                            'assets/images/final.png',
                            height: 16,
                            width: 16,
                          ),
                          Expanded(
                              child: Text(
                            widget.newTripDetailsInfo!.dropOffAddress
                                .toString(),
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey,
                            ),
                          ))
                        ],
                      ),
                      SizedBox(
                        height: 25,
                      ),
                      Center(
                        child: ElevatedButton(
                          child: Text(
                            buttonTitleText,
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                              backgroundColor: buttonColor),
                          onPressed: () async {
                            //arrived button
                            if (statusOfTrip == 'accepted') {
                              setState(() {
                                buttonTitleText = 'START TRIP';
                                buttonColor = Colors.green;
                              });
                              statusOfTrip = 'arrived';
                              FirebaseDatabase.instance
                                  .ref()
                                  .child('tripRequests')
                                  .child(widget.newTripDetailsInfo!.tripID!)
                                  .child('status')
                                  .set('arrived');
                              showDialog(
                                  barrierDismissible: false,
                                  context: context,
                                  builder: (context) => LoadingDialog(
                                      messageText: 'Please wait...'));
                              await osmMapController
                                  .removeMarker(firstDriverPosition!);
                              await obtainDirectionAndDrawRoute(
                                  widget.newTripDetailsInfo!.pickUpLatLng,
                                  widget.newTripDetailsInfo!.dropOffLatLng);
                              Navigator.pop(context);

                              //start trip button
                            } else if (statusOfTrip == 'arrived') {
                              setState(() {
                                buttonTitleText = 'END TRIP';
                                buttonColor = Colors.amber;
                              });
                              statusOfTrip = 'ontrip';
                              FirebaseDatabase.instance
                                  .ref()
                                  .child('tripRequests')
                                  .child(widget.newTripDetailsInfo!.tripID!)
                                  .child('status')
                                  .set('ontrip');
                              //end trip button
                            } else if (statusOfTrip == 'ontrip') {
                              //end the trip
                              endTripNow();
                            }
                          },
                        ),
                      )
                    ],
                  ),
                ),
              )),
        ],
      ),
    );
  }
}
