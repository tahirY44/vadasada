import 'dart:async';
import 'dart:convert';

import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vadasada/ListItem/cartItem.dart';
import 'package:localstorage/localstorage.dart';
import 'package:shimmer/shimmer.dart';
import 'package:vadasada/ListItem/ProductItem.dart';
import 'package:vadasada/UI/HomeUIComponent/productDetail.dart';
import 'package:vadasada/Api/api.dart';
import 'dart:math';
// import 'package:facebook_app_events/facebook_app_events.dart';

class searchAppbar extends StatefulWidget {
  @override
  _searchAppbarState createState() => _searchAppbarState();
}

class _searchAppbarState extends State<searchAppbar> {
  @override
  final searchController = TextEditingController();
  // static final facebookAppEvents = FacebookAppEvents();
  ScrollController _controller = new ScrollController();
  var rng = new Random();

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  List<ProductItem> searchedProducts = [];
  bool loadSearchProducts = false;
  String searchKeyword;
  int total_product = 0;
  int product_length = 0;

  final Connectivity _connectivity = Connectivity();
  StreamSubscription<ConnectivityResult> _connectivitySubscription;
  bool noInternet = false;

  void initState() {
    _controller.addListener(_scrollListenerData);
    searchController.addListener(_searchValue);
    // TODO: implement initState
    super.initState();
    initConnectivity();
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  }

  @override
  void dispose() {
    searchController.dispose();
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

  _searchValue() {
    setState(() {
      loadSearchProducts = false;
      product_length = 0;
    });
    getProducts();
  }

  getProducts() async {
    var parameters = {
      'appkey': Api.appkey,
      'search_keyword': searchKeyword,
      'offset': product_length.toString()
    };
    if (searchKeyword.length >= 5) {
      // facebookAppEvents.logEvent(
      //     name: 'searched', parameters: {'search_string': searchKeyword});
    }

    var response = await Api.getRequest(Api.search_product, parameters);
    var data = jsonDecode(response.body);
    var products = data['data'];

    setState(() {
      searchedProducts.clear();
      total_product = data["count"];
      product_length += products.length;
    });

    for (var i = 0; i < products.length; i++) {
      var id = products[i]['id'];
      var title = products[i]['title'];
      var image = products[i]['images'];
      var number = id.toString() + rng.nextInt(9999).toString();
      var price = products[i]['price'];
      var discount = products[i]['discounted'];
      var is_variation = products[i]['is_variation'];
      ProductItem obj = new ProductItem(
          id: id,
          title: title,
          images: image,
          heroId: number,
          price: price,
          discounted: discount,
          is_variation: is_variation);
      searchedProducts.add(obj);
    }

    setState(() {
      loadSearchProducts = true;
    });
  }

  _scrollListenerData() {
    if (_controller.position.pixels == _controller.position.maxScrollExtent) {
      // print("here inside");
      if (product_length < total_product) {
        startLoader();
      }
    }
  }

  void startLoader() {
    fetchData();
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
      'search_keyword': searchKeyword,
      'offset': product_length.toString()
    };

    var response = await Api.getRequest(Api.search_product, parameters);
    var data = jsonDecode(response.body);
    var products = data['data'];

    for (var i = 0; i < products.length; i++) {
      var id = products[i]['id'];
      var title = products[i]['title'];
      var image = products[i]['images'];
      var number = id.toString() + rng.nextInt(9999).toString();
      var price = products[i]['price'];
      var discount = products[i]['discounted'];
      var is_variation = products[i]['is_variation'];
      ProductItem obj = new ProductItem(
          id: id,
          title: title,
          images: image,
          heroId: number,
          price: price,
          discounted: discount,
          is_variation: is_variation);
      searchedProducts.add(obj);
    }
    setState(() {
      product_length += products.length;
    });
  }

  /// Sentence Text header "Hello i am Treva.........."
  var _textHello = Padding(
    padding: const EdgeInsets.only(right: 50.0, left: 20.0),
    child: Text(
      "Hello, Welcome to Vada Sada. What would you like to search ?",
      style: TextStyle(
          letterSpacing: 0.1,
          fontWeight: FontWeight.w600,
          fontSize: 22.0,
          color: Colors.black54,
          fontFamily: "Gotik"),
    ),
  );

  /// Item TextFromField Search

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
      itemHeight = height / 3.8;
    } else if (height > 950) {
      itemHeight = height / 3.3;
    } else if (height > 750) {
      itemHeight = height / 2.8;
    } else {
      itemHeight = height / 2.3;
    }

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Color(0xFF6991C7),
        ),
        title: Text(
          "Search",
          style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 18.0,
              color: Colors.black54,
              fontFamily: "Gotik"),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0.0,
      ),
      body: SingleChildScrollView(
        controller: _controller,
        child: GestureDetector(
          onTap: () {
            FocusScopeNode currentFocus = FocusScope.of(context);
            if (!currentFocus.hasPrimaryFocus) {
              currentFocus.unfocus();
            }
          },
          child: Container(
            color: Colors.white,
            child: Padding(
              padding: EdgeInsets.only(top: 15.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  /// Caliing a variable
                  _textHello,
                  Padding(
                    padding: const EdgeInsets.only(
                        top: 35.0, right: 20.0, left: 20.0, bottom: 15.0),
                    child: Container(
                      height: 50.0,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.all(Radius.circular(5.0)),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 15.0,
                                spreadRadius: 0.0)
                          ]),
                      child: Center(
                        child: Padding(
                          padding:
                              const EdgeInsets.only(left: 20.0, right: 10.0),
                          child: Theme(
                            data: ThemeData(hintColor: Colors.transparent),
                            child: TextField(
                              autofocus: true,
                              // controller: searchController,
                              onChanged: (String text) {
                                setState(() {
                                  searchKeyword = text;
                                });
                                _searchValue();
                              },
                              decoration: InputDecoration(
                                  border: InputBorder.none,
                                  icon: Icon(
                                    Icons.search,
                                    color: Color(0xFF6991C7),
                                    size: 28.0,
                                  ),
                                  hintText: "Find you want",
                                  hintStyle: TextStyle(
                                      color: Colors.black54,
                                      fontFamily: "Gotik",
                                      fontWeight: FontWeight.w400)),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(bottom: 0.0),
                    child: loadSearchProducts
                        ? Container(
                            color: Colors.white,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 20.0, top: 20.0),
                                  child: Text(
                                    "Search Products",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 17.0,
                                    ),
                                  ),
                                ),

                                /// To set GridView item
                                (total_product < 1)
                                    ? Padding(
                                        padding: const EdgeInsets.only(
                                            left: 20.0, top: 20.0),
                                        child: Container(
                                          child: Center(
                                            child: Text(
                                              "No products available for keyword",
                                              style: TextStyle(
                                                fontWeight: FontWeight.w300,
                                                fontSize: 15.0,
                                              ),
                                            ),
                                          ),
                                        ),
                                      )
                                    : GridView.builder(
                                        physics: ScrollPhysics(),
                                        shrinkWrap: true,
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 10.0, vertical: 20.0),
                                        gridDelegate:
                                            SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisSpacing: 10.0,
                                          mainAxisSpacing: 17.0,
                                          childAspectRatio:
                                              (itemWidth / itemHeight) * 0.90,
                                          crossAxisCount: 2,
                                        ),
                                        // primary: true,
                                        itemCount: searchedProducts.length,
                                        itemBuilder:
                                            (BuildContext context, int index) {
                                          return GestureDetector(
                                              child: ItemGrid(
                                                  searchedProducts[index]));
                                        },
                                      ),
                              ],
                            ),
                          )
                        : SingleChildScrollView(
                            child: Container(
                                margin:
                                    EdgeInsets.only(right: 10.0, bottom: 15.0),
                                child: _loadingImageAnimation(context)),
                          ),
                  ),
                ],
              ),
            ),
          ),
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
      itemWidth = width / 2;
    }
    if (height > 1200) {
      itemHeight = height / 3.8;
    } else if (height > 950) {
      itemHeight = height / 3.3;
    } else if (height > 750) {
      itemHeight = height / 2.8;
    } else {
      itemHeight = height / 2.3;
    }
    return InkWell(
      onTap: () {
        Navigator.of(context).push(PageRouteBuilder(
            pageBuilder: (_, __, ___) => new productDetail(widget.gridItem),
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
                  tag: "hero-grid-${widget.gridItem.heroId}",
                  child: Material(
                    child: InkWell(
//                      onTap: () {}
                      child: Container(
                        height: itemHeight * 0.65,
                        width: itemWidth * 0.93,
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
                Container(
                  height: itemHeight * 0.18,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 10.0, right: 10.0, top: 5.0, bottom: 5.0),
                        child: Text(
                          widget.gridItem.title,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                          style: TextStyle(
                              letterSpacing: 0.5,
                              color: Colors.black54,
                              fontFamily: "Sans",
                              fontWeight: FontWeight.w500,
                              fontSize: 13),
                        ),
                      ),
                    ],
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
                                          widget.gridItem.discounted.toString(),
                                      style: TextStyle(
                                          color: Api.primaryColor,
                                          fontWeight: FontWeight.w800,
                                          fontFamily: "Sans",
                                          fontSize: 13)),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(left: 10.0),
                                  child: Text(
                                    "Rs " + widget.gridItem.price.toString(),
                                    style: TextStyle(
                                        decoration: TextDecoration.lineThrough,
                                        color: Colors.black54,
                                        fontWeight: FontWeight.w600,
                                        fontFamily: "Sans",
                                        fontSize: 11.5),
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(Icons.shopping_cart_outlined),
                                  onPressed: () {
                                    _addItem(widget.gridItem);
                                  },
                                )
                              ]
                            : <Widget>[
                                Padding(
                                  padding: EdgeInsets.only(left: 10.0),
                                  child: Container(
                                    width: width * 0.42,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          "Rs " +
                                              widget.gridItem.price.toString(),
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
                                            _addItem(widget.gridItem);
                                          },
                                        )
                                      ],
                                    ),
                                  ),
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
    itemWidth = width / 2;
  }
  if (height > 1200) {
    itemHeight = height / 4;
  } else if (height > 950) {
    itemHeight = height / 3.5;
  } else {
    itemHeight = height / 3;
  }
  return InkWell(
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
                    height: itemHeight * 0.70,
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
  );
}

Widget _loadingImageAnimation(BuildContext context) {
  MediaQueryData mediaQueryData = MediaQuery.of(context);
  double size = mediaQueryData.size.height;
  double width = mediaQueryData.size.width;
  double height = mediaQueryData.size.height;
  int crossaxis;
  double itemWidth;
  double itemHeight;
  if (width > 800) {
    crossaxis = 4;
    itemWidth = mediaQueryData.size.width / 4;
  } else if (width > 550) {
    crossaxis = 3;
    itemWidth = mediaQueryData.size.width / 3;
  } else {
    crossaxis = 2;
    itemWidth = mediaQueryData.size.width / 2;
  }
  if (height > 1200) {
    itemHeight = height / 4;
  } else if (height > 950) {
    itemHeight = height / 3.5;
  } else {
    itemHeight = height / 3;
  }

  return GridView.builder(
      physics: ScrollPhysics(),
      shrinkWrap: true,
      padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisSpacing: 10.0,
        mainAxisSpacing: 17.0,
        childAspectRatio: (itemWidth / itemHeight),
        crossAxisCount: crossaxis,
      ),
      // primary: true,
      itemCount: 4,
      itemBuilder: (BuildContext context, int index) {
        return GestureDetector(child: _loadingItemCard(context));
      });
}

/// Popular Keyword Item class
class KeywordItem extends StatelessWidget {
  @override
  String title, title2;

  KeywordItem({this.title, this.title2});

  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        SubCategoryTile(title: title),
        Padding(padding: EdgeInsets.only(top: 15.0)),
        SubCategoryTile(title: title2),
      ],
    );
  }
}

class SubCategoryTile extends StatelessWidget {
  const SubCategoryTile({
    Key key,
    @required this.title,
  }) : super(key: key);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4.0, left: 3.0),
      child: Container(
        height: 29.5,
        width: 90.0,
        decoration: BoxDecoration(
          color: Colors.white,
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
          child: Text(
            title,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: Colors.black54, fontFamily: "Sans"),
          ),
        ),
      ),
    );
  }
}
