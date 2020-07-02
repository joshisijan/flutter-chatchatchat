import 'dart:io';

import 'package:chatchatchat/plugin/left_message.dart';
import 'package:chatchatchat/plugin/right_message.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

class MessagePage extends StatelessWidget {
  final FirebaseUser user;
  final String receipt;
  final String conversationId;

  MessagePage(
      {@required this.user,
      @required this.receipt,
      @required this.conversationId});

  final Firestore _fireStore = Firestore.instance;

  final TextEditingController _messageController = TextEditingController();

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: StreamBuilder(
          stream: _fireStore
              .collection('users')
              .where('userId', isEqualTo: receipt)
              .snapshots(),
          builder: (_, nameSnapshot) {
            if (nameSnapshot.hasData) {
              return Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    CircleAvatar(
                      radius: 12,
                      backgroundImage: NetworkImage(
                          nameSnapshot.data.documents[0]['photoUrl']),
                    ),
                    SizedBox(
                      width: 10.0,
                    ),
                    Text(nameSnapshot.data.documents[0]['name']),
                  ],
                ),
              );
            } else {
              return Text('Loading...');
            }
          },
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.more_vert),
            onPressed: () {

            },
          ),
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Expanded(
            child: StreamBuilder(
              stream: _fireStore
                  .collection('messages')
                  .where('conversationId', isEqualTo: this.conversationId)
                  .orderBy(
                    'createdAt',
                    descending: true,
                  )
                  .snapshots(),
              builder: (_, messageSnapshot) {
                if (messageSnapshot.hasData) {
                  if (messageSnapshot.data == null ||
                      messageSnapshot.data.documents.length <= 0) {
                    return Center(
                      child: Text(
                        'No messages yet',
                        style: Theme.of(context).textTheme.caption,
                      ),
                    );
                  } else {
                    var messageData = messageSnapshot.data.documents;
                    return ListView(
                      reverse: true,
                      children: messageData.map<Widget>((individualMessage) {
                            if (individualMessage['user'] == this.user.uid) {
                              return RightMessage(
                                message: individualMessage,
                                offline: individualMessage.metadata.hasPendingWrites,
                              );
                            } else {
                              return LeftMessage(
                                message: individualMessage,
                              );
                            }
                          }).toList() +
                          [
                            SizedBox(
                              height: 40.0,
                            )
                          ],
                    );
                  }
                } else {
                  return Center(
                    child: CupertinoActivityIndicator(),
                  );
                }
              },
            ),
          ),
          Container(
            child: Card(
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Container(
                      child: TextFormField(
                        maxLines: 3,
                        minLines: 1,
                        controller: _messageController,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 20.0, vertical: 10.0),
                          border: InputBorder.none,
                          hintText: 'Aa',
                        ),
                        keyboardType: TextInputType.text,
                        textInputAction: TextInputAction.send,
                        onEditingComplete: () {
                          _sendMessage(_messageController.text);
                        },
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.send),
                    color: Theme.of(context).buttonColor,
                    onPressed: () {
                      _sendMessage(_messageController.text);
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  _sendMessage(String x) async {
    x = x.trim();
    _fireStore
        .collection('conversations')
        .document(this.conversationId)
        .updateData({
      'lastMessage': x,
      'type' : 'text',
      'createdAt': FieldValue.serverTimestamp(),
      'user': this.user.uid,
      'seen': false,
    });
    _fireStore.collection('messages').document().setData({
      'conversationId': this.conversationId,
      'message': x,
      'type' : 'text',
      'user': this.user.uid,
      'createdAt': FieldValue.serverTimestamp(),
    }).then((value) {
      _fireStore
          .collection('conversations')
          .document(this.conversationId)
          .updateData({
        'lastMessage': x,
        'type' : 'text',
        'createdAt': FieldValue.serverTimestamp(),
        'user': this.user.uid,
        'seen': false,
      }).then((value) {});
    });
    _messageController.text = '';
  }
}
