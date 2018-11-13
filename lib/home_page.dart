import 'package:flutter/material.dart';
import 'auth_provider.dart';
import 'package:map_view/map_view.dart';
import 'googlemaps.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

var apiKey = "AIzaSyBlUWeW6NpkVWZ5yauucWt-RjQCE_pe6GM";

List<Marker> markers = <Marker>[];

/*class MarkerList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new StreamBuilder(
      stream: Firestore.instance
          .collection('users')
          .where('usertype', isEqualTo: 'Tutor')
          .snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) return new Text('Loading...');
        return new ListView(
          children: snapshot.data.documents.map((document) {
            return new ListTile(
              title: new Text(document['name']),
              subtitle: new Text(document['email']),
            );
          }).toList(),
        );
      },
    );
  }
}*/

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
    mapView.onMapTapped.listen((_) {
      setState(() {
        mapView.setMarkers(markers);
        mapView.zoomToFit(padding: 100);
      });
    });
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
              onPressed: () => widget.signOut(context))
        ],
      ),
      body: // new MarkerList(),

          Container(
        child: Center(
          child: RaisedButton(
              child: Text('Tap me'),
              color: Colors.red,
              textColor: Colors.white,
              elevation: 7.0,
              onPressed: displayMap),
        ),
      ),
    );
  }
}
