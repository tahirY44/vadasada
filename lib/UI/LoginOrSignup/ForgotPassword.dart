import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:vadasada/UI/BottomNavigationBar.dart';
import 'package:vadasada/UI/LoginOrSignup/Login.dart';
import 'package:vadasada/Api/api.dart';
import 'package:vadasada/UI/LoginOrSignup/LoginAnimation.dart';
import 'package:vadasada/UI/LoginOrSignup/Signup.dart';
import 'package:loading_overlay/loading_overlay.dart';

class ForgotPassword extends StatefulWidget {
  @override
  _ForgotPasswordState createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword>
    with TickerProviderStateMixin {
  final emailController = TextEditingController();
  String email;
  bool _loading = false;

  /// Set AnimationController to initState
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    emailController.addListener(_emailValue);
  }

  /// Dispose animationController
  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  _emailValue() {
    setState(() {
      email = emailController.text;
    });
  }

  Widget _textFromField(
      bool password,
      String email,
      IconData icon,
      TextInputType inputType,
      TextEditingController controller,
      FocusScopeNode node,
      bool isNext) {
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
          child: isNext
              ? TextField(
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
                  onEditingComplete: () => node.nextFocus(),
                )
              : TextField(
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
                  onSubmitted: (_) => node.unfocus(),
                ),
        ),
      ),
    );
  }

  submitRequest() async {
    setState(() {
      _loading = true;
    });
    var parameters = {'appkey': Api.appkey, 'email': email};

    // print(parameters);
    var response = await Api.getRequest(Api.forgot_password, parameters);
    var data = jsonDecode(response.body);
    var message = "";
    if (data == 1) {
      message = "Please check your inbox for new password.";
    } else {
      message = "Sorry! User not exists.";
    }
    setState(() {
      _loading = false;
    });
    _showDialog(message, data);
  }

  /// Component Widget layout UI
  @override
  Widget build(BuildContext context) {
    MediaQueryData mediaQueryData = MediaQuery.of(context);
    mediaQueryData.devicePixelRatio;
    mediaQueryData.size.height;
    mediaQueryData.size.width;
    FocusScopeNode node = FocusScope.of(context);

    return Scaffold(
      body: LoadingOverlay(
        isLoading: _loading,
        progressIndicator: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Api.primaryColor),
        ),
        child: GestureDetector(
          onTap: () {
            FocusScopeNode currentFocus = FocusScope.of(context);
            if (!currentFocus.hasPrimaryFocus) {
              currentFocus.unfocus();
            }
          },
          child: Stack(
            children: <Widget>[
              Container(
                /// Set Background image in layout
                decoration: BoxDecoration(
                    image: DecorationImage(
                  image: AssetImage("assets/mainSlider/loginBack.jpg"),
                  fit: BoxFit.cover,
                )),
                child: Container(
                  /// Set gradient color in image
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
                    padding: EdgeInsets.all(0.0),
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
                                            top: mediaQueryData.padding.top +
                                                40.0)),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: <Widget>[
                                        Image(
                                          image: AssetImage(
                                              "assets/img/company_logo_only_white.png"),
                                          height: 90.0,
                                        ),
                                      ],
                                    ),
                                    Padding(
                                        padding: EdgeInsets.symmetric(
                                            vertical: 70.0)),

                                    /// TextFromField Email
                                    _textFromField(
                                        false,
                                        "Email",
                                        Icons.email,
                                        TextInputType.emailAddress,
                                        emailController,
                                        node,
                                        false),
                                    FlatButton(
                                        padding: EdgeInsets.only(
                                            top: 20.0, bottom: 20.0),
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: Text(
                                          "Back to Login",
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 13.0,
                                              fontWeight: FontWeight.w600,
                                              fontFamily: "Sans"),
                                        )),

                                    /// Button Login
                                    Padding(
                                      padding: EdgeInsets.only(
                                          top:
                                              mediaQueryData.padding.top + 70.0,
                                          bottom: 0.0),
                                    )
                                  ],
                                ),
                              ),
                            ],
                          ),

                          /// Set Animaion after user click buttonLogin
                          InkWell(
                            splashColor: Colors.yellow,
                            onTap: () {
                              submitRequest();
                            },
                            child: buttonBlackBottom(),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  _showDialog(dynamic message, dynamic messageType) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => new SimpleDialog(
        children: <Widget>[
          Container(
            padding: EdgeInsets.only(top: 30.0, right: 60.0, left: 60.0),
            height: 110.0,
            decoration: BoxDecoration(
                color: Colors.white,
                image: DecorationImage(
                    image: (messageType.runtimeType == int && messageType > 0)
                        ? AssetImage("assets/img/success.png")
                        : AssetImage("assets/img/error.png"),
                    fit: BoxFit.contain)),
          ),
          Center(
              child: Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: Text(
              (messageType.runtimeType == int && messageType > 0)
                  ? "Success"
                  : "Error",
              style: _txtCustomHead,
            ),
          )),
          Center(
              child: Padding(
            padding: const EdgeInsets.only(
                top: 10.0, bottom: 40.0, left: 20.0, right: 20.0),
            child: Text(
              message,
              style: _txtCustomSub,
              textAlign: TextAlign.center,
            ),
          )),
          Center(
              child: Padding(
            padding: const EdgeInsets.only(
                top: 15.0, bottom: 10.0, left: 20.0, right: 20.0),
            child: InkWell(
              onTap: () {
                Navigator.of(context, rootNavigator: true).pop('dialog');
              },
              child: Text(
                "OK",
              ),
            ),
          ))
        ],
      ),
    );
  }
}

/// textfromfield custom class
class textFromField extends StatelessWidget {
  bool password;
  String email;
  IconData icon;
  TextInputType inputType;

  textFromField({this.email, this.icon, this.inputType, this.password});

  @override
  Widget build(BuildContext context) {
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
          child: TextFormField(
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
          "Submit",
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

/// Custom Text Header for Dialog after user succes payment
var _txtCustomHead = TextStyle(
  color: Colors.black54,
  fontSize: 23.0,
  fontWeight: FontWeight.w600,
  fontFamily: "Gotik",
);

/// Custom Text Description for Dialog after user succes payment
var _txtCustomSub = TextStyle(
  color: Colors.black38,
  fontSize: 15.0,
  fontWeight: FontWeight.w500,
  fontFamily: "Gotik",
);

/// Card Popup if success payment
