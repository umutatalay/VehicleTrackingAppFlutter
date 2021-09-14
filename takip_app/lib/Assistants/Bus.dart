class Bus{
  int id = 0;
  String typeOfBus = "";
  String firstLocation = "";
  String dropOffLocation = "";
  String hour = "";
  Bus({this.id=0,this.typeOfBus="",this.firstLocation="",this.dropOffLocation="",this.hour=""});

  fromJson(json){
    this.id = json["id"] ?? 0;
    this.typeOfBus = json["typeOfBus"] ?? "";
  }

  Map<String, dynamic> toMap(){
    return {
      "id":this.id,
      "typeOfBus":this.typeOfBus,
    };
  }


}