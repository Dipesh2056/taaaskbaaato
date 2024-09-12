import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  /// Fetches points of interest (POIs) near a given latitude and longitude.
  /// 
  /// Sends a GET request to the Baato API to retrieve a list of places around
  /// the specified coordinates [latitude] and [longitude]. The API key is included
  /// in the request for authentication.
  ///
  /// Returns a map containing the POI data if the request is successful.
  /// Throws an [Exception] if the request fails.
  static Future<Map<String, dynamic>> fetchPOIs(double latitude, double longitude) async {
    // API endpoint to fetch nearby places using latitude and longitude
    final url = 'https://api.baato.io/api/v1/places?lat=$latitude&lon=$longitude&key=bpk.FhqCNwsqS3vQz6KNopKlBOhudT4A_oPf5yOE4OMGW9Lr';
    
    // Send GET request
    final response = await http.get(Uri.parse(url));
    
    // Check if request was successful
    if (response.statusCode == 200) {
      // Parse and return the response body as JSON
      return json.decode(response.body);
    } else {
      // Throw an exception if the request fails
      throw Exception('Failed to load POIs');
    }
  }

  /// Fetches location details for a given latitude and longitude.
  ///
  /// Sends a GET request to the Baato API to retrieve details about the location
  /// specified by [latitude] and [longitude], such as the address and other relevant
  /// information. The API key is included in the request for authentication.
  ///
  /// Returns a map containing the location details if the request is successful.
  /// Throws an [Exception] if the request fails.
  static Future<Map<String, dynamic>> fetchLocationDetails(double latitude, double longitude) async {
    // API endpoint for reverse geocoding (converting coordinates into address details)
    final url = 'https://api.baato.io/api/v1/reverse?lat=$latitude&lon=$longitude&key=bpk.FhqCNwsqS3vQz6KNopKlBOhudT4A_oPf5yOE4OMGW9Lr';
    
    // Send GET request
    final response = await http.get(Uri.parse(url));
    
    // Check if request was successful
    if (response.statusCode == 200) {
      // Parse and return the response body as JSON
      return json.decode(response.body);
    } else {
      // Throw an exception if the request fails
      throw Exception('Failed to load location details');
    }
  }
}
