import 'dart:async';
import 'dart:convert';
import 'dart:io' show Platform;
import 'dart:io';
import 'package:vadasada/Api/api.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:localstorage/localstorage.dart';
import 'package:vadasada/UI/BottomNavigationBar.dart';
import 'package:vadasada/UI/LoginOrSignup/ChoseLoginOrSignup.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:connectivity/connectivity.dart';

class firstScreen extends StatefulWidget {
  @override
  _firstScreenState createState() => _firstScreenState();
}

class _firstScreenState extends State<firstScreen> {
  final LocalStorage storage = new LocalStorage('vadasada');

  @override
  void initState() {
    // print(storage.getItem("user"));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    /// To set orientation always portrait
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    ///Set color status bar
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark.copyWith(
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
      home: SplashScreen(),

      /// Move splash screen to ChoseLogin Layout
      /// Routes
      routes: <String, WidgetBuilder>{
        "login": (BuildContext context) => new ChoseLogin(),
        "home": (BuildContext context) => new bottomNavigationBar()
      },
    );
  }
}

/// Component UI
class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

/// Component UI
class _SplashScreenState extends State<SplashScreen> {
  final LocalStorage storage = new LocalStorage('vadasada');
  final Connectivity _connectivity = Connectivity();
  // final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

  StreamSubscription<ConnectivityResult> _connectivitySubscription;
  bool noInternet = false;
  BuildContext ctx;
  var cartItem;
  var user;

  @override

  /// Setting duration in splash screen
  startTime() async {
    return new Timer(Duration(milliseconds: 1000), navigatorPage);
  }

  Future<void> initConnectivity() async {
    ConnectivityResult result;
    try {
      result = await _connectivity.checkConnectivity();
    } on PlatformException catch (e) {
      print(e.toString());
    }
    if (!mounted) {
      return Future.value(null);
    }
    _updateConnectionStatus(result);
  }

  Future<void> _updateConnectionStatus(ConnectivityResult result) async {
    switch (result) {
      case ConnectivityResult.wifi:
        if (noInternet) {
          Navigator.of(context, rootNavigator: true).pop('dialog');
          setState(() {
            noInternet = false;
          });
        }
        navigatorPage();
        break;
      case ConnectivityResult.mobile:
        if (noInternet) {
          Navigator.of(context, rootNavigator: true).pop('dialog');
          setState(() {
            noInternet = false;
          });
        }
        navigatorPage();
        break;
      case ConnectivityResult.none:
        setState(() {
          noInternet = true;
        });
        // _showNoInternetDialog();
        break;
      // setState(() => _connectionStatus = result.toString());r
      default:
        setState(() {
          noInternet = true;
        });
      // _showNoInternetDialog();
    }
  }

  /// To navigate layout change
  navigatorPage() {
    package();
  }

  package() async {
    // PackageInfo packageInfo = await PackageInfo.fromPlatform();
    // print(packageInfo.version);
    // var parameters = {'appkey': Api.appkey, 'version': packageInfo.version};

    // var response = await Api.getRequest(Api.active_version, parameters);
    // var data = jsonDecode(response.body);

    // if (data == 0) {
    //   _showMyDialog();
    // } else {
    if (storage.getItem("user") == null) {
      Navigator.of(context).pushReplacementNamed("login");
    } else {
      Navigator.of(context).pushReplacementNamed("home");
    }
    // }
  }

  void _launchUrl(url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  // _showMyDialog() {
  //   return showDialog(
  //     context: context,
  //     barrierDismissible: false, // user must tap button!
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         title: Text('Alert'),
  //         content: SingleChildScrollView(
  //           child: ListBody(
  //             children: <Widget>[
  //               Text('An update is available, Kindly update your application!'),
  //             ],
  //           ),
  //         ),
  //         actions: <Widget>[
  //           TextButton(
  //             child: Text('Close'),
  //             onPressed: () {
  //               exit(0);
  //             },
  //           ),
  //           TextButton(
  //             child: Text('Update'),
  //             onPressed: () {
  //               if (Platform.isAndroid) {
  //                 _launchUrl(Api.play_store_link);
  //               }
  //               if (Platform.isIOS) {
  //                 _launchUrl(Api.app_store_link);
  //               }
  //               // exit(0);
  //               // Navigator.of(context).pop();
  //               // logout();
  //             },
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }

  // _showNoInternetDialog() {
  //   return showDialog(
  //     context: context,
  //     barrierDismissible: false, // user must tap button!
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         content: SingleChildScrollView(
  //           child: ListBody(
  //             children: <Widget>[
  //               Column(
  //                 crossAxisAlignment: CrossAxisAlignment.center,
  //                 children: [
  //                   Container(
  //                     padding:
  //                         EdgeInsets.only(top: 30.0, right: 60.0, left: 60.0),
  //                     height: 110.0,
  //                     decoration: BoxDecoration(
  //                         color: Colors.white,
  //                         image: DecorationImage(
  //                             image: AssetImage("assets/img/sad_emoji.png"),
  //                             fit: BoxFit.contain)),
  //                   ),
  //                   Padding(
  //                     padding: const EdgeInsets.only(
  //                         left: 8.0, right: 8.0, top: 16.0),
  //                     child: Text(
  //                       'Something has gone wrong, check your internet connection.',
  //                       textAlign: TextAlign.center,
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //             ],
  //           ),
  //         ),
  //       );
  //     },
  //   );
  // }

  /// Declare startTime to InitState
  @override
  void initState() {
    // // startTime();
    // _firebaseMessaging.configure(
    //   onMessage: (Map<String, dynamic> message) async {
    //     print("onMessage: Push Messaging message: $message");
    //   },
    //   onLaunch: (Map<String, dynamic> message) async {
    //     print("onLaunch: Push Messaging message: $message");
    //   },
    //   onResume: (Map<String, dynamic> message) async {
    //     print("onResume: Push Messaging message: $message");
    //   },
    // );
    // _firebaseMessaging.requestNotificationPermissions(
    //     const IosNotificationSettings(sound: true, badge: true, alert: true));
    // _firebaseMessaging.onIosSettingsRegistered
    //     .listen((IosNotificationSettings settings) {
    //   print("Settings registered: $settings");
    // });
    // _firebaseMessaging.getToken().then((String token) {
    //   assert(token != null);
    //   print("Push Messaging token: $token");
    //   storage.setItem("firebase_token", token);
    // });
    // _firebaseMessaging.subscribeToTopic("general");

    initConnectivity();

    super.initState();
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }

  /// Code Create UI Splash Screen
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        /// Set Background image in splash screen layout (Click to open code)
        decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage('assets/img/imageLoading.gif'))),
      ),
    );
  }
}
