import 'package:flutter/material.dart';
import 'auth_provider.dart';
import 'package:map_view/map_view.dart';

var apiKey = "AIzaSyBlUWeW6NpkVWZ5yauucWt-RjQCE_pe6GM";

final MapView mapView = new MapView();

void displayMap() {
  MapView.setApiKey(apiKey);
  mapView
      .show(new MapOptions(showUserLocation: true, showMyLocationButton: true));
}

class HomePage extends StatelessWidget {
  HomePage({this.onSignedOut});
  final VoidCallback onSignedOut;

  void _signOut(BuildContext context) async {
    try {
      var auth = AuthProvider.of(context).auth;
      await auth.signOut();
      onSignedOut();
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Welcome'),
          actions: <Widget>[
            FlatButton(
                child: Text('Logout',
                    style: TextStyle(fontSize: 17.0, color: Colors.white)),
                onPressed: () => _signOut(context))
          ],
        ),
        body: Container(
            child: Center(
          child: RaisedButton(
            child: Text('Tap me'),
            color: Colors.blue,
            textColor: Colors.white,
            elevation: 7.0,
            onPressed: displayMap,
          ),
        )));
  }
}
