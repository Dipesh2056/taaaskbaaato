import 'package:flutter/material.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:testapp/utils/api_service.dart';

class POIWidget extends StatefulWidget {
  final MaplibreMapController? mapController;

  // Constructor that takes an optional MaplibreMapController
  POIWidget({this.mapController});

  @override
  _POIWidgetState createState() => _POIWidgetState();
}

class _POIWidgetState extends State<POIWidget> {
  // List to store map symbols representing POIs
  List<Symbol> _poiSymbols = [];
  
  // Map to store POI data associated with each symbol
  Map<Symbol, Map<String, dynamic>> _poiData = {};

  @override
  void initState() {
    super.initState();
    
    // Fetch POIs if the map controller is available
    if (widget.mapController != null) {
      _fetchPOIs();
    }
  }

  /// Fetches POIs from the API and plots them on the map.
  ///
  /// Calls the ApiService to get POI data based on the location, and then
  /// plots these points on the map using symbols. If an error occurs, a toast
  /// message is shown to inform the user.
  Future<void> _fetchPOIs() async {
    try {
      // Replace static coordinates with dynamic location if needed
      final data = await ApiService.fetchPOIs(
        27.7192873, 85.3238007, 
      );
      
      // Plot the POIs on the map after fetching
      _plotPOIs(data);
    } catch (e) {
      // Show an error message using FlutterToast if fetching POIs fails
      Fluttertoast.showToast(msg: "Error fetching POIs: $e");
    }
  }

  /// Plots the fetched POIs on the map as symbols.
  ///
  /// Iterates through the list of POIs fetched from the API and adds a symbol
  /// for each POI to the map. The method also sets up a listener for symbol taps
  /// to show a toast message with the POI name.
  Future<void> _plotPOIs(Map<String, dynamic> data) async {
    // Clear any existing symbols and associated data
    setState(() {
      _poiSymbols.clear();
      _poiData.clear();
    });

    // Loop through the list of places (POIs) returned from the API
    for (var poi in data['places']) {
      final latLng = LatLng(poi['lat'], poi['lng']);

      try {
        // Add a symbol for each POI with a marker icon and label
        final symbol = await widget.mapController!.addSymbol(
          SymbolOptions(
            geometry: latLng,
            iconImage: "assets/ic_marker.png", // Custom marker icon
            textField: poi['name'] ?? '',      // Display POI name as text
            textOffset: Offset(0, 2),          // Offset the text above the marker
          ),
        );
        
        // Store the symbol and corresponding POI data
        _poiSymbols.add(symbol);
        _poiData[symbol] = poi;

        // Add a listener to handle symbol tap events
        widget.mapController!.onSymbolTapped.add((symbol) {
          Fluttertoast.showToast(msg: "Clicked on: ${_poiData[symbol]!['name']}");
        });
      } catch (e) {
        // Show an error message if adding the symbol fails
        Fluttertoast.showToast(msg: "Error adding symbol: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Return an empty container as this widget primarily handles map interaction
    return Container();
  }
}
