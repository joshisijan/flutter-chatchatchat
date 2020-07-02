import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SearchPage extends SearchDelegate {
  final FirebaseUser firebaseUser;

  SearchPage({@required this.firebaseUser});

  final Firestore _fireStore = Firestore.instance;

  @override
  List<Widget> buildActions(BuildContext context) {
    // TODO: implement buildActions
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    // TODO: implement buildLeading
    return BackButton();
  }

  @override
  Widget buildResults(BuildContext context) {
    // TODO: implement buildResults
    return _searchResult(context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    // TODO: implement buildSuggestions
    return _searchResult(context);
  }

  _searchResult(BuildContext context) {
    return StreamBuilder(
      stream: _fireStore
          .collection('users')
          .where('keywords', arrayContains: query)
          .snapshots(),
      builder: (_, querySnapshot) {
        if (querySnapshot.hasData) {
          var queryData = querySnapshot.data.documents;
          if (queryData != null && queryData.length > 0) {
            return ListView(
              children: queryData.map<Widget>((queryListData) {
                return Card(
                  child: ListTile(
                    isThreeLine: true,
                    title: Text(queryListData['name']),
                    subtitle: Text(queryListData['email']),
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(queryListData['photoUrl']),
                    ),
                    trailing: StreamBuilder(
                      stream: _fireStore
                          .collection('users')
                          .document(this.firebaseUser.uid)
                          .get()
                          .asStream(),
                      builder: (_, friendSearchSnapshot) {
                        if (friendSearchSnapshot.hasData) {
                          var friendSearchData = friendSearchSnapshot.data;
                          if (queryListData['userId'] ==
                              this.firebaseUser.uid) {
                            return Container(
                              padding: EdgeInsets.all(20.0),
                              child: Icon(Icons.account_circle),
                            );
                          }
                          else {
                            if(queryListData['requests'].contains(this.firebaseUser.uid)){
                              return DropdownButton(
                                iconSize: 0.0,
                                underline: SizedBox(),
                                hint: Chip(
                                  label: Text('Respond'),
                                ),
                                autofocus: false,
                                onChanged: (value){
                                 if(value == 'rejected'){
                                   _fireStore.collection('users').document(queryListData['userId']).get().then((user) async{
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
                                   _fireStore.collection('users').document(queryListData['userId']).get().then((user) async{
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
                              );
                            }
                            else{
                              if (friendSearchData['requests']
                                  .contains(queryListData['userId'])) {
                                return RawMaterialButton(
                                  child: Chip(
                                    label: Text('Cancle'),
                                  ),
                                  onPressed: () {
                                    _fireStore
                                        .collection('users')
                                        .document(this.firebaseUser.uid)
                                        .get()
                                        .then((user) async {
                                      if (user['requests'] != null &&
                                          user['requests'].length > 0) {
                                        var newRequest = user['requests'];
                                        if(newRequest.contains(queryListData['userId'])){
                                          await newRequest.remove(queryListData['userId']);
                                          await _fireStore
                                              .collection('users')
                                              .document(this.firebaseUser.uid)
                                              .setData({'requests':newRequest},
                                              merge: true);
                                        }
                                      }
                                    });
                                  },
                                );
                              }
                              else {
                                if(friendSearchData['friends'].contains(queryListData['userId'])){
                                  return Chip(
                                    label: Text('Friends'),
                                  );
                                }else{
                                  return RawMaterialButton(
                                    child: Chip(
                                      label: Text('Add friend'),
                                    ),
                                    onPressed: () {
                                      _fireStore
                                          .collection('users')
                                          .document(this.firebaseUser.uid)
                                          .get()
                                          .then((user) async {
                                        if (user['requests'] == null ||
                                            user['requests'].length <= 0) {
                                          _fireStore
                                              .collection('users')
                                              .document(this.firebaseUser.uid)
                                              .setData({
                                            'requests': [queryListData['userId']]
                                          }, merge: true);
                                        } else {
                                          var oldRequest = user['requests'];
                                          if(!oldRequest.contains(queryListData['userId'])){
                                            var newRequest =
                                                oldRequest + [queryListData['userId']];
                                            await _fireStore
                                                .collection('users')
                                                .document(this.firebaseUser.uid)
                                                .setData({'requests':newRequest},
                                                merge: true);
                                          }
                                        }
                                      });
                                    },
                                  );
                                }
                              }
                            }
                          }
                        } else {
                          return Container(
                            padding: EdgeInsets.all(20.0),
                            child: CupertinoActivityIndicator(),
                          );
                        }
                      },
                    ),
                    onTap: () {},
                  ),
                );
              }).toList(),
            );
          } else {
            return Center(
              child: Text('No user found'),
            );
          }
        } else {
          return Center(
            child: CupertinoActivityIndicator(),
          );
        }
      },
    );
  }

  @override
  // TODO: implement searchFieldLabel
  String get searchFieldLabel => 'Find new friends';

  @override
  ThemeData appBarTheme(BuildContext context) {
    // TODO: implement appBarTheme
    return super.appBarTheme(context).copyWith(
          unselectedWidgetColor: ThemeData.dark().unselectedWidgetColor,
          typography: ThemeData.dark().typography,
          tooltipTheme: ThemeData.dark().tooltipTheme,
          toggleButtonsTheme: ThemeData.dark().toggleButtonsTheme,
          toggleableActiveColor: ThemeData.dark().toggleableActiveColor,
          textSelectionHandleColor: ThemeData.dark().textSelectionHandleColor,
          textSelectionColor: ThemeData.dark().textSelectionColor,
          tabBarTheme: ThemeData.dark().tabBarTheme,
          splashColor: ThemeData.dark().splashColor,
          splashFactory: ThemeData.dark().splashFactory,
          snackBarTheme: ThemeData.dark().snackBarTheme,
          sliderTheme: ThemeData.dark().sliderTheme,
          selectedRowColor: ThemeData.dark().selectedRowColor,
          secondaryHeaderColor: ThemeData.dark().secondaryHeaderColor,
          scaffoldBackgroundColor: ThemeData.dark().scaffoldBackgroundColor,
          primaryTextTheme: ThemeData.dark().primaryTextTheme,
          primaryIconTheme: ThemeData.dark().primaryIconTheme,
          primaryColorLight: ThemeData.dark().primaryColorLight,
          primaryColorDark: ThemeData.dark().primaryColorDark,
          primaryColorBrightness: ThemeData.dark().primaryColorBrightness,
          popupMenuTheme: ThemeData.dark().popupMenuTheme,
          platform: ThemeData.dark().platform,
          pageTransitionsTheme: ThemeData.dark().pageTransitionsTheme,
          materialTapTargetSize: ThemeData.dark().materialTapTargetSize,
          indicatorColor: ThemeData.dark().indicatorColor,
          hoverColor: ThemeData.dark().hoverColor,
          highlightColor: ThemeData.dark().highlightColor,
          focusColor: ThemeData.dark().focusColor,
          floatingActionButtonTheme: ThemeData.dark().floatingActionButtonTheme,
          errorColor: ThemeData.dark().errorColor,
          dividerTheme: ThemeData.dark().dividerTheme,
          dividerColor: ThemeData.dark().disabledColor,
          disabledColor: ThemeData.dark().disabledColor,
          dialogTheme: ThemeData.dark().dialogTheme,
          dialogBackgroundColor: ThemeData.dark().dialogBackgroundColor,
          cursorColor: ThemeData.dark().cursorColor,
          cupertinoOverrideTheme: ThemeData.dark().cupertinoOverrideTheme,
          chipTheme: ThemeData.dark().chipTheme,
          cardTheme: ThemeData.dark().cardTheme,
          cardColor: ThemeData.dark().cardColor,
          canvasColor: ThemeData.dark().canvasColor,
          buttonTheme: ThemeData.dark().buttonTheme,
          buttonBarTheme: ThemeData.dark().buttonBarTheme,
          brightness: ThemeData.dark().brightness,
          bottomSheetTheme: ThemeData.dark().bottomSheetTheme,
          bottomAppBarTheme: ThemeData.dark().bottomAppBarTheme,
          bottomAppBarColor: ThemeData.dark().bottomAppBarColor,
          bannerTheme: ThemeData.dark().bannerTheme,
          applyElevationOverlayColor:
              ThemeData.dark().applyElevationOverlayColor,
          accentTextTheme: ThemeData.dark().accentTextTheme,
          accentIconTheme: ThemeData.dark().accentIconTheme,
          accentColorBrightness: ThemeData.dark().accentColorBrightness,
          inputDecorationTheme: ThemeData.dark().inputDecorationTheme,
          accentColor: ThemeData.dark().accentColor,
          backgroundColor: ThemeData.dark().backgroundColor,
          buttonColor: ThemeData.dark().buttonColor,
          hintColor: ThemeData.dark().hintColor,
          iconTheme: ThemeData.dark().iconTheme,
          textTheme: ThemeData.dark().textTheme,
          appBarTheme: ThemeData.dark().appBarTheme,
          colorScheme: ThemeData.dark().colorScheme,
          primaryColor: ThemeData.dark().primaryColor,
        );
  }
}
