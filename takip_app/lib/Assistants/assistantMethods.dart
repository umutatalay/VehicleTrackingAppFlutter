import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:takip_app/Assistants/requestAssistant.dart';
import 'package:takip_app/ConfigMaps.dart';
import 'package:takip_app/DataHandler/appData.dart';
import 'package:takip_app/Models/address.dart';
import 'package:takip_app/Models/directDetails.dart';

class AssistantMethods
{
  static Future<String> searchCoordinateAddress(Position position, context) async{
    String placeAddress="";
    String st1, st2, st3,st4;
    String url="https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&key=$mapkey";
    var response = await RequestAssistant.getRequest(url);
    if(response!="failed"){
      //placeAddress =response["results"][0]["formatted_address"];
      st1 =response["results"][0]["address_components"][0]["long_name"]; // daire no gibi
      st2 =response["results"][0]["address_components"][4]["long_name"]; // cadde
      st3 =response["results"][0]["address_components"][5]["long_name"];
      st4 =response["results"][0]["address_components"][6]["long_name"]; // ülke
      placeAddress = st1+ ", " + st2 + ", " + st3 + ", "+ st4;
      Address userPickUpAddress = new Address();
      userPickUpAddress.longitude=position.longitude;
      userPickUpAddress.latitude=position.latitude;
      userPickUpAddress.placeName=placeAddress;

      Provider.of<AppData>(context,listen: false).updatePickUpLocationAddress(userPickUpAddress);

    }

    return placeAddress;
  }


  static Future<DirectionDetails> obtainPlaceDirectionDetails(LatLng initalPosition, LatLng finalPosition) async
  {
    String directionUrl="https://maps.googleapis.com/maps/api/directions/json?origin=${initalPosition.latitude},${initalPosition.longitude}&destination=${finalPosition.latitude},${finalPosition.longitude}&key=$mapkey";


    var res = await RequestAssistant.getRequest(directionUrl);
    if(res=="failed"){
      return null;
    }

    DirectionDetails directionDetails =DirectionDetails();
    directionDetails.encodedPoints= res["routes"][0]["overview_polyline"]["points"];

    directionDetails.distanceText= res["routes"][0]["legs"][0]["distance"]["text"];
    directionDetails.distanceValue= res["routes"][0]["legs"][0]["distance"]["value"];

    directionDetails.durationText= res["routes"][0]["legs"][0]["duration"]["text"];
    directionDetails.durationValue= res["routes"][0]["legs"][0]["duration"]["value"];

    return directionDetails;

  }

}