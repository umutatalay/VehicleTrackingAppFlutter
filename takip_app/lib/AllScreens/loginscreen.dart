import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:takip_app/AllScreens/mainscreen.dart';
import 'package:takip_app/AllScreens/registrationscreen.dart';
import 'package:takip_app/AllWidgets/ProgressDialog.dart';
import 'package:takip_app/main.dart';

class LoginScreen extends StatelessWidget {

  static const String idScreen="login";
  TextEditingController emailTextEditingController=TextEditingController();
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
            "Sürücü olarak giriş yap",
            style: TextStyle(fontSize: 24.0, fontFamily: "bolt-semibold"),
            textAlign: TextAlign.center,

          ),
          Padding(
            padding: EdgeInsets.all(20.0),
            child: Column(
              children: [
                SizedBox(height: 1.0,),
                TextField(
                  controller: emailTextEditingController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                      labelText: "Email",
                      labelStyle: TextStyle(fontSize: 14.0,), hintStyle: TextStyle(color: Colors.grey,fontSize: 10.0)

                  ),
                  style: TextStyle(fontSize: 14.0),
                ),
                SizedBox(height: 1.0,),
                TextField(
                  controller: passwordTextEditingController,
                  obscureText: true,
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
                child: Text("Giriş Yap",style: TextStyle(fontFamily: "bolt-semibold"),),

              ),
            ),
            shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(24.0)),
            onPressed: (){
              if(!emailTextEditingController.text.contains("@")){
                displayToastMessage("E Mail uygun formatta girilmeli !", context);
              }
              else{
                loginAndAuthenticateUser(context);
              }

            },
          ),



        FlatButton(child:Text("Kayıt ol ") ,
        onPressed: (){Navigator.pushNamedAndRemoveUntil(context, RegistrationsScreen.idScreen, (route) => false);},)
        ],

      ),
    );
  }

  final FirebaseAuth _firebaseAuth=FirebaseAuth.instance;

  void loginAndAuthenticateUser(BuildContext context) async{
    showDialog(context: context,
    barrierDismissible: false,
      builder: (BuildContext context){
       return ProgressDialog(message: "Bekle",);
      }
    );
    final User firebaseUser = (await _firebaseAuth
        .signInWithEmailAndPassword(email: emailTextEditingController.text, password: passwordTextEditingController.text).catchError((ErrMsg){
          Navigator.pop(context);
      displayToastMessage("Hata: "+ErrMsg.toString(), context);
    })).user;

    if(firebaseUser!=null){

      usersRef.child(firebaseUser.uid).once().then((DataSnapshot snap){
        if(snap.value != null){
          Navigator.pushNamedAndRemoveUntil(context, MainScreen.idScreen, (route) => false);
          displayToastMessage("Giriş yapıldı.", context);
        }
        else{
          Navigator.pop(context);
          _firebaseAuth.signOut();
          displayToastMessage("Böyle bir hesap bulunamadıdı", context);
        }
      });

    }
    else{
      Navigator.pop(context);
      displayToastMessage("Giris yapilamadi", context);
    }
  }
}


