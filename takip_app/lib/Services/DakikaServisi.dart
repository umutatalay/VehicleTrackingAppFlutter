import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:takip_app/Assistants/requestAssistant.dart';
class DakikaServisi{

   Future <dynamic> getDakika(String str1,String str2) async {


    String url="https://maps.googleapis.com/maps/api/distancematrix/json?units=imperial&origins=$str1&destinations=$str2&key=AIzaSyAob4ScOyrDcHnwN7yNqs5ynUlHN2DiSgs";
    var response = await RequestAssistant.getRequest(url);

    return response;
  }
}

