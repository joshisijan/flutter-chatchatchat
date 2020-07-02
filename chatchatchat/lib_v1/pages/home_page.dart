import 'package:chatchatchat/pages/account_container.dart';
import 'package:chatchatchat/pages/friends_container.dart';
import 'package:chatchatchat/pages/message_container.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

// ignore: must_be_immutable
class HomePage extends StatefulWidget {
  final FirebaseUser firebaseUser;

  HomePage({@required this.firebaseUser});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  PageController _pageController;

  final PageStorageBucket bucket = PageStorageBucket();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

  int _currentIndex = 1;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _pageController = PageController(
      initialPage: 1,
      keepPage: true,
    );

    _firebaseMessaging.configure();

    _firebaseMessaging.requestNotificationPermissions(
      IosNotificationSettings(
        alert: true,
        badge: true,
        provisional: true,
        sound: true,
      ),
    );

  }

  @override
  void dispose() {
    // TODO: implement dispose
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(45.0),
          child: Container(
            padding: EdgeInsets.only(
              bottom: 15.0,
              top: 20.0,
            ),
            child: BottomNavigationBar(
              backgroundColor: Colors.transparent,
              elevation: 0.0,
              type: BottomNavigationBarType.fixed,
              onTap: (index) {
                setState(() {
                  _currentIndex = index;
                  _pageController.animateToPage(index, duration: Duration(microseconds: 350), curve: Curves.easeInCubic);
                });
              },
              currentIndex: _currentIndex,
              selectedFontSize: Theme.of(context).textTheme.caption.fontSize,
              showSelectedLabels: false,
              showUnselectedLabels: false,
              items: <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                  icon: Icon(Icons.people_outline),
                  activeIcon: Icon(Icons.people),
                  title: Text('Friends'),
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.message),
                  title: Text('Messages'),
                ),
                BottomNavigationBarItem(
                  icon: CircleAvatar(
                    backgroundColor: Colors.transparent,
                    child: CircleAvatar(
                      radius: 14.0,
                      backgroundImage: NetworkImage(this.widget.firebaseUser.photoUrl),
                    ),
                  ),
                  activeIcon: CircleAvatar(
                    child: CircleAvatar(
                      radius: 14.0,
                      backgroundImage: NetworkImage(this.widget.firebaseUser.photoUrl),
                    ),
                  ),
                  title: Text('My Account'),
                ),
              ],
            ),
          ),
        ),
      ),
      body: PageView(
        controller: _pageController,
        onPageChanged: (index){
          setState(() {
            _currentIndex = index;
          });
        },
        children: <Widget>[
          FriendsContainer(
            firebaseUser: this.widget.firebaseUser,
          ),
          MessagesContainer(
            firebaseUser: this.widget.firebaseUser,
            pageController: _pageController,
          ),
          AccountContainer(
            firebaseUser: this.widget.firebaseUser,
          ),
        ],
      ),
    );
  }

}
