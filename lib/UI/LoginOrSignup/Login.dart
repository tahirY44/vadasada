import 'dart:async';
import 'dart:convert';
import 'package:vadasada/UI/BottomNavigationBar.dart';
import 'package:vadasada/UI/LoginOrSignup/ForgotPassword.dart';
import 'package:http/http.dart' as http;
import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:vadasada/UI/LoginOrSignup/LoginAnimation.dart';
import 'package:vadasada/UI/LoginOrSignup/Signup.dart';
import 'package:vadasada/Api/api.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:localstorage/localstorage.dart';

class loginScreen extends StatefulWidget {
  @override
  _loginScreenState createState() => _loginScreenState();
}

/// Component Widget this layout UI
class _loginScreenState extends State<loginScreen>
    with TickerProviderStateMixin {
  //Animation Declaration

  final LocalStorage storage = new LocalStorage('vadasada');

  AnimationController sanimationController;
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  String email;
  String password;
  bool _loading = false;
  var tap = 0;
  var notify_token;

  @override

  /// set state animation controller
  void initState() {
    setState(() {
      notify_token = '7hg64yfd5tetdg';
    });
    sanimationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 800))
          ..addStatusListener((statuss) {
            if (statuss == AnimationStatus.dismissed) {
              setState(() {
                tap = 0;
              });
            }
          });
    emailController.addListener(_emailValue);
    passwordController.addListener(_passwordValue);
    // TODO: implement initState
    super.initState();
  }

  /// Dispose animation controller
  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    sanimationController.dispose();
    super.dispose();
  }

  _emailValue() {
    setState(() {
      email = emailController.text;
    });
  }

  _passwordValue() {
    setState(() {
      password = passwordController.text;
    });
  }

  Widget _textFromField(bool password, String email, IconData icon,
      TextInputType inputType, TextEditingController controller) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 30.0),
      child: Container(
        height: 60.0,
        alignment: AlignmentDirectional.center,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14.0),
            color: Colors.white,
            boxShadow: [BoxShadow(blurRadius: 10.0, color: Colors.black12)]),
        padding:
            EdgeInsets.only(left: 20.0, right: 30.0, top: 0.0, bottom: 0.0),
        child: Theme(
          data: ThemeData(
            hintColor: Colors.transparent,
          ),
          child: TextField(
            controller: controller,
            obscureText: password,
            decoration: InputDecoration(
                border: InputBorder.none,
                labelText: email,
                icon: Icon(
                  icon,
                  color: Colors.black38,
                ),
                labelStyle: TextStyle(
                    fontSize: 15.0,
                    fontFamily: 'Sans',
                    letterSpacing: 0.3,
                    color: Colors.black38,
                    fontWeight: FontWeight.w600)),
            keyboardType: inputType,
          ),
        ),
      ),
    );
  }

  Widget _buttonCustomFacebook() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30.0),
      child: InkWell(
        onTap: () {
          // loginFb();
        },
        child: Container(
          alignment: FractionalOffset.center,
          height: 49.0,
          width: 500.0,
          decoration: BoxDecoration(
            color: Color.fromRGBO(107, 112, 248, 1.0),
            borderRadius: BorderRadius.circular(40.0),
            boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 15.0)],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Image.asset(
                "assets/img/icon_facebook.png",
                height: 25.0,
              ),
              Padding(padding: EdgeInsets.symmetric(horizontal: 7.0)),
              Text(
                "Login With Facebook",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 15.0,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Sans'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  _showMyDialog(String message) {
    return showDialog(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(message),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  /// Playanimation set forward reverse
  Future<Null> _PlayAnimation() async {
    try {
      await sanimationController.forward();
      await sanimationController.reverse();
    } on TickerCanceled {}
  }

  login() async {
    var parameters = {
      'appkey': Api.appkey,
      'email': email,
      'password': password,
      'notify_token': notify_token.toString()
    };
    var response = await Api.getRequest(Api.login, parameters);
    // print(parameters);
    var data = jsonDecode(response.body);
    if (data != 0) {
      // print(data);
      storage.setItem("user", data);
      setState(() {
        tap = 1;
      });
      new LoginAnimation(
        animationController: sanimationController.view,
      );
      _PlayAnimation();
      return tap;
    } else {
      _showMyDialog("Login Error");
    }
  }

  // loginFb() async {
  //   final result = await facebookLogin.logIn(['public_profile', 'email']);
  //   setState(() {
  //     _loading = true;
  //   });
  //   switch (result.status) {
  //     case FacebookLoginStatus.loggedIn:
  //       final token = result.accessToken.token;
  //       final graphResponse = await http.get(
  //           'https://graph.facebook.com/v2.12/me?fields=name,first_name,last_name,email,picture.width(400).height(400)&access_token=${token}');
  //       final profile = jsonDecode(graphResponse.body);
  //       var name = profile["name"];
  //       var email = profile["email"];
  //       var facebook_image = profile["picture"]["data"]["url"];
  //       var parameters = {
  //         'appkey': Api.appkey,
  //         'name': name.toString(),
  //         'email': email.toString(),
  //         'facebook_image': facebook_image.toString(),
  //         'notify_token': notify_token.toString()
  //       };
  //       var response = await Api.getRequest(Api.register_fb, parameters);
  //       var data = jsonDecode(response.body);
  //       storage.setItem("user", data);
  //       setState(() {
  //         _loading = false;
  //         tap = 1;
  //       });
  //       new LoginAnimation(
  //         animationController: sanimationController.view,
  //       );
  //       _PlayAnimation();
  //       return tap;

  //       // print(parameters);

  //       // _showLoggedInUI();
  //       break;
  //     case FacebookLoginStatus.cancelledByUser:
  //       print('User Cancelled');
  //       setState(() {
  //         _loading = false;
  //       });
  //       break;
  //     case FacebookLoginStatus.error:
  //       setState(() {
  //         _loading = false;
  //       });
  //       _showMyDialog(result.errorMessage);
  //       break;
  //   }

  //   // final token = result.accessToken.token;
  // }

  /// Component Widget layout UI
  @override
  Widget build(BuildContext context) {
    MediaQueryData mediaQueryData = MediaQuery.of(context);
    mediaQueryData.devicePixelRatio;
    mediaQueryData.size.width;
    mediaQueryData.size.height;
    return Scaffold(
      backgroundColor: Colors.white,
      body: LoadingOverlay(
        isLoading: _loading,
        progressIndicator: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Api.primaryColor),
        ),
        child: Container(
          /// Set Background image in layout (Click to open code)
          decoration: BoxDecoration(
              image: DecorationImage(
            image: AssetImage("assets/img/loginBack.jpg"),
            fit: BoxFit.cover,
          )),
          child: Container(
            /// Set gradient color in image (Click to open code)
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color.fromRGBO(0, 0, 0, 0.2),
                  Color.fromRGBO(0, 0, 0, 0.3)
                ],
                begin: FractionalOffset.topCenter,
                end: FractionalOffset.bottomCenter,
              ),
            ),

            /// Set component layout
            child: ListView(
              children: <Widget>[
                Stack(
                  alignment: AlignmentDirectional.bottomCenter,
                  children: <Widget>[
                    Column(
                      children: <Widget>[
                        Container(
                          alignment: AlignmentDirectional.topCenter,
                          child: Column(
                            children: <Widget>[
                              /// padding logo
                              Padding(
                                  padding: EdgeInsets.only(
                                      top: mediaQueryData.padding.top + 20.0)),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Image(
                                    image: AssetImage(
                                        "assets/img/company_logo_only_white.png"),
                                    height: 90.0,
                                  ),
                                ],
                              ),
                              Platform.isAndroid
                                  ? (Column(
                                      children: [
                                        Padding(
                                            padding: EdgeInsets.symmetric(
                                                vertical: 40.0)),

                                        // _buttonCustomFacebook(),

                                        /// Set Text
                                        // Padding(
                                        //     padding: EdgeInsets.symmetric(
                                        //         vertical: 10.0)),
                                        // Text(
                                        //   "OR",
                                        //   style: TextStyle(
                                        //       fontWeight: FontWeight.w900,
                                        //       color: Colors.white,
                                        //       letterSpacing: 0.2,
                                        //       fontFamily: 'Sans',
                                        //       fontSize: 17.0),
                                        // )
                                      ],
                                    ))
                                  : Padding(
                                      padding:
                                          EdgeInsets.symmetric(vertical: 60.0)),

                              /// TextFromField Email
                              Padding(
                                  padding:
                                      EdgeInsets.symmetric(vertical: 10.0)),
                              _textFromField(false, "Email", Icons.email,
                                  TextInputType.emailAddress, emailController),

                              Padding(
                                  padding: EdgeInsets.symmetric(vertical: 5.0)),
                              _textFromField(true, "Password", Icons.vpn_key,
                                  TextInputType.text, passwordController),

                              FlatButton(
                                  padding: EdgeInsets.only(top: 20.0),
                                  onPressed: () {
                                    Navigator.of(context).push(
                                        MaterialPageRoute(
                                            builder: (BuildContext context) =>
                                                new ForgotPassword()));
                                  },
                                  child: Text(
                                    "Forgot Password?",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 13.0,
                                        fontWeight: FontWeight.w600,
                                        fontFamily: "Sans"),
                                  )),
                              Padding(
                                padding: const EdgeInsets.only(top: 10),
                                child: Text(
                                  "OR",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 13.0,
                                      fontWeight: FontWeight.w600,
                                      fontFamily: "Sans"),
                                ),
                              ),

                              /// Button Signup
                              FlatButton(
                                  padding: EdgeInsets.only(top: 10.0),
                                  onPressed: () {
                                    Navigator.of(context).push(
                                        MaterialPageRoute(
                                            builder: (BuildContext context) =>
                                                new Signup()));
                                  },
                                  child: Text(
                                    "Not Have Acount? Sign Up",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 13.0,
                                        fontWeight: FontWeight.w600,
                                        fontFamily: "Sans"),
                                  )),
                              Padding(
                                padding: EdgeInsets.only(
                                    top: mediaQueryData.padding.top + 100.0,
                                    bottom: 0.0),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                    Positioned(
                      top: 10,
                      right: 5,
                      child: IconButton(
                        icon: new Icon(
                          Icons.home,
                          color: Colors.white,
                          size: 30,
                        ),
                        onPressed: () => Navigator.of(context)
                            .pushAndRemoveUntil(
                                MaterialPageRoute(
                                    builder: (BuildContext context) =>
                                        new bottomNavigationBar()),
                                (r) => false),
                      ),
                    ),

                    /// Set Animaion after user click buttonLogin
                    tap == 0
                        ? InkWell(
                            splashColor: Colors.yellow,
                            onTap: () {
                              login();
                            },
                            child: buttonBlackBottom(),
                          )
                        : new LoginAnimation(
                            animationController: sanimationController.view,
                          )
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

///buttonCustomGoogle class
class buttonCustomGoogle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30.0),
      child: Container(
        alignment: FractionalOffset.center,
        height: 49.0,
        width: 500.0,
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10.0)],
          borderRadius: BorderRadius.circular(40.0),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.asset(
              "assets/img/icon_facebook.png",
              height: 25.0,
            ),
            Padding(padding: EdgeInsets.symmetric(horizontal: 7.0)),
            Text(
              "Login With Google",
              style: TextStyle(
                  color: Colors.black26,
                  fontSize: 15.0,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Sans'),
            )
          ],
        ),
      ),
    );
  }
}

///ButtonBlack class
class buttonBlackBottom extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(30.0),
      child: Container(
        height: 55.0,
        width: 600.0,
        child: Text(
          "Login",
          style: TextStyle(
              color: Colors.white,
              letterSpacing: 0.2,
              fontFamily: "Sans",
              fontSize: 18.0,
              fontWeight: FontWeight.w800),
        ),
        alignment: FractionalOffset.center,
        decoration: BoxDecoration(
            boxShadow: [BoxShadow(color: Colors.black38, blurRadius: 15.0)],
            borderRadius: BorderRadius.circular(30.0),
            color: Api.primaryColor),
      ),
    );
  }
}
