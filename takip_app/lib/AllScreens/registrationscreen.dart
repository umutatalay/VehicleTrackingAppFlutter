import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:takip_app/AllScreens/loginscreen.dart';
import 'package:takip_app/AllScreens/mainscreen.dart';
import 'package:takip_app/AllWidgets/ProgressDialog.dart';
import 'package:takip_app/main.dart';

class RegistrationsScreen extends StatelessWidget {

  static const String idScreen="register";
  TextEditingController nameTextEditingController=TextEditingController();
  TextEditingController emailTextEditingController=TextEditingController();
  TextEditingController phoneTextEditingController=TextEditingController();
  TextEditingController passwordTextEditingController=TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          SizedBox(height: 45.0,),
          Image(
            image: AssetImage("images/logo.png"),
            width: 390.0,
            height: 250.0,
            alignment: Alignment.center,
          ),
          SizedBox(height: 1.0,),
          Text(
            "Sürücü olarak kayıt ol",
            style: TextStyle(fontSize: 24.0, fontFamily: "bolt-semibold"),
            textAlign: TextAlign.center,

          ),
          Padding(
            padding: EdgeInsets.all(20.0),
            child: Column(
              children: [
                SizedBox(height: 1.0,),
                TextField(keyboardType: TextInputType.text,
                  controller: nameTextEditingController,
                  decoration: InputDecoration(
                      labelText: "İsim",
                      labelStyle: TextStyle(fontSize: 14.0,), hintStyle: TextStyle(color: Colors.grey,fontSize: 10.0)

                  ),
                  style: TextStyle(fontSize: 14.0),
                ),
                SizedBox(height: 1.0,),
                TextField(keyboardType: TextInputType.emailAddress,
                  controller: emailTextEditingController,
                  decoration: InputDecoration(
                      labelText: "Email",
                      labelStyle: TextStyle(fontSize: 14.0,), hintStyle: TextStyle(color: Colors.grey,fontSize: 10.0)

                  ),
                  style: TextStyle(fontSize: 14.0),
                ),
                SizedBox(height: 1.0,),
                TextField(keyboardType: TextInputType.phone,
                  controller: phoneTextEditingController,
                  decoration: InputDecoration(
                      labelText: "Telefon Numarası",
                      labelStyle: TextStyle(fontSize: 14.0,), hintStyle: TextStyle(color: Colors.grey,fontSize: 10.0)

                  ),
                  style: TextStyle(fontSize: 14.0),
                ),
                SizedBox(height: 1.0,),
                TextField(obscureText: true,
                  controller: passwordTextEditingController,
                  decoration: InputDecoration(
                      labelText: "Parola",
                      labelStyle: TextStyle(fontSize: 14.0,), hintStyle: TextStyle(color: Colors.grey,fontSize: 10.0)

                  ),
                  style: TextStyle(fontSize: 14.0),
                ),
              ],
            ),
          ),

          SizedBox(height: 1.0,),
          RaisedButton(
            color: Colors.black,textColor: Colors.white,
            child: Container(
              height: 50.0,
              child: Center(
                child: Text("Kayıt ol",style: TextStyle(fontFamily: "bolt-semibold"),),

              ),
            ),
            shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(24.0)),
            onPressed: (){
              if(nameTextEditingController.text.length<3){
                Fluttertoast.showToast(msg: "İsim Alanı 3 karakterterden az olamaz.");
              }
              else if(!emailTextEditingController.text.contains("@")){
                displayToastMessage("E Mail uygun formatta girilmeli !", context);
              }
              else if(phoneTextEditingController.text.isEmpty){
                displayToastMessage("Telefon numarası boş bırakılamaz.", context);
              }
              else{
                registerNewUser(context);
              }

            },
          ),



          FlatButton(child:Text("Zaten kayıtlı mısın? Giriş yap") , onPressed: (){
             Navigator.pushNamedAndRemoveUntil(context, LoginScreen.idScreen, (route) => false);
          },)
        ],

      ),
    );
  }
  final FirebaseAuth _firebaseAuth=FirebaseAuth.instance;

  void registerNewUser(BuildContext context) async
  {
    showDialog(context: context,
        barrierDismissible: false,
        builder: (BuildContext context){
          return ProgressDialog(message: "Kayit Olunuyor.",);
        }
    );
      final User firebaseUser = (await _firebaseAuth
          .createUserWithEmailAndPassword(email: emailTextEditingController.text, password: passwordTextEditingController.text).catchError((ErrMsg){
        Navigator.pop(context);
            displayToastMessage("Hata: "+ErrMsg.toString(), context);
      })).user;
   if(firebaseUser!=null){
     // save user info to db

      Map UserDataMap ={
        "name": nameTextEditingController.text.trim(),
        "email":emailTextEditingController.text.trim(),
        "phone":phoneTextEditingController.text.trim(),

      };
      usersRef.child(firebaseUser.uid).set(UserDataMap);
      displayToastMessage("Kayıt işlemi başarı ile gerçekleşti.", context);
      Navigator.pushNamedAndRemoveUntil(context, MainScreen.idScreen, (route) => false);
   }
   else{
     displayToastMessage("New user has not been created", context);
   }

  }
}


displayToastMessage(String message, BuildContext context ){
  Fluttertoast.showToast(msg: message);
}
