import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class GoggleMapsScreen extends StatefulWidget {
  const GoggleMapsScreen({super.key});

  @override
  State<GoggleMapsScreen> createState() => _GoggleMapsScreenState();
}

class _GoggleMapsScreenState extends State<GoggleMapsScreen> {

  double defaultLat = 22.2945650;
  double defaultLng = 73.3620657;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.greenAccent,
        title: const Text("Current Address"),
      ),
      body: Stack(
        children: [
          GoogleMap(
            mapType: MapType.normal,
            initialCameraPosition: CameraPosition(
                target: LatLng(defaultLat, defaultLng),
              zoom: 17,
            ),
            onCameraMove: (CameraPosition position){
              print('lat: ${position.target.latitude} || lng: ${position.target.longitude}');
            },
          ),
          Center(child: Icon(Icons.location_on, size: 50, color: Colors.redAccent,),)
        ],
      )
    );
  }
}
