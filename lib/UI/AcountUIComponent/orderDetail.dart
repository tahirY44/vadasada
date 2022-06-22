import 'dart:async';
import 'dart:convert';

import 'package:vadasada/Api/api.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:localstorage/localstorage.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class orderDetail extends StatefulWidget {
  final int orderID;
  final String randID;

  const orderDetail({this.orderID, this.randID, key}) : super(key: key);

  @override
  _orderDetailState createState() => _orderDetailState();
}

class _orderDetailState extends State<orderDetail> {
  int orderID;
  String randID;
  bool _loading = false, showDetail = false;
  var orderData;
  var cart_list;
  final LocalStorage storage = new LocalStorage('vadasada');

  String net_total = "0", address = "";
  int total = 0, discount = 0, shipping_charges = 0;
  List<Widget> item_summary = [];

  final Connectivity _connectivity = Connectivity();
  StreamSubscription<ConnectivityResult> _connectivitySubscription;
  bool noInternet = false;
  int initialData = 0;

  void initState() {
    super.initState();
    initConnectivity();
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  }

  @override
  dispose() {
    super.dispose();
    _connectivitySubscription.cancel();
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
    setState(() {
      orderID = widget.orderID;
      randID = widget.randID;
      _loading = true;
    });
    getOrderDetail();
  }

  getOrderDetail() async {
    var parameters = {'appkey': Api.appkey, 'oid': orderID.toString()};

    var response = await Api.getRequest(Api.order_summary, parameters);
    var data = jsonDecode(response.body);
    // print(data);
    setState(() {
      total = data['total'];
      discount = data['coupons_discount'];
      shipping_charges = data['shipping_charges'];
      net_total = data['grand_total'];
      address = data['address'];
      for (var i = 0; i < data["items"].length; i++) {
        item_summary.add(orderItem(data["items"][i]));
        if (i < (data['items'].length - 1)) {
          item_summary.add(Container(
            color: Colors.black38,
            height: 0.5,
          ));
        }
      }
      _loading = false;
      showDetail = true;
    });
  }

  Widget build(BuildContext context) {
    MediaQueryData mediaQueryData = MediaQuery.of(context);
    double width = mediaQueryData.size.width;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Api.primaryColor,
        title: Text(
          "Order Detail",
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
        isLoading: _loading,
        progressIndicator: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Api.primaryColor),
        ),
        child: showDetail
            ? SingleChildScrollView(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 10.0, bottom: 10),
                      child: Container(
                        color: Colors.white,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(
                                  top: 10, left: 15.0, bottom: 10),
                              child: Text(
                                randID == null
                                    ? "Order ID : ${orderID}"
                                    : "Order ID : ${randID}",
                                style: _txtCustom,
                              ),
                            ),
                            // Padding(
                            //     padding: EdgeInsets.only(
                            //         top: 10.0, right: 15.0, bottom: 10),
                            //     child: InkWell(
                            //       onTap: () {
                            //         _showMyDialog();
                            //       },
                            //       child: Container(
                            //         decoration: BoxDecoration(
                            //             borderRadius:
                            //                 BorderRadius.circular(14.0),
                            //             color: Colors.white,
                            //             boxShadow: [
                            //               BoxShadow(
                            //                   blurRadius: 5.0,
                            //                   color: Colors.red[900])
                            //             ]),
                            //         child: Padding(
                            //           padding: const EdgeInsets.all(7.0),
                            //           child: Text(
                            //             "Re-Order",
                            //             style: _txtCustomRed,
                            //           ),
                            //         ),
                            //       ),
                            //     ))
                          ],
                        ),
                      ),
                    ),
                    Padding(
                        padding: EdgeInsets.only(bottom: 10.0),
                        child: Container(
                          child: Text(
                            "Item Summary",
                            style: _txtCustomHeading,
                          ),
                        )),
                    Padding(
                        padding: EdgeInsets.only(bottom: 10),
                        child: Container(
                          width: width,
                          decoration: BoxDecoration(
                            color: Colors.white,
                          ),
                          child: Column(
                            children: item_summary,
                          ),
                        )),
                    Padding(
                        padding: EdgeInsets.only(bottom: 10.0),
                        child: Container(
                          child: Text(
                            "Payment Summary",
                            style: _txtCustomHeading,
                          ),
                        )),
                    Padding(
                      padding: EdgeInsets.only(bottom: 10),
                      child: Container(
                        width: width,
                        decoration: BoxDecoration(
                          color: Colors.white,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            children: [
                              Padding(
                                padding: EdgeInsets.only(
                                    top: 8.0, left: 15.0, right: 15.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        FaIcon(FontAwesomeIcons.receipt),
                                        Padding(
                                            padding: EdgeInsets.only(left: 22)),
                                        Text(
                                          "Total Amount",
                                          style: _txtCustom,
                                        )
                                      ],
                                    ),
                                    Text(
                                      "Rs. ${total}",
                                      style: _txtCustom,
                                    )
                                  ],
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(
                                    top: 8.0, left: 15.0, right: 15.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        FaIcon(FontAwesomeIcons.truck),
                                        Padding(
                                            padding: EdgeInsets.only(left: 10)),
                                        Text(
                                          "Delivery Charges",
                                          style: _txtCustom,
                                        )
                                      ],
                                    ),
                                    Text(
                                      shipping_charges > 0
                                          ? "Rs. ${shipping_charges}"
                                          : "FREE",
                                      style: _txtCustom,
                                    )
                                  ],
                                ),
                              ),
                              (discount > 0)
                                  ? Padding(
                                      padding: EdgeInsets.only(
                                          top: 8.0,
                                          left: 15.0,
                                          right: 15.0,
                                          bottom: 8.0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              FaIcon(FontAwesomeIcons.star),
                                              Padding(
                                                  padding: EdgeInsets.only(
                                                      left: 14)),
                                              Text(
                                                "Discount",
                                                style: _txtCustom,
                                              )
                                            ],
                                          ),
                                          Text(
                                            "Rs. -${discount}",
                                            style: _txtCustom,
                                          )
                                        ],
                                      ),
                                    )
                                  : Padding(
                                      padding: EdgeInsets.only(bottom: 8.0)),
                              Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Container(
                                  height: 0.5,
                                  color: Colors.black38,
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(
                                    top: 8.0, left: 15.0, right: 15.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "Total Payable Amount",
                                      style: _txtCustom,
                                    ),
                                    Text(
                                      "Rs. ${net_total}",
                                      style: _txtCustom,
                                    )
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: Container(
                        height: 130.0,
                        width: width * 0.8,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius:
                                BorderRadius.all(Radius.circular(10.0)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12.withOpacity(0.1),
                                blurRadius: 4.5,
                                spreadRadius: 1.0,
                              )
                            ]),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Image.asset("assets/img/house.png"),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Container(
                                width: width * 0.6,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Text(
                                      "Delivery Address",
                                      style: _txtCustom.copyWith(
                                          fontWeight: FontWeight.w700),
                                    ),
                                    Padding(padding: EdgeInsets.only(top: 8.0)),
                                    Text(
                                      "${address}",
                                      style: _txtCustom.copyWith(
                                          fontWeight: FontWeight.w400,
                                          fontSize: 13.0,
                                          color: Colors.black38),
                                    )
                                  ],
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              )
            : Container(),
      ),
    );
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
                Text('Are you sure you would like to ReOrder'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Confirm'),
              onPressed: () {
                Navigator.of(context).pop();
                // reOrder();
              },
            ),
          ],
        );
      },
    );
  }

  // reOrder() async {
  //   setState(() {
  //     _loading = true;
  //   });
  //   var parameters = {
  //     'appkey': Api.appkey,
  //     'orderid': orderID.toString()
  //   };

  //   var response = await Api.getRequest(Api.reorder, parameters);
  //   var data = jsonDecode(response.body);
  //   setState(() {
  //     cart_list = [];
  //   });
  //   for (var i = 0; i < data.length; i++) {
  //     var item = {
  //       'id': data[i]['product_id'],
  //       'priceid': data[i]['prices'],
  //       'weight': data[i]['weight'],
  //       'unit': data[i]['unit'],
  //       'unit_title': data[i]['unit_title'],
  //       'title': data[i]['product_title'],
  //       'image': data[i]['image'],
  //       'qty': data[i]['qty'],
  //       'dprice': data[i]['dprice'],
  //       'price': data[i]['price'],
  //       'amount': data[i]['amount'],
  //     };
  //     cart_list.add(item);
  //   }
  //   storage.setItem("cart", cart_list);
  //   setState(() {
  //     _loading = false;
  //   });
  //   Navigator.of(context)
  //       .push(PageRouteBuilder(pageBuilder: (_, __, ___) => new cart()));
  // }

  orderItem(item) {
    MediaQueryData mediaQueryData = MediaQuery.of(context);
    double width = mediaQueryData.size.width;
    String variations = "";
    for (var i = 0; i < item['variations'].length; i++) {
      if (i == (item['variations'].length - 1)) {
        variations +=
            "${item['variations'][i]['groups_title']} : ${item['variations'][i]['value_title']}";
      } else {
        variations +=
            "${item['variations'][i]['groups_title']} : ${item['variations'][i]['value_title']}, ";
      }
    }
    return Container(
        child: Row(
      children: [
        Padding(
            padding: EdgeInsets.only(left: 10, right: 5),
            child: Container(
                height: 110.0,
                width: width * 0.21,
                decoration: BoxDecoration(color: Colors.white, boxShadow: [
                  BoxShadow(
                      color: Colors.black12.withOpacity(0.1),
                      blurRadius: 0.5,
                      spreadRadius: 0.1)
                ]),
                child: Image.network(
                  item["image"],
                  fit: BoxFit.contain,
                ))),
        Container(
          width: width * 0.61,
          child: Padding(
            padding: const EdgeInsets.only(
                left: 5.0, right: 5.0, top: 10, bottom: 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['product_title'],
                  style: _txtCustomItem,
                ),
                Padding(padding: EdgeInsets.only(bottom: 7.0)),
                Text(
                  "${variations}",
                  maxLines: 2,
                  style: _txtCustomSmall,
                  overflow: TextOverflow.ellipsis,
                ),
                Padding(padding: EdgeInsets.only(bottom: 7.0)),
                Text(
                  "Rs. ${item['price']} x ${item['qty']}",
                  style: _txtCustomItem,
                )
              ],
            ),
          ),
        ),
        Container(
          width: width * 0.14,
          child: Padding(
            padding: const EdgeInsets.only(left: 5.0, right: 5.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "${item['amount']}",
                  style: _txtCustomItem,
                )
              ],
            ),
          ),
        )
      ],
    ));
  }
}

var _txtCustom = TextStyle(
  color: Colors.black54,
  fontSize: 15.0,
  fontWeight: FontWeight.w500,
  fontFamily: "Gotik",
);

var _txtCustomItem = TextStyle(
  color: Colors.black,
  fontSize: 14.0,
  fontWeight: FontWeight.w500,
  fontFamily: "Gotik",
);

var _txtCustomSmall = TextStyle(
  color: Colors.black54,
  fontSize: 14.0,
  fontWeight: FontWeight.w500,
  fontFamily: "Gotik",
);

var _txtCustomHeading = TextStyle(
  color: Colors.black54,
  fontSize: 20.0,
  fontWeight: FontWeight.w500,
  fontFamily: "Gotik",
);

var _txtCustomWhite = TextStyle(
  color: Colors.white,
  fontSize: 15.0,
  fontWeight: FontWeight.w500,
  fontFamily: "Gotik",
);

var _txtCustomStatus = TextStyle(
  color: Colors.black54,
  fontSize: 10.0,
  fontWeight: FontWeight.w500,
  fontFamily: "Gotik",
);

var _txtCustomRed = TextStyle(
  color: Colors.red[900],
  fontWeight: FontWeight.w500,
  fontFamily: "Gotik",
);
