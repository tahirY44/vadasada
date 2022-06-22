import 'package:vadasada/Api/api.dart';
import 'package:flutter/material.dart';
import 'package:loading_overlay/loading_overlay.dart';

class changePassword extends StatefulWidget {
  final int userID;

  const changePassword({this.userID, key}) : super(key: key);

  @override
  _changePasswordState createState() => _changePasswordState();
}

class _changePasswordState extends State<changePassword> {
  final oldPassController = TextEditingController();
  final newPassController = TextEditingController();
  final confirmPassController = TextEditingController();
  String oldPass = "", newPass = "", confirmPass = "";
  int userID;
  bool _loading = false;

  void initState() {
    // TODO: implement initState
    super.initState();
    oldPassController.addListener(_oldPassValue);
    newPassController.addListener(_newPassValue);
    confirmPassController.addListener(_confirmPassValue);
    setState(() {
      userID = widget.userID;
    });
  }

  void dispose() {
    oldPassController.dispose();
    newPassController.dispose();
    confirmPassController.dispose();
    super.dispose();
  }

  _oldPassValue() {
    setState(() {
      oldPass = oldPassController.text;
    });
  }

  _newPassValue() {
    setState(() {
      newPass = newPassController.text;
    });
  }

  _confirmPassValue() {
    setState(() {
      confirmPass = confirmPassController.text;
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
          "Change Password",
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
                    color: Colors.white,
                    child: Padding(
                        padding: const EdgeInsets.only(
                            top: 20.0, left: 20, right: 20.0),
                        child: Column(children: <Widget>[
                          Padding(padding: EdgeInsets.only(top: 20.0)),
                          TextField(
                            controller: oldPassController,
                            keyboardType: TextInputType.text,
                            decoration: InputDecoration(
                                labelText: "Current Password *",
                                hintText: "Current Password *",
                                hintStyle: TextStyle(color: Colors.black54)),
                            onEditingComplete: () => node.nextFocus(),
                          ),
                          Padding(padding: EdgeInsets.only(top: 20.0)),
                          TextField(
                            controller: newPassController,
                            keyboardType: TextInputType.text,
                            obscureText: true,
                            decoration: InputDecoration(
                                labelText: "New Password *",
                                hintText: "New Password *",
                                hintStyle: TextStyle(color: Colors.black54)),
                            onEditingComplete: () => node.nextFocus(),
                          ),
                          Padding(padding: EdgeInsets.only(top: 20.0)),
                          TextField(
                            controller: confirmPassController,
                            keyboardType: TextInputType.text,
                            obscureText: true,
                            decoration: InputDecoration(
                                labelText: "Confirm Password *",
                                hintText: "Confirm Password *",
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
                        ])))),
          )),
    );
  }

  void submitMessage(BuildContext context) async {
    if (oldPass.isEmpty || newPass.isEmpty || confirmPass.isEmpty) {
      _showMyDialog("Please fill all mandatory fields");
    } else if (newPass != confirmPass) {
      _showMyDialog("Confirm password doesn't matched");
    } else {
      setState(() {
        _loading = true;
      });
      var parameters = {
        'appkey': Api.appkey,
        'uid': userID.toString(),
        'old_password': oldPass,
        'password': newPass
      };
      var response = await Api.getRequest(Api.update_password, parameters);
      setState(() {
        _loading = false;
      });
      if (int.tryParse(response.body) == 1) {
        setState(() {
          oldPassController.text =
              newPassController.text = confirmPassController.text = "";
        });
        _showDialog("Password updated successfully", 1);
      } else {
        _showDialog("Current Password isn't correct", 0);
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
