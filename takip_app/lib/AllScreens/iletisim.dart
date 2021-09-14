import 'dart:convert';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:takip_app/Assistants/minRequestAssistant.dart';
import 'package:animated_text_kit/animated_text_kit.dart';

class IletisimScreen extends StatefulWidget {

  @override
  _IletisimScreenState createState() => _IletisimScreenState();
}

class _IletisimScreenState extends State<IletisimScreen> {
  TextEditingController  NameController = TextEditingController();
  TextEditingController EPostaAdresiController = TextEditingController();
  TextEditingController CepTelefonuController = TextEditingController();
  TextEditingController MesajController = TextEditingController();
  String _Name="";
  String EPostaAdresi="";
  String CepTelefonu="";
  String Mesaj="";
  initState () {
    GetApi();
    print("umut");
  }


  @override
  Widget build(BuildContext context) {



    return Scaffold(
      body: Column(
        children: [
          Container(
            child: Padding(
              padding: EdgeInsets.all(3.0),
              child: Column(
                children: [
                  SizedBox(height: 50.0,),

                  SizedBox(
                    width: 250.0,
                    child: FadeAnimatedTextKit(
                        onTap: () {
                          print("Tap Event");
                        },
                        text: [
                          "İletişim Sayfası",
                          "İletişim Sayfası",
                          "İletişim Sayfası"
                        ],
                        textStyle: TextStyle(
                            fontSize: 32.0,
                            fontWeight: FontWeight.bold
                        ),
                        textAlign: TextAlign.start,
                        alignment: AlignmentDirectional.topStart // or Alignment.topLeft
                    ),
                  ),
                  TextField(
                    controller: NameController,
                    decoration: InputDecoration(
                      hintText: "Ad Soyad",
                      fillColor: Colors.grey,
                    ),
                  ),
                  TextField(
                    controller: EPostaAdresiController,
                    decoration: InputDecoration(
                      hintText: "E Posta Adresi",
                      fillColor: Colors.grey,
                    ),
                  ),
                  TextField(
                    controller: CepTelefonuController,
                    decoration: InputDecoration(
                      hintText: "Telefon Numarası",
                      fillColor: Colors.grey,
                    ),
                  ),
                  TextField(
                    controller: MesajController,
                    decoration: InputDecoration(
                      hintText: "Mesajınızı buraya yazabilirsiniz.",
                      fillColor: Colors.grey,
                    ),
                  ),
                  RaisedButton(
                    onPressed: addData,
                    child: Container(
                      height: 50.0,
                      child: Center(
                        child: Text("Gönder",style: TextStyle(fontFamily: "bolt-semibold"),),



                      ),
                    ),
                  ),
                  SizedBox(height: 100.0,),
                  SizedBox(
                    width: 250.0,
                    child: TyperAnimatedTextKit(
                        onTap: () {
                          print("Tap Event");
                        },
                        text: [
                          "İletişim formu ile",
                          "bize görüş,talep ve önerilerinizi",
                          "gönderebilirsiz.",


                        ],
                        textStyle: TextStyle(
                            fontSize: 30.0,
                            fontFamily: "Bobbers"
                        ),
                        textAlign: TextAlign.start,
                        alignment: AlignmentDirectional.topStart // or Alignment.topLeft
                    ),
                  ),
                ]

                ,

              ),
            ),
          )
        ],
      ),
    );



  }

  void GetApi() async{



    print("Selam");
    dynamic res2= await RequestAssistant.getRequest("http://10.0.2.2:5000/api/bus/hepsi");
    //var res3=res2["typeOfBus"];
    //var a=json.decode(res3.body.toString());
    print(res2);


    dynamic abc= res2[0]["dropOffLocation"];
    print(abc);

    print("res");


  }

  final databaseRef = FirebaseDatabase.instance.reference(); //database reference object

  void addData() {
     String a_Name=NameController.text.toString();
     String Eposta = EPostaAdresiController.text.toString();
     String Telefon=CepTelefonuController.text.toString();
     String Mesaj=MesajController.text.toString();
    databaseRef.child("Iletisim").push().set({'name': a_Name, 'EPosta': Eposta,'CepTelefonu': Telefon, 'Mesaj': Mesaj});
  }
}
