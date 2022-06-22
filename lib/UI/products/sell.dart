import 'dart:convert';

import 'package:vadasada/UI/AcountUIComponent/OrderList.dart';
import 'package:vadasada/UI/AcountUIComponent/changePassword.dart';
import 'package:vadasada/UI/AcountUIComponent/profileSetting.dart';
import 'package:vadasada/UI/AcountUIComponent/userWishlist.dart';
import 'package:vadasada/Api/api.dart';
import 'package:vadasada/UI/HomeUIComponent/ContactUs.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:localstorage/localstorage.dart';
import 'package:vadasada/UI/LoginOrSignup/Login.dart';
import 'package:vadasada/UI/LoginOrSignup/Signup.dart';

class sell extends StatefulWidget {
  @override
  _sellState createState() => _sellState();
}

/// Custom Font
var _txt = TextStyle(
  color: Colors.black,
  fontFamily: "Sans",
);

/// Get _txt and custom value of Variable for Name User
var _txtName = _txt.copyWith(fontWeight: FontWeight.w700, fontSize: 17.0);

/// Get _txt and custom value of Variable for Edit text
var _txtEdit = _txt.copyWith(color: Colors.black26, fontSize: 15.0);

/// Get _txt and custom value of Variable for Category Text
var _txtCategory = _txt.copyWith(
    fontSize: 14.5, color: Colors.black54, fontWeight: FontWeight.w500);

class _sellState extends State<sell> {
  @override
  final LocalStorage storage = new LocalStorage('vadasada');
  User userData = new User();
  var user;
  var notify_token;
  bool showselle = false;

  @override
  void initState() {
    if (storage.getItem("user") != null) {
      setState(() {
        user = storage.getItem("user");
        notify_token = storage.getItem("firebase_token").toString();
        userData.id = user["id"];
        userData.role = user["role"];
        userData.name = user["name"];
        userData.email = user["email"];
        userData.mobile = user["mobile"];
        userData.phone = user["phone"];
        userData.address = user["address"];
        userData.delivery_address = user["delivery_address"];
        userData.city = user["city"];
        if (user['image'] != null) {
          userData.image = user["image"];
        } else if (user['facebook_image'] != null) {
          userData.facebook_image = user["facebook_image"];
        }
        showselle = true;
      });
      // if (user['id'] == 34) {
      //   print('int');
      // }
      // print(user['id']);
    }
    // print(storage.getItem("user"));
    super.initState();
  }

  Widget build(BuildContext context) {
    /// Declare MediaQueryData
    MediaQueryData mediaQueryData = MediaQuery.of(context);
    double height = mediaQueryData.size.height;
    double width = mediaQueryData.size.width;

    /// To Sett Photoselle,Name and Edit selle
    return Scaffold(
        body: showselle
            ? SingleChildScrollView(
                child: Container(
                color: Colors.white,
                child: Stack(
                  children: <Widget>[
                    /// Setting Header Banner
                    Container(
                      height: 240.0,
                      decoration: BoxDecoration(
                          image: DecorationImage(
                              image: AssetImage(
                                  "assets/mainSlider/accountHeader.jpg"),
                              fit: BoxFit.cover)),
                    ),

                    Padding(
                      padding: EdgeInsets.only(
                        top: 185.0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          Container(),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Container(
                                height: 100.0,
                                width: 100.0,
                                decoration: BoxDecoration(
                                    border: Border.all(
                                        color: Colors.white, width: 2.5),
                                    shape: BoxShape.circle,
                                    image: DecorationImage(
                                        image: user['image'] != null
                                            ? NetworkImage(userData.image)
                                            : (user['facebook_image'] != null
                                                ? NetworkImage(
                                                    userData.facebook_image)
                                                : AssetImage(
                                                    "assets/img/user_profile.png")))),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 5.0),
                                child: Text(
                                  userData.name,
                                  style: _txtName,
                                ),
                              ),
                            ],
                          ),
                          Container(),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 330.0),
                      child: Column(
                        /// Setting Category List
                        children: <Widget>[
                          // Call category class
                          // category(
                          //   txt: "My Orders",
                          //   padding: 30.0,
                          //   isImage: true,
                          //   icon: FontAwesomeIcons.truck,
                          //   tap: () {
                          //     Navigator.of(context).push(PageRouteBuilder(
                          //         pageBuilder: (_, __, ___) =>
                          //             new orderList()));
                          //   },
                          // ),
                          // Padding(
                          //   padding: const EdgeInsets.only(
                          //       top: 20.0, left: 85.0, right: 30.0),
                          //   child: Divider(
                          //     color: Colors.black12,
                          //     height: 2.0,
                          //   ),
                          // ),
                          // category(
                          //   padding: 30.0,
                          //   txt: "Wishlist",
                          //   isImage: false,
                          //   icon: Icons.favorite,
                          //   tap: () {
                          //     Navigator.of(context).push(PageRouteBuilder(
                          //         pageBuilder: (_, __, ___) => new wishlist(
                          //               userID: userData.id,
                          //             )));
                          //   },
                          // ),
                          Padding(
                            padding: const EdgeInsets.only(
                                top: 20.0, left: 85.0, right: 30.0),
                            child: Divider(
                              color: Colors.black12,
                              height: 2.0,
                            ),
                          ),
                          category(
                            txt: "Account Setting",
                            padding: 30.0,
                            isImage: true,
                            icon: FontAwesomeIcons.cogs,
                            tap: () {
                              Navigator.of(context).push(PageRouteBuilder(
                                  pageBuilder: (_, __, ___) =>
                                      new profileSetting(
                                        userID: userData.id,
                                      )));
                            },
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                                top: 20.0, left: 85.0, right: 30.0),
                            child: Divider(
                              color: Colors.black12,
                              height: 2.0,
                            ),
                          ),
                          category(
                            txt: "Change Password",
                            padding: 30.0,
                            isImage: true,
                            icon: FontAwesomeIcons.key,
                            tap: () {
                              Navigator.of(context).push(PageRouteBuilder(
                                  pageBuilder: (_, __, ___) =>
                                      new changePassword(
                                        userID: userData.id,
                                      )));
                            },
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                                top: 20.0, left: 85.0, right: 30.0),
                            child: Divider(
                              color: Colors.black12,
                              height: 2.0,
                            ),
                          ),
                          category(
                            padding: 30.0,
                            txt: "Help Center",
                            isImage: false,
                            icon: Icons.contact_support_sharp,
                            tap: () {
                              Navigator.of(context).push(PageRouteBuilder(
                                  pageBuilder: (_, __, ___) =>
                                      new contactUs()));
                            },
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                                top: 20.0, left: 85.0, right: 30.0),
                            child: Divider(
                              color: Colors.black12,
                              height: 2.0,
                            ),
                          ),
                          category(
                            padding: 30.0,
                            txt: "Logout",
                            isImage: false,
                            icon: Icons.power_settings_new,
                            tap: () {
                              _showMyDialog();
                            },
                          ),

                          Padding(padding: EdgeInsets.only(bottom: 20.0)),
                        ],
                      ),
                    ),
                  ],
                ),
              ))
            : Stack(children: <Widget>[
                Container(
                  decoration: BoxDecoration(
                      image: DecorationImage(
                          image: AssetImage('assets/img/loginBack.jpg'),
                          fit: BoxFit.cover)),
                ),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                        colors: [
                          Color.fromRGBO(0, 0, 0, 0.2),
                          Color.fromRGBO(0, 0, 0, 0.3)
                        ],
                        begin: FractionalOffset.topCenter,
                        end: FractionalOffset.bottomCenter),
                  ),
                  child: Center(
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                        Container(
                          width: width * 0.40,
                          child: Column(children: <Widget>[
                            Image.asset(
                                "assets/img/company_logo_only_white.png",
                                fit: BoxFit.fill)
                          ]),
                        ),
                        Container(
                          height: height * 0.15,
                        ),

                        /// to set Text "get best product...." (Click to open code)
                        Text(
                          "Get best products in vadasada Super Market",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 17.0,
                              fontWeight: FontWeight.w200,
                              fontFamily: "Sans",
                              letterSpacing: 1.3),
                          textAlign: TextAlign.center,
                        ),
                        Container(
                          height: height * 0.15,
                        ),
                        ButtonCustom(
                          txt: "Sign Up",
                          ontap: () => {goToSignUp()},
                        ),
                        Padding(padding: EdgeInsets.only(bottom: 10.0)),
                        ButtonCustom(
                          txt: "Login",
                          ontap: () => {goToLogin()},
                        ),
                      ])),
                )
              ]));
  }

  _showMyDialog() {
    return showDialog(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmation?'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Are you sure you want to logout'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('No'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Yes'),
              onPressed: () {
                Navigator.of(context).pop();
                logout();
              },
            ),
          ],
        );
      },
    );
  }

  logout() async {
    // var parameters = {
    //   'appkey': Api.appkey,
    //   "user_id": user["id"].toString(),
    //   'notify_token': notify_token.toString()
    // };
    // var response = await Api.getRequest(Api.logout, parameters);
    // var data = jsonDecode(response.body);
    // if (data != 0) {
    storage.setItem("user", null);
    setState(() {
      showselle = false;
    });
    // }
  }

  goToLogin() {
    Navigator.of(context)
        .push(PageRouteBuilder(pageBuilder: (_, __, ___) => new loginScreen()));
  }

  goToSignUp() {
    Navigator.of(context)
        .push(PageRouteBuilder(pageBuilder: (_, __, ___) => new Signup()));
  }
}

class ButtonCustom extends StatelessWidget {
  @override
  String txt;
  GestureTapCallback ontap;

  ButtonCustom({this.txt, this.ontap});

  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: ontap,
        splashColor: Colors.white,
        child: LayoutBuilder(builder: (context, constraint) {
          return Container(
            width: 300.0,
            height: 52.0,
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

/// Component category class to set list
class category extends StatelessWidget {
  @override
  String txt;
  GestureTapCallback tap;
  double padding;
  bool isImage;
  IconData icon;

  category({this.txt, this.tap, this.padding, this.isImage, this.icon});

  Widget build(BuildContext context) {
    return InkWell(
      onTap: tap,
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top: 15.0, left: 30.0),
            child: Row(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(right: padding),
                  child: isImage
                      ? FaIcon(icon, color: Colors.black54, size: 25.0)
                      : Icon(
                          icon,
                          color: Colors.black54,
                          size: 25.0,
                        ),
                ),
                Text(
                  txt,
                  style: _txtCategory,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class User {
  String name,
      email,
      mobile,
      phone,
      address,
      delivery_address,
      image,
      facebook_image;
  int id, role, city;

  User(
      {this.id,
      this.role,
      this.name,
      this.email,
      this.mobile,
      this.phone,
      this.address,
      this.delivery_address,
      this.city,
      this.image,
      this.facebook_image});
}
