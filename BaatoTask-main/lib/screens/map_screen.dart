import 'dart:math';

import 'package:flutter/material.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:geolocator/geolocator.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:share_plus/share_plus.dart';
import 'package:permission_handler/permission_handler.dart'; // Import permission handler
import 'package:testapp/utils/api_service.dart';
import 'package:testapp/widgets/poi_widget.dart';

class MapScreen extends StatefulWidget {
  final double? latitude;
  final double? longitude;

  MapScreen({this.latitude, this.longitude});

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  MaplibreMapController? _mapController;
  bool _isCameraMoving = false;
  LatLng? _currentLocation;
  LatLng? _pinnedLocation;
  Map<String, dynamic>? _placeResponse;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _handleDeepLink();
    });
  }

  Future<void> _handleDeepLink() async {
    final uri = Uri.base; // Use the current URL of the app
    if (uri.queryParameters.isNotEmpty) {
      final String? latString = uri.queryParameters['lat'];
      final String? lngString = uri.queryParameters['lng'];

      if (latString != null && lngString != null) {
        final double lat = double.tryParse(latString) ?? 0.0;
        final double lng = double.tryParse(lngString) ?? 0.0;
        setState(() {
          _pinnedLocation = LatLng(lat, lng);
        });
        _setCameraPosition(lat, lng);
        _showMarkerOnTheTappedLocation(LatLng(lat, lng));
      }
    }
  }

  Future<void> _getCurrentLocation() async {
    // Request location permission
    PermissionStatus permission = await Permission.location.request();

    if (permission.isGranted) {
      try {
        Position position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high);
        setState(() {
          _currentLocation = LatLng(position.latitude, position.longitude);
        });
        if (_mapController != null && _pinnedLocation == null) {
          _setCameraPosition(position.latitude, position.longitude);
        }
      } catch (e) {
        Fluttertoast.showToast(msg: "Error getting current location: $e");
      }
    } else if (permission.isDenied) {
      Fluttertoast.showToast(msg: "Location permission denied");
      // Optionally, show a dialog to the user explaining why you need the location permission
    } else if (permission.isPermanentlyDenied) {
      // Open app settings for the user to manually enable permissions
      openAppSettings();
    }
  }

  void _setCameraPosition(double lat, double lng) {
    if (_mapController != null) {
      _mapController!.moveCamera(
        CameraUpdate.newLatLngZoom(LatLng(lat, lng), 14.0),
      );
    }
  }

  void _onMapCreated(MaplibreMapController controller) {
    _mapController = controller;
    Fluttertoast.showToast(
        msg:
            "Move the map to change the marker location and get location details of that point...",
        toastLength: Toast.LENGTH_LONG);

    if (_currentLocation != null && _pinnedLocation == null) {
      _setCameraPosition(
          _currentLocation!.latitude, _currentLocation!.longitude);
    }

    _mapController!.addListener(() {
      if (_mapController!.isCameraMoving &&
          _mapController!.symbols.isNotEmpty) {
        _mapController!.removeSymbol(_mapController!.symbols.first);
      }
      setState(() {
        _isCameraMoving = _mapController!.isCameraMoving;
      });
    });
  }

  void _onCameraIdle() {
    if (_mapController != null && !_mapController!.isCameraMoving) {
      final target = _mapController!.cameraPosition!.target;
      _fetchLocationDetails(target);
      _showMarkerOnTheTappedLocation(target);
    }
  }

  Future<void> _fetchLocationDetails(LatLng latLng) async {
    try {
      final data = await ApiService.fetchLocationDetails(
          latLng.latitude, latLng.longitude);
      setState(() {
        _placeResponse = data;
      });
    } catch (e) {
      Fluttertoast.showToast(msg: "Error fetching location details: $e");
    }
  }

  void _showMarkerOnTheTappedLocation(LatLng latLng) {
    if (_mapController != null && _mapController!.symbols.isNotEmpty) {
      _mapController!.removeSymbol(_mapController!.symbols.first);
    }
    setState(() {
      _pinnedLocation = latLng;
    });
    if (_mapController != null) {
      _mapController!.addSymbol(
        SymbolOptions(
          geometry: latLng,
          iconImage: "assets/ic_marker.png",
        ),
      );
    }
  }

  void _shareLocation() {
    if (_pinnedLocation != null) {
      final lat = _pinnedLocation!.latitude;
      final lng = _pinnedLocation!.longitude;
      final locationUrl =
          'https://example.com/your_path?lat=$lat&lng=$lng'; // Adjust the URL as needed
      Share.share('Check out this location: $locationUrl');
    } else {
      Fluttertoast.showToast(msg: "No location to share");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Baato Map App'),
        actions: [
          IconButton(
            icon: Icon(Icons.share),
            onPressed: _shareLocation,
          ),
        ],
      ),
      body: Stack(
        children: [
          MaplibreMap(
            trackCameraPosition: true,
            onMapCreated: _onMapCreated,
            onCameraIdle: _onCameraIdle,
            onMapClick: (point, latLng) async {
              _mapController?.moveCamera(CameraUpdate.newLatLng(latLng));
              await _fetchLocationDetails(latLng);
              _showMarkerOnTheTappedLocation(latLng);
            },
            initialCameraPosition: CameraPosition(
              target: _currentLocation ??
                  LatLng(widget.latitude ?? 27.7192873,
                      widget.longitude ?? 85.3238007),
              zoom: 14.0,
            ),
            styleString:
                "https://api.baato.io/api/v1/styles/retro?key=bpk.FhqCNwsqS3vQz6KNopKlBOhudT4A_oPf5yOE4OMGW9Lr",
          ),
          Center(
            child: Container(
              child:
                  _isCameraMoving ? Image.asset('assets/ic_marker.png') : null,
            ),
          ),
          _placeResponse != null && _placeResponse!['data'].isNotEmpty
              ? Positioned(
                  bottom: 20,
                  left: 10,
                  right: 10,
                  child: Card(
                    elevation: 8,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _placeResponse!['data'][0]['name'] ?? 'Unknown',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 8),
                          Text(
                            _placeResponse!['data'][0]['address'] ?? 'Unknown',
                            style: TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              : Container(),
          POIWidget(mapController: _mapController), // Pass the mapController
        ],
      ),
    );
  }
}
