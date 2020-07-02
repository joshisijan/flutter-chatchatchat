import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../plugin/error_message.dart';



// ignore: must_be_immutable
class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final SvgPicture googleLogoSvg = SvgPicture.string(
    '''<svg viewBox="0 0 533.5 544.3" xmlns="http://www.w3.org/2000/svg"><path d="M533.5 278.4c0-18.5-1.5-37.1-4.7-55.3H272.1v104.8h147c-6.1 33.8-25.7 63.7-54.4 82.7v68h87.7c51.5-47.4 81.1-117.4 81.1-200.2z" fill="#4285f4"/><path d="M272.1 544.3c73.4 0 135.3-24.1 180.4-65.7l-87.7-68c-24.4 16.6-55.9 26-92.6 26-71 0-131.2-47.9-152.8-112.3H28.9v70.1c46.2 91.9 140.3 149.9 243.2 149.9z" fill="#34a853"/><path d="M119.3 324.3c-11.4-33.8-11.4-70.4 0-104.2V150H28.9c-38.6 76.9-38.6 167.5 0 244.4l90.4-70.1z" fill="#fbbc04"/><path d="M272.1 107.7c38.8-.6 76.3 14 104.4 40.8l77.7-77.7C405 24.6 339.7-.8 272.1 0 169.2 0 75.1 58 28.9 150l90.4 70.1c21.5-64.5 81.8-112.4 152.8-112.4z" fill="#ea4335"/></svg>''',
    width: 24.0,
    height: 24.0,
    colorBlendMode: BlendMode.color,
  );

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  final Firestore _fireStore = Firestore.instance;

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

  final GoogleSignIn _googleSignIn = GoogleSignIn();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Center(
          child: Container(
            width: double.maxFinite,
            padding: EdgeInsets.all(20.0),
            child: RawMaterialButton(
              padding: EdgeInsets.all(15.0),
              fillColor: Theme.of(context).buttonColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(100.0),
              ),
              child: Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                children: <Widget>[
                  Container(
                    child: googleLogoSvg,
                    width: 24.0,
                    height: 24.0,
                  ),
                  SizedBox(
                    width: 20.0,
                  ),
                  Text(
                    'Continue with Google account',
                    style: TextStyle(
                      color: Theme.of(context).textTheme.caption.color,
                    ),
                  ),
                ],
              ),
              onPressed: () {
                _signInWithGoogle().catchError((e) {
                  switch (e.code) {
                    case 'ERROR_NETWORK_REQUEST_FAILED':
                    case 'network_error':
                      showError(context,'Please check your internet connection and try again.');
                      break;
                    default:
                      showError(context,'An error occoured. Please retry logging in.');
                  }
                });
              },
            ),
          ),
        ),
      ),
    );
  }

  _signInWithGoogle() async {
    final GoogleSignInAccount googleSignInAccount =
    await _googleSignIn.signIn();
    final GoogleSignInAuthentication googleSignInAuthentication =
    await googleSignInAccount.authentication;

    final AuthCredential credential = GoogleAuthProvider.getCredential(
      idToken: googleSignInAuthentication.idToken,
      accessToken: googleSignInAuthentication.accessToken,
    );

    await _firebaseAuth.signInWithCredential(credential);
  }

  _signOut() async {
    _googleSignIn.disconnect().then((value) async {
      await _firebaseAuth.signOut();
    });
  }
}
