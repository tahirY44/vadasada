import 'dart:async';
import 'dart:convert';

import 'package:connectivity/connectivity.dart';
import 'package:flutter/services.dart';
import 'package:shimmer/shimmer.dart';
import 'package:vadasada/Library/carousel_pro/carousel_pro.dart';
import 'package:flutter/material.dart';
import 'package:vadasada/ListItem/ProductItem.dart';
import 'package:vadasada/UI/HomeUIComponent/productDetail.dart';
import 'package:vadasada/Api/api.dart';
import 'package:vadasada/UI/HomeUIComponent/Search.dart';
import 'dart:math';

class brandDetail extends StatefulWidget {
  String title;
  int id;
  brandDetail({this.title, this.id});
  @override
  _brandDetailState createState() => _brandDetailState(title: title, id: id);
}

/// if user click icon in category layout navigate to categoryDetail Layout
class _brandDetailState extends State<brandDetail> {
  String title;
  int id;
  _brandDetailState({this.title, this.id});

  ///
  /// check the condition is right or wrong for image loaded or no
  ///
  bool loadImage = true, loadFeaturedItems = false, isLoading = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  List<ProductItem> brandProducts = [];
  ScrollController _controller = new ScrollController();
  int product_length = 0;
  int total_products;
  bool showBanner = false, notShowBanners = false, showSubCategories = false;
  var banner = [];
  var rng = new Random();

  final Connectivity _connectivity = Connectivity();
  StreamSubscription<ConnectivityResult> _connectivitySubscription;
  bool noInternet = false;
  int initialData = 0;

  /// custom text variable is make it easy a custom textStyle black font
  static var _customTextStyleBlack = TextStyle(
      fontFamily: "Gotik",
      color: Colors.black,
      fontWeight: FontWeight.w700,
      fontSize: 15.0);

  /// Custom text blue in variable
  static var _customTextStyleBlue = TextStyle(
      fontFamily: "Gotik",
      color: Color(0xFF6991C7),
      fontWeight: FontWeight.w700,
      fontSize: 15.0);

  @override
  void initState() {
    _controller.addListener(_scrollListenerData);
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
    print(title);
    getData();
  }

  getData() async {
    var parameters = {
      'appkey': Api.appkey,
      'brand': id.toString(),
      'offset': product_length.toString()
    };

    var response = await Api.getRequest(Api.brand_product_content, parameters);
    var data = jsonDecode(response.body);
    var products = data['products'];
    var bannerImage = data['info']['images'];

    setState(() {
      total_products = data['total_products']['total'];
      if (bannerImage != null) {
        banner.add(NetworkImage(bannerImage));
      }
      if (banner.length > 0) {
        showBanner = true;
      } else {
        notShowBanners = true;
      }
    });

    for (var i = 0; i < products.length; i++) {
      var id = products[i]['id'];
      var title = products[i]['title'];
      var number = id.toString() + rng.nextInt(9999).toString();
      var image = products[i]['images'];
      var price = products[i]['price'];
      var discount = products[i]['discounted'];
      ProductItem obj = new ProductItem(
          id: id,
          title: title,
          heroId: number,
          images: image,
          price: price,
          discounted: discount);
      brandProducts.add(obj);
    }
    setState(() {
      product_length += products.length;
      loadFeaturedItems = true;
    });
  }

  _scrollListenerData() {
    if (_controller.position.pixels == _controller.position.maxScrollExtent) {
      // print("here inside");
      startLoader();
    }
  }

  void startLoader() {
    setState(() {
      if (product_length < total_products) {
        fetchData();
      }
    });
  }

  fetchData() async {
    _scaffoldKey.currentState.showSnackBar(new SnackBar(
      duration: new Duration(milliseconds: 1000),
      backgroundColor: Colors.white,
      content: Row(
        children: <Widget>[
          CircularProgressIndicator(),
          Padding(
            padding: EdgeInsets.only(left: 10.0),
            child: Text(
              " Loading...",
              style: TextStyle(color: Colors.black54),
            ),
          )
        ],
      ),
    ));
    var parameters = {
      'appkey': Api.appkey,
      'brand': id.toString(),
      'offset': product_length.toString()
    };

    var response = await Api.getRequest(Api.brand_product_content, parameters);
    var data = jsonDecode(response.body);
    var products = data['products'];

    setState(() {
      for (var i = 0; i < products.length; i++) {
        var id = products[i]['id'];
        var title = products[i]['title'];
        var image = products[i]['images'];
        var number = id.toString() + rng.nextInt(9999).toString();
        var price = products[i]['price'];
        var discount = products[i]['discounted'];
        ProductItem obj = new ProductItem(
            id: id,
            title: title,
            heroId: number,
            images: image,
            price: price,
            discounted: discount);
        brandProducts.add(obj);
      }
      product_length += products.length;
    });
  }

  /// All Widget Component layout
  @override
  Widget build(BuildContext context) {
    MediaQueryData mediaQueryData = MediaQuery.of(context);
    double height = mediaQueryData.size.height;
    double width = mediaQueryData.size.width;
    double itemHeight;
    double itemWidth;
    if (width > 800) {
      itemWidth = width / 4;
    } else if (width > 550) {
      itemWidth = width / 3;
    } else {
      itemWidth = width / 2;
    }
    if (height > 1200) {
      itemHeight = height / 4;
    } else if (height > 950) {
      itemHeight = height / 3.5;
    } else if (height > 750) {
      itemHeight = height / 3;
    } else {
      itemHeight = height / 2.5;
    }

    /// imageSlider in header layout category detail
    var _imageSlider = Padding(
      padding: const EdgeInsets.only(
          top: 0.0, left: 10.0, right: 10.0, bottom: 20.0),
      child: Container(
        height: 150.0,
        child: new Carousel(
          boxFit: BoxFit.contain,
          dotColor: Colors.transparent,
          dotSize: 5.5,
          dotSpacing: 16.0,
          dotBgColor: Colors.transparent,
          showIndicator: false,
          overlayShadow: false,
          overlayShadowColors: Colors.white.withOpacity(0.9),
          overlayShadowSize: 0.9,
          images:
              showBanner ? banner : [AssetImage("assets/img/imageLoading.gif")],
        ),
      ),
    );

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: Api.primaryColor,
        actions: <Widget>[
          IconButton(
            onPressed: () {
              Navigator.of(context).push(PageRouteBuilder(
                  pageBuilder: (_, __, ___) => new searchAppbar()));
            },
            icon: Icon(Icons.search, color: Colors.white),
          ),
        ],
        centerTitle: true,
        title: Text(
          title,
          style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 16.0,
              color: Colors.black54,
              fontFamily: "Gotik"),
        ),
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
        elevation: 0.0,
      ),

      /// For call a variable include to body
      body: SingleChildScrollView(
        controller: _controller,
        child: Container(
          color: Colors.white,
          child: Column(children: <Widget>[
            notShowBanners ? Container() : _imageSlider,
            Padding(
              padding: EdgeInsets.only(bottom: 0.0),
              child: loadFeaturedItems
                  ? (product_length > 0
                      ? Container(
                          color: Colors.white,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              /// To set GridView item
                              GridView.builder(
                                physics: ScrollPhysics(),
                                shrinkWrap: true,
                                padding: EdgeInsets.symmetric(
                                    horizontal: 10.0, vertical: 20.0),
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisSpacing: 10.0,
                                  mainAxisSpacing: 17.0,
                                  childAspectRatio: (itemWidth / itemHeight),
                                  crossAxisCount: 2,
                                ),
                                // primary: true,
                                itemCount: brandProducts.length,
                                itemBuilder: (BuildContext context, int index) {
                                  return GestureDetector(
                                      child: ItemGrid(brandProducts[index]));
                                },
                              ),
                            ],
                          ),
                        )
                      : Padding(
                          padding: const EdgeInsets.only(top: 20.0),
                          child: Text(
                            "No products found",
                            textAlign: TextAlign.center,
                          ),
                        ))
                  : SingleChildScrollView(
                      child: Container(
                          margin: EdgeInsets.only(right: 10.0, bottom: 15.0),
                          height: 300.0,
                          child: _loadingImageAnimation(context)),
                    ),
            ),
            _loader(),
          ]),
        ),
      ),
    );
  }

  Widget _loader() {
    return isLoading
        ? new Align(
            child: new Container(
              width: 70.0,
              height: 70.0,
              child: new Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: new Center(child: new CircularProgressIndicator())),
            ),
            alignment: FractionalOffset.bottomCenter,
          )
        : new SizedBox(
            width: 0.0,
            height: 0.0,
          );
  }
}

class ItemGrid extends StatelessWidget {
  /// Get data from HomeGridItem.....dart class
  ProductItem gridItem;

  ItemGrid(this.gridItem);

  @override
  Widget build(BuildContext context) {
    MediaQueryData mediaQueryData = MediaQuery.of(context);
    double height = mediaQueryData.size.height;
    double width = mediaQueryData.size.width;
    double itemHeight;
    double itemWidth;
    if (width > 800) {
      itemWidth = width / 4;
    } else if (width > 550) {
      itemWidth = width / 3;
    } else {
      itemWidth = width / 2;
    }
    if (height > 1200) {
      itemHeight = height / 4;
    } else if (height > 950) {
      itemHeight = height / 3.5;
    } else if (height > 750) {
      itemHeight = height / 3;
    } else {
      itemHeight = height / 2.5;
    }
    return InkWell(
      onTap: () {
        Navigator.of(context).push(PageRouteBuilder(
            pageBuilder: (_, __, ___) => new productDetail(gridItem),
            transitionDuration: Duration(milliseconds: 900),

            /// Set animation Opacity in route to detailProduk layout
            transitionsBuilder:
                (_, Animation<double> animation, __, Widget child) {
              return Opacity(
                opacity: animation.value,
                child: child,
              );
            }));
      },
      child: Container(
        decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(width: 1.0, color: Colors.black26),
            boxShadow: [
              BoxShadow(
                color: Color(0xFF656565).withOpacity(0.15),
                blurRadius: 4.0,
                spreadRadius: 1.0,
//           offset: Offset(4.0, 10.0)
              )
            ]),
        child: Wrap(
          children: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                /// Set Animation image to detailProduk layout
                Hero(
                  tag: "hero-grid-${gridItem.heroId}",
                  child: Material(
                    child: InkWell(
//                      onTap: () {}
                      child: Container(
                        height: itemHeight * 0.70,
                        width: itemWidth * 0.93,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(7.0),
                                topRight: Radius.circular(7.0)),
                            image: DecorationImage(
                                image: NetworkImage(gridItem.images),
                                fit: BoxFit.contain)),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: itemHeight * 0.13,
                  child: Padding(
                    padding: const EdgeInsets.only(
                        left: 10.0, right: 10.0, top: 10.0, bottom: 5.0),
                    child: Text(
                      gridItem.title,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          letterSpacing: 0.5,
                          color: Colors.black54,
                          fontFamily: "Sans",
                          fontWeight: FontWeight.w500,
                          fontSize: 13),
                    ),
                  ),
                ),
                SizedBox(
                    height: itemHeight * 0.14,
                    child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: gridItem.discounted > 0
                            ? <Widget>[
                                Padding(
                                  padding: EdgeInsets.only(left: 10.0),
                                  child: Text(
                                      "Rs " + gridItem.discounted.toString(),
                                      style: TextStyle(
                                          color: Api.primaryColor,
                                          fontWeight: FontWeight.w800,
                                          fontFamily: "Sans",
                                          fontSize: 13)),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(left: 10.0),
                                  child: Text(
                                    "Rs " + gridItem.price.toString(),
                                    style: TextStyle(
                                        decoration: TextDecoration.lineThrough,
                                        color: Colors.black54,
                                        fontWeight: FontWeight.w600,
                                        fontFamily: "Sans",
                                        fontSize: 11.5),
                                  ),
                                ),
                              ]
                            : <Widget>[
                                Padding(
                                  padding: EdgeInsets.only(left: 10.0),
                                  child: Text("Rs " + gridItem.price.toString(),
                                      style: TextStyle(
                                          color: Api.primaryColor,
                                          fontWeight: FontWeight.w800,
                                          fontFamily: "Sans",
                                          fontSize: 13)),
                                ),
                              ]))
                // Padding(padding: EdgeInsets.only(top: 7.0)),
                // Padding(padding: EdgeInsets.only(top: 1.0)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Class Component Card in Category Detail

///
///
///
/// Loading Item Card Animation Constructor
///
///
///
class loadingMenuItemCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
          top: 20.0, left: 10.0, bottom: 10.0, right: 0.0),
      child: InkWell(
        onTap: () {},
        child: Container(
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(5.0)),
              boxShadow: [
                BoxShadow(
                  color: Color(0xFF656565).withOpacity(0.15),
                  blurRadius: 2.0,
                  spreadRadius: 1.0,
//           offset: Offset(4.0, 10.0)
                )
              ]),
          child: Wrap(
            children: <Widget>[
              Shimmer.fromColors(
                baseColor: Colors.black38,
                highlightColor: Colors.white,
                child: Container(
                  width: 160.0,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Container(
                        height: 185.0,
                        width: 160.0,
                        color: Colors.black12,
                      ),
                      Padding(
                          padding: const EdgeInsets.only(
                              left: 10.0, right: 5.0, top: 12.0),
                          child: Container(
                            height: 9.5,
                            width: 130.0,
                            color: Colors.black12,
                          )),
                      Padding(
                          padding: const EdgeInsets.only(
                              left: 10.0, right: 5.0, top: 10.0),
                          child: Container(
                            height: 9.5,
                            width: 80.0,
                            color: Colors.black12,
                          )),
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 15.0, right: 15.0, top: 15.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Row(
                              children: <Widget>[
                                Text(
                                  "",
                                  style: TextStyle(
                                      fontFamily: "Sans",
                                      color: Colors.black26,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 12.0),
                                )
                              ],
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

///
///
/// Calling imageLoading animation for set a grid layout
///
///
Widget _loadingImageAnimation(BuildContext context) {
  return ListView.builder(
    scrollDirection: Axis.horizontal,
    itemBuilder: (BuildContext context, int index) => loadingMenuItemCard(),
    itemCount: 6,
  );
}

///
///
/// Calling imageLoading animation for set a grid layout
///
///
