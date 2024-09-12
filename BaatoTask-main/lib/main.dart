import 'dart:math';

import 'package:flutter/material.dart';
import 'package:testapp/screens/map_screen.dart';
import 'package:uni_links/uni_links.dart';
import 'dart:async'; // Import required for StreamSubscription
import 'package:flutter/services.dart'; // Import required for PlatformException

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  StreamSubscription<String?>? _sub;

  @override
  void initState() {
    super.initState();
    print('firsts');

    initUniLinks();
  }

  Future<void> initUniLinks() async {
    // Handle the initial link
    try {
      final initialLink = await getInitialLink();
      print('sds');
      print(initialLink);
      if (initialLink != null) {
        Uri uri = Uri.parse(initialLink);
        print('Initial link: $uri');
        // Handle the initial deep link here
      }
    } on PlatformException catch (e) {
      print("PlatformException in initUniLinks: $e");
    }

    // Attach a listener to handle link changes
    _sub = linkStream.listen((String? link) {
      if (link != null) {
        Uri uri = Uri.parse(link);
        print('Received link: $uri');
        // Handle deep link changes here
      }
    }, onError: (Object err) {
      print('Error in linkStream: $err');
    });
  }

  @override
  void dispose() {
    _sub?.cancel(); // Cancel the stream subscription to prevent memory leaks
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Baato Map App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MapScreen(),
    );
  }
}
