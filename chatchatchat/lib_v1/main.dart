import 'package:chatchatchat/pages/home_page.dart';
import 'package:chatchatchat/pages/login_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main(){
  runApp(MainAppBase());
}


class MainAppBase extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: StreamBuilder(
        stream: FirebaseAuth.instance.onAuthStateChanged,
        builder: (context,snapshot){
          if(snapshot.hasData){
            if(snapshot.data == null){
              return LoginPage();
            }else{
              return HomePage(
                firebaseUser: snapshot.data,
              );
            }
          }else{
            return LoginPage();
          }
        },
      ),
    );
  }
}


