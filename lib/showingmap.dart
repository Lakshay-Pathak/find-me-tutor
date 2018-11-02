import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong/latlong.dart';
import 'package:geocoder/geocoder.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MapPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  List<Marker> allMarkers = [];
  String inputaddr = '';

  addToList() async {
    final query = inputaddr;
    var addresses = await Geocoder.local.findAddressesFromQuery(query);
    var first = addresses.first;
    Firestore.instance.collection('collection').add({
      'coords':
          new GeoPoint(first.coordinates.latitude, first.coordinates.longitude),
      'place': first.featureName
    });
  }

  Future addMarker() async {
    await showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return new SimpleDialog(
            title: new Text(
              'Add Marker',
              style: new TextStyle(fontSize: 17.0),
            ),
            children: <Widget>[
              new TextField(
                onChanged: (String enteredLoc) {
                  setState(() {
                    inputaddr = enteredLoc;
                  });
                },
              ),
              new SimpleDialogOption(
                child: new Text('Add It',
                    style: new TextStyle(color: Colors.blue)),
                onPressed: () {
                  addToList();
                  Navigator.of(context).pop();
                },
              )
            ],
          );
        });
  }

  Widget loadMap() {
    return StreamBuilder(
      stream: Firestore.instance.collection('markers').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return Text('Loading maps.. Please Wait');
        for (int i = 0; i < snapshot.data.documents.length; i++) {
          allMarkers.add(new Marker(
              width: 45.0,
              height: 45.0,
              point: new LatLng(snapshot.data.documents[i]['coords'].latitude,
                  snapshot.data.documents[i]['coords'].longitude),
              builder: (context) => new Container(
                    child: IconButton(
                      icon: Icon(Icons.location_on),
                      color: Colors.red,
                      iconSize: 45.0,
                      onPressed: () {
                        print(snapshot.data.documents[i]['place']);
                      },
                    ),
                  )));
        }
        return new FlutterMap(
            options:
                new MapOptions(center: new LatLng(30.91, 75.84), minZoom: 10.0),
            layers: [
              new TileLayerOptions(
                  urlTemplate:
                      "http://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                  subdomains: ['a', 'b', 'c']),
              new MarkerLayerOptions(markers: allMarkers)
            ]);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
          title: new Text('Leaflet Maps'),
          leading: new IconButton(
            icon: Icon(Icons.add),
            onPressed: addMarker,
          ),
          centerTitle: true,
        ),
        body: loadMap());
  }
}
