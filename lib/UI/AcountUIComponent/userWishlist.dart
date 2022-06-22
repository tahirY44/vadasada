import 'dart:async';
import 'dart:convert';

import 'package:vadasada/Api/api.dart';
import 'package:vadasada/ListItem/ProductItem.dart';
import 'package:vadasada/UI/HomeUIComponent/productDetail.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'dart:math';

class wishlist extends StatefulWidget {
  final int userID;

  const wishlist({this.userID, key}) : super(key: key);

  @override
  _wishlistState createState() => _wishlistState();
}

class _wishlistState extends State<wishlist> {
  var wishlistData = [];
  var user_id;
  bool _loading = false, showData = false;
  var rng = new Random();
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<ConnectivityResult> _connectivitySubscription;
  bool noInternet = false;
  int initialData = 0;

  @override
  void initState() {
    setState(() {
      user_id = widget.userID;
    });
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
    getWishlist();
  }

  getWishlist() async {
    setState(() {
      _loading = true;
    });
    var parameters = {
      'appkey': Api.appkey,
      'uid': user_id.toString(),
    };
    var response = await Api.getRequest(Api.user_wishlist, parameters);
    var data = jsonDecode(response.body);
    setState(() {
      _loading = false;
      showData = true;
      wishlistData = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
        appBar: AppBar(
          iconTheme: IconThemeData(color: Colors.white),
          centerTitle: true,
          backgroundColor: Api.primaryColor,
          title: Text(
            "Wishlist",
            style: TextStyle(
                fontFamily: "Gotik",
                fontSize: 18.0,
                color: Colors.white,
                fontWeight: FontWeight.w700),
          ),
          elevation: 0.0,
        ),
        body: LoadingOverlay(
            isLoading: _loading,
            progressIndicator: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Api.primaryColor),
            ),
            child: showData
                ? (wishlistData.length > 0
                    ? Column(
                        children: [
                          Container(
                            color: Colors.black12,
                            width: width,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text("Note : Swipe left to Remove",
                                  textAlign: TextAlign.center),
                            ),
                          ),
                          Flexible(
                            child: ListView.builder(
                              itemCount: wishlistData.length,
                              itemBuilder: (context, position) {
                                ///
                                /// Widget for list view slide delete
                                ///
                                return Slidable(
                                  // actionPane: new SlidableDrawerActionPane(),
                                  // actionExtentRatio: 0.25,
                                  // secondaryActions: <Widget>[
                                  //   new IconSlideAction(
                                  //     key: Key(wishlistData[position]['id']
                                  //         .toString()),
                                  //     caption: 'Delete',
                                  //     color: Colors.red,
                                  //     icon: Icons.delete,
                                  //     onTap: () {
                                  //       _deleteWishlist(
                                  //           context,
                                  //           wishlistData[position]['id'],
                                  //           position);
                                  //     },
                                  //   ),
                                  // ],
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        top: 3.5,
                                        left: 13.0,
                                        right: 13.0,
                                        bottom: 3.5),

                                    /// Background Constructor for card
                                    child: InkWell(
                                      onTap: () {
                                        _onClickProduct(wishlistData[position]);
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black12
                                                  .withOpacity(0.1),
                                              blurRadius: 3.5,
                                              spreadRadius: 0.4,
                                            )
                                          ],
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: <Widget>[
                                                Padding(
                                                    padding:
                                                        EdgeInsets.all(10.0),

                                                    /// Image item
                                                    child: Container(
                                                        decoration:
                                                            BoxDecoration(
                                                                color: Colors
                                                                    .white,
                                                                boxShadow: [
                                                              BoxShadow(
                                                                  color: Colors
                                                                      .black12
                                                                      .withOpacity(
                                                                          0.1),
                                                                  blurRadius:
                                                                      0.5,
                                                                  spreadRadius:
                                                                      0.1)
                                                            ]),
                                                        child: Image.network(
                                                          '${wishlistData[position]["images"]}',
                                                          height: 130.0,
                                                          width: 120.0,
                                                          fit: BoxFit.contain,
                                                        ))),
                                                Flexible(
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            top: 20.0,
                                                            left: 10.0,
                                                            right: 5.0),
                                                    child: Column(
                                                      /// Text Information Item
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      children: <Widget>[
                                                        Text(
                                                          '${wishlistData[position]["title"]}',
                                                          style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.w700,
                                                            fontFamily: "Sans",
                                                            color:
                                                                Colors.black87,
                                                          ),
                                                        ),
                                                        Padding(
                                                            padding:
                                                                EdgeInsets.only(
                                                                    top: 10.0)),
                                                        Text(
                                                          '',
                                                          style: TextStyle(
                                                            color:
                                                                Colors.black54,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            fontSize: 12.0,
                                                          ),
                                                        ),
                                                        Padding(
                                                            padding:
                                                                EdgeInsets.only(
                                                                    top: 10.0)),
                                                        Text(
                                                            'Rs ${wishlistData[position]["price"]}'),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Padding(
                                                padding:
                                                    EdgeInsets.only(top: 8.0)),
                                            // Divider(
                                            //   height: 2.0,
                                            //   color: Colors.black12,
                                            // ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                              scrollDirection: Axis.vertical,
                            ),
                          )
                        ],
                      )
                    : noItemCart())
                : Container()));
  }

  _deleteWishlist(BuildContext context, dynamic id, int position) async {
    setState(() {
      _loading = true;
    });
    var parameters = {'appkey': Api.appkey, 'wid': id.toString()};

    var response = await Api.getRequest(Api.delete_wishlist, parameters);
    var data = jsonDecode(response.body);
    setState(() {
      _loading = false;
    });
    if (data == 1) {
      wishlistData.removeAt(position);
      Scaffold.of(context).showSnackBar(SnackBar(
        content: Text("Item deleted from wishlist"),
        duration: Duration(seconds: 1),
        backgroundColor: Api.primaryColor,
      ));
    } else {
      Scaffold.of(context).showSnackBar(SnackBar(
          content: Text("Something went wrong"),
          duration: Duration(seconds: 1),
          backgroundColor: Colors.redAccent));
    }
  }

  _onClickProduct(dynamic data) {
    var id = data['product_id'];
    var title = data['title'];
    var image = data['images'];
    var number = id.toString() + rng.nextInt(9999).toString();
    var price = data['price'];
    var discount = data['discounted'];
    ProductItem obj = new ProductItem(
        id: id,
        title: title,
        images: image,
        heroId: number,
        price: price,
        discounted: discount);

    Navigator.of(context)
        .push(PageRouteBuilder(
            pageBuilder: (_, __, ___) => new productDetail(obj),
            transitionDuration: Duration(milliseconds: 900),

            /// Set animation Opacity in route to detailProduk layout
            transitionsBuilder:
                (_, Animation<double> animation, __, Widget child) {
              return Opacity(
                opacity: animation.value,
                child: child,
              );
            }))
        .then((value) {
      setState(() {
        showData = false;
      });
      getWishlist();
    });
  }
}

///
///
/// If no item cart this class showing
///
class noItemCart extends StatelessWidget {
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
              "WishList is Empty",
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
