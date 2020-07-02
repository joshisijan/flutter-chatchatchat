import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';

import 'package:http/http.dart' as http;

import '../plugin/error_message.dart';


class HomePage extends StatelessWidget {

  final FirebaseUser firebaseUser;

  HomePage({@required this.firebaseUser});

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: RawMaterialButton(
          child: Text('logout'),
          onPressed: (){
            _firebaseAuth.signOut();
          },
        ),
      ),
      body: StreamBuilder(
        stream: Stream.periodic(Duration(seconds: 1)).asyncMap((i){
          return http.get('http://192.168.1.69/chatchatchat/user.php?'
            'apikey=joshisijan'
            '&firebaseUID=${firebaseUser.uid}'
            '&email=${firebaseUser.email}'
            '&displayName=${firebaseUser.displayName}'
            '&createdAt=${firebaseUser.metadata.creationTime}'
            '&lastSignin=${firebaseUser.metadata.lastSignInTime}'
            '&photoUrl=${firebaseUser.photoUrl}'
            '');
        }),
        builder: (_, snapshot){
          if(snapshot.hasData){
            if(snapshot.data.body == 'api error'){
              showError(context, 'An error occured try again');
              return Center(
                child: Text('An error occured try again'),
              );
            }
            else{
              var data = jsonDecode(snapshot.data.body);
              return ListView(
                children: <Widget>[
                  Image.network(data[0]['photoUrl'] ?? ''),
                  Text(data[0]['displayName']),
                ],
              );
            }
          }else{
            return Center(
              child: CupertinoActivityIndicator(),
            );
          }
        },
      ),
    );
  }
}
