import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:testapp/screens/map_screen.dart';

void main() {
  testWidgets('MapScreen should display map and handle deep linking', (WidgetTester tester) async {
    // Provide latitude and longitude for testing
    final latitude = 27.7192873;
    final longitude = 85.3238007;

    // Build the MapScreen widget with a deep link as initial route
    await tester.pumpWidget(
      MaterialApp(
        home: MapScreen(latitude: latitude, longitude: longitude),
        onGenerateRoute: (settings) {
          if (settings.name == '/') {
            return MaterialPageRoute(builder: (context) => MapScreen(latitude: latitude, longitude: longitude));
          }
          if (settings.name == '/map') {
            final uri = Uri.parse(settings.name!);
            final lat = double.tryParse(uri.queryParameters['lat'] ?? '0.0') ?? latitude;
            final lng = double.tryParse(uri.queryParameters['lng'] ?? '0.0') ?? longitude;
            return MaterialPageRoute(
              builder: (context) => MapScreen(latitude: lat, longitude: lng),
            );
          }
          return null;
        },
      ),
    );

    // Verify that the map is displayed
    expect(find.byType(MaplibreMap), findsOneWidget);

    // Simulate deep linking via Navigator push (navigate to the deep link route)
    await tester.tap(find.byType(MaplibreMap));
    await tester.pumpAndSettle(); // Wait for the navigation to complete

    await tester.pumpWidget(
      MaterialApp(
        home: Navigator(
          onGenerateRoute: (RouteSettings settings) {
            final uri = Uri.parse('/map?lat=27.7192873&lng=85.3238007');
            final lat = double.tryParse(uri.queryParameters['lat']!) ?? 27.7192873;
            final lng = double.tryParse(uri.queryParameters['lng']!) ?? 85.3238007;
            return MaterialPageRoute(
              builder: (context) => MapScreen(latitude: lat, longitude: lng),
            );
          },
        ),
      ),
    );

    // Verify that the marker was placed at the deep link location
    expect(find.text('Location pinned: 27.7192873, 85.3238007'), findsOneWidget);
  });
}
