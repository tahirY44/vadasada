import 'dart:async';
import 'dart:convert';

import 'package:connectivity/connectivity.dart';
import 'package:flutter/services.dart';
import 'package:vadasada/ListItem/cartItem.dart';
import 'package:localstorage/localstorage.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter/material.dart';
import 'package:vadasada/ListItem/ProductItem.dart';
import 'package:vadasada/UI/HomeUIComponent/productDetail.dart';
import 'package:vadasada/Api/api.dart';
import 'package:vadasada/UI/HomeUIComponent/Search.dart';
import 'dart:math';

class categoryDetail extends StatefulWidget {
  String title;
  int id;
  categoryDetail({this.title, this.id});
  @override
  _categoryDetailState createState() =>
      _categoryDetailState(title: title, id: id);
}

/// if user click icon in category layout navigate to categoryDetail Layout
class _categoryDetailState extends State<categoryDetail> {
  String title;
  int id;
  _categoryDetailState({this.title, this.id});

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  final Connectivity _connectivity = Connectivity();
  StreamSubscription<ConnectivityResult> _connectivitySubscription;
  bool noInternet = false;
  int initialData = 0;

  ///
  /// check the condition is right or wrong for image loaded or no
  ///
  bool loadImage = true, loadFeaturedItems = false, isLoading = false;
  List<ProductItem> categoryProducts = [];
  ScrollController _controller = new ScrollController();
  var rng = new Random();

  int product_length = 0;
  int total_products = 0;
  var categories = [];

  bool showBanner = false, showSubCategories = false;
  var banner = [];
  List<Widget> categoryTile = [];
  List<Widget> categoryBox = [];

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
    getCategoryData();
    // getProducts();
  }

  getCategoryData() async {
    var parameters = {
      'appkey': Api.appkey,
      'category': id.toString(),
      'offset': '0'
    };

    var response =
        await Api.getRequest(Api.category_product_content, parameters);
    var data = jsonDecode(response.body);

    var subCategories = categories = data['children'];

    for (var i = 0; i < subCategories.length; i++) {
      var urdu_title = subCategories[i]['urdu_title'];
      var title = subCategories[i]['title'];
      var id = subCategories[i]['id'];
      categoryTile.add(SubCategoryTile(
        title: title,
        tap: () => {onClickCategory(title, id)},
      ));
      categoryBox.add(CategoryBox(
        urdu_title: urdu_title,
        title: title,
        tap: () => {onClickCategory(title, id)},
      ));
    }
    setState(() {
      showSubCategories = true;
    });

    setState(() {
      product_length = data['product_count'];
      total_products = data['total_products']['total'];
    });
    var products = data['products'];

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
      categoryProducts.add(obj);
    }
    setState(() {
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
    if (product_length < total_products) {
      fetchData();
    }
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
      'category': id.toString(),
      'offset': product_length.toString()
    };

    var response =
        await Api.getRequest(Api.category_product_content, parameters);
    var data = jsonDecode(response.body);
    var products = data['products'];

    setState(() {
      product_length += data['product_count'];
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
            images: image,
            heroId: number,
            price: price,
            discounted: discount);
        categoryProducts.add(obj);
      }
      isLoading = !isLoading;
    });
  }

  onClickCategory(String s, int id) {
    Navigator.of(context).push(PageRouteBuilder(
        pageBuilder: (_, __, ___) => new categoryDetail(title: s, id: id),
        transitionDuration: Duration(milliseconds: 750),
        transitionsBuilder: (_, Animation<double> animation, __, Widget child) {
          return Opacity(
            opacity: animation.value,
            child: child,
          );
        }));
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
    // var _imageSlider = Padding(
    //   padding: const EdgeInsets.only(
    //       top: 0.0, left: 10.0, right: 10.0, bottom: 35.0),
    //   child: Container(
    //     height: 100.0,
    //     child: showBanner
    //         ? new Carousel(
    //             boxFit: BoxFit.fill,
    //             dotColor: Colors.transparent,
    //             dotSize: 5.5,
    //             dotSpacing: 16.0,
    //             dotBgColor: Colors.transparent,
    //             showIndicator: false,
    //             overlayShadow: false,
    //             overlayShadowColors: Colors.white.withOpacity(0.9),
    //             overlayShadowSize: 0.9,
    //             images: banner,
    //           )
    //         : Container(
    //             /// Set Background image in splash screen layout (Click to open code)
    //             decoration: BoxDecoration(
    //                 color: Colors.white,
    //                 image: DecorationImage(
    //                     image: AssetImage('assets/img/imageLoading.gif'))),
    //           ),
    //   ),
    // );

    /// Variable Category (Sub Category)
    var _subCategory = Container(
      child: Column(
        children: <Widget>[
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.only(
                  top: 10, bottom: 5.0, right: 10, left: 10),
              child: Container(
                color: Colors.white,
                height: 60.0,
                child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: showSubCategories ? categoryBox : []),
              ),
            ),
          )
        ],
      ),
    );

    //  var _subCategory = Container(
    //   child: Column(
    //     children: <Widget>[
    //       SingleChildScrollView(
    //         child: Padding(
    //           padding: const EdgeInsets.only(
    //               top: 10, bottom: 5.0, right: 10, left: 10),
    //           child: Container(
    //             color: Colors.white,
    //             height: 60.0,
    //             child: ListView(
    //                 scrollDirection: Axis.horizontal,
    // children: showSubCategories ? categoryTile : []),
    //           ),
    //         ),
    //       )
    //     ],
    //   ),
    // );

    /// Variable New Items with Card

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
              color: Colors.white,
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
            // _imageSlider,
            // categoryTile.length > 0 ? _subCategory : Container(),
            categories.length > 0
                ? GridView.builder(
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      // crossAxisSpacing: 20.0,
                      // mainAxisSpacing: 5.0,
                      childAspectRatio: (itemWidth / itemHeight) * 1.1,
                    ),
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      return InkWell(
                        onTap: () => {
                          onClickCategory(categories[index]['title'],
                              categories[index]['id'])
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            // decoration: BoxDecoration(
                            // border: Border.all(
                            //   width: 1,
                            //   color: Api.primaryColor,
                            // ),
                            // ),
                            child: Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 5.0),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        width: 1,
                                        color: Api.primaryColor,
                                      ),
                                    ),
                                    child: Image.network(
                                      categories[index]['icon'],
                                      height: 100,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),
                                Text(
                                  categories[index]['title'],
                                  style: TextStyle(
                                      fontSize: 12, color: Colors.black),
                                  textAlign: TextAlign.center,
                                ),
                                Text(
                                  categories[index]['urdu_title'] ?? '',
                                  style: TextStyle(
                                      fontSize: 11, color: Colors.black),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  )
                : Container(),
            Padding(
              padding: EdgeInsets.only(bottom: 0.0),
              child: loadFeaturedItems
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
                              childAspectRatio: (itemWidth / itemHeight) * 0.85,
                              crossAxisCount: 2,
                            ),
                            // primary: true,
                            itemCount: categoryProducts.length,
                            itemBuilder: (BuildContext context, int index) {
                              return GestureDetector(
                                  child: ItemGrid(categoryProducts[index]));
                            },
                          ),
                        ],
                      ),
                    )
                  : SingleChildScrollView(
                      child: Container(
                          margin: EdgeInsets.only(right: 10.0, bottom: 15.0),
                          height: 300.0,
                          child: _loadingImageAnimation(context)),
                    ),
            ),
          ]),
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
                        height: itemHeight * 0.70,
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
                SizedBox(
                  height: itemHeight * 0.2,
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
                          fontSize: 13),
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
                                  "Rs " + widget.gridItem.discounted.toString(),
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
                                    decoration: TextDecoration.lineThrough,
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
                                width: width * 0.42,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "Rs " + widget.gridItem.price.toString(),
                                      style: TextStyle(
                                          color: Api.primaryColor,
                                          fontWeight: FontWeight.w800,
                                          fontFamily: "Sans",
                                          fontSize: 16),
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.shopping_cart_outlined),
                                      onPressed: () {
                                        _addItem(widget.gridItem);
                                      },
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ],
                  ),
                ),
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

Widget _loadingImageAnimation(BuildContext context) {
  return ListView.builder(
    scrollDirection: Axis.horizontal,
    itemBuilder: (BuildContext context, int index) => loadingMenuItemCard(),
    itemCount: 6,
  );
}

class SubCategoryTile extends StatelessWidget {
  SubCategoryTile({this.title, this.tap});

  final String title;
  GestureTapCallback tap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Api.primaryColor),
          ),
          color: Colors.white,
          // color: Color(0xFF5A6268),
          // boxShadow: [
          //   BoxShadow(
          //     color: Colors.black.withOpacity(0.1),
          //     blurRadius: 4.5,
          //     spreadRadius: 1.0,
          //   )
          // ],
        ),
        child: Center(
          child: InkWell(
            onTap: tap,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black, fontFamily: "Sans"),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class CategoryBox extends StatelessWidget {
  CategoryBox({this.urdu_title, this.title, this.tap});

  final String title, urdu_title;
  GestureTapCallback tap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Api.primaryColor),
          ),
          color: Colors.white,
          // color: Color(0xFF5A6268),
          // boxShadow: [
          //   BoxShadow(
          //     color: Colors.black.withOpacity(0.1),
          //     blurRadius: 4.5,
          //     spreadRadius: 1.0,
          //   )
          // ],
        ),
        child: Center(
          child: InkWell(
            onTap: tap,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black, fontFamily: "Sans"),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
