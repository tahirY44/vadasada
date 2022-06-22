import 'dart:convert';

import 'package:vadasada/ListItem/userCheckoutData.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:vadasada/Api/api.dart';
import 'package:flutter/material.dart';
import 'package:vadasada/UI/CartUIComponent/Payment.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:localstorage/localstorage.dart';
// import 'package:facebook_app_events/facebook_app_events.dart';

class delivery extends StatefulWidget {
  @override
  _deliveryState createState() => _deliveryState();
}

class _deliveryState extends State<delivery> {
  final LocalStorage storage = new LocalStorage('vadasada');
  // static final facebookAppEvents = FacebookAppEvents();
  final nameController = TextEditingController();
  final mobileController = TextEditingController();
  final emailController = TextEditingController();
  final addressController = TextEditingController();
  final instructionController = TextEditingController();
  String name, email, mobile, address, instruction, city, city_title;

  List<selectItem> cityData = [];
  List<String> cities_title = [];
  List<String> cities_id = [];
  bool _loading = false;

  var user;
  userCheckoutData userData = new userCheckoutData();

  getCities() async {
    setState(() {
      _loading = true;
    });
    var parameters = {'appkey': Api.appkey, 'country': '1'};
    var response = await Api.getRequest(Api.get_cities, parameters);
    var data = jsonDecode(response.body);

    if (data != 0) {
      for (var row in data) {
        cities_title.add(row["title"]);
        cities_id.add(row["id"].toString());
      }
      // for (var i = 0; i < data.length; i++) {
      //   var id = data[i]['id'];
      //   var title = data[i]['title'];
      //   setState(() {
      //     cityData.add(selectItem(id, title));
      //   });
      // }
    }
    setState(() {
      user = storage.getItem("user");
      nameController.text = name = user['name'];
      emailController.text = email = user['email'];
      mobileController.text = mobile = user['mobile'];
      if (user['delivery_address'] != null) {
        addressController.text = address = user['delivery_address'];
      }
      for (var i = 0; i < cities_id.length; i++) {
        if (cities_id[i] == user['city'].toString()) {
          city = cities_id[i];
          city_title = cities_title[i];
        }
      }
      _loading = false;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    var cart_items = storage.getItem("cart");
    var store_info = storage.getItem("store_info") ?? null;
    var product_ids = '';
    int delivery;
    int discount;
    int total_amount;
    int total = 0;
    int quatities = 0;
    if (cart_items.length > 0) {
      for (var i = 0; i < cart_items.length; i++) {
        product_ids += (i > 0 ? ',' : '') + cart_items[i]['id'].toString();
        total += cart_items[i]['amount'];
        quatities += cart_items[i]['qty'];
      }
    }
    if (store_info != null && store_info['free_delivery_on'] <= total) {
      delivery = 0;
    } else {
      delivery = store_info['delivery_charges'];
    }
    discount = 0;

    total_amount = (total + delivery) - (discount);

    // print(product_ids);
    // print(quatities);
    // print(total);
    // print(total_amount);

    // facebookAppEvents.logInitiatedCheckout(
    //     totalPrice: double.parse(total_amount.toString()),
    //     currency: 'PKR',
    //     contentType: 'Product',
    //     contentId: product_ids,
    //     numItems: quatities);

    getCities();
    nameController.addListener(_nameValue);
    mobileController.addListener(_mobileValue);
    emailController.addListener(_emailValue);
    addressController.addListener(_addressValue);
    instructionController.addListener(_instructionValue);
  }

  @override
  void dispose() {
    nameController.dispose();
    mobileController.dispose();
    emailController.dispose();
    addressController.dispose();
    instructionController.dispose();
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

  _instructionValue() {
    setState(() {
      instruction = instructionController.text;
    });
  }

  @override
  Widget build(BuildContext context) {
    FocusScopeNode node = FocusScope.of(context);
    MediaQueryData mediaQueryData = MediaQuery.of(context);
    double size = mediaQueryData.size.height;
    double width = mediaQueryData.size.width;

    return Scaffold(
      appBar: AppBar(
        leading: InkWell(
            onTap: () {
              Navigator.of(context).pop(false);
            },
            child: Icon(Icons.arrow_back)),
        elevation: 0.0,
        title: Text(
          "Check-Out",
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
              color: Colors.white,
              child: Padding(
                padding:
                    const EdgeInsets.only(top: 30.0, left: 20.0, right: 20.0),
                child: Column(
                  children: <Widget>[
                    Text(
                      "User Information",
                      style: TextStyle(
                          letterSpacing: 0.1,
                          fontWeight: FontWeight.w600,
                          fontSize: 25.0,
                          color: Colors.black54,
                          fontFamily: "Gotik"),
                    ),
                    Padding(padding: EdgeInsets.only(top: 25.0)),
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
                    Padding(padding: EdgeInsets.only(top: 30.0)),
                    Text(
                      "Where are your ordered items shipped ?",
                      style: TextStyle(
                          letterSpacing: 0.1,
                          fontWeight: FontWeight.w600,
                          fontSize: 25.0,
                          color: Colors.black54,
                          fontFamily: "Gotik"),
                    ),
                    Padding(padding: EdgeInsets.only(top: 25.0)),
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
                      child: DropdownSearch<String>(
                        selectedItem: city_title,
                        // boxTextStyle: Theme.of(context).textTheme.subtitle1,
                        // searchBoxDecoration: InputDecoration(
                        //   border: OutlineInputBorder(),
                        //   focusedBorder: OutlineInputBorder(
                        //     borderSide:
                        //         const BorderSide(color: Color(0xFFF28C00)),
                        //   ),
                        // ),
                        // mode: Mode.BOTTOM_SHEET,
                        // items: cities_title,
                        // hint: "Select One",
                        // onChanged: (value) {
                        //   var index = cities_title.indexOf(value);
                        //   setState(() {
                        //     city = cities_id[index];
                        //     city_title = value;
                        //   });
                        // },
                        // showSearchBox: true,
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
                      controller: instructionController,
                      keyboardType: TextInputType.text,
                      maxLines: 3,
                      decoration: InputDecoration(
                          labelText: "Other Instructions",
                          hintText: "Other Instructions",
                          hintStyle: TextStyle(color: Colors.black54)),
                      onSubmitted: (_) => node.unfocus(),
                    ),
                    Padding(padding: EdgeInsets.only(top: 80.0)),
                    InkWell(
                      onTap: () {
                        proceedPayment(context);
                      },
                      child: Container(
                        height: 55.0,
                        width: 300.0,
                        decoration: BoxDecoration(
                            borderRadius:
                                BorderRadius.all(Radius.circular(40.0)),
                            color: Api.primaryColor),
                        child: Center(
                          child: Text(
                            "Go to payment",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 16.5,
                                letterSpacing: 1.0),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20.0,
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void proceedPayment(BuildContext context) {
    if (name.isEmpty ||
        email.isEmpty ||
        mobile.isEmpty ||
        (address == null || address.isEmpty)) {
      _showMyDialog();
    } else {
      //facebook

      // facebookAppEvents.logInitiatedCheckout();

      setState(() {
        userData.name = name;
        userData.email = email;
        userData.mobile = mobile;
        userData.address = address;
        userData.instruction = instruction;
        userData.city_id = city;
        Navigator.of(context).pushReplacement(PageRouteBuilder(
            pageBuilder: (_, __, ___) => payment(userData: userData)));
      });
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
}

class selectItem {
  final String title;
  final int id;
  selectItem(this.id, this.title);
}
