import 'package:flutter/material.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:uber_clone_driver_app/models/trip_details.dart';
import 'package:uber_clone_driver_app/widgets/loading_dialog.dart';

class NewTripPage extends StatefulWidget {
  const NewTripPage({Key? key,this.newTripDetailsInfo}) : super(key: key);
  final TripDetails? newTripDetailsInfo;

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

  obtainDirectionAndDrawRoute(driverCurrentLocationLatLng,userPickUpLocationLatLng){
    showDialog(
      barrierDismissible: false,
        context: context,
        builder: (context)=>LoadingDialog(messageText: 'Please wait...'));
  }


  @override
  Widget build(BuildContext context) {
    return Stack(
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
                await osmMapController.currentLocation(); //???
                var driverCurrentPosition= await osmMapController.myLocation();
                var driverCurrentLocationLatLng=LatLng(driverCurrentPosition.latitude,
                    driverCurrentPosition.longitude);
                var userPickUpLocationLatLng=widget.newTripDetailsInfo!.pickUpLatLng;

                obtainDirectionAndDrawRoute(driverCurrentLocationLatLng,userPickUpLocationLatLng);

              });
            }
          },
          mapIsLoading: Center(child: CircularProgressIndicator()),
        ),
      ],
    );
  }
}
