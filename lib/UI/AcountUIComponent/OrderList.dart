import 'dart:async';
import 'dart:convert';

import 'package:vadasada/Api/api.dart';
import 'package:vadasada/ListItem/orderItem.dart';
import 'package:vadasada/UI/AcountUIComponent/orderDetail.dart';
import 'package:vadasada/UI/CartUIComponent/CartLayout.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:localstorage/localstorage.dart';
import 'package:url_launcher/url_launcher.dart';

class orderList extends StatefulWidget {
  @override
  _orderListState createState() => _orderListState();
}

class _orderListState extends State<orderList> {
  final LocalStorage storage = new LocalStorage('vadasada');

  bool _loading = false;
  var user;
  var user_id;
  var cart_list;
  List<orderItem> orderList = [];

  final Connectivity _connectivity = Connectivity();
  StreamSubscription<ConnectivityResult> _connectivitySubscription;
  bool noInternet = false;
  int initialData = 0;

  @override
  void initState() {
    // TODO: implement initState
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

  void launchUrl2() async {
    var url =
        'fb://facewebmodal/f?href=https://www.facebook.com/vadasadapakistan/reviews';
    if (await canLaunch(url)) {
      await launch(
        url,
        universalLinksOnly: true,
      );
    } else {
      throw 'There was a problem to open the url: $url';
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
      _loading = true;
      user = storage.getItem("user");
      user_id = user["id"];
    });
    getOrders();
  }

  getOrders() async {
    var parameters = {'appkey': Api.appkey, 'uid': user_id.toString()};

    var response = await Api.getRequest(Api.user_orders, parameters);
    var data = jsonDecode(response.body);
    // print("${data.length}");
    setState(() {
      for (var i = 0; i < data.length; i++) {
        var id = data[i]["id"];
        var rand_id = data[i]["rend_order_id"];
        var total = data[i]["total"];
        var discount = data[i]["coupons_discount"];
        var shipping_charges = data[i]["shipping_charges"];
        var net_total = data[i]["net_total"];
        var status = data[i]["status_id"];
        var status_title = data[i]["status"];
        var address = data[i]["address"];
        var created_on = data[i]["createdon"];

        // print(rand_id.runtimeType);

        orderItem item = new orderItem(
            id: id,
            rand_id: rand_id,
            total: total,
            discount: discount,
            shipping_charges: shipping_charges,
            net_total: net_total,
            status: status,
            status_title: status_title,
            address: address,
            created_on: created_on);
        orderList.add(item);
      }
    });
    setState(() {
      _loading = false;
    });
  }

  reOrder(orderId) async {
    setState(() {
      _loading = true;
    });
    var parameters = {'appkey': Api.appkey, 'orderid': orderId.toString()};

    var response = await Api.getRequest(Api.reorder, parameters);
    var data = jsonDecode(response.body);
    setState(() {
      cart_list = [];
    });
    for (var i = 0; i < data.length; i++) {
      var item = {
        'id': data[i]['product_id'],
        'priceid': data[i]['prices'],
        'weight': data[i]['weight'],
        'unit': data[i]['unit'],
        'unit_title': data[i]['unit_title'],
        'title': data[i]['product_title'],
        'image': data[i]['image'],
        'qty': data[i]['qty'],
        'dprice': data[i]['dprice'],
        'price': data[i]['price'],
        'amount': data[i]['amount'],
      };
      cart_list.add(item);
    }
    storage.setItem("cart", cart_list);
    setState(() {
      _loading = false;
    });
    Navigator.of(context)
        .push(PageRouteBuilder(pageBuilder: (_, __, ___) => new cart()));
  }

  _showMyDialog(orderId) {
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
                reOrder(orderId);
              },
            ),
          ],
        );
      },
    );
  }

  Widget build(BuildContext context) {
    MediaQueryData mediaQueryData = MediaQuery.of(context);
    double width = mediaQueryData.size.width;
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Api.primaryColor,
          title: Text(
            "My Orders",
            style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 20.0,
                color: Colors.white,
                fontFamily: "Gotik"),
          ),
          centerTitle: true,
          iconTheme: IconThemeData(
            color: Colors.white,
          ),
          elevation: 0.0,
        ),
        body: LoadingOverlay(
            isLoading: _loading,
            progressIndicator: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Api.primaryColor),
            ),
            child: orderList.length > 0
                ? Column(
                    // child: Container(),
                    children: [
                        Container(
                          child: Flexible(
                              child: ListView.builder(
                                  itemCount: orderList.length,
                                  itemBuilder: (context, index) {
                                    return orderItemData(
                                        width, orderList[index]);
                                  })),
                        ),
                      ])
                : noOrder()));
  }

  Widget orderItemData(double width, orderItem item) {
    return Container(
        width: width,
        color: Colors.white,
        child: Padding(
            padding: EdgeInsets.all(10),
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black38),
                color: Colors.grey[100],
              ),
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Text(
                          "Placed on : ${item.created_on}",
                          style: _txtCustom,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Container(
                          color: Colors.white,
                          child: Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(
                                      bottom: 5.0, top: 5.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            top: 5.0, left: 15.0),
                                        child: Text(
                                          item.rand_id == null
                                              ? "Order ID ${item.id}"
                                              : "Order ID ${item.rand_id}",
                                          // "Order ID : " +
                                          //     (item.rand_id != null
                                          //         ? item.rand_id
                                          //         : item.id),
                                          style: _txtCustom,
                                        ),
                                      ),
                                      // Padding(
                                      //     padding: EdgeInsets.only(
                                      //         top: 5.0, right: 15.0),
                                      //     child: InkWell(
                                      //       onTap: () {
                                      //         _showMyDialog(item.id);
                                      //       },
                                      //       child: Container(
                                      //         decoration: BoxDecoration(
                                      //             borderRadius:
                                      //                 BorderRadius.circular(
                                      //                     14.0),
                                      //             color: Colors.white,
                                      //             boxShadow: [
                                      //               BoxShadow(
                                      //                   blurRadius: 5.0,
                                      //                   color: Colors.red[900])
                                      //             ]),
                                      //         child: Padding(
                                      //           padding:
                                      //               const EdgeInsets.all(7.0),
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
                                Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Container(
                                    height: 1,
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
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          FaIcon(FontAwesomeIcons.receipt),
                                          Padding(
                                              padding:
                                                  EdgeInsets.only(left: 22)),
                                          Text(
                                            "Total Amount",
                                            style: _txtCustom,
                                          )
                                        ],
                                      ),
                                      Text(
                                        "Rs. ${item.total}",
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
                                              padding:
                                                  EdgeInsets.only(left: 10)),
                                          Text(
                                            "Delivery Charges",
                                            style: _txtCustom,
                                          )
                                        ],
                                      ),
                                      Text(
                                        item.shipping_charges > 0
                                            ? "Rs. ${item.shipping_charges}"
                                            : "FREE",
                                        style: _txtCustom,
                                      )
                                    ],
                                  ),
                                ),
                                (item.discount > 0)
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
                                                  MainAxisAlignment
                                                      .spaceBetween,
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
                                              "Rs. -${item.discount}",
                                              style: _txtCustom,
                                            )
                                          ],
                                        ),
                                      )
                                    : Padding(
                                        padding: EdgeInsets.only(bottom: 8.0)),
                                (item.status == 2 ||
                                        item.status == 3 ||
                                        item.status == 10 ||
                                        item.status == 5)
                                    ? Padding(
                                        padding: EdgeInsets.only(
                                            top: 15, bottom: 10),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 25.0, right: 25.0),
                                              child: Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    children: [
                                                      (item.status == 2 ||
                                                              item.status ==
                                                                  3 ||
                                                              item.status ==
                                                                  10 ||
                                                              item.status == 5)
                                                          ? _bigCircle
                                                          : _bigCircleNotYet,
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(top: 8.0),
                                                        child: Text(
                                                          "Pending",
                                                          style:
                                                              _txtCustomStatus,
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                  Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    children: [
                                                      (item.status == 3 ||
                                                              item.status ==
                                                                  10 ||
                                                              item.status == 5)
                                                          ? _bigCircle
                                                          : _bigCircleNotYet,
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(top: 8.0),
                                                        child: Text(
                                                          "Confirmed",
                                                          style:
                                                              _txtCustomStatus,
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                  Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    children: [
                                                      (item.status == 10 ||
                                                              item.status == 5)
                                                          ? _bigCircle
                                                          : _bigCircleNotYet,
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(top: 8.0),
                                                        child: Text(
                                                          "On the way",
                                                          style:
                                                              _txtCustomStatus,
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                  Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    children: [
                                                      (item.status == 5)
                                                          ? _bigCircle
                                                          : _bigCircleNotYet,
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(top: 8.0),
                                                        child: Text(
                                                          "Delivered",
                                                          style:
                                                              _txtCustomStatus,
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            )
                                          ],
                                        ),
                                      )
                                    : Padding(
                                        padding: const EdgeInsets.all(10.0),
                                        child: Container(
                                          decoration: BoxDecoration(
                                              color: Colors.white,
                                              border: Border.all(
                                                  color: Colors.black38)),
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                                top: 7.0,
                                                bottom: 7.0,
                                                left: 15.0,
                                                right: 15.0),
                                            child: Text(
                                              "${item.status_title}",
                                              style: _txtCustomRed,
                                            ),
                                          ),
                                        ),
                                      ),
                                Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Container(
                                    height: 1,
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
                                        "Rs. ${item.net_total}",
                                        style: _txtCustom,
                                      )
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(20.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: InkWell(
                                          onTap: () {
                                            Navigator.of(context).push(
                                                PageRouteBuilder(
                                                    pageBuilder: (_, __, ___) =>
                                                        new orderDetail(
                                                            orderID: item.id,
                                                            randID:
                                                                item.rand_id)));
                                          },
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Container(
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(14.0),
                                                color: Api.primaryColor,
                                              ),
                                              child: Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 7.0,
                                                    bottom: 7.0,
                                                    left: 20.0,
                                                    right: 20.0),
                                                child: Center(
                                                  child: Text(
                                                    "View Details",
                                                    style: _txtCustomWhite,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      item.status == 5
                                          ? Expanded(
                                              child: InkWell(
                                                onTap: () {
                                                  launchUrl2();
                                                },
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(14.0),
                                                        color: Api.primaryColor,
                                                        boxShadow: [
                                                          BoxShadow(
                                                              blurRadius: 5.0,
                                                              color: Api
                                                                  .primaryColor)
                                                        ]),
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              top: 7.0,
                                                              bottom: 7.0,
                                                              left: 20.0,
                                                              right: 20.0),
                                                      child: Center(
                                                        child: Text(
                                                          "Feedback",
                                                          style:
                                                              _txtCustomWhite,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            )
                                          : Container()
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                    ]),
              ),
            )));
  }
}

class noOrder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    MediaQueryData mediaQueryData = MediaQuery.of(context);
    return Container(
      width: 500.0,
      color: Colors.white,
      height: double.infinity,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Padding(
                padding:
                    EdgeInsets.only(top: mediaQueryData.padding.top + 50.0)),
            Image.asset(
              "assets/imgIllustration/IlustrasiCart.png",
              height: 300.0,
            ),
            Padding(padding: EdgeInsets.only(bottom: 10.0)),
            Text(
              "No Order History",
              style: TextStyle(
                  fontWeight: FontWeight.w400,
                  fontSize: 18.5,
                  color: Colors.black26.withOpacity(0.2),
                  fontFamily: "Popins"),
            ),
          ],
        ),
      ),
    );
  }
}

var _txtCustom = TextStyle(
  color: Colors.black54,
  fontSize: 15.0,
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

var _bigCircle = Padding(
  padding: const EdgeInsets.only(top: 0.0),
  child: Container(
    height: 20.0,
    width: 20.0,
    decoration: BoxDecoration(
      color: Colors.lightGreen,
      shape: BoxShape.circle,
    ),
    child: Center(
      child: Icon(
        Icons.check,
        color: Colors.white,
        size: 14.0,
      ),
    ),
  ),
);

var _bigCircleNotYet = Padding(
  padding: const EdgeInsets.only(top: 0.0),
  child: Container(
    height: 20.0,
    width: 20.0,
    decoration: BoxDecoration(
      color: Colors.red,
      shape: BoxShape.circle,
    ),
    child: Center(
      child: Icon(
        Icons.clear,
        color: Colors.white,
        size: 14.0,
      ),
    ),
  ),
);
