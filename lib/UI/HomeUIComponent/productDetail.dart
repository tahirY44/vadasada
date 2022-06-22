import 'dart:async';
import 'dart:convert';
import 'dart:ui';
// import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:sweetalert/sweetalert.dart';
import 'package:vadasada/UI/BottomNavigationBar.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_html/style.dart';
import 'package:flutter_rating/flutter_rating.dart';
import 'package:localstorage/localstorage.dart';
import 'package:vadasada/Api/api.dart';
import 'package:vadasada/Library/carousel_pro/carousel_pro.dart';
import 'package:vadasada/ListItem/ProductItem.dart';
import 'package:vadasada/UI/CartUIComponent/CartLayout.dart';
import 'package:shimmer/shimmer.dart';
import 'package:vadasada/ListItem/cartItem.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'dart:math';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:vadasada/UI/products/MyListings.dart';
// import 'package:facebook_app_events/facebook_app_events.dart';

Widget _line() {
  return Container(
    height: 0.9,
    width: double.infinity,
    color: Colors.black12,
  );
}

/// Class for card product in "Top Rated Products"
class FavoriteItem extends StatelessWidget {
  String image, Rating, Salary, title, sale;

  FavoriteItem({this.image, this.Rating, this.Salary, this.title, this.sale});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 5.0),
      child: Container(
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(10.0)),
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
                Container(
                  height: 150.0,
                  width: 150.0,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(7.0),
                          topRight: Radius.circular(7.0)),
                      image: DecorationImage(
                          image: AssetImage(image), fit: BoxFit.cover)),
                ),
                Padding(padding: EdgeInsets.only(top: 15.0)),
                Padding(
                  padding: const EdgeInsets.only(left: 15.0, right: 15.0),
                  child: Text(
                    title,
                    style: TextStyle(
                        letterSpacing: 0.5,
                        color: Colors.black54,
                        fontFamily: "Sans",
                        fontWeight: FontWeight.w500,
                        fontSize: 13.0),
                  ),
                ),
                Padding(padding: EdgeInsets.only(top: 1.0)),
                Padding(
                  padding: const EdgeInsets.only(left: 15.0, right: 15.0),
                  child: Text(
                    Salary,
                    style: TextStyle(
                        fontFamily: "Sans",
                        fontWeight: FontWeight.w500,
                        fontSize: 14.0),
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.only(left: 15.0, right: 15.0, top: 5.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Text(
                            Rating,
                            style: TextStyle(
                                fontFamily: "Sans",
                                color: Colors.black26,
                                fontWeight: FontWeight.w500,
                                fontSize: 12.0),
                          ),
                          Icon(
                            Icons.star,
                            color: Colors.yellow,
                            size: 14.0,
                          )
                        ],
                      ),
                      Text(
                        sale,
                        style: TextStyle(
                            fontFamily: "Sans",
                            color: Colors.black26,
                            fontWeight: FontWeight.w500,
                            fontSize: 12.0),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class ItemGrid extends StatefulWidget {
  /// Get data from HomeGridItem.....dart class
  ProductItem gridItem;

  ItemGrid(this.gridItem);

  @override
  _ItemGridState createState() => _ItemGridState();
}

class _ItemGridState extends State<ItemGrid> {
  LocalStorage storage = new LocalStorage('vadasada');

  int cartItemCount = 0;
  int product_variation_type = 0;
  var cart_list = [];
  var cartItems = [];
  int cartTotal;

  _addItem(item) {
    if (item.is_variation == 0) {
      cartItem newItem = new cartItem();
      newItem.product_variation_type = 0;
      newItem.id = item.id;
      newItem.title = item.title;
      newItem.price = item.price;
      newItem.dprice = item.discounted;
      newItem.image = item.images;
      newItem.qty = 1;
      newItem.amount = item.discounted > 0 ? item.discounted : item.price;

      cart_list = storage.getItem('cart') ?? [];
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          // action: SnackBarAction(
          //   label: 'Action',
          //   onPressed: () {
          //     // Code to execute.
          //   },
          // ),
          content: const Text(
            'Item Added to Cart',
            textAlign: TextAlign.center,
          ),
          duration: const Duration(milliseconds: 1500),
          width: 280.0, // Width of the SnackBar.
          padding: const EdgeInsets.symmetric(
            horizontal: 8.0, // Inner padding for SnackBar content.
          ),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),
      );
      setState(() {
        if (cart_list.length > 0) {
          bool found = false;
          for (var i = 0; i < cart_list.length; i++) {
            if (cart_list[i]['id'] == newItem.id) {
              cart_list[i]['qty'] += 1;
              cart_list[i]['amount'] = cart_list[i]['amount'] + newItem.amount;
              found = true;
            }
          }
          if (!found) {
            cart_list.add(newItem.toJSONEncodable());
            _saveToStorage();
            cartItemCount += 1;
          } else {
            _saveToStorage();
            cartItemCount += 1;
          }
        } else {
          cart_list.add(newItem.toJSONEncodable());
          _saveToStorage();
          cartItemCount += 1;
        }
      });
      refreshAppBar();
      setState(() {
        product_variation_type = 0;
      });
    } else {
      Navigator.of(context).push(PageRouteBuilder(
          pageBuilder: (_, __, ___) => new productDetail(item),
          transitionDuration: Duration(milliseconds: 900),

          /// Set animation Opacity in route to detailProduk layout
          transitionsBuilder:
              (_, Animation<double> animation, __, Widget child) {
            return Opacity(
              opacity: animation.value,
              child: child,
            );
          }));
    }
  }

  _saveToStorage() {
    storage.setItem('cart', cart_list);
  }

  void initializeCart() {
    setState(() {
      cartItemCount = 0;
      cart_list = storage.getItem('cart') ?? [];
      // list.items = storage.getItem('cart') ?? [];
      if (cart_list.length > 0) {
        for (var i = 0; i < cart_list.length; i++) {
          cartItemCount += cart_list[i]['qty'];
        }
      }
    });
  }

  void refreshAppBar() {
    setState(() {
      // storage.deleteItem("cart");
      int total = 0;
      cartItems = storage.getItem("cart") ?? [];
      if (cartItems.length > 0) {
        for (var i = 0; i < cartItems.length; i++) {
          total += cartItems[i]['qty'];
        }
      }
      cartTotal = total;
    });
  }

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
      itemWidth = width / 2.4;
    }
    if (height > 1200) {
      itemHeight = height / 4.5;
    } else if (height > 950) {
      itemHeight = height / 4;
    } else if (height > 750) {
      itemHeight = height / 4;
    } else {
      itemHeight = height / 3;
    }
    return Padding(
      padding: const EdgeInsets.only(left: 5.0, right: 5.0),
      child: InkWell(
        onTap: () {
          Navigator.of(context)
              .push(PageRouteBuilder(
                  pageBuilder: (_, __, ___) =>
                      new productDetail(widget.gridItem),
                  transitionDuration: Duration(milliseconds: 900),

                  /// Set animation Opacity in route to detailProduk layout
                  transitionsBuilder:
                      (_, Animation<double> animation, __, Widget child) {
                    return Opacity(
                      opacity: animation.value,
                      child: child,
                    );
                  }))
              .then((value) => {initializeCart()});
        },
        child: Container(
          width: itemWidth,
          height: itemHeight,
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
                    tag: "hero-grid-${widget.gridItem.heroId}",
                    child: Material(
                      child: InkWell(
//                      onTap: () {}
                        child: Container(
                          height: itemHeight * 0.68,
                          width: itemWidth,
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(7.0),
                                  topRight: Radius.circular(7.0)),
                              image: DecorationImage(
                                  image: NetworkImage(widget.gridItem.images),
                                  fit: BoxFit.contain)),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: itemHeight * 0.27,
                    child: Padding(
                      padding: const EdgeInsets.only(
                          left: 10.0, right: 10.0, top: 10.0, bottom: 5.0),
                      child: Text(
                        widget.gridItem.title,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                        style: TextStyle(
                            letterSpacing: 0.5,
                            color: Colors.black54,
                            fontFamily: "Sans",
                            fontWeight: FontWeight.w500,
                            fontSize: 14),
                      ),
                    ),
                  ),
                  SizedBox(
                      height: itemHeight * 0.10,
                      child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: widget.gridItem.discounted > 0
                              ? <Widget>[
                                  Padding(
                                    padding: EdgeInsets.only(left: 10.0),
                                    child: Text(
                                        "Rs " +
                                            widget.gridItem.discounted
                                                .toString(),
                                        style: TextStyle(
                                            color: Api.primaryColor,
                                            fontWeight: FontWeight.w800,
                                            fontFamily: "Sans",
                                            fontSize: 16)),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(left: 10.0),
                                    child: Text(
                                      "Rs " + widget.gridItem.price.toString(),
                                      style: TextStyle(
                                          decoration:
                                              TextDecoration.lineThrough,
                                          color: Colors.black54,
                                          fontWeight: FontWeight.w600,
                                          fontFamily: "Sans",
                                          fontSize: 12.5),
                                    ),
                                  ),
                                ]
                              : <Widget>[
                                  Padding(
                                    padding: EdgeInsets.only(left: 10.0),
                                    child: Container(
                                      width: width * 0.38,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            "Rs " +
                                                widget.gridItem.price
                                                    .toString(),
                                            style: TextStyle(
                                                color: Api.primaryColor,
                                                fontWeight: FontWeight.w800,
                                                fontFamily: "Sans",
                                                fontSize: 16),
                                          ),
                                          IconButton(
                                            icon: Icon(
                                                Icons.shopping_cart_outlined),
                                            onPressed: () {
                                              // print('in cart');
                                              _addItem(widget.gridItem);
                                            },
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                ]))
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class productDetail extends StatefulWidget {
  ProductItem productItem;
  productDetail(this.productItem);

  @override
  _productDetailState createState() => _productDetailState(productItem);
}

class _productDetailState extends State<productDetail> {
  @override
  static BuildContext ctx;
  LocalStorage storage = new LocalStorage('vadasada');
  // static final facebookAppEvents = FacebookAppEvents();

  var cart_list = [];
  var user;
  bool _loading = true, loadIcons = false;
  int product_variation_type = 0;
  String variationHeading1 = "";
  String variationHeading2 = "";

  var product = {};
  bool showVariations = false,
      showDescription = false,
      showSpecification = false,
      showReview = false,
      showRelated = false;
  int vendorId = 0;
  var vendorName = '';
  var vendorContactNo = '';
  int activeVariation1 = 100;
  int activeVariation2 = 100;
  List<Widget> variationWidget1 = [];
  List<Widget> variationWidget2 = [];
  List<Widget> icons = [];
  List<ProductItem> relatedProductCategory = [];
  var rng = new Random();

  String desc = "";
  String specification = "";
  String brands = "";

  cartItem newItem = new cartItem();

  /// Custom Text black
  static var _customTextStyle = TextStyle(
    color: Colors.black,
    fontFamily: "Gotik",
    fontSize: 17.0,
    fontWeight: FontWeight.w800,
  );

  /// Custom Text for Header title
  static var _subHeaderCustomStyle = TextStyle(
      color: Colors.black54,
      fontWeight: FontWeight.w700,
      fontFamily: "Gotik",
      fontSize: 16.0);

  /// Custom Text for Detail title
  static var _detailText = TextStyle(
      fontFamily: "Gotik",
      color: Colors.black54,
      letterSpacing: 0.3,
      wordSpacing: 0.5);

  double rating = 3.5;
  int starCount = 5;
  final ProductItem productItem;

  int cartItemCount = 0;

  final GlobalKey<ScaffoldState> _key = GlobalKey<ScaffoldState>();

  final Connectivity _connectivity = Connectivity();
  StreamSubscription<ConnectivityResult> _connectivitySubscription;
  bool noInternet = false;
  int initialData = 0;

  var product_images = [];

  /// Variable Component UI use in bottom layout "Top Rated Products"
  var _suggestedItem = "";

  _productDetailState(this.productItem);

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
    return Scaffold(
      key: _key,
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.white, //change your color here
        ),
        actions: <Widget>[
          InkWell(
            onTap: () {
              Navigator.of(context).pushAndRemoveUntil(
                  PageRouteBuilder(
                      pageBuilder: (_, __, ___) => new bottomNavigationBar()),
                  (r) => false);
            },
            child: IconButton(
              onPressed: null,
              icon: Icon(Icons.home, color: Colors.white),
            ),
          ),
        ],
        elevation: 0.5,
        centerTitle: true,
        backgroundColor: Api.primaryColor,
        title: Text(
          "Product Details",
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: Colors.white,
            fontSize: 17.0,
            fontFamily: "Gotik",
          ),
        ),
      ),
      body: LoadingOverlay(
        isLoading: _loading,
        progressIndicator: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Api.primaryColor),
        ),
        child: Column(
          children: <Widget>[
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    /// Header image slider
                    Container(
                      height: 300.0,
                      child: Hero(
                        tag: "hero-grid-${productItem.heroId}",
                        child: Material(
                          color: Colors.white,
                          child: new Carousel(
                            dotColor: Colors.black26,
                            dotIncreaseSize: 1.7,
                            dotBgColor: Colors.transparent,
                            autoplay: false,
                            boxFit: BoxFit.contain,
                            images: product_images.length > 0
                                ? product_images
                                : [
                                    NetworkImage(productItem.images),
                                  ],
                          ),
                        ),
                      ),
                    ),

                    /// Background white title,price and ratting
                    Container(
                      decoration:
                          BoxDecoration(color: Colors.white, boxShadow: [
                        BoxShadow(
                          color: Color(0xFF656565).withOpacity(0.15),
                          blurRadius: 1.0,
                          spreadRadius: 0.2,
                        )
                      ]),
                      child: Padding(
                        padding: const EdgeInsets.only(
                            left: 20.0, top: 10.0, right: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.only(top: 10.0),
                              child: Text(
                                newItem.title != null
                                    ? '${newItem.title}'
                                    : productItem.title,
                                style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontFamily: "Sans",
                                    fontSize: 20,
                                    height: 1.2),
                              ),
                            ),
                            brands.isNotEmpty
                                ? Padding(
                                    padding: const EdgeInsets.only(top: 10.0),
                                    child: Text(
                                      'Brand : ${brands}',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontFamily: "Sans",
                                          fontSize: 16,
                                          color: Colors.grey.shade600,
                                          height: 1),
                                    ),
                                  )
                                : Padding(
                                    padding: const EdgeInsets.only(top: 0.0),
                                  ),
                            vendorName.isNotEmpty
                                ? Padding(
                                    padding: const EdgeInsets.only(top: 10.0),
                                    child: InkWell(
                                      onTap: () {
                                        Navigator.of(context).push(
                                            PageRouteBuilder(
                                                pageBuilder: (_, __, ___) =>
                                                    new MyListings(
                                                        title: vendorName,
                                                        id: vendorId),
                                                transitionDuration:
                                                    Duration(milliseconds: 900),

                                                /// Set animation Opacity in route to detailProduk layout
                                                transitionsBuilder: (_,
                                                    Animation<double> animation,
                                                    __,
                                                    Widget child) {
                                                  return Opacity(
                                                    opacity: animation.value,
                                                    child: child,
                                                  );
                                                }));
                                      },
                                      child: Text(
                                        'Merchant : ${vendorName}',
                                        style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontFamily: "Sans",
                                            fontSize: 16,
                                            color: Api.thirdColor,
                                            height: 1),
                                      ),
                                    ),
                                  )
                                : Padding(
                                    padding: const EdgeInsets.only(top: 0.0),
                                  ),
                            newItem.id != null
                                ? Padding(
                                    padding: const EdgeInsets.only(top: 10.0),
                                    child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: newItem.dprice > 0
                                            ? <Widget>[
                                                Padding(
                                                  padding: EdgeInsets.only(
                                                      left: 5.0),
                                                  child: Text(
                                                      "Rs " +
                                                          newItem.dprice
                                                              .toString(),
                                                      style: TextStyle(
                                                          color:
                                                              Api.primaryColor,
                                                          fontWeight:
                                                              FontWeight.w800,
                                                          fontFamily: "Sans",
                                                          fontSize: 13)),
                                                ),
                                                Padding(
                                                  padding: EdgeInsets.only(
                                                      left: 5.0),
                                                  child: Text(
                                                    "Rs " +
                                                        newItem.price
                                                            .toString(),
                                                    style: TextStyle(
                                                        decoration:
                                                            TextDecoration
                                                                .lineThrough,
                                                        color: Colors.black54,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        fontFamily: "Sans",
                                                        fontSize: 16.5),
                                                  ),
                                                ),
                                              ]
                                            : <Widget>[
                                                Padding(
                                                  padding: EdgeInsets.only(
                                                      left: 0.0),
                                                  child: Text(
                                                      "Rs " +
                                                          newItem.price
                                                              .toString(),
                                                      style: TextStyle(
                                                          color:
                                                              Api.primaryColor,
                                                          fontWeight:
                                                              FontWeight.w700,
                                                          fontFamily: "Sans",
                                                          fontSize: 22)),
                                                ),
                                              ]),
                                  )
                                : Padding(
                                    padding: const EdgeInsets.only(top: 10.0),
                                    child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: productItem.discounted > 0
                                            ? <Widget>[
                                                Padding(
                                                  padding: EdgeInsets.only(
                                                      left: 5.0),
                                                  child: Text(
                                                      "Rs " +
                                                          productItem.discounted
                                                              .toString(),
                                                      style: TextStyle(
                                                          color:
                                                              Api.primaryColor,
                                                          fontWeight:
                                                              FontWeight.w800,
                                                          fontFamily: "Sans",
                                                          fontSize: 13)),
                                                ),
                                                Padding(
                                                  padding: EdgeInsets.only(
                                                      left: 5.0),
                                                  child: Text(
                                                    "Rs " +
                                                        productItem.price
                                                            .toString(),
                                                    style: TextStyle(
                                                        decoration:
                                                            TextDecoration
                                                                .lineThrough,
                                                        color: Colors.black54,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        fontFamily: "Sans",
                                                        fontSize: 11.5),
                                                  ),
                                                ),
                                              ]
                                            : <Widget>[
                                                Padding(
                                                  padding: EdgeInsets.only(
                                                      left: 10.0),
                                                  child: Text(
                                                      "Rs " +
                                                          productItem.price
                                                              .toString(),
                                                      style: TextStyle(
                                                          color:
                                                              Api.primaryColor,
                                                          fontWeight:
                                                              FontWeight.w800,
                                                          fontFamily: "Sans",
                                                          fontSize: 13)),
                                                ),
                                              ]),
                                  ),
                            Padding(padding: EdgeInsets.only(top: 10.0)),
                            Divider(
                              color: Colors.black12,
                              height: 1.0,
                            )
                          ],
                        ),
                      ),
                    ),

                    product_variation_type > 0
                        ? Padding(
                            padding: const EdgeInsets.only(top: 10.0),
                            child: Container(
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  boxShadow: [
                                    BoxShadow(
                                      color:
                                          Color(0xFF656565).withOpacity(0.15),
                                      blurRadius: 1.0,
                                      spreadRadius: 0.2,
                                    )
                                  ]),
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    top: 20.0, left: 20.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text("Select ${variationHeading1}",
                                        style: _subHeaderCustomStyle),
                                    Padding(
                                      padding: EdgeInsets.only(bottom: 10.0),
                                    ),
                                    SingleChildScrollView(
                                      child: Container(
                                        color: Colors.white,
                                        margin: EdgeInsets.only(
                                            right: 5.0, top: 2.0),
                                        height: 45.0,
                                        child: ListView(
                                          padding: EdgeInsets.only(bottom: 5.0),
                                          scrollDirection: Axis.horizontal,
                                          children: variationWidget1.length > 0
                                              ? variationWidget1
                                              : [],
                                        ),
                                      ),
                                    ),
                                    Padding(padding: EdgeInsets.only(top: 15.0))
                                  ],
                                ),
                              ),
                            ),
                          )
                        : Container(),

                    product_variation_type > 1
                        ? Padding(
                            padding: const EdgeInsets.only(top: 10.0),
                            child: Container(
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  boxShadow: [
                                    BoxShadow(
                                      color:
                                          Color(0xFF656565).withOpacity(0.15),
                                      blurRadius: 1.0,
                                      spreadRadius: 0.2,
                                    )
                                  ]),
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    top: 20.0, left: 20.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text("Select ${variationHeading2}",
                                        style: _subHeaderCustomStyle),
                                    Padding(
                                      padding: EdgeInsets.only(bottom: 10.0),
                                    ),
                                    SingleChildScrollView(
                                      child: Container(
                                        color: Colors.white,
                                        margin: EdgeInsets.only(
                                            right: 5.0, top: 2.0),
                                        height: 45.0,
                                        child: ListView(
                                          padding: EdgeInsets.only(bottom: 5.0),
                                          scrollDirection: Axis.horizontal,
                                          children: variationWidget2.length > 0
                                              ? variationWidget2
                                              : [],
                                        ),
                                      ),
                                    ),
                                    Padding(padding: EdgeInsets.only(top: 15.0))
                                  ],
                                ),
                              ),
                            ),
                          )
                        : Container(),

                    desc.isNotEmpty
                        ? Padding(
                            padding: const EdgeInsets.only(top: 10.0),
                            child: Container(
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  boxShadow: [
                                    BoxShadow(
                                      color:
                                          Color(0xFF656565).withOpacity(0.15),
                                      blurRadius: 1.0,
                                      spreadRadius: 0.2,
                                    )
                                  ]),
                              child: Padding(
                                padding: EdgeInsets.only(top: 20.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(left: 20.0),
                                      child: Text(
                                        "Description",
                                        style: _subHeaderCustomStyle,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          top: 15.0,
                                          right: 20.0,
                                          bottom: 10.0,
                                          left: 20.0),
                                      child: Html(data: desc, style: {
                                        "hr": Style(
                                            margin: EdgeInsets.symmetric(
                                                vertical: 10))
                                      }
                                          // style: {
                                          //   "hr": Style(
                                          //       padding:
                                          //           EdgeInsets.only(bottom: 10))
                                          // },
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          )
                        : Padding(
                            padding: const EdgeInsets.only(top: 0.0),
                          ),

                    specification.isNotEmpty
                        ? Padding(
                            padding: const EdgeInsets.only(top: 10.0),
                            child: Container(
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  boxShadow: [
                                    BoxShadow(
                                      color:
                                          Color(0xFF656565).withOpacity(0.15),
                                      blurRadius: 1.0,
                                      spreadRadius: 0.2,
                                    )
                                  ]),
                              child: Padding(
                                padding: EdgeInsets.only(top: 20.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(left: 20.0),
                                      child: Text(
                                        "Specification",
                                        style: _subHeaderCustomStyle,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          top: 15.0,
                                          right: 20.0,
                                          bottom: 10.0,
                                          left: 20.0),
                                      child: Html(data: specification, style: {
                                        "hr": Style(
                                            margin: EdgeInsets.symmetric(
                                                vertical: 10))
                                      }
                                          // style: {
                                          //   "hr": Style(
                                          //       padding:
                                          //           EdgeInsets.only(bottom: 10))
                                          // },
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          )
                        : Padding(
                            padding: const EdgeInsets.only(top: 0.0),
                          ),
                    Padding(
                      padding: const EdgeInsets.only(top: 10.0),
                      child: Container(
                        // decoration: BoxDecoration(color: Colors.white),
                        color: Colors.white,
                        width: double.infinity,
                        alignment: Alignment.centerLeft,
                        child: Column(
                          children: loadIcons ? icons : [],
                        ),
                      ),
                    ),
                    // Padding(
                    //   padding: const EdgeInsets.only(
                    //       left: 15.0, right: 20.0, top: 30.0, bottom: 20.0),
                    //   child: Container(
                    //     height: itemHeight + 12,
                    //     child: Column(
                    //       children: <Widget>[
                    //         Row(
                    //           children: <Widget>[
                    //             Text(
                    //               "Top Related Products",
                    //               style: TextStyle(
                    //                   fontWeight: FontWeight.w600,
                    //                   fontFamily: "Gotik",
                    //                   fontSize: 15.0),
                    //             )
                    //           ],
                    //         ),
                    //         Expanded(
                    //           child: showRelated
                    //               ? (relatedProductCategory.length > 0
                    //                   ? ListView.builder(
                    //                       padding: EdgeInsets.only(
                    //                           top: 20.0, bottom: 2.0),
                    //                       scrollDirection: Axis.horizontal,
                    //                       itemCount:
                    //                           relatedProductCategory.length,
                    //                       itemBuilder: (BuildContext context,
                    //                           int Index) {
                    //                         return GestureDetector(
                    //                             child: ItemGrid(
                    //                                 relatedProductCategory[
                    //                                     Index]));
                    //                         // return _itemGrid(context,
                    //                         //     relatedProductCategory[Index]);
                    //                       })
                    //                   : Padding(
                    //                       padding:
                    //                           const EdgeInsets.only(top: 20.0),
                    //                       child: Text(
                    //                         "No related products found",
                    //                         textAlign: TextAlign.center,
                    //                       ),
                    //                     ))
                    //               : ListView.builder(
                    //                   padding: EdgeInsets.only(
                    //                       top: 20.0, bottom: 2.0),
                    //                   scrollDirection: Axis.horizontal,
                    //                   itemCount: 4,
                    //                   itemBuilder:
                    //                       (BuildContext context, int Index) {
                    //                     return _loadingItemCard(context);
                    //                   }),
                    //         ),
                    //       ],
                    //     ),
                    //   ),
                    // )
                  ],
                ),
              ),
            ),

            /// If user click icon chart SnackBar show
            /// this code to show a SnackBar
            /// and Increase a cartItemCount + 1

            vendorContactNo.isNotEmpty
                ? Padding(
                    padding: const EdgeInsets.only(bottom: 0.0),
                    child: Container(
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                          InkWell(
                            onTap: () {
                              var url = "sms:${vendorContactNo}";
                              _launchUrl(url);
                            },
                            child: Container(
                              height: 50.0,
                              width: width * 0.33,
                              decoration: BoxDecoration(
                                  color: Colors.lightBlue,
                                  border: Border.all(color: Colors.black12)),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.email,
                                    color: Colors.white,
                                  ),
                                  Padding(
                                    padding:
                                        EdgeInsets.only(left: 5.0, right: 5.0),
                                    child: Text(
                                      "SMS",
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w700),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              var url = "tel:${vendorContactNo}";
                              _launchUrl(url);
                            },
                            child: Container(
                                height: 50.0,
                                width: width * 0.33,
                                decoration: BoxDecoration(
                                  color: Api.primaryColor,
                                  // border: Border.all(color: Colors.black12)
                                ),
                                child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Icon(
                                        Icons.phone,
                                        color: Colors.white,
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(
                                            left: 5.0, right: 5.0),
                                        child: Text(
                                          "Call",
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w700),
                                        ),
                                      ),
                                    ])),
                          ),
                          InkWell(
                            onTap: () {
                              var url = 'https://wa.me/${vendorContactNo}';
                              _launchUrl(url);
                            },
                            child: Container(
                              height: 50.0,
                              width: width * 0.33,
                              decoration: BoxDecoration(
                                  color: Colors.green,
                                  border: Border.all(color: Colors.black12)),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  FaIcon(
                                    FontAwesomeIcons.whatsapp,
                                    color: Colors.white,
                                  ),
                                  Padding(
                                    padding:
                                        EdgeInsets.only(left: 5.0, right: 5.0),
                                    child: Text(
                                      "WhatsApp",
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w700),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ])),
                  )
                : Container(),
          ],
        ),
      ),
      // bottomNavigationBar: vendorContactNo.isNotEmpty
      //     ? Padding(
      //         padding: EdgeInsets.symmetric(horizontal: 15, vertical: 25),
      //         child: Container(
      //           width: double.infinity,
      //           child: TextButton(
      //             onPressed: () async {
      //               print('here');
      //             },
      //             style: TextButton.styleFrom(
      //                 primary: Colors.white,
      //                 backgroundColor: Api.primaryColor,
      //                 shape: RoundedRectangleBorder(
      //                   borderRadius: BorderRadius.circular(6.0),
      //                 ),
      //                 padding: EdgeInsets.symmetric(vertical: 12)),
      //             child: Text(
      //               'Contact Vendor',
      //               style: TextStyle(fontSize: 14, color: Colors.white),
      //             ),
      //           ),
      //         ),
      //       )
      //     : null,
    );
  }

  void _launchUrl(url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      _key.currentState.showSnackBar(SnackBar(
          content: Text(
            "Could not launch $url",
            textAlign: TextAlign.center,
          ),
          duration: const Duration(milliseconds: 1500),
          width: 280.0, // Width of the SnackBar.
          padding: const EdgeInsets.symmetric(
            horizontal: 8.0, // Inner padding for SnackBar content.
          ),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          )));
      // throw 'Could not launch $url';
    }
  }

  Future<void> _makePhoneCall(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  _callNumber() async {
    const number = '03215002052'; //set the number here
    bool res = await FlutterPhoneDirectCaller.callNumber(number);
  }

  addToCart() {
    print('Add to cart');
  }

  getRelatedProductCategory(String category_id, int id) async {
    var parameters = {
      'appkey': Api.appkey,
      'category': category_id,
      'product': id.toString()
    };

    var response =
        await Api.getRequest(Api.category_product_related, parameters);
    var relatedProduct = jsonDecode(response.body);

    if (relatedProduct != 0) {
      setState(() {
        for (var i = 0; i < relatedProduct.length; i++) {
          var id = relatedProduct[i]['id'];
          var title = relatedProduct[i]['title'];
          var image = relatedProduct[i]['images'];
          var number = id.toString() + rng.nextInt(9999).toString();
          var price = relatedProduct[i]['price'];
          var discount = relatedProduct[i]['discounted'];
          var is_variation = relatedProduct[i]['is_variation'];
          ProductItem obj = new ProductItem(
              id: id,
              title: title,
              images: image,
              heroId: number,
              price: price,
              discounted: discount,
              is_variation: is_variation);
          relatedProductCategory.add(obj);
        }
        showRelated = true;
      });
    } else {
      setState(() {
        showRelated = true;
      });
    }
  }

  getData() async {
    MediaQueryData mediaQueryData = MediaQuery.of(context);
    double height = mediaQueryData.size.height;
    double width = mediaQueryData.size.width;
    double itemHeight;
    double itemWidth;
    if (width > 800) {
      itemWidth = width / 4.5;
    } else if (width > 550) {
      itemWidth = width / 3.5;
    } else {
      itemWidth = width / 2.5;
    }
    var parameters = {'appkey': Api.appkey, 'id': productItem.id.toString()};
    var response = await Api.getRequest(Api.product_content, parameters);

    var data = jsonDecode(response.body);
    // print(data);
    setState(() {
      product = data;
      vendorId = data['vendor']['id'];
      vendorName = data['vendor']['name'];
      vendorContactNo = data['vendor']['mobile'];
    });

    // getRelatedProductCategory(product['categories'], product['id']);

    setState(() {
      for (var i = 0; i < data['images'].length; i++) {
        product_images.add(NetworkImage(data['images'][i]['images']));
      }

      // for (var i = 0; i < data['icons'].length; i++) {
      //   icons.add(Padding(
      //     padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 20.0),
      //     child: Row(
      //       mainAxisAlignment: MainAxisAlignment.start,
      //       children: [
      //         Padding(
      //           padding: const EdgeInsets.only(bottom: 5.0, right: 15.0),
      //           child: SvgPicture.network(
      //             data['icons'][i]['images'],
      //             width: 30,
      //           ),
      //         ),
      //         Container(
      //           child: Column(
      //             mainAxisAlignment: MainAxisAlignment.start,
      //             crossAxisAlignment: CrossAxisAlignment.start,
      //             children: [
      //               Padding(
      //                 padding: const EdgeInsets.only(bottom: 5.0),
      //                 child: Text(
      //                   data['icons'][i]['title'],
      //                   style: TextStyle(
      //                     fontWeight: FontWeight.bold,
      //                     fontSize: 16,
      //                   ),
      //                 ),
      //               ),
      //               Container(
      //                 width: itemWidth * 1.8,
      //                 child: Text(
      //                   data['icons'][i]['description'],
      //                   style: TextStyle(
      //                     fontSize: 16,
      //                   ),
      //                 ),
      //               ),
      //             ],
      //           ),
      //         ),
      //       ],
      //     ),
      //   ));
      //   icons.add(Container(
      //     width: double.infinity,
      //     height: 0.2,
      //     color: Colors.grey,
      //   ));
      // }
      loadIcons = true;
    });
    if (data['parent_variation'] == null) {
      setState(() {
        product_variation_type = 0;
      });
    } else {
      // print(data);
      if (data['parent_variation'].length > 0 &&
          data['parent_variation'][0]['child_variation'].length == 0) {
        setState(() {
          product_variation_type = 1;
        });
      } else {
        setState(() {
          product_variation_type = 2;
        });
      }
    }
    // facebookAppEvents.logViewContent(
    //     id: data['id'].toString(),
    //     type: 'product',
    //     currency: 'PKR',
    //     price: data['discounted'] > 0
    //         ? double.parse(data['discounted'].toString())
    //         : double.parse(data['price'].toString()));
    setState(() {
      newItem.product_variation_type = product_variation_type;
      newItem.id = data['id'];
      newItem.code = data['product_code'];
      newItem.title = data['title'];
      newItem.price = data['price'];
      newItem.dprice = data['discounted'];
      newItem.image = data['images'][0]['images'];
      newItem.qty = 1;
      newItem.amount =
          data['discounted'] > 0 ? data['discounted'] : data['price'];
      if (product_variation_type > 0) {
        variationHeading1 = data['parent_variation'].length > 0
            ? data['parent_variation'][0]['group_title']
            : '';
        for (var i = 0; i < product['parent_variation'].length; i++) {
          var title = product['parent_variation'][i]['value_title'];
          variationWidget1
              .add(_variationButton(title, () => {setVariationData1(i)}, i));
          variationWidget1.add(Padding(padding: EdgeInsets.only(left: 15.0)));
        }

        if (product_variation_type > 1) {
          variationHeading2 = data['parent_variation'].length > 0
              ? data['parent_variation'][0]['child_variation'][0]['group_title']
              : '';
          var childData = data['parent_variation'].length > 0
              ? data['parent_variation'][0]['child_variation']
              : '';
          for (var i = 0; i < childData.length; i++) {
            var title = childData[i]['value_title'];
            variationWidget2
                .add(_variationButton2(title, () => {setVariationData2(i)}, i));
            variationWidget2.add(Padding(padding: EdgeInsets.only(left: 15.0)));
          }
        }
      }
      if (data['description'] != null) {
        desc = data["description"];
      }
      if (data['specification'] != null) {
        specification = data["specification"];
      }
      if (data['brands'] != null) {
        brands = data["brands"];
      }
    });
    setState(() {
      _loading = false;
    });
  }

  Future<void> dialNumber({@required String phoneNumber}) async {
    final url = "tel:$phoneNumber";
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      _key.currentState.showSnackBar(SnackBar(
          content: Text(
            "Unable to call $phoneNumber",
            textAlign: TextAlign.center,
          ),
          duration: const Duration(milliseconds: 1500),
          width: 280.0, // Width of the SnackBar.
          padding: const EdgeInsets.symmetric(
            horizontal: 8.0, // Inner padding for SnackBar content.
          ),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          )));
      ;
    }

    return;
  }

  void initState() {
    setState(() {
      user = storage.getItem("user") ?? null;
    });
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
    initializeCart();
    getData();
  }

  void initializeCart() {
    setState(() {
      cartItemCount = 0;
      cart_list = storage.getItem('cart') ?? [];
      // list.items = storage.getItem('cart') ?? [];
      if (cart_list.length > 0) {
        for (var i = 0; i < cart_list.length; i++) {
          cartItemCount += cart_list[i]['qty'];
        }
      }
    });
  }

  _addToWishlist() async {
    if (user != null) {
      var parameters = {
        'appkey': Api.appkey,
        'uid': user['id'].toString(),
        'product': product['id'].toString()
      };
      var response = await Api.getRequest(Api.add_to_wishlist, parameters);
      var data = jsonDecode(response.body);
      // print(data);
      _showMyDialog(data);
    } else {
      _key.currentState.showSnackBar(SnackBar(
        content: Text("Please login to add to wishlist "),
        duration: Duration(milliseconds: 500),
        backgroundColor: Colors.red,
      ));
    }
  }

  _showMyDialog(dynamic message) {
    return showDialog(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Info'),
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

  _addItem() {
    _key.currentState.showSnackBar(
      SnackBar(
        // action: SnackBarAction(
        //   label: 'Action',
        //   onPressed: () {
        //     // Code to execute.
        //   },
        // ),
        content: const Text(
          'Item Added to Cart',
          textAlign: TextAlign.center,
        ),
        duration: const Duration(milliseconds: 1500),
        width: 280.0, // Width of the SnackBar.
        padding: const EdgeInsets.symmetric(
          horizontal: 8.0, // Inner padding for SnackBar content.
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
      ),
    );
    setState(() {
      if (cart_list.length > 0) {
        bool found = false;
        for (var i = 0; i < cart_list.length; i++) {
          if (cart_list[i]['id'] == newItem.id) {
            cart_list[i]['qty'] += 1;
            cart_list[i]['amount'] = cart_list[i]['amount'] + newItem.amount;
            found = true;
          }
        }
        if (!found) {
          cart_list.add(newItem.toJSONEncodable());
          _saveToStorage();
          cartItemCount += 1;
        } else {
          _saveToStorage();
          cartItemCount += 1;
        }
      } else {
        cart_list.add(newItem.toJSONEncodable());
        _saveToStorage();
        cartItemCount += 1;
      }
    });

    // facebookAppEvents.logAddToCart(
    //     id: newItem.id.toString(),
    //     type: 'Product',
    //     currency: 'PKR',
    //     price: newItem.dprice > 0
    //         ? double.parse(newItem.dprice.toString())
    //         : double.parse(newItem.price.toString()));
  }

  _addItemQuick() {
    setState(() {
      if (cart_list.length > 0) {
        bool found = false;
        for (var i = 0; i < cart_list.length; i++) {
          if (cart_list[i]['id'] == newItem.id) {
            cart_list[i]['qty'] += 1;
            cart_list[i]['amount'] = cart_list[i]['amount'] + newItem.amount;
            found = true;
          }
        }
        if (!found) {
          cart_list.add(newItem.toJSONEncodable());
          _saveToStorage();
          cartItemCount += 1;
        } else {
          _saveToStorage();
          cartItemCount += 1;
        }
      } else {
        cart_list.add(newItem.toJSONEncodable());
        _saveToStorage();
        cartItemCount += 1;
      }

      // facebookAppEvents.logAddToCart(
      //     id: newItem.id.toString(),
      //     type: 'Product',
      //     currency: 'PKR',
      //     price: double.parse(newItem.price.toString()));

      Navigator.of(context)
          .push(PageRouteBuilder(pageBuilder: (_, __, ___) => new cart()))
          .then((res) => {initializeCart()});
    });
  }

  _saveToStorage() {
    storage.setItem('cart', cart_list);
  }

  /// BottomSheet for view more in specification
  void _bottomSheet() {
    showModalBottomSheet(
        context: context,
        builder: (builder) {
          return SingleChildScrollView(
            child: Container(
              color: Colors.black26,
              child: Padding(
                padding: const EdgeInsets.only(top: 2.0),
                child: Container(
                  height: 1500.0,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20.0),
                          topRight: Radius.circular(20.0))),
                  child: new Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Padding(padding: EdgeInsets.only(top: 20.0)),
                      Center(
                          child: Text(
                        "Description",
                        style: _subHeaderCustomStyle,
                      )),
                      Padding(
                        padding: const EdgeInsets.only(
                            top: 20.0, left: 20.0, right: 20.0, bottom: 20.0),
                        child: Text(desc, style: _detailText),
                      ),
                      // Padding(
                      //   padding: const EdgeInsets.only(left: 20.0),
                      //   child: Text(
                      //     "Specifications :",
                      //     style: TextStyle(
                      //         fontFamily: "Gotik",
                      //         fontWeight: FontWeight.w600,
                      //         fontSize: 15.0,
                      //         color: Colors.black,
                      //         letterSpacing: 0.3,
                      //         wordSpacing: 0.5),
                      //   ),
                      // ),
                      // Padding(
                      //   padding: const EdgeInsets.only(top: 20.0, left: 20.0),
                      //   child: Text(
                      //     " - Lorem ipsum is simply dummy  ",
                      //     style: _detailText,
                      //   ),
                      // )
                    ],
                  ),
                ),
              ),
            ),
          );
        });
  }

  void setVariationData1(int index) {
    setState(() {
      activeVariation1 = index;
      variationWidget1 = [];
    });
    var variation_title_1 = product['parent_variation'][index]['group_title'] +
        " : " +
        product['parent_variation'][index]['value_title'];
    // print(variation_title_1);
    for (var i = 0; i < product['parent_variation'].length; i++) {
      var title = product['parent_variation'][i]['value_title'];
      variationWidget1
          .add(_variationButton(title, () => {setVariationData1(i)}, i));
      variationWidget1.add(Padding(padding: EdgeInsets.only(left: 15.0)));
    }
    if (product_variation_type > 1) {
      setState(() {
        activeVariation2 = 0;
        variationWidget2 = [];
      });
      var childDataEntry =
          product['parent_variation'][activeVariation1]['child_variation'];
      for (var i = 0; i < childDataEntry.length; i++) {
        var title = childDataEntry[i]['value_title'];
        variationWidget2
            .add(_variationButton2(title, () => {setVariationData2(i)}, i));
        variationWidget2.add(Padding(padding: EdgeInsets.only(left: 15.0)));
      }
      var dataEntryChild =
          product['parent_variation'][activeVariation1]['child_variation'][0];
      var variation_title_2 =
          dataEntryChild['group_title'] + " : " + dataEntryChild['value_title'];
      setState(() {
        newItem.id = dataEntryChild['product']['id'];
        newItem.code = dataEntryChild['product']['product_code'];
        newItem.title = dataEntryChild['product']['title'];
        newItem.price = dataEntryChild['product']['price'];
        newItem.dprice = dataEntryChild['product']['discounted'];
        newItem.image = dataEntryChild['product']['images'][0]['images'];
        newItem.qty = 1;
        newItem.variation_1 = variation_title_1;
        newItem.variation_2 = variation_title_2;
        newItem.amount = dataEntryChild['product']['discounted'] > 0
            ? dataEntryChild['product']['discounted']
            : dataEntryChild['product']['price'];
        product_images = [];
        for (var i = 0; i < dataEntryChild['product']['images'].length; i++) {
          product_images.add(
              NetworkImage(dataEntryChild['product']['images'][i]['images']));
        }
        if (dataEntryChild['product']['description'] != null) {
          desc = dataEntryChild['product']['description'];
        }
        if (dataEntryChild['product']['specification'] != null) {
          specification = dataEntryChild['product']['specification'];
        }
      });
    } else {
      var dataEntry = product['parent_variation'][index];
      setState(() {
        newItem.id = dataEntry['product']['id'];
        newItem.code = dataEntry['product']['product_code'];
        newItem.title = dataEntry['product']['title'];
        newItem.price = dataEntry['product']['price'];
        newItem.dprice = dataEntry['product']['discounted'];
        newItem.image = dataEntry['product']['images'][0]['images'];
        newItem.qty = 1;
        newItem.variation_1 = variation_title_1;
        newItem.amount = dataEntry['product']['discounted'] > 0
            ? dataEntry['product']['discounted']
            : dataEntry['product']['price'];
        product_images = [];
        for (var i = 0; i < dataEntry['product']['images'].length; i++) {
          product_images
              .add(NetworkImage(dataEntry['product']['images'][i]['images']));
        }
        if (dataEntry['product']['description'] != null) {
          desc = dataEntry['product']['description'];
        }
        if (dataEntry['product']['specification'] != null) {
          specification = dataEntry['product']['specification'];
        }
      });
    }
  }

  void setVariationData2(int index) {
    setState(() {
      activeVariation2 = index;
      variationWidget2 = [];
    });
    var childData =
        product['parent_variation'][activeVariation1]['child_variation'];
    for (var i = 0; i < childData.length; i++) {
      var title = childData[i]['value_title'];
      variationWidget2
          .add(_variationButton2(title, () => {setVariationData2(i)}, i));
      variationWidget2.add(Padding(padding: EdgeInsets.only(left: 15.0)));
    }
    var dataEntry =
        product['parent_variation'][activeVariation1]['child_variation'][index];
    var variation_title_2 =
        dataEntry['group_title'] + " : " + dataEntry['value_title'];
    setState(() {
      newItem.id = dataEntry['product']['id'];
      newItem.code = dataEntry['product']['product_code'];
      newItem.title = dataEntry['product']['title'];
      newItem.price = dataEntry['product']['price'];
      newItem.dprice = dataEntry['product']['discounted'];
      newItem.image = dataEntry['product']['images'][0]['images'];
      newItem.qty = 1;
      newItem.variation_2 = variation_title_2;
      newItem.amount = dataEntry['product']['discounted'] > 0
          ? dataEntry['product']['discounted']
          : dataEntry['product']['price'];
      product_images = [];
      for (var i = 0; i < dataEntry['product']['images'].length; i++) {
        product_images
            .add(NetworkImage(dataEntry['product']['images'][i]['images']));
      }
    });
  }

  Widget _buildRating(
      String date, String details, Function changeRating, String image) {
    return ListTile(
      leading: Container(
        height: 45.0,
        width: 45.0,
        decoration: BoxDecoration(
            image: DecorationImage(image: AssetImage(image), fit: BoxFit.cover),
            borderRadius: BorderRadius.all(Radius.circular(50.0))),
      ),
      title: Row(
        children: <Widget>[
          StarRating(
              size: 20.0,
              rating: 3.5,
              starCount: 5,
              color: Colors.yellow,
              onRatingChanged: changeRating),
          SizedBox(width: 8.0),
          Text(
            date,
            style: TextStyle(fontSize: 12.0),
          )
        ],
      ),
      subtitle: Text(
        details,
        style: _detailText,
      ),
    );
  }

  Widget _variationButton(String text, GestureTapCallback setTitle, int index) {
    return Padding(
      padding: const EdgeInsets.only(top: 4.0, left: 3.0),
      child: Container(
        height: 29.5,
        decoration: BoxDecoration(
          color: activeVariation1 == index ? Api.primaryColor : Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(20.0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4.5,
              spreadRadius: 1.0,
            )
          ],
        ),
        child: Center(
          widthFactor: 1.5,
          child: InkWell(
            onTap: setTitle,
            child: Text(
              text,
              style: TextStyle(
                  color:
                      activeVariation1 == index ? Colors.white : Colors.black54,
                  fontFamily: "Sans"),
            ),
          ),
        ),
      ),
    );
  }

  Widget _variationButton2(
      String text, GestureTapCallback setTitle, int index) {
    return Padding(
      padding: const EdgeInsets.only(top: 4.0, left: 3.0),
      child: Container(
        height: 29.5,
        decoration: BoxDecoration(
          color: activeVariation2 == index ? Api.primaryColor : Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(20.0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4.5,
              spreadRadius: 1.0,
            )
          ],
        ),
        child: Center(
          widthFactor: 1.5,
          child: InkWell(
            onTap: setTitle,
            child: Text(
              text,
              style: TextStyle(
                  color:
                      activeVariation2 == index ? Colors.white : Colors.black54,
                  fontFamily: "Sans"),
            ),
          ),
        ),
      ),
    );
  }

  Widget _itemGrid(BuildContext context, ProductItem gridItem) {
    MediaQueryData mediaQueryData = MediaQuery.of(context);
    double height = mediaQueryData.size.height;
    double width = mediaQueryData.size.width;
    double itemHeight;
    double itemWidth;
    if (width > 800) {
      itemWidth = width / 4.5;
    } else if (width > 550) {
      itemWidth = width / 3.5;
    } else {
      itemWidth = width / 2.5;
    }
    if (height > 1200) {
      itemHeight = height / 4;
    } else if (height > 950) {
      itemHeight = height / 3.5;
    } else if (height > 750) {
      itemHeight = height / 3.5;
    } else {
      itemHeight = height / 2.8;
    }
    return Padding(
      padding: const EdgeInsets.only(left: 5.0, right: 5.0),
      child: InkWell(
        onTap: () {
          Navigator.of(context)
              .push(PageRouteBuilder(
                  pageBuilder: (_, __, ___) => new productDetail(gridItem),
                  transitionDuration: Duration(milliseconds: 900),

                  /// Set animation Opacity in route to detailProduk layout
                  transitionsBuilder:
                      (_, Animation<double> animation, __, Widget child) {
                    return Opacity(
                      opacity: animation.value,
                      child: child,
                    );
                  }))
              .then((value) => {initializeCart()});
        },
        child: Container(
          width: itemWidth,
          height: itemHeight,
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
                          height: itemHeight * 0.68,
                          width: itemWidth,
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
                    height: itemHeight * 0.2,
                    child: Padding(
                      padding: const EdgeInsets.only(
                          left: 10.0, right: 10.0, top: 10.0, bottom: 5.0),
                      child: Text(
                        gridItem.title,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                        style: TextStyle(
                            letterSpacing: 0.5,
                            color: Colors.black54,
                            fontFamily: "Sans",
                            fontWeight: FontWeight.w500,
                            fontSize: 14),
                      ),
                    ),
                  ),
                  SizedBox(
                      height: itemHeight * 0.10,
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
                                            fontSize: 16)),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(left: 10.0),
                                    child: Text(
                                      "Rs " + gridItem.price.toString(),
                                      style: TextStyle(
                                          decoration:
                                              TextDecoration.lineThrough,
                                          color: Colors.black54,
                                          fontWeight: FontWeight.w600,
                                          fontFamily: "Sans",
                                          fontSize: 12.5),
                                    ),
                                  ),
                                ]
                              : <Widget>[
                                  Padding(
                                    padding: EdgeInsets.only(left: 10.0),
                                    child: Container(
                                      width: width * 0.35,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            "Rs " + gridItem.price.toString(),
                                            style: TextStyle(
                                                color: Api.primaryColor,
                                                fontWeight: FontWeight.w800,
                                                fontFamily: "Sans",
                                                fontSize: 16),
                                          ),
                                          IconButton(
                                            icon: Icon(
                                                Icons.shopping_cart_outlined),
                                            onPressed: () {
                                              print('in cart');
                                              // _addItem(gridItem);
                                            },
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                ]))
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _loadingItemCard(BuildContext context) {
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
      itemWidth = width / 2.5;
    }
    if (height > 1200) {
      itemHeight = height / 4;
    } else if (height > 950) {
      itemHeight = height / 3.5;
    } else {
      itemHeight = height / 3;
    }
    return Padding(
      padding: const EdgeInsets.only(left: 5.0, right: 5.0),
      child: InkWell(
        onTap: () {},
        child: Container(
          width: itemWidth,
          height: itemHeight,
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Container(
                        height: itemHeight * 0.7,
                        width: itemWidth,
                        color: Colors.black12,
                      ),
                      Padding(
                          padding: const EdgeInsets.only(
                              left: 10.0, right: 5.0, top: 12.0),
                          child: Container(
                            height: 9.5,
                            width: itemWidth * 0.7,
                            color: Colors.black12,
                          )),
                      Padding(
                          padding: const EdgeInsets.only(
                              left: 10.0, right: 5.0, top: 10.0),
                          child: Container(
                            height: 9.5,
                            width: itemWidth * 0.5,
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
