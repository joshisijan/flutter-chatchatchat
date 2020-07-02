import 'dart:async';

import 'package:time_formatter/time_formatter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';


class LeftMessage extends StatefulWidget {

  final DocumentSnapshot message;

  LeftMessage({@required this.message});

  @override
  _LeftMessageState createState() => _LeftMessageState();
}

class _LeftMessageState extends State<LeftMessage> {

  bool timeShown = false;

  @override
  Widget build(BuildContext context) {

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
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
              left: 15.0,
              top: 5.0,
              right: MediaQuery.of(context).size.width * 0.4,
            ),
            decoration: BoxDecoration(
              color: this.timeShown ? Colors.teal.withAlpha(150) : Colors.teal,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(15.0),
                bottomRight: Radius.circular(15.0),
                topRight: Radius.circular(15.0),
                topLeft: Radius.circular(15.0),
              ),
            ),
            child: Text(this.widget.message['message'].toString()),
          ),
        ),
        this.timeShown ? AnimatedContainer(
          duration: Duration(microseconds: 350),
          width: double.maxFinite,
          alignment: Alignment.topLeft,
          margin: EdgeInsets.only(
            left: 17,
          ),
          child: Text(
            formatTime(this.widget.message['createdAt'].seconds * 1000),
            style: Theme.of(context).textTheme.caption,
          ),
        ) : SizedBox(),
      ],
    );
  }
}
