import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';


class AccountContainer extends StatelessWidget {

  final FirebaseUser firebaseUser;

  AccountContainer({@required this.firebaseUser});

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  final GoogleSignIn _googleSignIn = GoogleSignIn();

  @override
  Widget build(BuildContext context) {
    return Container(
      key: PageStorageKey('account_container_key'),
      margin: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top,
      ),
      child: ListView(
        children: <Widget>[
         Container(
           child: Column(
             children: <Widget>[
               CircleAvatar(
                 backgroundImage: NetworkImage(this.firebaseUser.photoUrl),
                 radius: 40.0,
               ),
               SizedBox(
                 height: 15.0,
               ),
               Text(
                 this.firebaseUser.displayName,
                 style: Theme.of(context).textTheme.title.copyWith(
                   fontWeight: FontWeight.bold,
                 ),
               ),
               SizedBox(
                 height: 15.0,
               ),
               Text(
                 this.firebaseUser.email,
                 style: Theme.of(context).textTheme.caption,
               ),
             ],
           ),
         ),
          SizedBox(
            height: 15.0,
          ),
          Card(
            child: ListTile(
              leading: Icon(Icons.close),
              title: Text('Logout'),
              onTap: (){
               _signOut();
              },
            ),
          ),
        ],
      ),
    );
  }
  _signOut() async {
    _firebaseAuth.signOut().then((value) async {
      await _googleSignIn.disconnect();
    });
  }
}
