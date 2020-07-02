import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';


class FriendRequests extends StatelessWidget {

  final FirebaseUser firebaseUser;

  FriendRequests({ @required this.firebaseUser });

  final Firestore _fireStore = Firestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            'Friend Requests'
        ),
        centerTitle: true,
      ),
      body: StreamBuilder(
        stream: _fireStore.collection('users').where('requests',arrayContains: this.firebaseUser.uid).snapshots(),
        builder: (_, snapshot){
          if(snapshot.hasData){
            var data = snapshot.data.documents;
            if(data.length <= 0){
              return Center(
                child: Text('You have no friend requests'),
              );
            }else{
              return ListView(
                children: data.map<Widget>((friend){
                  return ListTile(
                    title: Text(friend['name']),
                    subtitle: Text(friend['email']),
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(friend['photoUrl']),
                    ),
                    trailing: DropdownButton(
                      iconSize: 0.0,
                      underline: SizedBox(),
                      hint: Chip(
                        label: Text('Respond'),
                      ),
                      autofocus: false,
                      onChanged: (value){
                        if(value == 'rejected'){
                          _fireStore.collection('users').document(friend['userId']).get().then((user) async{
                            if (user['requests'] != null &&
                                user['requests'].length > 0) {
                              var newRequest = user['requests'];
                              if(newRequest.contains(this.firebaseUser.uid)){
                                await newRequest.remove(this.firebaseUser.uid);
                                await _fireStore
                                    .collection('users')
                                    .document(user['userId'])
                                    .setData({'requests':newRequest},
                                    merge: true);
                              }
                            }
                          });
                        }else{
                          _fireStore.collection('users').document(friend['userId']).get().then((user) async{
                            if (user['requests'] != null &&
                                user['requests'].length > 0) {
                              var newRequest = user['requests'];
                              if(newRequest.contains(this.firebaseUser.uid)){
                                await newRequest.remove(this.firebaseUser.uid);
                                await _fireStore
                                    .collection('users')
                                    .document(user['userId'])
                                    .setData({'requests':newRequest},
                                    merge: true).then((removed){
                                  _fireStore.collection('users').document(user['userId']).get().then((user1) async {
                                    var oldFriends = user1['friends'];
                                    if(!oldFriends.contains(this.firebaseUser.uid)){
                                      var newFriends = oldFriends + [this.firebaseUser.uid];
                                      await _fireStore.collection('users').document(user['userId']).setData({'friends' : newFriends},merge: true);
                                    }
                                  }).then((onFirstChanged){_fireStore.collection('users').document(this.firebaseUser.uid).get().then((user2) async {
                                    var oldFriends = user2['friends'];
                                    if(!oldFriends.contains(user['userId'])){
                                      var newFriends = oldFriends + [user['userId']];
                                      await _fireStore.collection('users').document(this.firebaseUser.uid).setData({'friends' : newFriends},merge: true);
                                    }
                                  });
                                  });

                                });
                              }
                            }
                          });
                        }
                      },
                      items: <DropdownMenuItem>[
                        DropdownMenuItem(
                          value: 'accepted',
                          child: Chip(
                            label: Text('Accept'),
                          ),
                        ),
                        DropdownMenuItem(
                          value: 'rejected',
                          child: Chip(
                            label: Text('Reject'),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
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
