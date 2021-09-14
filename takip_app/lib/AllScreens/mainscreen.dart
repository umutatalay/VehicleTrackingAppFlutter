import 'dart:async';

//import 'dart:html';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:takip_app/AllScreens/SeferSaatleri.dart';
import 'package:takip_app/AllScreens/iletisim.dart';
import 'package:takip_app/AllScreens/loginscreen.dart';
import 'package:takip_app/AllScreens/registrationscreen.dart';
import 'package:takip_app/AllScreens/searchScreen.dart';
import 'package:takip_app/AllWidgets/Divider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:takip_app/AllWidgets/ProgressDialog.dart';
import 'package:takip_app/Assistants/assistantMethods.dart';
import 'package:takip_app/Assistants/geoFireAssistant.dart';
import 'package:takip_app/Assistants/minRequestAssistant.dart';
import 'package:takip_app/ConfigMaps.dart';
import 'package:takip_app/DataHandler/appData.dart';
import 'dart:math';

import 'package:takip_app/Models/directDetails.dart';
import 'package:takip_app/Models/nearbyAvailableDrivers.dart';
import 'package:takip_app/Services/DakikaServisi.dart';

import '../main.dart';

class MainScreen extends StatefulWidget {
  static const String idScreen = "mainscreen";

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with TickerProviderStateMixin {
  Completer<GoogleMapController> _controllerGoogleMap = Completer();
  GoogleMapController newgoogleMapController;
  GlobalKey<ScaffoldState> scaffoldkey = new GlobalKey<ScaffoldState>();
  DirectionDetails tripdirectionDetails;

  List<LatLng> pLineCoerordinates = [];
  Set<Polyline> polylineset = {}; // var type ?
  Position currentposition;
  var geoLocator = Geolocator();
  double bottomPaddingOfMap = 0;

  Set<Marker> markersSet = {};
  Set<Circle> circlesSet = {};

  double rideDetailsContainerHeight = 0;
  double requestRideContainerHeight = 0;
  double searchContainerHeight = 300;
  String KalanDakika="";
  bool drawerOpen = true;
  bool nearbyavailableDriverKeysLoaded = false;

  DatabaseReference rideRequestRef;

  BitmapDescriptor nearByIcon; // Bu araçların iconları için olan bir şey
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    updateAvailableDriversOnMap();
    AssistantMethods.getCurrentOnlineUserInfo();
  }

  void saveRideRequest() {
    rideRequestRef =
        FirebaseDatabase.instance.reference().child("Ride Request").push();

    var pickUp = Provider.of<AppData>(context, listen: false).pickUpLocation;
    var dropOff = Provider.of<AppData>(context, listen: false).dropOffLocation;

    Map piclUpLocMap = {
      "latitude": pickUp.latitude.toString(),
      "longitude": pickUp.longitude.toString(),
    };

    Map dropOffLocMap = {
      "latitude": dropOff.latitude.toString(),
      "longitude": dropOff.longitude.toString(),
    };

    Map rideInfoMap = {
      "driver_id": "waiting",
      "payment_method": "cash",
      "pickup": piclUpLocMap,
      "dropoff": dropOffLocMap,
      "created_at": DateTime.now().toString(),
      "rider_name": userCurrentInfo.name,
      "rider_phone": userCurrentInfo.phone,
      "pickup_address": pickUp.placeName,
      "dropoff_address": dropOff.placeName,
    };

    rideRequestRef.set(rideInfoMap);
  }

  void cancelRideRequest() {
    rideRequestRef.remove();
  }

  void displayRequestRideContainer() {
    setState(() {
      requestRideContainerHeight = 250.0;
      rideDetailsContainerHeight = 0;
      bottomPaddingOfMap = 230.0;
      drawerOpen = true;
    });

    saveRideRequest();
  }

  resetApp() {
    setState(() {
      drawerOpen = true;
      searchContainerHeight = 300.0;
      rideDetailsContainerHeight = 0;
      requestRideContainerHeight = 0;
      bottomPaddingOfMap = 230.0;

      polylineset.clear();
      markersSet.clear();
      circlesSet.clear();
      pLineCoerordinates.clear();
    });

    locatePosition();
  }

  void displayRideDetailsContainer() async {
    await getPlaceDirection();

    setState(() {
      searchContainerHeight = 0;
      rideDetailsContainerHeight = 240.0;
      bottomPaddingOfMap = 230.0;
      drawerOpen = false;
    });
  }

  void locatePosition() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    currentposition = position;

    LatLng latLngPosition = LatLng(position.latitude, position.longitude);

    CameraPosition cameraPosition =
        new CameraPosition(target: latLngPosition, zoom: 14);
    newgoogleMapController
        .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));

    String address =
        await AssistantMethods.searchCoordinateAddress(position, context);
    print("Adress : " + address);

    initGeoFireListener();
  }

  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(41.66644833580664, -122.085749655962),
    zoom: 14.4746,
  );

  @override
  Widget build(BuildContext context) {

    CreateIconMarker();

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
                    decoration: BoxDecoration(color: Colors.white),
                    child: Row(
                      children: [
                        Image.asset(
                          "images/user_icon.png",
                          height: 65.0,
                          width: 65.0,
                        ),
                        SizedBox(
                          width: 16.0,
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Umut Atalay",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16.0,
                                  fontFamily: "Brand-Bold"),
                            ),
                            SizedBox(
                              height: 6.0,
                            ),
                            Text("Profilim"),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                DividerWidget(),

                SizedBox(
                  height: 12.0,
                ),
                //Drawer Body Controllers

                GestureDetector(
                  child: ListTile(

                    onTap: () async {
                      var res = await Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => SeferSaatleriScreen()));

                      if (res == "obtainDirection") {
                        //await getPlaceDirection();
                        displayRideDetailsContainer();
                      }
                    },


                    leading: Icon(
                      Icons.hourglass_full,
                    ),
                    title: Text(
                      "Sefer Saatleri",
                      style: TextStyle(fontSize: 15.0),
                    ),
                  ),
                ),
                GestureDetector(
                  child: ListTile(

                    onTap: () async {
                      var res = await Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => IletisimScreen()));

                      if (res == "obtainDirection") {
                        //await getPlaceDirection();
                        displayRideDetailsContainer();
                      }
                    },


                    leading: Icon(
                      Icons.person,
                    ),
                    title: Text(
                      "İletişim",
                      style: TextStyle(fontSize: 15.0),
                    ),
                  ),
                ),
                GestureDetector(
                  child: ListTile(

                    onTap: () async {
                      var res = await Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => SearchScreen()));

                      if (res == "obtainDirection") {
                        //await getPlaceDirection();
                        displayRideDetailsContainer();
                      }
                    },


                    leading: Icon(
                      Icons.local_car_wash,
                    ),
                    title: Text(
                      "Yolculuk Hesaplayıcı",
                      style: TextStyle(fontSize: 15.0),
                    ),
                  ),
                ),

                GestureDetector(
                  onTap: () {
                    FirebaseAuth.instance.signOut();
                    Navigator.pushNamedAndRemoveUntil(
                        context, LoginScreen.idScreen, (route) => false);
                  },
                  child: ListTile(
                    leading: Icon(
                      Icons.info,
                    ),
                    title: Text(
                      "Çıkış yap",
                      style: TextStyle(fontSize: 15.0),
                    ),
                  ),
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
              onMapCreated: (GoogleMapController controller) {
                _controllerGoogleMap.complete(controller);
                newgoogleMapController = controller;

                setState(() {
                  bottomPaddingOfMap = 500.0;
                });
                locatePosition();
              },
            ),

            //HamburgerButton for drawer
            Positioned(
              top: 38.0,
              left: 22.0,
              child: GestureDetector(
                onTap: () {
                  if (drawerOpen) {
                    scaffoldkey.currentState.openDrawer();
                  } else {
                    resetApp();
                  }
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
                      ]),
                  child: CircleAvatar(
                    backgroundColor: Colors.white,
                    child: Icon(
                      (drawerOpen) ? Icons.menu : Icons.close,
                      color: Colors.black,
                    ),
                    radius: 20.0,
                  ),
                ),
              ),
            ),

            // Alt menü buraya gelecek

            Positioned(
              bottom: 0.0,
              left: 0.0,
              right: 0.0,
              child: AnimatedSize(
                vsync: this,
                curve: Curves.bounceIn,
                duration: new Duration(microseconds: 160),
                child: Container(
                  height: rideDetailsContainerHeight,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16.0),
                      topRight: Radius.circular(16.0),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black,
                        blurRadius: 16.0,
                        spreadRadius: 0.5,
                        offset: Offset(0.7, 0.7),
                      )
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 17.0),
                    child: Column(
                      children: [
                        Container(
                            width: double.infinity,
                            color: Colors.tealAccent,
                            child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 16.0),
                                child: Row(
                                  children: [
                                    Image.asset(
                                      "images/bus.png",
                                      height: 70,
                                      width: 80.0,
                                    ),
                                    SizedBox(
                                      width: 10.0,
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Konumlar arası tahmini mesafe ve süre",
                                          style: TextStyle(
                                              fontSize: 14.0,
                                              fontFamily: "Brand-Bond"),
                                        ),
                                        Text(
                                          (tripdirectionDetails != null)
                                              ? tripdirectionDetails
                                                  .durationText + " ve "+ tripdirectionDetails.distanceText
                                              : "",
                                          style: TextStyle(
                                              fontSize: 18.0,
                                              fontFamily:
                                                  "Brand-Bond"), // for the kilometre için km
                                        ),
                                      ],
                                    ),
                                    Expanded(
                                      child: Container(),
                                    ),
                                  ],
                                ))),
                        SizedBox(
                          height: 20.0,
                        ),

                        SizedBox(
                          height: 20.0,
                        ),

                        // request olan buradki kodu aldım
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20.0),
                          child: RaisedButton(
                            onPressed: () {

                              SeferSaatleriScreen();
                              // displayRequestRideContainer() bu vardı üstteki geldi
                              print("tiklandi");
                            },
                            color: Theme.of(context).accentColor,
                            child: Padding(
                              padding: EdgeInsets.all(17.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Sefer Saatleri",
                                    style: TextStyle(
                                        fontSize: 20.0,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white),
                                  ),
                                  Icon(
                                    FontAwesomeIcons.taxi,
                                    color: Colors.white,
                                    size: 26.0,
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 24.0,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            Positioned(
              bottom: 0.0,
              left: 0.0,
              right: 0.0,
              child: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(16.0),
                      topLeft: Radius.circular(16.0),
                    ),
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                          spreadRadius: 0.5,
                          blurRadius: 16.0,
                          color: Colors.black54,
                          offset: Offset(0.7, 0.7)),
                    ]),
                height: requestRideContainerHeight,
                child: Padding(
                  padding: const EdgeInsets.all(20.0), // 30
                  child: Column(
                    children: [
                      SizedBox(
                        height: 12.0,
                      ),
                      SizedBox(
                        width: double.infinity,
                        child: ColorizeAnimatedTextKit(
                          onTap: () {
                            print("tap event");
                          },
                          text: [
                            "Lütfen Bekleyin",
                            "wait",
                          ],
                          textStyle: TextStyle(
                            fontSize: 55.0,
                          ),
                          colors: [
                            Colors.red,
                            Colors.black54,
                            Colors.blueAccent,
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 22.0,
                      ),
                      GestureDetector(
                        onTap: () {
                          cancelRideRequest();
                          resetApp();
                        },
                        child: Container(
                          height: 60.0,
                          width: 60.0,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(26.0),
                            border:
                                Border.all(width: 2.0, color: Colors.black54),
                          ),
                          child: Icon(
                            Icons.close,
                            size: 26.0,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 10.0,
                      ),
                      Container(
                        width: double.infinity,
                        child: Text(
                          "Vazgeçtim gitmiycem",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 12.0),
                        ),
                      )
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
    var initialPos =
        Provider.of<AppData>(context, listen: false).pickUpLocation;
    var finalPos = Provider.of<AppData>(context, listen: false).dropOffLocation;

    var pickUpLapLng = LatLng(initialPos.latitude, initialPos.longitude);
    var dropOffLapLng = LatLng(finalPos.latitude, finalPos.longitude);

    showDialog(
        context: context,
        builder: (BuildContext) => ProgressDialog(
              message: "Lütfen Bekle",
            ));
    var details = await AssistantMethods.obtainPlaceDirectionDetails(
        pickUpLapLng, dropOffLapLng);
    setState(() {
      tripdirectionDetails = details;
    });
    Navigator.pop(context);

    print("this is encoded points:"); // beni kaldır
    print(details.encodedPoints); // beni de kaldır.

    PolylinePoints polylinePoints = PolylinePoints();
    List<PointLatLng> decodedPolyLinePointsResult =
        polylinePoints.decodePolyline(details.encodedPoints);

    pLineCoerordinates.clear();

    if (decodedPolyLinePointsResult.isNotEmpty) {
      decodedPolyLinePointsResult.forEach((PointLatLng pointLatLng) {
        pLineCoerordinates
            .add(LatLng(pointLatLng.latitude, pointLatLng.longitude));
      });
    }

    polylineset.clear();

    setState(() {
      Polyline polyline = Polyline(
        color: Colors.red,
        polylineId: PolylineId("PolylineID"),
        jointType: JointType.round,
        points: pLineCoerordinates,
        width: 5,
        // must be int miş galiba
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
        geodesic: true,
      );

      polylineset.add(polyline);
    });

    LatLngBounds latLngBounds;
    if (pickUpLapLng.latitude > dropOffLapLng.latitude &&
        pickUpLapLng.longitude > dropOffLapLng.longitude) {
      latLngBounds =
          LatLngBounds(southwest: dropOffLapLng, northeast: pickUpLapLng);
    } else if (pickUpLapLng.longitude > dropOffLapLng.longitude) {
      latLngBounds = LatLngBounds(
          southwest: LatLng(pickUpLapLng.latitude, dropOffLapLng.longitude),
          northeast: LatLng(dropOffLapLng.latitude, pickUpLapLng.longitude));
    } else if (pickUpLapLng.latitude > dropOffLapLng.latitude) {
      latLngBounds = LatLngBounds(
          southwest: LatLng(dropOffLapLng.latitude, pickUpLapLng.longitude),
          northeast: LatLng(pickUpLapLng.latitude, dropOffLapLng.longitude));
    } else {
      latLngBounds =
          LatLngBounds(southwest: pickUpLapLng, northeast: dropOffLapLng);
    }

    newgoogleMapController
        .animateCamera(CameraUpdate.newLatLngBounds(latLngBounds, 70));
    Marker pickUpLocMarker = Marker(
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
      infoWindow:
          InfoWindow(title: initialPos.placeName, snippet: "My location"),
      position: pickUpLapLng,
      markerId: MarkerId("pickUpId"),
    );

    Marker dropOffLocMarker = Marker(
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
      infoWindow:
          InfoWindow(title: finalPos.placeName, snippet: "Son Durak"),
      // burada kaldı dk 19 07
      position: dropOffLapLng,
      // t yerine p yazmısım eegeg
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

  void initGeoFireListener() {

    Geofire.initialize("availablesDrivers");
    // 25 kilometre yakındaki araçları gösteren kod
    Geofire.queryAtLocation(
            currentposition.latitude, currentposition.longitude, 25)
        .listen((map) {
      print(map);
      if (map != null) {
        var callBack = map['callBack'];
        //updateAvailableDriversOnMap();
        //latitude will be retrieved from map['latitude']
        //longitude will be retrieved from map['longitude']

        switch (callBack) {
          case Geofire.onKeyEntered:
            NearbyAvailableDrivers nearbyAvailableDrivers =
                NearbyAvailableDrivers();
            nearbyAvailableDrivers.key = map['key'];
            nearbyAvailableDrivers.latitude = map['latitude'];
            nearbyAvailableDrivers.longitude = map['longitude'];
            GeoFireAssistant.nearByAvailableDriversList
                .add(nearbyAvailableDrivers);
            if (nearbyavailableDriverKeysLoaded == true) {
              updateAvailableDriversOnMap();
            }
            break;

          case Geofire.onKeyExited:
            GeoFireAssistant.removeDriverFromList(map['key']);
            updateAvailableDriversOnMap();
            break;

          case Geofire.onKeyMoved:
            NearbyAvailableDrivers nearbyAvailableDrivers =
                NearbyAvailableDrivers();
            nearbyAvailableDrivers.key = map['key'];
            nearbyAvailableDrivers.latitude = map['latitude'];
            nearbyAvailableDrivers.longitude = map['longitude'];
            GeoFireAssistant.updateDriverNearbyLocation(nearbyAvailableDrivers);
            updateAvailableDriversOnMap();

            // Update your key's location
            break;

          case Geofire.onGeoQueryReady:
            updateAvailableDriversOnMap();

            // All Intial Data is loaded

            break;
        }
      }

      setState(() {});
    });
  }

  void updateAvailableDriversOnMap() {
    setState(() {
      markersSet.clear();
    });

    Set<Marker> tMarkers = Set<Marker>();
    for (NearbyAvailableDrivers driver
        in GeoFireAssistant.nearByAvailableDriversList) {
      LatLng driverAvaiablePosition = LatLng(driver.latitude, driver.longitude);

      Marker marker = Marker(
        markerId: MarkerId('driver${driver.key}'),
        position: driverAvaiablePosition,
        icon: nearByIcon,
        onTap: CaronTap,
        rotation: AssistantMethods.createRandomNumber(360),
      );

      tMarkers.add(marker);
    }
    setState(() {
      markersSet = tMarkers;
    });
  }

  // Araçların harita üzerinde gösterilecek olan iconları için fonksiyn
  void CreateIconMarker() {
    if (nearByIcon == null) {


      ImageConfiguration imageConfiguration =
          createLocalImageConfiguration(context, size: Size(5, 5));

      BitmapDescriptor.fromAssetImage(imageConfiguration, "images/bus.png")
          .then((value) {

        nearByIcon = value;
      });
    }
  }
   void CaronTap() async{
    var res = DakikaServisi().getDakika("Avcilar","Bakirkoy");
    String _UserLat=currentposition.latitude.toString();
    String _UserLng=currentposition.longitude.toString();
    var res2= await RequestAssistant.getRequest("https://maps.googleapis.com/maps/api/distancematrix/json?units=imperial&origins=$_UserLat,$_UserLng&destinations=Bakirkoy&key=AIzaSyAob4ScOyrDcHnwN7yNqs5ynUlHN2DiSgs");
    var res3=res2["rows"][0]["elements"][0]["duration"]["text"];
    print(res3);
    print("res");
    KalanDakika=res3;
    displayToastMessage("Bu aracın sizin konumunuza tahmini olarak ulaşma süresisi: $KalanDakika", context);
    print(currentposition.longitude);
    print(currentposition.latitude);
    GetAraclar();
  }

  void GetAraclar(){
    usersRef.once().then((DataSnapshot snapshot) {
      print('Data : ${snapshot.value}');
    });
  }
}
