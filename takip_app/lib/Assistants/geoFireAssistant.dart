import 'package:takip_app/Models/nearbyAvailableDrivers.dart';

class GeoFireAssistant{
  static List<NearbyAvailableDrivers> nearByAvailableDriversList = [];

  static void removeDriverFromList(String key){
    int index = nearByAvailableDriversList.indexWhere((element) => element.key==key);
    nearByAvailableDriversList.removeAt(index);
  }

  static void updateDriverNearbyLocation(NearbyAvailableDrivers driver){
    int index = nearByAvailableDriversList.indexWhere((element) => element.key==driver.key);

    nearByAvailableDriversList[index].latitude=driver.latitude;
    nearByAvailableDriversList[index].longitude=driver.longitude;
  }
}