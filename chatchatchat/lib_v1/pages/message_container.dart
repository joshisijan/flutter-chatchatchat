import 'package:chatchatchat/pages/message_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:time_formatter/time_formatter.dart';

class MessagesContainer extends StatelessWidget {
  final FirebaseUser firebaseUser;
  final PageController pageController;

  MessagesContainer(
      {@required this.firebaseUser, @required this.pageController});

  final Firestore _fireStore = Firestore.instance;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: PageStorageKey('messages_container_key'),
      margin: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top,
      ),
      child: StreamBuilder(
        stream: _fireStore
            .collection('conversations')
            .where('participants', arrayContains: this.firebaseUser.uid).orderBy('createdAt',descending: true,)
            .snapshots(),
        builder: (_, messageSnapshot) {
          if (messageSnapshot.hasData) {
            var conversationData = messageSnapshot.data.documents;
            if (conversationData.length > 0) {
              return ListView(
                children: conversationData.map<Widget>((message) {
                  var messageData = message.data;
                  var tempId = messageData['participants'];
                  tempId.remove(this.firebaseUser.uid);
                  var receiptId = tempId[0];
                  return StreamBuilder(
                    stream: _fireStore
                        .collection('users')
                        .where('userId', isEqualTo: receiptId)
                        .snapshots(),
                    builder: (_, messageUser) {
                      if (messageUser.hasData) {
                        var userData = messageUser.data.documents[0];
                        var normalCardElevation = Theme.of(context).cardTheme.elevation;
                        return Stack(
                          children: <Widget>[
                            Card(
                              elevation: messageData['user'] == this.firebaseUser.uid ? normalCardElevation : messageData['seen'] ? normalCardElevation : 10.0,
                              child: ListTile(
                                isThreeLine: true,
                                title: Text(
                                  userData['name'],
                                  style: TextStyle(
                                    fontWeight: messageData['user'] == this.firebaseUser.uid ? FontWeight.normal : messageData['seen'] ? FontWeight.normal : FontWeight.bold,
                                  ),
                                ),
                                subtitle: Row(
                                  children: <Widget>[
                                    message.metadata.hasPendingWrites ? Container(
                                      margin: EdgeInsets.only(right: 5.0),
                                      child: CupertinoActivityIndicator(
                                        radius: 8.0,
                                      ),
                                    ) : SizedBox(),
                                    Text(
                                        messageData['lastMessage'].toString(),
                                        style: TextStyle(
                                          fontWeight: messageData['user'] ==
                                              this.firebaseUser.uid
                                              ? FontWeight.normal
                                              : messageData['seen']
                                              ? FontWeight.normal
                                              : FontWeight.bold ,
                                        ),
                                    ),
                                  ],
                                ),
                                leading: CircleAvatar(
                                  backgroundImage:
                                  NetworkImage(userData['photoUrl']),
                                ),
                                onTap: (){
                                  Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) => MessagePage(
                                      user: this.firebaseUser,
                                      receipt: userData['userId'],
                                      conversationId: message.documentID,
                                    ),
                                  )).then((value) async {
                                    _fireStore.collection('conversations').document(message.documentID).get().then((value) async {
                                      if(value.data['user'] != this.firebaseUser.uid){
                                        _fireStore.collection('conversations').document(message.documentID).setData({'seen' : true}, merge: true);
                                      }
                                    });
                                  });
                                },
                              ),
                            ),
                            Positioned(
                              bottom: 20.0,
                              right: 20.0,
                              child: messageData['createdAt'] == null ?
                              CupertinoActivityIndicator(
                                radius: 8.0,
                              )
                                  :
                              Text(
                                formatTime(messageData['createdAt'].seconds * 1000),
                                style: Theme.of(context).textTheme.caption.copyWith(
                                  fontWeight: messageData['user'] == this.firebaseUser.uid ? FontWeight.normal : messageData['seen'] ? FontWeight.normal : FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        );
                      } else {
                        return Card(
                          child: Container(
                            padding: EdgeInsets.all(20.0),
                            child: CupertinoActivityIndicator(),
                          ),
                        );
                      }
                    },
                  );
                }).toList(),
              );
            } else {
              return Center(
                child: Card(
                  child: ListTile(
                    dense: true,
                    title: Wrap(
                      alignment: WrapAlignment.center,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: <Widget>[
                        Icon(Icons.message),
                        SizedBox(
                          width: 20.0,
                        ),
                        Text(
                          'Start a conversation',
                        ),
                      ],
                    ),
                    onTap: () {
                      this.pageController.animateToPage(0,
                          duration: Duration(microseconds: 350),
                          curve: Curves.easeInCubic);
                    },
                  ),
                ),
              );
            }
          } else {
            return Center(
              child: CupertinoActivityIndicator(),
            );
          }
        },
      ),
    );
  }

}

