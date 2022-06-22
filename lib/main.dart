import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:localstorage/localstorage.dart';
import 'package:vadasada/UI/BottomNavigationBar.dart';
import 'package:vadasada/UI/LoginOrSignup/ChoseLoginOrSignup.dart';
import 'package:vadasada/UI/SplashScreen.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';

/// Run first apps open
void main() async {
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
      statusBarColor: Colors.white,
      statusBarIconBrightness: Brightness.light,
    ),
  );
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(myApp());
}

/// Set orienttation
class myApp extends StatefulWidget {
  @override
  _myAppState createState() => _myAppState();
}

class _myAppState extends State<myApp> {
  final LocalStorage storage = new LocalStorage('vadasada');

  @override
  Widget build(BuildContext context) {
    /// To set orientation always portrait
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    ///Set color status bar
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light.copyWith(
      statusBarColor: Colors.transparent, //or set color with: Color(0xFF0000FF)
    ));
    return new MaterialApp(
      title: "vadasada",
      theme: ThemeData(
          brightness: Brightness.light,
          backgroundColor: Colors.white,
          primaryColorLight: Colors.white,
          primaryColorBrightness: Brightness.light,
          primaryColor: Colors.white),
      debugShowCheckedModeBanner: false,
      home: SplashScreen(storage),

      /// Move splash screen to ChoseLogin Layout
      /// Routes
      routes: <String, WidgetBuilder>{
        "login": (BuildContext context) => new ChoseLogin(),
        "home": (BuildContext context) => new bottomNavigationBar(),
        "first": (BuildContext context) => new firstScreen()
      },
    );
  }
}

/// Component UI
class SplashScreen extends StatefulWidget {
  LocalStorage storage;

  SplashScreen(this.storage);

  @override
  _SplashScreenState createState() => _SplashScreenState(storage);
}

/// Component UI
class _SplashScreenState extends State<SplashScreen> {
  LocalStorage storage;

  _SplashScreenState(this.storage);

  var cartItem;
  var user;

  @override

  /// Setting duration in splash screen
  startTime() async {
    return new Timer(Duration(milliseconds: 4500), NavigatorPage);
  }

  /// To navigate layout change
  void NavigatorPage() {
    // if (user == null) {
    //   Navigator.of(context).pushReplacementNamed("first");
    // } else {
    Navigator.of(context).pushReplacementNamed("first");
    // }
  }

  /// Declare startTime to InitState
  @override
  void initState() {
    startTime();
    // print(storage.getItem("user"));
    super.initState();
  }

  /// Code Create UI Splash Screen
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: Container(
          /// Set Background image in splash screen layout (Click to open code)
          decoration: BoxDecoration(
              image: DecorationImage(
                  image: AssetImage('assets/img/man.jpg'), fit: BoxFit.cover)),
        ),
      ),
    );
  }
}
