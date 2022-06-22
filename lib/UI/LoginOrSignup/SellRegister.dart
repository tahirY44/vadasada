import 'dart:async';
import 'dart:convert';

// import 'package:vadasada/UI/HomeUIComponent/Home.dart';
import 'package:flutter/material.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:vadasada/UI/BottomNavigationBar.dart';
import 'package:vadasada/UI/LoginOrSignup/Login.dart';
import 'package:vadasada/Api/api.dart';
import 'package:vadasada/UI/LoginOrSignup/LoginAnimation.dart';
// import 'package:vadasada/UI/LoginOrSellRegister/SellRegister.dart';
import 'package:localstorage/localstorage.dart';
// import 'package:velocity_x/velocity_x.dart';

class SellRegister extends StatefulWidget {
  @override
  _SellRegisterState createState() => _SellRegisterState();
}

class _SellRegisterState extends State<SellRegister>
    with TickerProviderStateMixin {
  //Animation Declaration
  AnimationController sanimationController;
  AnimationController animationControllerScreen;
  final LocalStorage storage = new LocalStorage('vadasada');
  Animation animationScreen;
  var tap = 0;
  bool _loading = false;
  final companyNameController = TextEditingController();
  final displayNameController = TextEditingController();
  final contactPersonController = TextEditingController();
  final mobileController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String company_name,
      display_name,
      contact_person_name,
      email,
      mobile,
      password;

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
    companyNameController.addListener(_company_nameValue);
    displayNameController.addListener(_display_nameValue);
    contactPersonController.addListener(_contact_person_nameValue);
    mobileController.addListener(_mobileValue);
    emailController.addListener(_emailValue);
    passwordController.addListener(_passwordValue);
  }

  /// Dispose animationController
  @override
  void dispose() {
    companyNameController.dispose();
    displayNameController.dispose();
    contactPersonController.dispose();
    mobileController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
    sanimationController.dispose();
  }

  _company_nameValue() {
    setState(() {
      company_name = companyNameController.text;
    });
  }

  _display_nameValue() {
    setState(() {
      display_name = displayNameController.text;
    });
  }

  _contact_person_nameValue() {
    setState(() {
      contact_person_name = contactPersonController.text;
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

  sellRegister(context) async {
    setState(() {
      _loading = true;
    });
    if (_formKey.currentState?.validate()) {
      try {
        var parameters = {
          'appkey': Api.appkey,
          'company_name': company_name,
          'name': display_name,
          'contact_person': contact_person_name,
          'mobile': mobile,
          'email': email,
          'password': password,
          'notify_token': '6564tfg65fguh'
        };

        // print(parameters);
        var response = await Api.postRequest(Api.signup_merchant, parameters);
        var data = jsonDecode(response.body);

        var message = data['msg'];
        var error = data['error'];
        setState(() {
          _loading = false;
        });

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
      } catch (e) {
        print(e);
      }
    }
  }

  /// Component Widget layout UI
  @override
  Widget build(BuildContext context) {
    MediaQueryData mediaQueryData = MediaQuery.of(context);
    // mediaQueryData.devicePixelRatio;
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
                      Form(
                        key: _formKey,
                        child: Stack(
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
                                                  20.0)),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: <Widget>[
                                          Image(
                                            image: AssetImage(
                                                "assets/img/company_logo_only_white.png"),
                                            height: 100.0,
                                          ),
                                        ],
                                      ),

                                      /// TextFromField Company Name
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 30.0),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              'Company Name',
                                              style: TextStyle(
                                                  // fontWeight: FontWeight.bold,
                                                  fontSize: 14,
                                                  color: Colors.white),
                                            ),
                                            Text(
                                              'کمپنی کا نام',
                                              style: TextStyle(
                                                  // fontWeight: FontWeight.bold,
                                                  fontSize: 14,
                                                  color: Colors.white),
                                            )
                                          ],
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 30.0),
                                        child: TextFormField(
                                          controller: companyNameController,
                                          onEditingComplete: () =>
                                              node.nextFocus(),
                                          style: TextStyle(
                                            letterSpacing: 0.3,
                                            color: Colors.black,
                                            // fontWeight: FontWeight.w600,
                                          ),
                                          decoration: const InputDecoration(
                                            errorStyle: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 13,
                                            ),
                                            fillColor: Colors.white,
                                            filled: true,
                                            focusedBorder: OutlineInputBorder(
                                              borderSide: const BorderSide(
                                                color: Colors.white,
                                                width: 1,
                                              ),
                                            ),
                                            enabledBorder:
                                                const OutlineInputBorder(
                                              borderRadius: BorderRadius.all(
                                                Radius.circular(6),
                                              ),
                                              borderSide: const BorderSide(
                                                color: Colors.white,
                                                width: 0.5,
                                              ),
                                            ),
                                            border: const OutlineInputBorder(),
                                            isDense: true,
                                            contentPadding: EdgeInsets.fromLTRB(
                                                10, 20, 10, 0),
                                            hintText: 'Enter Your Company Name',
                                            hintStyle: TextStyle(
                                              fontSize: 12,
                                              color: Colors.black,
                                            ),
                                          ),
                                          validator: (value) {
                                            if (value?.isEmpty) {
                                              return "Company Name cannot be empty";
                                            }
                                            return null;
                                          },
                                          onChanged: (value) {
                                            company_name = value;
                                            setState(() {});
                                          },
                                        ),
                                      ),

                                      /// TextFromField Display Name
                                      Padding(
                                          padding: EdgeInsets.symmetric(
                                              vertical: 5.0)),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 30.0),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              'Display Name',
                                              style: TextStyle(
                                                  // fontWeight: FontWeight.bold,
                                                  fontSize: 14,
                                                  color: Colors.white),
                                            ),
                                            Text(
                                              'دکھانے کا نام',
                                              style: TextStyle(
                                                  // fontWeight: FontWeight.bold,
                                                  fontSize: 14,
                                                  color: Colors.white),
                                            )
                                          ],
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 30.0),
                                        child: TextFormField(
                                          controller: displayNameController,
                                          onEditingComplete: () =>
                                              node.nextFocus(),
                                          style: TextStyle(
                                            letterSpacing: 0.3,
                                            color: Colors.black,
                                          ),
                                          decoration: const InputDecoration(
                                            errorStyle: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 13,
                                            ),
                                            fillColor: Colors.white,
                                            filled: true,
                                            focusedBorder: OutlineInputBorder(
                                              borderSide: const BorderSide(
                                                color: Colors.white,
                                                width: 1,
                                              ),
                                            ),
                                            enabledBorder:
                                                const OutlineInputBorder(
                                              borderRadius: BorderRadius.all(
                                                Radius.circular(6),
                                              ),
                                              borderSide: const BorderSide(
                                                color: Colors.white,
                                                width: 0.5,
                                              ),
                                            ),
                                            border: const OutlineInputBorder(),
                                            isDense: true,
                                            contentPadding: EdgeInsets.fromLTRB(
                                                10, 20, 10, 0),
                                            hintText: 'Enter Your Display Name',
                                            hintStyle: TextStyle(
                                              fontSize: 12,
                                              color: Colors.black,
                                            ),
                                          ),
                                          validator: (value) {
                                            if (value?.isEmpty) {
                                              return "Display Name cannot be empty";
                                            }
                                            return null;
                                          },
                                          onChanged: (value) {
                                            display_name = value;
                                            setState(() {});
                                          },
                                        ),
                                      ),

                                      /// TextFromField Contact Person Name
                                      Padding(
                                          padding: EdgeInsets.symmetric(
                                              vertical: 5.0)),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 30.0),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              'Contact Person Name',
                                              style: TextStyle(
                                                  // fontWeight: FontWeight.bold,
                                                  fontSize: 14,
                                                  color: Colors.white),
                                            ),
                                            Text(
                                              'رابطہ کا نام',
                                              style: TextStyle(
                                                  // fontWeight: FontWeight.bold,
                                                  fontSize: 14,
                                                  color: Colors.white),
                                            )
                                          ],
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 30.0),
                                        child: TextFormField(
                                          controller: contactPersonController,
                                          onEditingComplete: () =>
                                              node.nextFocus(),
                                          style: TextStyle(
                                            letterSpacing: 0.3,
                                            color: Colors.black,
                                            // fontWeight: FontWeight.w600,
                                          ),
                                          decoration: const InputDecoration(
                                            errorStyle: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 13,
                                            ),
                                            fillColor: Colors.white,
                                            filled: true,
                                            focusedBorder: OutlineInputBorder(
                                              borderSide: const BorderSide(
                                                color: Colors.white,
                                                width: 1,
                                              ),
                                            ),
                                            enabledBorder:
                                                const OutlineInputBorder(
                                              borderRadius: BorderRadius.all(
                                                Radius.circular(6),
                                              ),
                                              borderSide: const BorderSide(
                                                color: Colors.white,
                                                width: 0.5,
                                              ),
                                            ),
                                            border: const OutlineInputBorder(),
                                            isDense: true,
                                            contentPadding: EdgeInsets.fromLTRB(
                                                10, 20, 10, 0),
                                            hintText:
                                                'Enter Your Contact Person Name',
                                            hintStyle: TextStyle(
                                              fontSize: 12,
                                              color: Colors.black,
                                            ),
                                          ),
                                          validator: (value) {
                                            if (value?.isEmpty) {
                                              return "Contact Person Name cannot be empty";
                                            }
                                            return null;
                                          },
                                          onChanged: (value) {
                                            contact_person_name = value;
                                            setState(() {});
                                          },
                                        ),
                                      ),

                                      /// TextFromField Contact No.
                                      Padding(
                                          padding: EdgeInsets.symmetric(
                                              vertical: 5.0)),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 30.0),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              'Contact No.',
                                              style: TextStyle(
                                                  // fontWeight: FontWeight.bold,
                                                  fontSize: 14,
                                                  color: Colors.white),
                                            ),
                                            Text(
                                              'رابطہ نمبر',
                                              style: TextStyle(
                                                  // fontWeight: FontWeight.bold,
                                                  fontSize: 14,
                                                  color: Colors.white),
                                            )
                                          ],
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 30.0),
                                        child: TextFormField(
                                          onEditingComplete: () =>
                                              node.nextFocus(),
                                          controller: mobileController,
                                          style: TextStyle(
                                            letterSpacing: 0.3,
                                            color: Colors.black,
                                            // fontWeight: FontWeight.w600,
                                          ),
                                          decoration: const InputDecoration(
                                            errorStyle: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 13,
                                            ),
                                            fillColor: Colors.white,
                                            filled: true,
                                            focusedBorder: OutlineInputBorder(
                                              borderSide: const BorderSide(
                                                color: Colors.white,
                                                width: 1,
                                              ),
                                            ),
                                            enabledBorder:
                                                const OutlineInputBorder(
                                              borderRadius: BorderRadius.all(
                                                Radius.circular(6),
                                              ),
                                              borderSide: const BorderSide(
                                                color: Colors.white,
                                                width: 0.5,
                                              ),
                                            ),
                                            border: const OutlineInputBorder(),
                                            isDense: true,
                                            contentPadding: EdgeInsets.fromLTRB(
                                                10, 20, 10, 0),
                                            hintText: 'Enter Your Contact No.',
                                            hintStyle: TextStyle(
                                              fontSize: 12,
                                              color: Colors.black,
                                            ),
                                          ),
                                          validator: (value) {
                                            if (value?.isEmpty) {
                                              return "Contact No cannot be empty";
                                            }
                                            return null;
                                          },
                                          onChanged: (value) {
                                            mobile = value;
                                            setState(() {});
                                          },
                                        ),
                                      ),

                                      /// TextFromField Email
                                      Padding(
                                          padding: EdgeInsets.symmetric(
                                              vertical: 5.0)),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 30.0),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              'Email',
                                              style: TextStyle(
                                                  // fontWeight: FontWeight.bold,
                                                  fontSize: 14,
                                                  color: Colors.white),
                                            ),
                                            Text(
                                              'ای میل',
                                              style: TextStyle(
                                                  // fontWeight: FontWeight.bold,
                                                  fontSize: 14,
                                                  color: Colors.white),
                                            )
                                          ],
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 30.0),
                                        child: TextFormField(
                                          onEditingComplete: () =>
                                              node.nextFocus(),
                                          controller: emailController,
                                          style: TextStyle(
                                            letterSpacing: 0.3,
                                            color: Colors.black,
                                            // fontWeight: FontWeight.w600,
                                          ),
                                          decoration: const InputDecoration(
                                            errorStyle: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 13,
                                            ),
                                            fillColor: Colors.white,
                                            filled: true,
                                            focusedBorder: OutlineInputBorder(
                                              borderSide: const BorderSide(
                                                color: Colors.white,
                                                width: 1,
                                              ),
                                            ),
                                            enabledBorder:
                                                const OutlineInputBorder(
                                              borderRadius: BorderRadius.all(
                                                Radius.circular(6),
                                              ),
                                              borderSide: const BorderSide(
                                                color: Colors.white,
                                                width: 0.5,
                                              ),
                                            ),
                                            border: const OutlineInputBorder(),
                                            isDense: true,
                                            contentPadding: EdgeInsets.fromLTRB(
                                                10, 20, 10, 0),
                                            hintText: 'Enter Your Email',
                                            hintStyle: TextStyle(
                                              fontSize: 12,
                                              color: Colors.black,
                                            ),
                                          ),
                                          validator: (value) {
                                            if (value?.isEmpty) {
                                              return "Contact No cannot be empty";
                                            }
                                            return null;
                                          },
                                          onChanged: (value) {
                                            mobile = value;
                                            setState(() {});
                                          },
                                        ),
                                      ),

                                      /// TextFromField Password
                                      Padding(
                                          padding: EdgeInsets.symmetric(
                                              vertical: 5.0)),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 30.0),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              'Password',
                                              style: TextStyle(
                                                  // fontWeight: FontWeight.bold,
                                                  fontSize: 14,
                                                  color: Colors.white),
                                            ),
                                            Text(
                                              'پاسورڈ',
                                              style: TextStyle(
                                                  // fontWeight: FontWeight.bold,
                                                  fontSize: 14,
                                                  color: Colors.white),
                                            )
                                          ],
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 30.0),
                                        child: TextFormField(
                                          onEditingComplete: () =>
                                              node.unfocus(),
                                          controller: emailController,
                                          style: TextStyle(
                                            letterSpacing: 0.3,
                                            color: Colors.black,
                                            // fontWeight: FontWeight.w600,
                                          ),
                                          decoration: const InputDecoration(
                                            fillColor: Colors.white,
                                            filled: true,
                                            errorStyle: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 13,
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderSide: const BorderSide(
                                                color: Colors.white,
                                                width: 1,
                                              ),
                                            ),
                                            enabledBorder:
                                                const OutlineInputBorder(
                                              borderRadius: BorderRadius.all(
                                                Radius.circular(6),
                                              ),
                                              borderSide: const BorderSide(
                                                color: Colors.white,
                                                width: 0.5,
                                              ),
                                            ),
                                            border: const OutlineInputBorder(),
                                            isDense: true,
                                            contentPadding: EdgeInsets.fromLTRB(
                                                10, 20, 10, 0),
                                            hintText: 'Enter Your Password',
                                            hintStyle: TextStyle(
                                              fontSize: 12,
                                              color: Colors.black,
                                            ),
                                          ),
                                          validator: (value) {
                                            if (value?.isEmpty) {
                                              return "Password cannot be empty";
                                            }
                                            return null;
                                          },
                                          onChanged: (value) {
                                            mobile = value;
                                            setState(() {});
                                          },
                                        ),
                                      ),

                                      /// Button Login
                                      FlatButton(
                                          padding: EdgeInsets.only(top: 20.0),
                                          onPressed: () {
                                            Navigator.of(context).push(
                                                MaterialPageRoute(
                                                    builder: (BuildContext
                                                            context) =>
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
                                            top: mediaQueryData.padding.top +
                                                50.0,
                                            bottom: 0.0),
                                      )
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            // Positioned(
                            //   top: 40,
                            //   right: 5,
                            //   child: IconButton(
                            //     icon: new Icon(
                            //       Icons.home,
                            //       color: Colors.white,
                            //       size: 30,
                            //     ),
                            //     onPressed: () => Navigator.of(context)
                            //         .pushAndRemoveUntil(
                            //             MaterialPageRoute(
                            //                 builder: (BuildContext context) =>
                            //                     new bottomNavigationBar()),
                            //             (r) => false),
                            //   ),
                            // ),
                            tap == 0
                                ? InkWell(
                                    splashColor: Colors.black,
                                    onTap: () {
                                      sellRegister(context);
                                    },
                                    child: buttonBlackBottom(),
                                  )
                                : new LoginAnimation(
                                    animationController:
                                        sanimationController.view,
                                  )
                          ],
                        ),
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
              color: Colors.black,
              letterSpacing: 0.2,
              fontFamily: "Sans",
              fontSize: 18.0,
              fontWeight: FontWeight.w800),
        ),
        alignment: FractionalOffset.center,
        decoration: BoxDecoration(
            boxShadow: [BoxShadow(color: Colors.black38, blurRadius: 15.0)],
            borderRadius: BorderRadius.circular(30.0),
            color: Colors.white),
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
