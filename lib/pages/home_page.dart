import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:just_audio/just_audio.dart';
import 'package:uber_clone_driver_app/push_notification/push_notification_system.dart';

import '../global/global_var.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final Completer<GoogleMapController> googleMapCompleterController =
      Completer<GoogleMapController>();
  GoogleMapController? controllerGoogleMap;
  Position? currentPositionOfUser;
  GeoPoint? currentPositionOfUser1;
  Color colorToShow = Colors.green;
  String titleToShow = 'GO ONLINE NOW';
  bool isDriverAvailable = false;
  MapController mapController = MapController.withUserPosition(
    trackUserLocation: UserTrackingOption(
      enableTracking: true,
      unFollowUser: true,
    ),
  );
  DatabaseReference? newTripRequestReference;

  /*getCurrentLiveLocationOfDriver() async {
    Position positionUser = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.bestForNavigation);
    currentPositionOfUser = positionUser;
    LatLng positionOfUserInLatLng = LatLng(
        currentPositionOfUser!.latitude, currentPositionOfUser!.longitude);
    CameraPosition cameraPosition =
        CameraPosition(target: positionOfUserInLatLng, zoom: 15);
    controllerGoogleMap!
        .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
  }*/
  goOnlineNow() {
    //all drivers who are Available for new trip requests
    Geofire.initialize('onlineDrivers');
    Geofire.setLocation(
      FirebaseAuth.instance.currentUser!.uid,
      currentPositionOfUser1!.latitude,
      currentPositionOfUser1!.longitude,
    );
    newTripRequestReference = FirebaseDatabase.instance
        .ref()
        .child('drivers')
        .child(FirebaseAuth.instance.currentUser!.uid)
        .child('newTripStatus');
    newTripRequestReference!.set('waiting');
    newTripRequestReference!.onValue.listen((event) {
    });
  }

  setAndGetLocationUpdates(){
positionStreamHomePage=Geolocator.getPositionStream().listen(( position1) {
  currentPositionOfUser1=GeoPoint(latitude: position1.latitude,
      longitude: position1.longitude);
  if(isDriverAvailable){
    Geofire.setLocation(
        FirebaseAuth.instance.currentUser!.uid,
        currentPositionOfUser1!.latitude,
        currentPositionOfUser1!.longitude,
        );
  }
  /*LatLng position=LatLng(currentPositionOfUser1!.latitude
      , currentPositionOfUser1!.longitude);*/
  //тут должно быть центрирование местопожения (если гугл карта)
});
  }

  goOfflineNow(){
    Geofire.removeLocation(FirebaseAuth.instance.currentUser!.uid);
    newTripRequestReference!.onDisconnect();
    newTripRequestReference!.remove();
    newTripRequestReference=null;
  }

  initializePushNotificationSystem(){
    PushNotificationSystem notificationSystem=PushNotificationSystem();
    notificationSystem.generateDeviceRegistrationToken();
    notificationSystem.startListeningForNewNotification(context);
  }

  @override
  void initState() {
    super.initState();
    initializePushNotificationSystem();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          //open map
          OSMFlutter(
            controller: mapController,
            osmOption: OSMOption(
              enableRotationByGesture: false,
              zoomOption: ZoomOption(
                initZoom: 16,
                /* minZoomLevel: 4,
          maxZoomLevel: 14,*/
                stepZoom: 1,
              ),
              /*userTrackingOption: UserTrackingOption(
          enableTracking: true,
          unFollowUser: true,
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
            onLocationChanged: (GeoPoint geo)async {
              print('ИЗменить${geo.toString()}');
              //await mapController.currentLocation();
            },
            onMapIsReady: (isReady) async {
              if (isReady) {
                await Future.delayed(Duration(seconds: 1), () async {
                  await mapController.currentLocation(); //???
                  currentPositionOfUser1 = await mapController.myLocation();
                  //getCurrentLiveLocationOfDriver();
                });
              }
            },
            mapIsLoading: Center(child: CircularProgressIndicator()),
          ),

          Container(
            height: 136,
            width: double.infinity,
            color: Colors.black54,
          ),

          //go online offline button
          Positioned(
              top: 61,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    style:
                        ElevatedButton.styleFrom(backgroundColor: colorToShow),
                    child: Text(
                      titleToShow,
                      style: TextStyle(color: Colors.white),
                    ),
                    onPressed: () {
                      showModalBottomSheet(
                          isDismissible: false,
                          context: context,
                          builder: (context) {
                            return Container(
                              decoration: BoxDecoration(
                                  color: Colors.black87,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey,
                                      blurRadius: 5,
                                      spreadRadius: 0.5,
                                      offset: Offset(0.7, 0.7),
                                    )
                                  ]),
                              height: 221,
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 24, vertical: 18),
                                child: Column(
                                  children: [
                                    SizedBox(
                                      height: 11,
                                    ),
                                    Text(
                                      (!isDriverAvailable)
                                          ? 'GO ONLINE NOW'
                                          : 'GO OFFLINE NOW',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 22,
                                        color: Colors.white70,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(
                                      height: 21,
                                    ),
                                    Text(
                                      (!isDriverAvailable)
                                          ? 'You are about to go online, you will become available to receive trip requests from users.'
                                          : 'You are about to go offline, you will stop receiving new trip requests from users.',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Colors.white38,
                                      ),
                                    ),
                                    SizedBox(
                                      height: 25,
                                    ),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.blue),
                                            child: Text(
                                              'BACK',
                                              style: TextStyle(
                                                  color: Colors.white),
                                            ),
                                            onPressed: () {
                                              Navigator.pop(context);
                                            },
                                          ),
                                        ),
                                        SizedBox(
                                          width: 16,
                                        ),
                                        Expanded(
                                          child: ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: (titleToShow ==
                                                      'GO ONLINE NOW')
                                                  ? Colors.green
                                                  : Colors.pink,
                                            ),
                                            child: Text(
                                              'CONFIRM',
                                              style: TextStyle(
                                                  color: Colors.white),
                                            ),
                                            onPressed: () async{
                                              if (!isDriverAvailable) {
                                                //go online
                                                goOnlineNow();
                                                //get driver location updates
                                                setAndGetLocationUpdates();
                                                Navigator.pop(context);
                                                setState(() {
                                                  colorToShow = Colors.pink;
                                                  titleToShow =
                                                      'GO OFFLINE NOW';
                                                  isDriverAvailable = true;
                                                });
                                              } else {
                                                //go offline
                                                goOfflineNow();
                                                Navigator.pop(context);
                                                setState(() {
                                                  colorToShow = Colors.green;
                                                  titleToShow = 'GO ONLINE NOW';
                                                  isDriverAvailable = false;
                                                });
                                              }
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          });
                    },
                  )
                ],
              ))
        ],
      ),
    );
  }
}
