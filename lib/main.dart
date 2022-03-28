import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'my_flutter_app_icons.dart';
import 'package:latlong2/latlong.dart' as lat_lng;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fishing zones',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyInitialMap(),
    );
  }
}

class MyInitialMap extends StatefulWidget {
  const MyInitialMap({Key? key}) : super(key: key);

  @override
  State<MyInitialMap> createState() => _MyMap();
}

class _MyMap extends State<MyInitialMap> {
  late Position currentPosition;
  @protected
  @mustCallSuper
  void initState() {
    _determinePosition();
    super.initState();
  }
  Future<Position?> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    try {
      setState(() {
        currentPosition = position;
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        FlutterMap(
          options: MapOptions(
            center: lat_lng.LatLng(currentPosition.latitude.toDouble(),
                currentPosition.longitude.toDouble()),
            zoom: 13.0,
          ),
          layers: [
            TileLayerOptions(
              urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
              subdomains: ['a', 'b', 'c'],
            ),
            MarkerLayerOptions(
              markers: [
                Marker(
                    point: lat_lng.LatLng(
                        currentPosition.latitude.toDouble(),
                        currentPosition.longitude.toDouble()
                    ),
                    builder: (ctx) => const Icon(MyFlutterApp.fishingRod)
                )]
            )
          ],
        ),
        Align(
          alignment: Alignment.bottomRight,
          child: FloatingActionButton(
            onPressed: () {},
          ),
        ),
      ],
    );
  }
}
