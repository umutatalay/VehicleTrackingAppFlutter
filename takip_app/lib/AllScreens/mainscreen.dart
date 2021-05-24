import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:takip_app/AllScreens/searchScreen.dart';
import 'package:takip_app/AllWidgets/Divider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:takip_app/AllWidgets/ProgressDialog.dart';
import 'package:takip_app/Assistants/assistantMethods.dart';
import 'package:takip_app/DataHandler/appData.dart';
import 'dart:math';
class MainScreen extends StatefulWidget {

  static const String idScreen="mainscreen";
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {

  Completer<GoogleMapController> _controllerGoogleMap = Completer();
  GoogleMapController newgoogleMapController;
  GlobalKey<ScaffoldState> scaffoldkey= new GlobalKey<ScaffoldState>();

  List<LatLng> pLineCoerordinates = [];
  Set<Polyline> polylineset = {}; // var type ?
  Position currentposition;
  var geoLocator=Geolocator();
  double bottomPaddingOfMap=0;

  Set<Marker> markersSet ={};
  Set<Circle> circlesSet={};
  void  locatePosition() async{
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      currentposition=position;

      LatLng latLngPosition =LatLng(position.latitude, position.longitude);

      CameraPosition cameraPosition= new CameraPosition(target: latLngPosition,zoom: 14);
      newgoogleMapController.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));

      String address = await AssistantMethods.searchCoordinateAddress(position,context);
      print("Adress : "+address);
  }


  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(41.66644833580664, -122.085749655962),
    zoom: 14.4746,
  );

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        key: scaffoldkey,
        // appBar: AppBar(
        //
        //   title: Text('Main Screen'),
        //
        // ),
        drawer: Container(
          color: Colors.white,
          width: 255.0,
          child: Drawer(
            child: ListView(
              children: [
                // drawer header
                Container(
                  height: 165.0,
                  child: DrawerHeader(
                    decoration: BoxDecoration(
                      color: Colors.white
                    ),
                    child: Row(children: [
                      Image.asset("images/user_icon.png",height: 65.0,width: 65.0,),
                      SizedBox(width: 16.0,),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("Umut Atalay",style: TextStyle(color: Colors.white,fontSize: 16.0,fontFamily: "Brand-Bold"),),
                          SizedBox(height: 6.0,),
                          Text("Profilim"),
                        ],
                      ),

                    ],),
                  ),
                ),
                DividerWidget(

                ),

                SizedBox(
                  height: 12.0,
                ),
                //Drawer Body Controllers
                ListTile(
                  leading: Icon(Icons.history,),
                  title: Text("History",style: TextStyle(fontSize: 15.0),),
                ),
                ListTile(
                  leading: Icon(Icons.person,),
                  title: Text("Visit Profile",style: TextStyle(fontSize: 15.0),),
                ),
                ListTile(
                  leading: Icon(Icons.info,),
                  title: Text("About",style: TextStyle(fontSize: 15.0),),
                ),

              ],
            ),
          ),
        ),
        body: Stack(
          children: [
            GoogleMap(
              padding: EdgeInsets.only(bottom: bottomPaddingOfMap),
              mapType: MapType.normal,
              myLocationButtonEnabled: true,
              initialCameraPosition: _kGooglePlex,
              myLocationEnabled: true,
              zoomGesturesEnabled: true,
              zoomControlsEnabled: true,
              polylines: polylineset,
              markers: markersSet,
              circles: circlesSet,
              onMapCreated: (GoogleMapController controller){

                _controllerGoogleMap.complete(controller);
                newgoogleMapController = controller;

                setState(() {
                  bottomPaddingOfMap=500.0;
                });
                locatePosition();

              },
            ),

            //HamburgerButton for drawer
            Positioned(
              top: 45.0,
              left: 22.0,

              child: GestureDetector(
                onTap: (){
                  scaffoldkey.currentState.openDrawer();
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black,
                        blurRadius: 8.0,
                        spreadRadius: 0.5,
                        offset: Offset(
                            0.7,
                            0.7,
                        ),

                      ),
                    ]
                  ),
                  child: CircleAvatar(
                    backgroundColor: Colors.white,
                    child: Icon(Icons.menu, color: Colors.black,),
                    radius: 20.0,
                  ),
                ),
              ),
            ),


            Positioned(
              left: 0.0,
              right: 0.0,
              bottom: 0.0,
              child: Container(
                height: 300.0,
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(18.0),topRight: Radius.circular(18.0)),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.white,blurRadius: 16.0,spreadRadius: 0.5,offset: Offset(0.7,0.7),
                    )],


                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      SizedBox(height: 6.0,),
                      Text("Selam",style: TextStyle(fontSize: 18.0,color: Colors.white,fontFamily: "Brand-Bold"),),
                      Text("Selam",style: TextStyle(fontSize: 12.0,color: Colors.white),),
                      SizedBox(height: 20.0,),
                      GestureDetector(
                        onTap:() async
                        {
                         var res = await Navigator.push(context, MaterialPageRoute(builder:(context)=>SearchScreen()));

                         if(res=="obtainDirection"){
                              await getPlaceDirection();
                         }


                        } ,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.only(topLeft: Radius.circular(18.0),topRight: Radius.circular(18.0)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.white,blurRadius: 16.0,spreadRadius: 0.5,offset: Offset(0.7,0.7),
                              )],

                          ),
                        child: Row(
                          children: [
                            Icon(Icons.search,color: Colors.white,),
                            SizedBox(width:10.0),
                            Text("Konum bul",style: TextStyle(color: Colors.white),),


                          ],
                        ),
                        ),
                      ),
                      SizedBox(
                        height: 26.0,
                      ),
                      DividerWidget(),
                      SizedBox(
                        height: 26.0,
                      ),
                      Row(
                        children: [Icon(Icons.home,color: Colors.white,),
                          SizedBox(height: 12.0,),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(Provider.of<AppData>(context).pickUpLocation!=null
                                  ? Provider.of<AppData>(context).pickUpLocation.placeName
                                  : "Adres Ekle"
                              ,),
                              SizedBox(height: 4.0,),
                              Text("Adres",style: TextStyle(color: Colors.white),),
                              SizedBox(
                                height: 26.0,
                              ),
                              Row(
                                children: [Icon(Icons.work,color: Colors.white,)],
                              ),

                            ],
                          ),
                          SizedBox(height: 12.0,),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Konum ekle"),
                              SizedBox(height: 4.0,),
                              Text("Adres",style: TextStyle(color: Colors.white),),

                            ],
                          ),
                        ],
                      ),









                      ],

                  ),
                ),
              ),

            ),
          ],
        ),
      ),
    );
  }
  Future<void> getPlaceDirection() async {
    var initialPos = Provider.of<AppData>(context, listen: false).pickUpLocation;
    var finalPos = Provider.of<AppData>(context, listen: false).dropOffLocation;

    var pickUpLapLng =LatLng(initialPos.latitude,initialPos.longitude);
    var dropOffLapLng =LatLng(finalPos.latitude,finalPos.longitude);

    showDialog(context: context,
    builder: (BuildContext)=>ProgressDialog(message: "Lütfen Bekle",)
    );
    var details = await AssistantMethods.obtainPlaceDirectionDetails(pickUpLapLng, dropOffLapLng);

    Navigator.pop(context);

    print("this is encoded points:"); // beni kaldır
    print(details.encodedPoints); // beni de kaldır.

    PolylinePoints polylinePoints =PolylinePoints();
    List<PointLatLng> decodedPolyLinePointsResult = polylinePoints.decodePolyline(details.encodedPoints);

    pLineCoerordinates.clear();

    if(decodedPolyLinePointsResult.isNotEmpty){
      decodedPolyLinePointsResult.forEach((PointLatLng pointLatLng) {
        pLineCoerordinates.add(LatLng(pointLatLng.latitude,pointLatLng.longitude));
      });
    }

    polylineset.clear();

  setState(() {
    Polyline polyline=Polyline(
      color: Colors.red,
      polylineId: PolylineId("PolylineID"),
      jointType: JointType.round,
      points: pLineCoerordinates,
      width: 5, // must be int miş galiba
      startCap: Cap.roundCap,
      endCap: Cap.roundCap,
      geodesic: true,

    );

    polylineset.add(polyline);
  });

  LatLngBounds latLngBounds;
  if(pickUpLapLng.latitude > dropOffLapLng.latitude && pickUpLapLng.longitude> dropOffLapLng.longitude){
    latLngBounds = LatLngBounds(southwest: dropOffLapLng, northeast: pickUpLapLng);
  }
  else if(pickUpLapLng.longitude > dropOffLapLng.longitude){
      latLngBounds = LatLngBounds(southwest: LatLng(pickUpLapLng.latitude,dropOffLapLng.longitude), northeast: LatLng(dropOffLapLng.latitude,pickUpLapLng.longitude));
    }

  else if(pickUpLapLng.latitude > dropOffLapLng.latitude){
    latLngBounds = LatLngBounds(southwest: LatLng(dropOffLapLng.latitude,pickUpLapLng.longitude), northeast: LatLng(pickUpLapLng.latitude,dropOffLapLng.longitude));
  }
  else{
    latLngBounds=LatLngBounds(southwest: pickUpLapLng,northeast: dropOffLapLng);
  }
  
  newgoogleMapController.animateCamera(CameraUpdate.newLatLngBounds(latLngBounds,70));
    Marker pickUpLocMarker = Marker(
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
      infoWindow: InfoWindow(title: initialPos.placeName, snippet: "My location"),
      position: pickUpLapLng,
      markerId: MarkerId("pickUpId"),


    );

    Marker dropOffLocMarker = Marker(
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
      infoWindow: InfoWindow(title: finalPos.placeName, snippet: "Drop off konumu"), // burada kaldı dk 19 07
      position: dropOffLapLng, // t yerine p yazmısım eegeg
      markerId: MarkerId("dropOffId"),
    );

    setState(() {
      markersSet.add(pickUpLocMarker);
      markersSet.add(dropOffLocMarker);
    });

    Circle pickUpLocCircle = Circle(
      fillColor: Colors.blueAccent,
      center: pickUpLapLng,
      radius: 12,
      strokeColor: Colors.yellowAccent,
      strokeWidth: 4,
      circleId: CircleId("pickUpId"),
    );

    Circle dropOffLocCircle = Circle(
      fillColor: Colors.deepPurple,
      center: dropOffLapLng,
      radius: 12,
      strokeColor: Colors.purple,
      strokeWidth: 4,
      circleId: CircleId("dropOffId"),
    );



    setState(() {
      circlesSet.add(pickUpLocCircle);
      circlesSet.add(dropOffLocCircle);
    });
  }


}
