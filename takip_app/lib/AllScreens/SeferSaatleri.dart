import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:takip_app/Assistants/Bus.dart';
import 'package:takip_app/Assistants/minRequestAssistant.dart';

class SeferSaatleriScreen extends StatefulWidget {
  @override
  _SeferSaatleriScreenState createState() => _SeferSaatleriScreenState();
}

class _SeferSaatleriScreenState extends State<SeferSaatleriScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    GetApi();
  }

  @override
  Widget build(BuildContext context) {
    GetApi();
    return Scaffold(
        body: SafeArea(
          child: Container(
              child: Row(
                children: [
                  RaisedButton(
                    color: Colors.black54,
                    onPressed: GetApi,
                  ),
                  DataTable(
                    columns: const <DataColumn>[
                      DataColumn(

                        label: Text(
                          'Servis Kodu ',
                          style: TextStyle(fontStyle: FontStyle.italic),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'Saat',
                          style: TextStyle(fontStyle: FontStyle.italic),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'Kalkış Yeri',
                          style: TextStyle(fontStyle: FontStyle.italic),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'Varış Yeri',
                          style: TextStyle(fontStyle: FontStyle.italic),
                        ),
                      ),

                    ],
                    rows: const <DataRow>[
                      DataRow(
                        cells: <DataCell>[
                          DataCell(Text('A1')),
                          DataCell(Text('10.00')),
                          DataCell(Text('Avcılar')),
                          DataCell(Text('a')),
                        ],
                      ),


                    ],
                  ),
                  SizedBox(height: 10.0,),

                ],
              )


          ),
        )
    );
  }

  void GetApi() async {
    List<String> DropOffKonumList;

    dynamic res2 = await RequestAssistant.getRequest(
        "http://10.0.2.2:5000/api/bus/hepsi");
    //var res3=res2["typeOfBus"];
    //var a=json.decode(res3.body.toString());
    print(res2);

    int sayac=-1;

    //DropOff için olan loop
    for (var DO in res2) {

      print(res2[sayac]["dropOffLocation"]);
      String DropOffitem= res2[sayac++]["dropOffLocation"].toString();
      DropOffKonumList.add(DropOffitem);

    }



    //dynamic abc = res2[0]["dropOffLocation"];
    //print(abc);

    //print("res");
    //List<String> myList = List<String>();
    //myList.add("bir");
    //myList.add("dos");
    //print("fore");
    //res2.forEach((element) {
    //  print(element);
    //});

    //print(res2);
    //List<Bus> reportList;
    //int sayac=0;
    //if (true) {
     // for (var report in res2 ?? []) {
       // reportList.add(Bus().fromJson(report[sayac]["dropOffLocation"]));
        //sayac++;
      //}
    //}
    //print("AAA");
    //res2.forEach((element) {

      //print(element);
    //});
  }
}