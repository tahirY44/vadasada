import 'dart:convert';

import 'package:vadasada/Api/api.dart';
import 'package:flutter/material.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:localstorage/localstorage.dart';

class profileSetting extends StatefulWidget {
  final int userID;

  const profileSetting({this.userID, key}) : super(key: key);

  @override
  _profileSettingState createState() => _profileSettingState();
}

class _profileSettingState extends State<profileSetting> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final mobileController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();
  final deliveryAddressController = TextEditingController();
  final LocalStorage storage = new LocalStorage('vadasada');

  var user;

  selectItem gender, city;

  List<selectItem> genderData = [
    selectItem(1, "Male"),
    selectItem(2, "Female")
  ];

  List<selectItem> cityData = [];

  String name = "",
      email = "",
      mobile = "",
      phone = "",
      address = "",
      deliveryAddress = "";
  int userID;
  bool _loading = false;

  getCities() async {
    var parameters = {'appkey': Api.appkey, 'country': '1'};
    var response = await Api.getRequest(Api.get_cities, parameters);
    var data = jsonDecode(response.body);

    if (data != 0) {
      for (var i = 0; i < data.length; i++) {
        var id = data[i]['id'];
        var title = data[i]['title'];
        setState(() {
          cityData.add(selectItem(id, title));
        });
      }
    }
    setState(() {
      user = storage.getItem("user");
      nameController.text = name = user["name"];
      emailController.text = email = user["email"];
      if (user['mobile'] != null) {
        mobileController.text = mobile = user["mobile"];
      }
      if (user['phone'] != null) {
        phoneController.text = phone = user["phone"];
      }
      if (user['address'] != null) {
        addressController.text = address = user["address"];
      }
      if (user['delivery_address'] != null) {
        deliveryAddressController.text =
            deliveryAddress = user["delivery_address"];
      }
      if (user['gender'] != 0) {
        if (user['gender'] == 1) {
          gender = genderData[0];
        } else {
          gender = genderData[1];
        }
      }
      for (var i = 0; i < cityData.length; i++) {
        if (cityData[i].id == user['city']) {
          city = cityData[i];
        }
      }
      _loading = false;
    });
  }

  void initState() {
    // TODO: implement initState
    super.initState();
    setState(() {
      _loading = true;
    });
    getCities();
    nameController.addListener(_nameValue);
    emailController.addListener(_emailValue);
    mobileController.addListener(_mobileValue);
    phoneController.addListener(_phoneValue);
    addressController.addListener(_addressValue);
    deliveryAddressController.addListener(_deliveryAddressValue);
    setState(() {
      userID = widget.userID;
    });
  }

  void dispose() {
    nameController.dispose();
    emailController.dispose();
    mobileController.dispose();
    phoneController.dispose();
    addressController.dispose();
    deliveryAddressController.dispose();
    super.dispose();
  }

  _nameValue() {
    setState(() {
      name = nameController.text;
    });
  }

  _emailValue() {
    setState(() {
      email = emailController.text;
    });
  }

  _mobileValue() {
    setState(() {
      mobile = mobileController.text;
    });
  }

  _phoneValue() {
    setState(() {
      phone = phoneController.text;
    });
  }

  _addressValue() {
    setState(() {
      address = addressController.text;
    });
  }

  _deliveryAddressValue() {
    setState(() {
      deliveryAddress = deliveryAddressController.text;
    });
  }

  Widget build(BuildContext context) {
    MediaQueryData mediaQueryData = MediaQuery.of(context);
    double size = mediaQueryData.size.height;
    double width = mediaQueryData.size.width;
    FocusScopeNode node = FocusScope.of(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Api.primaryColor,
        title: Text(
          "Account Setting",
          style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 20.0,
              color: Colors.white,
              fontFamily: "Gotik"),
        ),
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
        elevation: 0.0,
      ),
      body: LoadingOverlay(
          color: Colors.white,
          isLoading: _loading,
          child: GestureDetector(
            onTap: () {
              FocusScopeNode currentFocus = FocusScope.of(context);
              if (!currentFocus.hasPrimaryFocus) {
                currentFocus.unfocus();
              }
            },
            child: SingleChildScrollView(
                child: Container(
                    width: width,
                    color: Colors.white,
                    child: Padding(
                        padding: const EdgeInsets.only(
                            top: 20.0, left: 20, right: 20.0),
                        child: Column(children: <Widget>[
                          Padding(padding: EdgeInsets.only(top: 20.0)),
                          TextField(
                            controller: nameController,
                            keyboardType: TextInputType.text,
                            decoration: InputDecoration(
                                labelText: "Name *",
                                hintText: "Name *",
                                hintStyle: TextStyle(color: Colors.black54)),
                            onEditingComplete: () => node.nextFocus(),
                          ),
                          Padding(padding: EdgeInsets.only(top: 20.0)),
                          TextField(
                            controller: emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                                labelText: "Email *",
                                hintText: "Email *",
                                hintStyle: TextStyle(color: Colors.black54)),
                            onEditingComplete: () => node.nextFocus(),
                          ),
                          Padding(padding: EdgeInsets.only(top: 20.0)),
                          TextField(
                            controller: mobileController,
                            keyboardType: TextInputType.phone,
                            decoration: InputDecoration(
                                labelText: "Mobile *",
                                hintText: "Mobile *",
                                hintStyle: TextStyle(color: Colors.black54)),
                            onEditingComplete: () => node.nextFocus(),
                          ),
                          Padding(padding: EdgeInsets.only(top: 20.0)),
                          TextField(
                            controller: phoneController,
                            keyboardType: TextInputType.phone,
                            decoration: InputDecoration(
                                labelText: "Phone *",
                                hintText: "Phone *",
                                hintStyle: TextStyle(color: Colors.black54)),
                            onSubmitted: (_) => node.unfocus(),
                          ),
                          Padding(padding: EdgeInsets.only(top: 20.0)),
                          Container(
                            width: width * 0.8,
                            decoration: BoxDecoration(
                                color: Color(0xFFFFFFFF),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(5.0)),
                                boxShadow: [
                                  BoxShadow(
                                    color: Color(0xFF000000).withOpacity(0.8),
                                    blurRadius: 2.0,
                                    spreadRadius: 0.5,
//           offset: Offset(4.0, 10.0)
                                  )
                                ],
                                shape: BoxShape.rectangle),
                            child: DropdownButtonHideUnderline(
                              child: ButtonTheme(
                                alignedDropdown: true,
                                child: DropdownButton<selectItem>(
                                    isExpanded: true,
                                    hint: Text("Select Gender"),
                                    value: gender,
                                    onChanged: (selectItem Value) {
                                      setState(() {
                                        gender = Value;
                                      });
                                    },
                                    items: genderData.map((selectItem item) {
                                      return DropdownMenuItem<selectItem>(
                                        value: item,
                                        child: Row(
                                          children: <Widget>[
                                            Text(
                                              item.title,
                                              style: TextStyle(
                                                  color: Colors.black),
                                            ),
                                          ],
                                        ),
                                      );
                                    }).toList()),
                              ),
                            ),
                          ),
                          Padding(padding: EdgeInsets.only(top: 20.0)),
                          Container(
                            width: width * 0.8,
                            decoration: BoxDecoration(
                                color: Color(0xFFFFFFFF),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(5.0)),
                                boxShadow: [
                                  BoxShadow(
                                    color: Color(0xFF000000).withOpacity(0.8),
                                    blurRadius: 2.0,
                                    spreadRadius: 0.5,
//           offset: Offset(4.0, 10.0)
                                  )
                                ],
                                shape: BoxShape.rectangle),
                            child: DropdownButtonHideUnderline(
                              child: ButtonTheme(
                                alignedDropdown: true,
                                child: DropdownButton<selectItem>(
                                    isExpanded: true,
                                    hint: Text("Select City"),
                                    value: city,
                                    onChanged: (selectItem Value) {
                                      setState(() {
                                        city = Value;
                                      });
                                    },
                                    items: cityData.map((selectItem item) {
                                      return DropdownMenuItem<selectItem>(
                                        value: item,
                                        child: Row(
                                          children: <Widget>[
                                            Text(
                                              item.title,
                                              style: TextStyle(
                                                  color: Colors.black),
                                            ),
                                          ],
                                        ),
                                      );
                                    }).toList()),
                              ),
                            ),
                          ),
                          Padding(padding: EdgeInsets.only(top: 20.0)),
                          TextField(
                            controller: addressController,
                            keyboardType: TextInputType.text,
                            maxLines: 3,
                            decoration: InputDecoration(
                                labelText: "Address *",
                                hintText: "Address *",
                                hintStyle: TextStyle(color: Colors.black54)),
                            onEditingComplete: () => node.nextFocus(),
                          ),
                          Padding(padding: EdgeInsets.only(top: 20.0)),
                          TextField(
                            controller: deliveryAddressController,
                            keyboardType: TextInputType.text,
                            maxLines: 3,
                            decoration: InputDecoration(
                                labelText: "Delivery Address *",
                                hintText: "Delivery Address *",
                                hintStyle: TextStyle(color: Colors.black54)),
                            onSubmitted: (_) => node.unfocus(),
                          ),
                          Padding(padding: EdgeInsets.only(top: 40.0)),
                          InkWell(
                            onTap: () {
                              submitMessage(context);
                            },
                            child: Container(
                              height: 55.0,
                              width: width * 0.6,
                              decoration: BoxDecoration(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(40.0)),
                                  color: Api.primaryColor),
                              child: Center(
                                child: Text(
                                  "Submit",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 16.5,
                                      letterSpacing: 1.0),
                                ),
                              ),
                            ),
                          ),
                          Padding(padding: EdgeInsets.only(bottom: 50))
                        ])))),
          )),
    );
  }

  void submitMessage(BuildContext context) async {
    if (name.isEmpty ||
        email.isEmpty ||
        mobile.isEmpty ||
        phone.isEmpty ||
        address.isEmpty ||
        deliveryAddress.isEmpty ||
        gender == null ||
        city == null) {
      _showMyDialog("Please fill all mandatory fields");
    } else {
      setState(() {
        _loading = true;
      });
      var parameters = {
        'appkey': Api.appkey,
        'uid': userID.toString(),
        'name': name,
        'email': email,
        'mobile': mobile,
        'phone': phone,
        'gender': gender.id.toString(),
        'city': city.id.toString(),
        'address': address,
        'delivery_address': deliveryAddress
      };
      var response = await Api.getRequest(Api.update_profile, parameters);
      var data = jsonDecode(response.body);
      setState(() {
        _loading = false;
      });
      print(data);
      if (data != 0) {
        storage.setItem("user", data);
        _showDialog("Profile updated Successfully", 1);
      } else {
        _showDialog("User with same email already exist", 0);
      }
    }
  }

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

  _showDialog(dynamic message, dynamic messageType) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return SimpleDialog(
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
                  top: 10.0, bottom: 20.0, left: 20.0, right: 20.0),
              child: Text(
                message,
                style: _txtCustomSub,
              ),
            )),
            Center(
                child: Padding(
              padding: const EdgeInsets.only(
                  top: 15.0, bottom: 10.0, left: 20.0, right: 20.0),
              child: InkWell(
                onTap: () {
                  Navigator.pop(context, 'Lost');
                },
                child: Text(
                  "OK",
                ),
              ),
            )),
          ],
        );
      },
    );
  }

  _showMyDialog(dynamic message) {
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
}

class selectItem {
  final String title;
  final int id;
  selectItem(this.id, this.title);
}
