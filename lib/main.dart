// ignore_for_file: prefer_const_constructors
import 'dart:io';
//import 'package:in_app_update/in_app_update.dart';
import 'package:uje/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loader_overlay/loader_overlay.dart';

main() {
  HttpOverrides.global = MyHttpOverrides();
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: MyApp(),
    theme: ThemeData(primarySwatch: Colors.green),
    darkTheme: ThemeData(brightness: Brightness.dark, primarySwatch: Colors.green),
  ));
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    //checkForUpdate();
  }

  @override
  Widget build(BuildContext context) {
    return GlobalLoaderOverlay(
      useDefaultLoading: true,
      overlayColor: Colors.grey.withOpacity(0.3),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'CRDB BANK',
        theme: ThemeData(
          useMaterial3: true,
          brightness: Brightness.light,
          scaffoldBackgroundColor: Colors.white,
          textTheme: GoogleFonts.montserratTextTheme()
              .apply(bodyColor: Colors.black, displayColor: Colors.black),
          iconTheme: const IconThemeData(color: Colors.black),
          primaryColor: Colors.green[800],
        ),
        home: HomeScreen(),
      ),
    );
  }

  /*Future<void> checkForUpdate() async {
    try {
      final updateInfo = await InAppUpdate.checkForUpdate();
      if (updateInfo != null && updateInfo.updateAvailability == UpdateAvailability.updateAvailable) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Downloading application updates..."),
            duration: Duration(seconds: 5),
          ),
        );
        await InAppUpdate.startFlexibleUpdate();
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
      } else {
      }
    } catch (e) {
      print("Error checking for updates: $e");
    }
  }

  */
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}