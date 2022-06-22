import 'dart:async';
import 'dart:convert';

// import 'package:vadasada/UI/HomeUIComponent/Home.dart';
import 'package:flutter/material.dart';
import 'package:vadasada/UI/BottomNavigationBar.dart';
import 'package:vadasada/UI/LoginOrSignup/Login.dart';
import 'package:vadasada/Api/api.dart';
import 'package:vadasada/UI/LoginOrSignup/LoginAnimation.dart';
// import 'package:vadasada/UI/LoginOrSignup/Signup.dart';
import 'package:localstorage/localstorage.dart';

class Signup extends StatefulWidget {
  @override
  _SignupState createState() => _SignupState();
}

class _SignupState extends State<Signup> with TickerProviderStateMixin {
  //Animation Declaration
  AnimationController sanimationController;
  AnimationController animationControllerScreen;
  final LocalStorage storage = new LocalStorage('vadasada');
  Animation animationScreen;
  var tap = 0;
  final nameController = TextEditingController();
  final mobileController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  String name, email, mobile, password;

  /// Set AnimationController to initState
  @override
  void initState() {
    sanimationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 800))
          ..addStatusListener((statuss) {
            if (statuss == AnimationStatus.dismissed) {
              setState(() {
                tap = 0;
              });
            }
          });
    // TODO: implement initState
    super.initState();
    nameController.addListener(_nameValue);
    mobileController.addListener(_mobileValue);
    emailController.addListener(_emailValue);
    passwordController.addListener(_passwordValue);
  }

  /// Dispose animationController
  @override
  void dispose() {
    nameController.dispose();
    mobileController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
    sanimationController.dispose();
  }

  _nameValue() {
    setState(() {
      name = nameController.text;
    });
  }

  _mobileValue() {
    setState(() {
      mobile = mobileController.text;
    });
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

  /// Playanimation set forward reverse
  Future<Null> _PlayAnimation() async {
    try {
      await sanimationController.forward();
      await sanimationController.reverse();
    } on TickerCanceled {}
  }

  signup(context) async {
    // var notify_token = storage.getItem("firebase_token").toString();
    var parameters = {
      'appkey': Api.appkey,
      'name': name,
      'mobile': mobile,
      'email': email,
      'password': password,
      'notify_token': '6564tfg65fguh'
    };

    // print(parameters);
    var response = await Api.getRequest(Api.signup, parameters);
    var data = jsonDecode(response.body);

    var message = data['msg'];
    var error = data['error'];

    if (error == 0) {
      storage.setItem("user", data['user']);
      setState(() {
        tap = 1;
      });
      new LoginAnimation(
        animationController: sanimationController.view,
      );
      _PlayAnimation();
      return tap;
    } else {
      _showDialog(context, message, error);
    }
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
      body: GestureDetector(
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
                image: AssetImage("assets/img/loginBack.jpg"),
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
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Image(
                                        image: AssetImage(
                                            "assets/img/company_logo_only_white.png"),
                                        height: 90.0,
                                      ),
                                    ],
                                  ),
                                  Padding(
                                      padding:
                                          EdgeInsets.symmetric(vertical: 40.0)),
                                  _textFromField(
                                      false,
                                      "Name",
                                      Icons.person,
                                      TextInputType.name,
                                      nameController,
                                      node,
                                      true),
                                  Padding(
                                      padding:
                                          EdgeInsets.symmetric(vertical: 5.0)),
                                  _textFromField(
                                      false,
                                      "Mobile",
                                      Icons.phone,
                                      TextInputType.phone,
                                      mobileController,
                                      node,
                                      true),
                                  Padding(
                                      padding:
                                          EdgeInsets.symmetric(vertical: 5.0)),

                                  /// TextFromField Email
                                  _textFromField(
                                      false,
                                      "Email",
                                      Icons.email,
                                      TextInputType.emailAddress,
                                      emailController,
                                      node,
                                      true),
                                  Padding(
                                      padding:
                                          EdgeInsets.symmetric(vertical: 5.0)),

                                  /// TextFromField Password
                                  _textFromField(
                                      true,
                                      "Password",
                                      Icons.vpn_key,
                                      TextInputType.text,
                                      passwordController,
                                      node,
                                      false),

                                  /// Button Login
                                  FlatButton(
                                      padding: EdgeInsets.only(top: 20.0),
                                      onPressed: () {
                                        Navigator.of(context).push(
                                            MaterialPageRoute(
                                                builder:
                                                    (BuildContext context) =>
                                                        new loginScreen()));
                                      },
                                      child: Text(
                                        "Have Acount? Sign In",
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
                          top: 40,
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
                        tap == 0
                            ? InkWell(
                                splashColor: Colors.yellow,
                                onTap: () {
                                  signup(context);
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
          ],
        ),
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
          "Sign Up",
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
_showDialog(BuildContext ctx, dynamic message, dynamic messageType) {
  showDialog(
    context: ctx,
    barrierDismissible: true,
    builder: (_) => new SimpleDialog(
      children: <Widget>[
        Container(
          padding: EdgeInsets.only(top: 30.0, right: 60.0, left: 60.0),
          height: 110.0,
          decoration: BoxDecoration(
              color: Colors.white,
              image: DecorationImage(
                  image: AssetImage("assets/img/error.png"),
                  fit: BoxFit.contain)),
        ),
        Center(
            child: Padding(
          padding: const EdgeInsets.only(top: 16.0),
          child: Text(
            "Error",
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
          ),
        )),
      ],
    ),
  );
}
