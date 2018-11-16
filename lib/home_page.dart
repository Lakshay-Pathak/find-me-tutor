import 'package:flutter/material.dart';
import 'auth_provider.dart';
import 'package:map_view/map_view.dart';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

var apiKey = "AIzaSyBlUWeW6NpkVWZ5yauucWt-RjQCE_pe6GM";
String email;
String usertype1;
List<Marker> markers = <Marker>[];
String usertype;
Future<String> currentUser() async {
  FirebaseUser user = await FirebaseAuth.instance.currentUser();
  return user?.email;
}

class HomePage extends StatefulWidget {
  HomePage({this.onSignedOut});
  final VoidCallback onSignedOut;
  void signOut(BuildContext context) async {
    try {
      var auth = AuthProvider.of(context).auth;
      await auth.signOut();
      onSignedOut();
    } catch (e) {
      print(e);
    }
  }

  @override
  _HomePageState createState() => new _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final MapView mapView = new MapView();

  void loadMap() {
    if (usertype == 'Student') {
      Firestore.instance
          .collection('users')
          .where('usertype', isEqualTo: 'Tutor')
          .snapshots()
          .listen((data) {
        for (int i = 0; i < data.documents.length; i++) {
          markers.add(new Marker('$i+1', data.documents[i]['name'],
              data.documents[i]['latitude'], data.documents[i]['longitude'],
              color: Colors.amber));
        }
      });
    } else {
      Firestore.instance
          .collection('users')
          .where('usertype', isEqualTo: 'Student')
          .snapshots()
          .listen((data) {
        for (int i = 0; i < data.documents.length; i++) {
          markers.add(new Marker('$i+1', data.documents[i]['name'],
              data.documents[i]['latitude'], data.documents[i]['longitude'],
              color: Colors.amber));
        }
      });
    }
  }

  void displayMap() {
    loadMap();
    MapView.setApiKey(apiKey);
    mapView.show(
        new MapOptions(
            showUserLocation: true,
            showMyLocationButton: true,
            title: "Google Maps",
            initialCameraPosition:
                new CameraPosition(new Location(30.91, 75.84), 12.0)),
        toolbarActions: <ToolbarAction>[new ToolbarAction("Close", 1)]);
    mapView.setMarkers(markers);

    var sub = mapView.onToolbarAction.listen((id) {
      if (id == 1) {
        mapView.dismiss();
      }
    });
    mapView.onMapTapped.listen((_) async {
      setState(() {
        mapView.setMarkers(markers);
        mapView.zoomToFit(padding: 100);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    foo();
    _getUtype();
    print(email + usertype);
    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome'),
        actions: <Widget>[
          FlatButton(
              child: Text('Logout',
                  style: TextStyle(fontSize: 17.0, color: Colors.white)),
              onPressed: () => widget.signOut(context))
        ],
      ),
      body: // new MarkerList(),

          Container(
        child: Center(
          child: RaisedButton(
              child: Text('CLICK ME'),
              color: Colors.red,
              textColor: Colors.white,
              elevation: 10.0,
              onPressed: displayMap),
        ),
      ),
    );
  }
}

foo() async {
  email = await currentUser();
}

_getUtype() async {
  Firestore.instance
      .collection('users')
      .where('email', isEqualTo: '$email')
      .snapshots()
      .listen((data) {
    usertype = data.documents[0]['usertype'];
  });
}
