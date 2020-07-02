import 'package:chatchatchat/pages/friend_requests.dart';
import 'package:chatchatchat/pages/message_page.dart';
import 'package:chatchatchat/pages/sent_requests.dart';
import 'package:chatchatchat/pages/search_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class FriendsContainer extends StatelessWidget {
  final FirebaseUser firebaseUser;

  FriendsContainer({@required this.firebaseUser});

  final Firestore _fireStore = Firestore.instance;

  @override
  Widget build(BuildContext context) {
    List<Widget> topButtonList = [
      Card(
        child: ListTile(
          dense: true,
          title: Text('Find new friends'),
          leading: Icon(Icons.search),
          onTap: () {
            showSearch(
              context: context,
              delegate: SearchPage(
                firebaseUser: this.firebaseUser,
              ),
            );
          },
        ),
      ),
      Card(
        child: ListTile(
          dense: true,
          title: Text('Friend requests'),
          leading: Icon(Icons.person),
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => FriendRequests(
                firebaseUser: this.firebaseUser,
              ),
            ));
          },
          trailing: StreamBuilder(
            stream: _fireStore.collection('users').where('requests',arrayContains: this.firebaseUser.uid).snapshots(),
            builder: (_, noSentSnapshot){
              if(noSentSnapshot.hasData){
                var data = noSentSnapshot.data.documents;
                return Chip(
                  label: Text(data.length.toString()),
                );
              }else{
                return Container(
                  child: CupertinoActivityIndicator(),
                );
              }
            },
          ),
        ),
      ),
      Card(
        child: ListTile(
          dense: true,
          title: Text('Sent friend requests'),
          leading: Icon(Icons.person_add),
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => SentRequests(
                firebaseUser: this.firebaseUser,
              ),
            ));
          },
          trailing: StreamBuilder(
            stream: _fireStore.collection('users').where('userId',isEqualTo: this.firebaseUser.uid).snapshots(),
            builder: (_, noSentSnapshot){
              if(noSentSnapshot.hasData){
                var data = noSentSnapshot.data.documents[0];
                return Chip(
                  label: Text(data['requests'].length.toString()),
                );
              }else{
                return Container(
                  child: CupertinoActivityIndicator(),
                );
              }
            },
          ),
        ),
      ),
    ];

    Widget friendsTitle = Container(
      padding: EdgeInsets.all(20.0),
      alignment: Alignment.center,
      child: Wrap(
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: <Widget>[
          Text(
            'Friends',
            style: TextStyle(
              color: Theme.of(context).textTheme.caption.color,
              fontWeight: FontWeight.bold,
              fontSize:
              Theme.of(context).textTheme.title.fontSize,
            ),
          ),
          SizedBox(
            width: 20.0,
          ),
          StreamBuilder(
            stream: _fireStore.collection('users').where('userId', isEqualTo: this.firebaseUser.uid).snapshots(),
            builder: (_, friendCount){
              if(friendCount.hasData){
                var data = friendCount.data.documents[0];
                return Chip(
                  label: Text(data['friends'].length.toString()),
                );
                return Text('ss');
              }else{
                return Container(
                  padding: EdgeInsets.all(20.0),
                  child: CupertinoActivityIndicator(),
                );
              }
            },
          ),
        ],
      ),
    );

    return Container(
      key: PageStorageKey('friends_container_key'),
      margin: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top,
      ),
      child: StreamBuilder(
        stream: _fireStore
            .collection('users')
            .where('userId', isEqualTo: this.firebaseUser.uid)
            .snapshots(),
        builder: (_, friendsSnapshot) {
          if (friendsSnapshot.hasData) {
            var friendsData = friendsSnapshot.data.documents[0];
            if (friendsData != null) {
              if (friendsData['friends'] == null ||
                  friendsData['friends'].length <= 0) {
                return ListView(
                  children: topButtonList +
                      <Widget>[
                        friendsTitle,
                        Card(
                          child: ListTile(
                            title: Text(
                              'No friends yet',
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ],
                );
              } else {
                return ListView(
                  children: topButtonList +
                      <Widget>[
                      friendsTitle,
                      ] +
                      friendsData['friends'].map<Widget>((friend) {
                        return StreamBuilder(
                          stream: _fireStore
                              .collection('users')
                              .document(friend)
                              .get()
                              .asStream(),
                          builder: (_, friendSnapshot) {
                            if (friendSnapshot.hasData) {
                              var friendData = friendSnapshot.data;
                              return Card(
                                child: ListTile(
                                  title: Text(friendData['name']),
                                  subtitle: Text(friendData['email']),
                                  leading: CircleAvatar(
                                    backgroundImage:
                                        NetworkImage(friendData['photoUrl']),
                                  ),
                                  trailing: IconButton(
                                    icon: Icon(Icons.message),
                                    onPressed: (){
                                      startConversation(this.firebaseUser, friendData['userId'], context);
                                    },
                                  ),
                                  onTap: () {},
                                ),
                              );
                            } else {
                              return ListTile(
                                title: Center(
                                  child: CupertinoActivityIndicator(),
                                ),
                              );
                            }
                          },
                        );
                      }).toList(),
                );
              }
            } else {
              return ListView(
                children: topButtonList +
                    <Widget>[
                      friendsTitle,
                      Container(
                        padding: EdgeInsets.all(20.0),
                        child: CupertinoActivityIndicator(),
                      ),
                    ],
              );
            }
          } else {
            return ListView(
              children: topButtonList +
                  <Widget>[
                    friendsTitle,
                    Container(
                      padding: EdgeInsets.all(20.0),
                      child: CupertinoActivityIndicator(),
                    ),
                  ],
            );
          }
        },
      ),
    );
  }

  startConversation(FirebaseUser user, String receipt, BuildContext context) async {
    await _fireStore.collection('conversations').where('participants', arrayContains: user.uid).getDocuments().then((document){
      if(document == null || document.documents.length <= 0){
        _fireStore.collection('conversations').document().setData({
          'participants' : [
            user.uid,
            receipt
          ],
          'user' : user.uid,
          'createdAt' : FieldValue.serverTimestamp(),
          'seen' : false,
          'type' : 'text',
          'lastMessage' : '👋',
        }, merge: true).then((value){
          _fireStore.collection('conversations').where('participants', arrayContains: user.uid).getDocuments().then((value2){
            value2.documents.forEach((each) async {
              if(each['participants'].contains(receipt)){
                await _fireStore.collection('messages').document().setData({
                  'conversationId': each.documentID,
                  'message': '👋',
                  'type' : 'text',
                  'user': this.firebaseUser.uid,
                  'createdAt': FieldValue.serverTimestamp(),
                });
              }
            });
          });
        });
      }
      else{
        var total = document.documents.length;
        var temp = 0;
        document.documents.forEach((conversations){
          if(!conversations['participants'].contains(receipt)){
            temp += 1;
          }
        });
        var diff = total - temp;
        if(diff <= 0){
          _fireStore.collection('conversations').document().setData({
            'participants' : [
              user.uid,
              receipt
            ],
            'user' : user.uid,
            'lastMessage' : '👋',
            'type' : 'text',
            'createdAt' : FieldValue.serverTimestamp(),
            'seen' : false,
          }, merge: true).then((value){
            _fireStore.collection('conversations').where('participants', arrayContains: user.uid).getDocuments().then((value2){
              value2.documents.forEach((each) async {
                if(each['participants'].contains(receipt)){
                  await _fireStore.collection('messages').document().setData({
                    'conversationId': each.documentID,
                    'message': '👋',
                    'user': this.firebaseUser.uid,
                    'createdAt': FieldValue.serverTimestamp(),
                  });
                }
              });
            });
          });
        }
      }
    });
    _fireStore.collection('conversations').where('participants',arrayContains: user.uid).getDocuments().then((value){
      value.documents.forEach((data){
        if(data['participants'].contains(receipt)){
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => MessagePage(
              user: user,
              receipt: receipt,
              conversationId: data.documentID,
            ),
          ));
        }
      });
    });
  }

}
