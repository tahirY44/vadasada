import 'dart:async';
import 'dart:convert';
import 'package:vadasada/Api/api.dart';
import 'dart:io' show Platform;
import 'package:vadasada/ListItem/userCheckoutData.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:vadasada/UI/BottomNavigationBar.dart';
import 'package:flutter/services.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:localstorage/localstorage.dart';
// import 'package:facebook_app_events/facebook_app_events.dart';

class payment extends StatefulWidget {
  final userCheckoutData userData;

  const payment({this.userData, key}) : super(key: key);

  @override
  _paymentState createState() => _paymentState();
}

class _paymentState extends State<payment> {
  /// Duration for popup card if user succes to payment
  StartTime() async {
    return Timer(Duration(milliseconds: 2000), navigator);
  }

  final LocalStorage storage = new LocalStorage('vadasada');
  // static final facebookAppEvents = FacebookAppEvents();
  final couponController = TextEditingController();
  String coupon = "";
  String order_type = "";

  final Connectivity _connectivity = Connectivity();
  StreamSubscription<ConnectivityResult> _connectivitySubscription;
  bool noInternet = false;
  int initialData = 0;

  var store_info;
  var cart_items;
  var product_ids = '';
  var user;
  int amount;
  int discount = 0;
  int user_id = 0;
  int delivery;
  int total_amount;
  int total_qty;
  int coupon_id = 0;
  bool isSwitched = false;
  bool _loading = false;
  bool showDiscount = false;
  String discount_text = "Discount";
  int youSave = 0;

  paymentItem selectedPayment;

  List<paymentItem> paymentData = [];

  userCheckoutData userData;

  @override
  void initState() {
    super.initState();
    couponController.addListener(_couponValue);
    initConnectivity();
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
    setState(() {
      if (Platform.isAndroid) {
        order_type = "13";
      } else {
        order_type = "14";
      }
      userData = widget.userData;
      store_info = storage.getItem("store_info") ?? null;
      cart_items = storage.getItem("cart");
      user = storage.getItem("user");
      user_id = user['id'];
      // user_id = int.tryParse(user['id']);
      int total = 0;
      int quatities = 0;
      int saveMoney = 0;
      if (cart_items.length > 0) {
        for (var i = 0; i < cart_items.length; i++) {
          if (cart_items[i]['dprice'] > 0) {
            int price = cart_items[i]['price'];
            int dprice = cart_items[i]['dprice'];
            int qty = cart_items[i]['qty'];
            saveMoney += (price - dprice) * qty;
          }
          product_ids += (i > 0 ? ',' : '') + cart_items[i]['id'].toString();
          total += cart_items[i]['amount'];
          quatities += cart_items[i]['qty'];
        }
      }
      youSave = saveMoney;
      total_qty = quatities;
      amount = total;
      if (store_info != null && store_info['free_delivery_on'] <= amount) {
        delivery = 0;
      } else {
        delivery = store_info['delivery_charges'];
      }
      discount = 0;

      total_amount = (amount + delivery) - (discount);
    });
  }

  Future<void> initConnectivity() async {
    ConnectivityResult result;
    try {
      result = await _connectivity.checkConnectivity();
    } on PlatformException catch (e) {
      print(e.toString());
    }
    if (!mounted) {
      return Future.value(null);
    }
    _updateConnectionStatus(result);
  }

  Future<void> _updateConnectionStatus(ConnectivityResult result) async {
    switch (result) {
      case ConnectivityResult.wifi:
        closePopup();
        break;
      case ConnectivityResult.mobile:
        closePopup();
        break;
      case ConnectivityResult.none:
        setState(() {
          noInternet = true;
        });
        // _showNoInternetDialog();
        break;
      // setState(() => _connectionStatus = result.toString());r
      default:
        setState(() {
          noInternet = true;
        });
      // _showNoInternetDialog();
    }
  }

  void closePopup() {
    if (noInternet) {
      Navigator.of(context, rootNavigator: true).pop('dialog');
      setState(() {
        noInternet = false;
      });
    }
    if (initialData == 0) {
      setState(() {
        initialData = 1;
      });
      getAllData();
    }
  }

  // _showNoInternetDialog() {
  //   return showDialog(
  //     context: context,
  //     barrierDismissible: false, // user must tap button!
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         content: SingleChildScrollView(
  //           child: ListBody(
  //             children: <Widget>[
  //               Column(
  //                 crossAxisAlignment: CrossAxisAlignment.center,
  //                 children: [
  //                   Container(
  //                     padding:
  //                         EdgeInsets.only(top: 30.0, right: 60.0, left: 60.0),
  //                     height: 110.0,
  //                     decoration: BoxDecoration(
  //                         color: Colors.white,
  //                         image: DecorationImage(
  //                             image: AssetImage("assets/img/sad_emoji.png"),
  //                             fit: BoxFit.contain)),
  //                   ),
  //                   Padding(
  //                     padding: const EdgeInsets.only(
  //                         left: 8.0, right: 8.0, top: 16.0),
  //                     child: Text(
  //                       'Something has gone wrong, check your internet connection.',
  //                       textAlign: TextAlign.center,
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //             ],
  //           ),
  //         ),
  //       );
  //     },
  //   );
  // }

  void getAllData() {
    getPaymentMethod();
  }

  @override
  void dispose() {
    couponController.dispose();
    super.dispose();
    _connectivitySubscription.cancel();
  }

  _couponValue() {
    setState(() {
      coupon = couponController.text;
    });
  }

  getPaymentMethod() async {
    var response = await Api.getRequest(Api.payment_methods, null);
    var data = jsonDecode(response.body);
    setState(() {
      for (var i = 0; i < data.length; i++) {
        int id = data[i]['id'];
        String title = data[i]['title'];
        paymentData.add(paymentItem(id, title));
      }
    });
  }

  /// Navigation to route after user succes payment
  void navigator() {
    Navigator.of(context).pushReplacement(PageRouteBuilder(
        pageBuilder: (_, __, ___) => new bottomNavigationBar()));
  }

  /// Custom Text
  var _customStyle = TextStyle(
      fontFamily: "Gotik",
      fontWeight: FontWeight.w800,
      color: Colors.black,
      fontSize: 17.0);

  Widget build(BuildContext context) {
    MediaQueryData mediaQueryData = MediaQuery.of(context);
    // double size = mediaQueryData.size.height;
    double width = mediaQueryData.size.width;
    return Scaffold(
      /// Appbar
      appBar: AppBar(
        leading: InkWell(
            onTap: () {
              Navigator.of(context).pop(false);
            },
            child: Icon(Icons.arrow_back)),
        elevation: 0.0,
        title: Text(
          "Payment",
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
        child: SingleChildScrollView(
          child: Container(
            width: width,
            color: Colors.white,
            child: Padding(
              padding:
                  const EdgeInsets.only(top: 30.0, left: 20.0, right: 20.0),
              child: Column(
                children: <Widget>[
                  Text(
                    "Choose payment method *",
                    style: TextStyle(
                        letterSpacing: 0.1,
                        fontWeight: FontWeight.w600,
                        fontSize: 18.0,
                        color: Colors.black54,
                        fontFamily: "Gotik"),
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
                        child: DropdownButton<paymentItem>(
                            isExpanded: true,
                            hint: Text("Select item"),
                            value: selectedPayment,
                            onChanged: (paymentItem Value) {
                              setState(() {
                                selectedPayment = Value;
                              });
                            },
                            items: paymentData.map((paymentItem item) {
                              return DropdownMenuItem<paymentItem>(
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
                  Divider(
                    color: Colors.black54,
                    height: 4.0,
                  ),
                  Padding(padding: EdgeInsets.only(top: 20.0)),
                  Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Add Coupons",
                          style: TextStyle(
                              letterSpacing: 0.1,
                              fontWeight: FontWeight.w600,
                              fontSize: 16.0,
                              color: Colors.black54,
                              fontFamily: "Gotik"),
                        ),
                        Switch(
                            activeColor: Api.primaryColor,
                            value: isSwitched,
                            onChanged: (value) {
                              setState(() {
                                isSwitched = value;
                              });
                            })
                      ],
                    ),
                  ),
                  Padding(padding: EdgeInsets.only(top: 20.0)),
                  isSwitched
                      ? Container(
                          width: width * 0.8,
                          decoration: BoxDecoration(
                              color: Api.primaryColor,
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
                          child: Row(
                            children: [
                              Expanded(
                                  flex: 8,
                                  child: Container(
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(5.0),
                                            bottomLeft: Radius.circular(5.0))),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 0.0, horizontal: 10.0),
                                      child: TextField(
                                        controller: couponController,
                                        decoration: InputDecoration(
                                            border: InputBorder.none,
                                            hintText: "Add Code",
                                            hintStyle: TextStyle(
                                                color: Colors.black54)),
                                      ),
                                    ),
                                  )),
                              Expanded(
                                  flex: 2,
                                  child: Container(
                                    child: InkWell(
                                      onTap: () {
                                        setState(() {
                                          _loading = true;
                                        });
                                        submitCoupon(context);
                                      },
                                      child: Icon(
                                        Icons.arrow_forward_ios,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ))
                            ],
                          ),
                        )
                      : Container(),
                  isSwitched
                      ? Padding(padding: EdgeInsets.only(top: 20.0))
                      : Container(),

                  Divider(
                    color: Colors.black54,
                    height: 4.0,
                  ),
                  Padding(padding: EdgeInsets.only(top: 20.0)),
                  Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [Text("Amount"), Text("Rs $amount")],
                    ),
                  ),
                  Padding(padding: EdgeInsets.only(top: 10.0)),
                  showDiscount
                      ? Container(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(discount_text),
                              Text("Rs -$discount")
                            ],
                          ),
                        )
                      : Container(),
                  showDiscount
                      ? Padding(padding: EdgeInsets.only(top: 10.0))
                      : Container(),
                  Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [Text("Delivery"), Text("Rs $delivery")],
                    ),
                  ),
                  Padding(padding: EdgeInsets.only(top: 10.0)),
                  Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Amount Payable"),
                        Text("Rs $total_amount")
                      ],
                    ),
                  ),

                  Padding(padding: EdgeInsets.only(top: 20.0)),
                  Divider(
                    color: Colors.black54,
                    height: 4.0,
                  ),

                  Padding(padding: EdgeInsets.only(top: 60.0)),

                  /// Button pay
                  InkWell(
                    onTap: () {
                      submitOrder();
                    },
                    child: Container(
                      height: 55.0,
                      width: 300.0,
                      decoration: BoxDecoration(
                          color: Api.primaryColor,
                          borderRadius:
                              BorderRadius.all(Radius.circular(40.0))),
                      child: Center(
                        child: Text(
                          "Submit Order",
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 16.5,
                              letterSpacing: 2.0),
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
    );
  }

  void submitCoupon(BuildContext context) async {
    var parameters = {
      'appkey': Api.appkey,
      'uid': user_id.toString(),
      'code': coupon
    };

    var response = await Api.getRequest(Api.apply_coupon, parameters);
    var data = jsonDecode(response.body);
    if (data['error'] == 1) {
      setState(() {
        _loading = false;
      });
      _showDialog("Invalid or used Coupon", 0, false);
    } else {
      if (data['type'] == 1) {
        setState(() {
          // var dis_percent = data[0]['discount_percent'];
          discount_text =
              "Discount (" + data['discount_percent'].toString() + "%)";
          discount = ((amount * data['discount_percent']) / 100).round();
          coupon_id = data['coupon_id'];
          total_amount = (amount + delivery) - discount;
          showDiscount = true;
        });
      } else {
        setState(() {
          discount_text = "Discount";
          discount = data['discount_price'];
          coupon_id = data['coupon_id'];
          total_amount = (amount + delivery) - discount;
          showDiscount = true;
        });
      }
      setState(() {
        _loading = false;
      });
      _showDialog("Coupon Successfully Redeem", 1, false);
    }
  }

  _showMyDialog(message) {
    return showDialog(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('$message'),
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

  void submitOrder() async {
    if (selectedPayment == null) {
      _showMyDialog('Please fill all mandatory fields');
    } else if (amount < 500) {
      _showMyDialog(
          'You must have an order with a minimum of Rs. 500 to place your order, your current order total is Rs. $amount');
    } else {
      setState(() {
        _loading = true;
      });
      Map parameters = {
        'appkey': Api.appkey,
        'order_type': order_type,
        'uid': user_id.toString(),
        'name': userData.name,
        'email': userData.email,
        'mobile': userData.mobile,
        'address': userData.address,
        'city_id': userData.city_id,
        'instructions': userData.instruction,
        'payment_id': selectedPayment.id.toString(),
        'cart': cart_items,
        'qty_total': total_qty.toString(),
        'sub_total': amount.toString(),
        'discount': discount.toString(),
        'delivery': delivery.toString(),
        'net_total': total_amount.toString(),
        'coupon_id': coupon_id.toString(),
        'youSave': youSave.toString()
      };

      // var fb_parameters = {
      //   'uid': user_id.toString(),
      //   'name': userData.name,
      //   'email': userData.email,
      //   'mobile': userData.mobile,
      //   'address': userData.address,
      //   'city_id': userData.city_id,
      //   'instructions': userData.instruction,
      //   'payment_id': selectedPayment.id.toString(),
      //   'cart': cart_items,
      //   'qty_total': total_qty.toString(),
      //   'sub_total': amount.toString(),
      //   'discount': discount.toString(),
      //   'delivery': delivery.toString(),
      //   'net_total': total_amount.toString(),
      //   'coupon_id': coupon_id.toString(),
      //   'youSave': youSave.toString()
      // };
      print(parameters);
      var response = await Api.postRequest(Api.submit_order, parameters);
      setState(() {
        _loading = true;
      });
      print(response.body);
      var data = json.decode(response.body);
      if (data['error'] == 0) {
        // facebookAppEvents.logPurchase(
        //     amount: double.parse(total_amount.toString()),
        //     currency: 'PKR',
        //     parameters: {
        //       'content_type': 'Product',
        //       'content_id': product_ids,
        //       'value': total_amount.toString(),
        //       'currency': 'PKR'
        //     });

        String message =
            "Thankyou for you order at vadasada\nOrder ID ${data['oid']}";
        _showDialog(message, 1, true);
        storage.setItem("cart", []);
        // StartTime();
      } else if (data['error'] == 1) {
        String message = data['msg'];
        _showDialog(message, 0, false);
      } else {
        String message = "OOPS Something went wrong !";
        _showDialog(message, 0, false);
      }
    }
    // print(selectedPayment);

    // _showDialog(context);
    // StartTime();
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

class paymentItem {
  final int id;
  final String title;
  paymentItem(this.id, this.title);
}
