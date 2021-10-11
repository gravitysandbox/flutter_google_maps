import 'package:flutter/material.dart';
import 'package:flutter_google_maps/model/directions.dart';
import 'package:flutter_google_maps/repositories/directions_repository.dart';
import 'package:flutter_google_maps/widgets/total_distance.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  static const _initialCameraPosition = CameraPosition(
    target: LatLng(53.902334, 27.5618791),
    zoom: 11.5,
  );

  late GoogleMapController _googleMapController;
  Marker? _origin;
  Marker? _destination;
  Directions? _info;

  @override
  void dispose() {
    _googleMapController.dispose();
    super.dispose();
  }

  void _addMarker(LatLng position) async {
    _origin == null || (_origin != null && _destination != null)
        ? setState(() {
            _origin = Marker(
              markerId: const MarkerId('origin'),
              infoWindow: const InfoWindow(title: 'Origin'),
              icon: BitmapDescriptor.defaultMarkerWithHue(
                  BitmapDescriptor.hueBlue),
              position: position,
            );

            _destination = null;
            _info = null;
          })
        : setState(
            () {
              _destination = Marker(
                markerId: const MarkerId('destination'),
                infoWindow: const InfoWindow(title: 'Destination'),
                icon: BitmapDescriptor.defaultMarkerWithHue(
                    BitmapDescriptor.hueRed),
                position: position,
              );
            },
          );

    final directions = await DirectionsRepository()
        .getDirections(origin: _origin!.position, destination: position);
    setState(() => _info = directions);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      appBar: _appBar(context),
      floatingActionButton: _floatingActionButton(context),
      body: Stack(
        alignment: Alignment.center,
        children: [
          GoogleMap(
            myLocationButtonEnabled: false,
            zoomControlsEnabled: true,
            initialCameraPosition: _initialCameraPosition,
            onMapCreated: (controller) => _googleMapController = controller,
            markers: {
              if (_origin != null) _origin!,
              if (_destination != null) _destination!,
            },
            polylines: {
              if (_info != null)
                Polyline(
                  polylineId: const PolylineId('overview_polyline'),
                  color: Colors.red,
                  width: 5,
                  points: _info!.polylinePoints
                      .map((e) => LatLng(
                            e.latitude,
                            e.longitude,
                          ))
                      .toList(),
                ),
            },
            onLongPress: _addMarker,
          ),
          if (_info != null) TotalDistance(info: _info),
        ],
      ),
    );
  }

  FloatingActionButton _floatingActionButton(BuildContext context) {
    return FloatingActionButton(
      backgroundColor: Theme.of(context).primaryColor,
      foregroundColor: Colors.black,
      onPressed: () => _googleMapController.animateCamera(
        _info != null
            ? CameraUpdate.newLatLngBounds(_info!.bounds, 100.0)
            : CameraUpdate.newCameraPosition(_initialCameraPosition),
      ),
      child: const Icon(Icons.center_focus_strong),
    );
  }

  AppBar _appBar(BuildContext context) {
    return AppBar(
      centerTitle: false,
      backgroundColor: Theme.of(context).primaryColor,
      foregroundColor: Colors.black,
      title: const Text('Flutter Google Maps'),
      actions: [
        if (_origin != null)
          TextButton(
            onPressed: () => _googleMapController.animateCamera(
              CameraUpdate.newCameraPosition(
                CameraPosition(
                  target: _origin!.position,
                  zoom: 14.5,
                  tilt: 50.0,
                ),
              ),
            ),
            style: TextButton.styleFrom(
              primary: Colors.lightBlue,
              textStyle: const TextStyle(fontWeight: FontWeight.w600),
            ),
            child: const Text('ORIGIN'),
          ),
        if (_destination != null)
          TextButton(
            onPressed: () => _googleMapController.animateCamera(
              CameraUpdate.newCameraPosition(
                CameraPosition(
                  target: _destination!.position,
                  zoom: 14.5,
                  tilt: 50.0,
                ),
              ),
            ),
            style: TextButton.styleFrom(
              primary: Colors.red,
              textStyle: const TextStyle(fontWeight: FontWeight.w600),
            ),
            child: const Text('DEST'),
          ),
      ],
    );
  }
}
