import 'dart:convert';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:vadasada/Api/api.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:localstorage/localstorage.dart';
import 'package:url_launcher/url_launcher.dart';

class contactUs extends StatefulWidget {
  @override
  _contactUsState createState() => _contactUsState();
}

class _contactUsState extends State<contactUs> {
  final LocalStorage storage = new LocalStorage('vadasada');

  final nameController = TextEditingController();
  final mobileController = TextEditingController();
  final emailController = TextEditingController();
  final addressController = TextEditingController();
  final messageController = TextEditingController();
  String name = "", email = "", mobile = "", address = "", message = "";
  var user;
  var store_info;
  inquiryType selectedInquiry;
  List<inquiryType> inquiryData = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getInquiry();
    setState(() {
      user = storage.getItem("user") ?? null;
      store_info = storage.getItem("store_info");
      if (user != null) {
        nameController.text = name = user['name'];
        emailController.text = email = user['email'];
        mobileController.text = mobile = user['mobile'];
      }
    });
    nameController.addListener(_nameValue);
    mobileController.addListener(_mobileValue);
    emailController.addListener(_emailValue);
    addressController.addListener(_addressValue);
    messageController.addListener(_messageValue);
  }

  getInquiry() async {
    var response = await Api.getRequest(Api.inquiry_type, null);
    var data = jsonDecode(response.body);
    setState(() {
      for (var i = 0; i < data.length; i++) {
        int id = data[i]['id'];
        String title = data[i]['title'];
        inquiryData.add(inquiryType(id, title));
      }
    });
  }

  @override
  void dispose() {
    nameController.dispose();
    mobileController.dispose();
    emailController.dispose();
    addressController.dispose();
    messageController.dispose();
    super.dispose();
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

  _addressValue() {
    setState(() {
      address = addressController.text;
    });
  }

  _messageValue() {
    setState(() {
      message = messageController.text;
    });
  }

  @override
  Widget build(BuildContext context) {
    MediaQueryData mediaQueryData = MediaQuery.of(context);
    // double size = mediaQueryData.size.height;
    double width = mediaQueryData.size.width;
    FocusScopeNode node = FocusScope.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: InkWell(
            onTap: () {
              Navigator.of(context).pop(false);
            },
            child: Icon(Icons.arrow_back)),
        elevation: 0.0,
        title: Text(
          "Contact Us",
          style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 18.0,
              color: Colors.white,
              fontFamily: "Gotik"),
        ),
        centerTitle: true,
        backgroundColor: Api.primaryColor,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: GestureDetector(
        onTap: () {
          FocusScopeNode currentFocus = FocusScope.of(context);
          if (!currentFocus.hasPrimaryFocus) {
            currentFocus.unfocus();
          }
        },
        child: SingleChildScrollView(
          child: Container(
            color: Colors.white,
            child: Padding(
              padding:
                  const EdgeInsets.only(top: 30.0, left: 20.0, right: 20.0),
              child: Column(
                children: <Widget>[
                  Padding(padding: EdgeInsets.only(top: 20.0)),
                  TextField(
                    controller: nameController,
                    keyboardType: TextInputType.name,
                    decoration: InputDecoration(
                        labelText: "Full Name *",
                        hintText: "Full Name *",
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
                  Container(
                    width: width * 0.8,
                    decoration: BoxDecoration(
                        color: Color(0xFFFFFFFF),
                        borderRadius: BorderRadius.all(Radius.circular(5.0)),
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
                        child: DropdownButton<inquiryType>(
                            isExpanded: true,
                            hint: Text("Select Nature..."),
                            value: selectedInquiry,
                            onChanged: (inquiryType Value) {
                              setState(() {
                                selectedInquiry = Value;
                              });
                            },
                            items: inquiryData.map((inquiryType item) {
                              return DropdownMenuItem<inquiryType>(
                                value: item,
                                child: Row(
                                  children: <Widget>[
                                    Text(
                                      item.title,
                                      style: TextStyle(color: Colors.black),
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
                    controller: messageController,
                    keyboardType: TextInputType.text,
                    maxLines: 3,
                    decoration: InputDecoration(
                        labelText: "Message *",
                        hintText: "Message *",
                        hintStyle: TextStyle(color: Colors.black54)),
                    onSubmitted: (_) => node.unfocus(),
                  ),
                  Padding(padding: EdgeInsets.only(top: 60.0)),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Text(
                      '(Do not forget to mention your Order ID, if it relates to an order)',
                      style: TextStyle(color: Colors.red, fontSize: 11),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      submitMessage(context);
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(top: 10.0, bottom: 20.0),
                      child: Container(
                        height: 55.0,
                        width: 280.0,
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
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Padding(
                          padding: EdgeInsets.all(10.0),
                          child: InkWell(
                            onTap: () {
                              var url = store_info['messenger'];
                              _launchUrl(url);
                              // _launchUrl()
                            },
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                FaIcon(
                                  FontAwesomeIcons.facebookMessenger,
                                  size: 25,
                                ),
                                Padding(
                                  padding: EdgeInsets.all(5.0),
                                  child: Text('Messenger'),
                                )
                              ],
                            ),
                          )),
                      Padding(
                          padding: EdgeInsets.all(10.0),
                          child: InkWell(
                            onTap: () {
                              var url = "tel://" + store_info['phone'];
                              _launchUrl(url);
                            },
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.call,
                                  size: 25,
                                ),
                                Padding(
                                  padding: EdgeInsets.all(5.0),
                                  child: Text('Call'),
                                )
                              ],
                            ),
                          )),
                      Padding(
                          padding: EdgeInsets.all(10.0),
                          child: InkWell(
                            onTap: () {
                              var url =
                                  "https://wa.me/" + store_info['whatsapp'];
                              _launchUrl(url);
                            },
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                FaIcon(
                                  FontAwesomeIcons.whatsapp,
                                  size: 25,
                                ),
                                Padding(
                                  padding: EdgeInsets.all(5.0),
                                  child: Text('Whatsapp'),
                                )
                              ],
                            ),
                          ))
                    ],
                  ),
                  SizedBox(
                    height: 20.0,
                  ),
                  Container(
                    alignment: Alignment.centerLeft,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(
                                  right: 5.0, bottom: 5.0),
                              child: Icon(
                                Icons.call,
                                size: 20,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 15.0),
                              child: Text(
                                'SMS/Whatsapp:',
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                        Text(store_info['whatsapp']),
                        SizedBox(
                          height: 20.0,
                        ),
                        Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(
                                  right: 5.0, bottom: 5.0),
                              child: Icon(
                                Icons.call,
                                size: 20,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 15.0),
                              child: Text(
                                'Landline:',
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                        Text(store_info['phone']),
                        SizedBox(
                          height: 20.0,
                        ),
                        Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(
                                  right: 5.0, bottom: 5.0),
                              child: Icon(
                                CupertinoIcons.envelope,
                                size: 20,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 15.0),
                              child: Text(
                                'Email:',
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                        Text(store_info['email']),
                        SizedBox(
                          height: 20.0,
                        ),
                        Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(
                                  right: 5.0, bottom: 5.0),
                              child: Icon(
                                Icons.location_on,
                                size: 20,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 15.0),
                              child: Text(
                                'Address 1:',
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                        Text(store_info['address']),
                        SizedBox(
                          height: 20.0,
                        ),
                        Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(
                                  right: 5.0, bottom: 5.0),
                              child: Icon(
                                Icons.location_on_outlined,
                                size: 20,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 15.0),
                              child: Text(
                                'Address 2:',
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                        Text(store_info['address_2']),
                        SizedBox(
                          height: 20.0,
                        ),
                        Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(
                                  right: 5.0, bottom: 5.0),
                              child: Icon(
                                CupertinoIcons.time,
                                size: 20,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 15.0),
                              child: Text(
                                'Working Days/Hours:',
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                        Text(store_info['working_hours']),
                        SizedBox(
                          height: 20.0,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 20.0,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _launchUrl(url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  void submitMessage(BuildContext context) async {
    if (name.isEmpty ||
        email.isEmpty ||
        mobile.isEmpty ||
        message.isEmpty ||
        selectedInquiry == null) {
      _showMyDialog();
    } else {
      var parameters = {
        'appkey': Api.appkey,
        'name': name,
        'email': email,
        'mobile': mobile,
        'nature': selectedInquiry.id.toString(),
        'message': message
      };
      var response = await Api.getRequest(Api.contact_us, parameters);
      if (int.tryParse(response.body) == 1) {
        setState(() {
          nameController.text = mobileController.text =
              emailController.text = messageController.text = "";
          selectedInquiry = null;
        });
        _showDialog("Message Submitted", 1);
      }
    }
  }

  _showMyDialog() {
    return showDialog(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Please fill all mandatory fields'),
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
      barrierDismissible: true,
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
            // new SimpleDialogOption(
            //   child: new Text("Lost"),
            //   onPressed: () {
            //     Navigator.pop(context, 'Lost'); //For closing the SimpleDialog
            //     //After that do whatever you want
            //   },
            // )
          ],
        );
      },
    );
  }
}

class inquiryType {
  final int id;
  final String title;
  inquiryType(this.id, this.title);
}
