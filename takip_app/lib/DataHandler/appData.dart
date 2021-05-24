import 'package:flutter/cupertino.dart';
import 'package:takip_app/Models/address.dart';

class AppData extends ChangeNotifier{
 Address pickUpLocation, dropOffLocation;

 void updatePickUpLocationAddress(Address pickUpAddres){
   pickUpLocation =pickUpAddres;
   notifyListeners();

 }
 void updateDropOffLocationAddress(Address dropOffAddres){
   dropOffLocation =dropOffAddres;
   notifyListeners();

 }
}