import 'dart:convert';

import 'package:http/http.dart' as http;
class RequestAssistant{
  static Future<dynamic> getRequest(String url) async{
    http.Response response= await http.get(url);
    try{
      if(response.statusCode == 200){
        String jSonData = response.body;
        var decodedata = jsonDecode(jSonData);
        return decodedata;

      }
      else{
        return "failed";
      }

    }
    catch(exp){
        return "failed";
    }
  }
}