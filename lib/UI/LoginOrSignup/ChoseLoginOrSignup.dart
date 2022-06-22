import 'dart:async';
import 'package:vadasada/Api/api.dart';
import 'package:flutter/material.dart';
import 'package:vadasada/Library/carousel_pro/carousel_pro.dart';
import 'package:vadasada/UI/BottomNavigationBar.dart';
import 'package:vadasada/UI/LoginOrSignup/Login.dart';
import 'package:vadasada/UI/LoginOrSignup/Signup.dart';
import 'package:localstorage/localstorage.dart';

class ChoseLogin extends StatefulWidget {
  @override
  _ChoseLoginState createState() => _ChoseLoginState();
}

/// Component Widget this layout UI
class _ChoseLoginState extends State<ChoseLogin> with TickerProviderStateMixin {
  /// Declare Animation
  final LocalStorage storage = new LocalStorage('vadasada');

  AnimationController animationController;
  var tapLogin = 0;
  var tapSignup = 0;
  var tapSkip = 0;

  @override

  /// Declare animation in initState
  void initState() {
    // TODO: implement initState
    /// Animation proses duration
    animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 500))
          ..addStatusListener((statuss) {
            if (statuss == AnimationStatus.dismissed) {
              setState(() {
                tapLogin = 0;
                tapSignup = 0;
                tapSkip = 0;
              });
            }
          });
    super.initState();
  }

  /// To dispose animation controller
  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
    // TODO: implement dispose
  }

  /// Playanimation set forward reverse
  Future<Null> _Playanimation() async {
    try {
      await animationController.forward();
      await animationController.reverse();
    } on TickerCanceled {}
  }

  /// Component Widget layout UI
  @override
  Widget build(BuildContext context) {
    MediaQueryData mediaQuery = MediaQuery.of(context);
    mediaQuery.devicePixelRatio;
    double height = mediaQuery.size.height;
    mediaQuery.size.width;
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: <Widget>[
          ///
          /// Set background image slider
          ///
          Container(
            color: Colors.white,
            child: new Carousel(
              boxFit: BoxFit.cover,
              autoplay: true,
              animationDuration: Duration(milliseconds: 300),
              dotSize: 0.0,
              dotSpacing: 16.0,
              dotBgColor: Colors.transparent,
              showIndicator: false,
              overlayShadow: false,
              images: [
                AssetImage("assets/img/loginBack.jpg"),
                // AssetImage("assets/mainSlider/2.jpg"),
                // AssetImage("assets/mainSlider/3.jpg"),
                // AssetImage("assets/mainSlider/4.jpg"),
              ],
            ),
          ),
          Container(
            /// Set Background image in layout (Click to open code)
            decoration: BoxDecoration(
//              image: DecorationImage(
//                  image: AssetImage('assets/img/girl.png'), fit: BoxFit.cover)
                ),
            child: Container(
              /// Set gradient color in image (Click to open code)
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                      colors: [
                    Color.fromRGBO(0, 0, 0, 0.5),
                    Color.fromRGBO(0, 0, 0, 0.7)
                  ],
                      begin: FractionalOffset.topCenter,
                      end: FractionalOffset.bottomCenter)),

              /// Set component layout
              child: ListView(
                padding: EdgeInsets.all(0.0),
                children: <Widget>[
                  Stack(
                    alignment: AlignmentDirectional.bottomCenter,
                    children: <Widget>[
                      Stack(
                        alignment: AlignmentDirectional.bottomCenter,
                        children: <Widget>[
                          Container(
                            alignment: AlignmentDirectional.center,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Padding(
                                  padding: EdgeInsets.only(
                                      top: mediaQuery.padding.top + 50.0),
                                ),
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
                                SizedBox(
                                  height: height * 0.3,
                                ),

                                /// Padding Text "Get best product in treva shop" (Click to open code)

                                /// to set Text "get best product...." (Click to open code)
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 50, right: 50),
                                  child: Text(
                                    "Get best products in Vada Sada",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 17.0,
                                        fontWeight: FontWeight.w300,
                                        fontFamily: "Sans",
                                        letterSpacing: 1.3),
                                  ),
                                ),
                                SizedBox(
                                  height: height * 0.30,
                                )
                              ],
                            ),
                          ),
                          Stack(
                            alignment: AlignmentDirectional.bottomCenter,
                            children: <Widget>[
                              /// To create animation if user tap == animation play (Click to open code)
                              Column(
                                children: [
                                  tapLogin == 0
                                      ? Material(
                                          color: Colors.transparent,
                                          child: InkWell(
                                            splashColor: Colors.white,
                                            onTap: () {
                                              setState(() {
                                                tapLogin = 1;
                                              });
                                              _Playanimation();
                                              return tapLogin;
                                            },
                                            child: ButtonCustom(txt: "Signup"),
                                          ),
                                        )
                                      : AnimationSplashSignup(
                                          animationController:
                                              animationController.view,
                                        ),
                                  Padding(
                                      padding:
                                          const EdgeInsets.only(top: 110.0))
                                ],
                              ),
                              Column(
                                children: [
                                  tapSkip == 0
                                      ? Material(
                                          color: Colors.transparent,
                                          child: InkWell(
                                            splashColor: Colors.white,
                                            onTap: () {
                                              setState(() {
                                                tapSignup = 1;
                                              });
                                              _Playanimation();
                                              return tapSignup;
                                            },
                                            child: ButtonCustom(txt: "Login"),
                                          ),
                                        )
                                      // Material(
                                      //     color: Colors.transparent,
                                      //     child: InkWell(
                                      //         splashColor: Colors.white,
                                      //         onTap: () {
                                      //           setState(() {
                                      //             tapSkip = 1;
                                      //           });
                                      //           _Playanimation();
                                      //           return tapSkip;
                                      //         },
                                      //         child: ButtonCustomSmall(
                                      //           txt: "OR SKIP",
                                      //         )),
                                      //   )
                                      : AnimationSplashHome(
                                          animationController:
                                              animationController.view,
                                        ),
                                  Padding(
                                      padding: const EdgeInsets.only(top: 55.0))
                                ],
                              ),
                            ],
                          ),
                          tapSignup == 0
                              ? Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    splashColor: Colors.white,
                                    onTap: () {
                                      setState(() {
                                        tapSkip = 1;
                                      });
                                      _Playanimation();
                                      return tapSkip;
                                    },
                                    child: ButtonCustom(txt: "Skip"),
                                  ),
                                )
                              : AnimationSplashLogin(
                                  animationController: animationController.view,
                                ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Button Custom widget
class ButtonCustom extends StatelessWidget {
  @override
  String txt;
  GestureTapCallback ontap;

  ButtonCustom({this.txt});

  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        splashColor: Colors.white,
        child: LayoutBuilder(builder: (context, constraint) {
          return Container(
            width: 300.0,
            height: 45.0,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30.0),
                color: Colors.transparent,
                border: Border.all(color: Colors.white)),
            child: Center(
                child: Text(
              txt,
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 19.0,
                  fontWeight: FontWeight.w600,
                  fontFamily: "Sans",
                  letterSpacing: 0.5),
            )),
          );
        }),
      ),
    );
  }
}

class ButtonCustomSmall extends StatelessWidget {
  @override
  String txt;
  GestureTapCallback ontap;

  ButtonCustomSmall({this.txt});

  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        splashColor: Colors.white,
        child: LayoutBuilder(builder: (context, constraint) {
          return Container(
            width: 100,
            height: 40.0,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15.0),
                color: Colors.transparent,
                border: Border.all(color: Colors.white)),
            child: Center(
                child: Text(
              txt,
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 15.0,
                  fontWeight: FontWeight.w600,
                  fontFamily: "Sans",
                  letterSpacing: 0.5),
            )),
          );
        }),
      ),
    );
  }
}

/// Set Animation Login if user click button login
class AnimationSplashLogin extends StatefulWidget {
  AnimationSplashLogin({Key key, this.animationController})
      : animation = new Tween(
          end: 900.0,
          begin: 70.0,
        ).animate(CurvedAnimation(
            parent: animationController, curve: Curves.fastOutSlowIn)),
        super(key: key);

  final AnimationController animationController;
  final Animation animation;

  Widget _buildAnimation(BuildContext context, Widget child) {
    return Padding(
      padding: EdgeInsets.only(bottom: 60.0),
      child: Container(
        height: animation.value,
        width: animation.value,
        decoration: BoxDecoration(
          color: Api.primaryColor,
          shape: animation.value < 600 ? BoxShape.circle : BoxShape.rectangle,
        ),
      ),
    );
  }

  @override
  _AnimationSplashLoginState createState() => _AnimationSplashLoginState();
}

/// Set Animation Login if user click button login
class _AnimationSplashLoginState extends State<AnimationSplashLogin> {
  @override
  Widget build(BuildContext context) {
    widget.animationController.addListener(() {
      if (widget.animation.isCompleted) {
        Navigator.of(context).push(MaterialPageRoute(
            builder: (BuildContext context) => new loginScreen()));
      }
    });
    return AnimatedBuilder(
      animation: widget.animationController,
      builder: widget._buildAnimation,
    );
  }
}

/// Set Animation signup if user click button signup
class AnimationSplashSignup extends StatefulWidget {
  AnimationSplashSignup({Key key, this.animationController})
      : animation = new Tween(
          end: 900.0,
          begin: 70.0,
        ).animate(CurvedAnimation(
            parent: animationController, curve: Curves.fastOutSlowIn)),
        super(key: key);

  final AnimationController animationController;
  final Animation animation;

  Widget _buildAnimation(BuildContext context, Widget child) {
    return Padding(
      padding: EdgeInsets.only(bottom: 60.0),
      child: Container(
        height: animation.value,
        width: animation.value,
        decoration: BoxDecoration(
          color: Api.primaryColor,
          shape: animation.value < 600 ? BoxShape.circle : BoxShape.rectangle,
        ),
      ),
    );
  }

  @override
  _AnimationSplashSignupState createState() => _AnimationSplashSignupState();
}

/// Set Animation signup if user click button signup
class _AnimationSplashSignupState extends State<AnimationSplashSignup> {
  @override
  Widget build(BuildContext context) {
    widget.animationController.addListener(() {
      if (widget.animation.isCompleted) {
        Navigator.of(context).push(
            MaterialPageRoute(builder: (BuildContext context) => new Signup()));
      }
    });
    return AnimatedBuilder(
      animation: widget.animationController,
      builder: widget._buildAnimation,
    );
  }
}

/// Set Animation signup if user click button signup
class AnimationSplashHome extends StatefulWidget {
  AnimationSplashHome({Key key, this.animationController})
      : animation = new Tween(
          end: 900.0,
          begin: 70.0,
        ).animate(CurvedAnimation(
            parent: animationController, curve: Curves.fastOutSlowIn)),
        super(key: key);

  final AnimationController animationController;
  final Animation animation;

  Widget _buildAnimation(BuildContext context, Widget child) {
    return Padding(
      padding: EdgeInsets.only(bottom: 60.0),
      child: Container(
        height: animation.value,
        width: animation.value,
        decoration: BoxDecoration(
          color: Api.primaryColor,
          shape: animation.value < 600 ? BoxShape.circle : BoxShape.rectangle,
        ),
      ),
    );
  }

  @override
  _AnimationSplashHomeState createState() => _AnimationSplashHomeState();
}

/// Set Animation signup if user click button signup
class _AnimationSplashHomeState extends State<AnimationSplashHome> {
  @override
  Widget build(BuildContext context) {
    widget.animationController.addListener(() {
      if (widget.animation.isCompleted) {
        Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (BuildContext context) => new bottomNavigationBar()));
      }
    });
    return AnimatedBuilder(
      animation: widget.animationController,
      builder: widget._buildAnimation,
    );
  }
}
