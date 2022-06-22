import 'dart:io';

import 'package:vadasada/Api/api.dart';
import 'package:vadasada/UI/BottomNavigationBar.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_html/flutter_html.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';

class Prescription extends StatefulWidget {
  @override
  _prescriptionState createState() => _prescriptionState();
}

class _prescriptionState extends State<Prescription> {
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  String name = "", phone = "", email = "";

  bool _loading = false;
  Future<File> file;
  String status = '';
  String base64Image = '';
  File tmpFile;
  String errMessage = 'Error Uploading Image';

  // Widget html = Html(
  //   data: """
  //     <div class="prescription-box">
  //                       <h3>How to Upload your Prescription?<br>
  //                           <span>a Short guide</span></h3>
  //                       <ul>
  //                           <li>Do not crop out any part of the prescription image.</li>
  //                           <li>Avoid unclear or blurred image of your prescription.</li>
  //                           <li>Include details of your doctor, patient and clinic visit date.</li>
  //                           <li>Medicines will only be dispensed against a valid prescription.</li>
  //                       </ul>
  //                       <img src="https://www.fsm.com.pk/images/prescr.jpg" alt="" class="img-responsive">
  //                       <p>* As per the laws of Pakistan, no drug can be dispensed without a valid prescription - Drug Act 1976</p>
  //                   </div>
  //                   <div class="prescription-box">
  //                       <h3>Payment and Discount Short Guide </h3>
  //                       <ul>
  //                           <li>Our WhatsApp no. +923353763762</li>
  //                           <li>A valid prescription will be required.</li>
  //                           <li>Please note that the pharmaceutical products/medicines will be dispensed by one of our trusted hospitals/pharmacies partners.</li>
  //                       </ul>
  //                   </div>
  //   """,
  // );

  @override
  void initState() {
    super.initState();
    nameController.addListener(_nameValue);
    phoneController.addListener(_phoneValue);
    emailController.addListener(_emailValue);
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    super.dispose();
  }

  _nameValue() {
    setState(() {
      name = nameController.text;
    });
  }

  _phoneValue() {
    setState(() {
      phone = phoneController.text;
    });
  }

  _emailValue() {
    setState(() {
      email = emailController.text;
    });
  }

  chooseImage() {
    setState(() {
      // file = ImagePicker.pickImage(source: ImageSource.gallery);
    });
  }

  takeImage() {
    setState(() {
      // file = ImagePicker.pickImage(source: ImageSource.camera);
    });
  }

  startUpload() async {
    if (name.isEmpty || email.isEmpty || phone.isEmpty || base64Image.isEmpty) {
      _showMyDialog();
    } else {
      setState(() {
        _loading = true;
      });
      var parameters = {
        'name': name,
        'phone': phone,
        'email': email,
        'file': base64Image
      };

      var response =
          await Api.postImageRequest(Api.upload_prescription, parameters);
      var data = jsonDecode(response.body);

      setState(() {
        _loading = false;
      });
      if (data == 1) {
        _showDialog("Successfully Uploaded", 1, true);
      } else {
        _showDialog("Something went wrong", 0, false);
      }
    }
  }

  void navigator() {
    Navigator.of(context).pushReplacement(PageRouteBuilder(
        pageBuilder: (_, __, ___) => new bottomNavigationBar()));
  }

  @override
  Widget build(BuildContext context) {
    MediaQueryData mediaQueryData = MediaQuery.of(context);
    double itemWidth = mediaQueryData.size.width;
    FocusScopeNode node = FocusScope.of(context);

    return Scaffold(
        appBar: AppBar(
          iconTheme: IconThemeData(color: Color(0xFF6991C7)),
          centerTitle: true,
          backgroundColor: Colors.white,
          title: Text(
            "Upload Prescription",
            style: TextStyle(
                fontFamily: "Gotik",
                fontSize: 18.0,
                color: Colors.black54,
                fontWeight: FontWeight.w700),
          ),
          elevation: 0.0,
        ),
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
              child: SingleChildScrollView(
                child: Container(
                  width: itemWidth,
                  padding: EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      TextField(
                        controller: nameController,
                        keyboardType: TextInputType.name,
                        decoration: InputDecoration(
                            labelText: "First Name *",
                            hintText: "First Name *",
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
                          onSubmitted: (_) => node.unfocus()),
                      Padding(padding: EdgeInsets.only(top: 20.0)),
                      TextField(
                        controller: phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                            labelText: "Phone *",
                            hintText: "Phone *",
                            hintStyle: TextStyle(color: Colors.black54)),
                        onEditingComplete: () => node.nextFocus(),
                      ),
                      Padding(padding: EdgeInsets.only(top: 20.0)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          OutlinedButton(
                            onPressed: chooseImage,
                            child: Text('Choose Image'),
                          ),
                          OutlinedButton(
                            onPressed: takeImage,
                            child: Text('Take Image'),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 20.0,
                      ),
                      showImage(),
                      SizedBox(
                        height: 20.0,
                      ),
                      FlatButton(
                        onPressed: startUpload,
                        color: Api.primaryColor,
                        child: Text(
                          'Submit',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      SizedBox(
                        height: 20.0,
                      ),
                      // html
                    ],
                  ),
                ),
              ),
            )));
  }

  Widget showImage() {
    return FutureBuilder<File>(
      future: file,
      builder: (BuildContext context, AsyncSnapshot<File> snapshot) {
        MediaQueryData mediaQueryData = MediaQuery.of(context);
        double itemHeight = mediaQueryData.size.height / 2;
        if (snapshot.connectionState == ConnectionState.done &&
            null != snapshot.data) {
          tmpFile = snapshot.data;
          base64Image = base64Encode(snapshot.data.readAsBytesSync());
          return Image.file(
            snapshot.data,
            fit: BoxFit.fill,
          );
        } else if (null != snapshot.error) {
          return const Text(
            'Error Picking Image',
            textAlign: TextAlign.center,
          );
        } else {
          return const Text(
            'No Image Selected',
            textAlign: TextAlign.center,
          );
        }
      },
    );
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

  _showDialog(dynamic message, dynamic messageType, bool isFinal) {
    showDialog(
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
                        image:
                            (messageType.runtimeType == int && messageType > 0)
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
                    if (isFinal) {
                      navigator();
                    }
                  },
                  child: Text(
                    "OK",
                  ),
                ),
              ))
            ],
          );
        });
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
