import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';


class SentRequests extends StatelessWidget {

  final FirebaseUser firebaseUser;

  SentRequests({ @required this.firebaseUser });

  final Firestore _fireStore = Firestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Sent Requests'
        ),
        centerTitle: true,
      ),
      body: StreamBuilder(
        stream: _fireStore.collection('users').where('userId',isEqualTo: this.firebaseUser.uid).snapshots(),
        builder: (_, snapshot){
          if(snapshot.hasData){
            var data = snapshot.data.documents[0]['requests'];
            if(data.length <= 0){
              return Center(
                child: Text('You have no friend requests'),
              );
            }
            else{
              return ListView(
                children: data.map<Widget>((friendUid){
                  return StreamBuilder(
                    stream: _fireStore.collection('users').document(friendUid).get().asStream(),
                    builder: (_, friendData){
                      if(friendData.hasData){
                        var friend = friendData.data;
                        return Card(
                          child: ListTile(
                            dense: true,
                            isThreeLine: true,
                            title: Text(friend['name']),
                            subtitle: Text(friend['email']),
                            leading: CircleAvatar(
                              backgroundImage: NetworkImage(friend['photoUrl']),
                            ),
                            trailing: RawMaterialButton(
                              child: Chip(
                                label: Text('Cancle'),
                              ),
                              onPressed: (){
                                _fireStore.collection('users').document(this.firebaseUser.uid).get().then((user) async{
                                  if (user['requests'] != null &&
                                      user['requests'].length > 0) {
                                    var newRequest = user['requests'];
                                    if(newRequest.contains(friend['userId'])){
                                      await newRequest.remove(friend['userId']);
                                      await _fireStore
                                          .collection('users')
                                          .document(this.firebaseUser.uid)
                                          .setData({'requests':newRequest},
                                          merge: true);
                                    }
                                  }
                                });
                              },
                            ),
                          ),
                        );
                      }else{
                        return Card(
                          child: Container(
                            padding: EdgeInsets.all(20.0),
                            child: Center(
                              child: CupertinoActivityIndicator(),
                            ),
                          ),
                        );
                      }
                    },
                  );
                }).toList(),
              );
            }
          }
          else{
            return Center(
              child: CupertinoActivityIndicator(),
            );
          }
        },
      ),
    );
  }
}
