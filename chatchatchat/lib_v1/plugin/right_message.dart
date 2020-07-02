import 'dart:async';

import 'package:time_formatter/time_formatter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';


class RightMessage extends StatefulWidget {

  final DocumentSnapshot message;
  final bool offline;

  RightMessage({@required this.message, this.offline = false});

  @override
  _RightMessageState createState() => _RightMessageState();
}

class _RightMessageState extends State<RightMessage> {

  bool timeShown = false;

  @override
  Widget build(BuildContext context) {

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        GestureDetector(
          onTap: (){
            setState(() {
              this.timeShown = true;
            });
            Timer(Duration(seconds: 2), (){
              setState(() {
                this.timeShown = false;
              });
            });
          },
          child: AnimatedContainer(
            duration: Duration(microseconds: 350),
            padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
            margin: EdgeInsets.only(
              right: 15.0,
              top: 5.0,
              left: MediaQuery.of(context).size.width * 0.4,
            ),
            decoration: BoxDecoration(
              color: this.timeShown ? Colors.blue.withAlpha(150) : Colors.blue,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(15.0),
                bottomLeft: Radius.circular(15.0),
                topRight: Radius.circular(15.0),
                bottomRight: Radius.circular(15.0),
              ),
            ),
            child: Text(this.widget.message['message'].toString()),
          ),
        ),

        this.widget.offline ? AnimatedContainer(
          duration: Duration(microseconds: 350),
          width: double.maxFinite,
          alignment: Alignment.topRight,
          margin: EdgeInsets.only(
            top: 5.0,
            right: 17,
          ),
          child: CupertinoActivityIndicator(
            radius: 8.0,
          ),
        ) : SizedBox(),

        !this.widget.offline ? this.timeShown ? AnimatedContainer(
          duration: Duration(microseconds: 350),
          width: double.maxFinite,
          alignment: Alignment.topRight,
          margin: EdgeInsets.only(
            right: 17,
          ),
          child: Text(
            formatTime(this.widget.message['createdAt'].seconds * 1000),
            style: Theme.of(context).textTheme.caption,
          ),
        ) : SizedBox() : SizedBox(),
      ],
    );
  }
}
