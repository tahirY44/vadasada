import 'dart:convert';
import 'dart:async';
import 'dart:math';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:localstorage/localstorage.dart';
import 'package:share_plus/share_plus.dart';
import 'package:vadasada/Api/api.dart';
import 'package:vadasada/ListItem/cartItem.dart';
import 'package:vadasada/UI/HomeUIComponent/productDetail.dart';
import 'package:vadasada/UI/dynamic_link_service.dart';
import 'package:vadasada/UI/products/EditProduct.dart';
import 'package:vadasada/UI/products/widgets/ProductItem.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/services.dart';

class MyListings extends StatefulWidget {
  String title;
  int id;
  MyListings({@required this.title, @required this.id});
  // final category;
  @override
  State<MyListings> createState() => _MyListingsState(title: title, id: id);
}

class _MyListingsState extends State<MyListings> with TickerProviderStateMixin {
  String title;
  int id;
  _MyListingsState({this.title, this.id});
  TabController tabController;
  bool _loaded = false;
  final LocalStorage storage = new LocalStorage('vadasada');
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  final Connectivity _connectivity = Connectivity();
  StreamSubscription<ConnectivityResult> _connectivitySubscription;
  bool noInternet = false;
  int initialData = 0;

  ///
  /// check the condition is right or wrong for image loaded or no
  ///
  bool loadImage = true,
      _loading = true,
      loadFeaturedItems = false,
      loadMainCategory = false,
      isLoading = false;
  List<ProductItem> categoryProducts = [];
  List<ProductItem> product = [];
  ScrollController _controller = new ScrollController();
  var rng = new Random();
  var products = [];
  int product_length = 0;
  String total_products = '0';
  String text = '';
  String subject = '';

  bool showBanner = false, showSubCategories = false;
  var categories = [];
  var banner = [];
  List<Widget> categoryTile = [];

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

  void initDynamicLinks() async {
    FirebaseDynamicLinks.instance.onLink.listen((dynamicLinkData) {
      final deeplink = dynamicLinkData.link;

      if (deeplink != null) {
        handleMyLink(deeplink);
      }
    }).onError((error) {
      print("We got error $error");
    });
  }

  void handleMyLink(Uri url) {
    var user = storage.getItem('user');
    List<String> sepeatedLink = [];

    /// osama.link.page/Hellow --> osama.link.page and Hellow
    sepeatedLink.addAll(url.path.split('/'));

    print("The Token that i'm interesed in is ${sepeatedLink[1]}");
    Get.to(
        () => MyListings(title: user['name'], id: int.parse(sepeatedLink[1])));
  }

  buildDynamicLinks(String title, String image, String docId) async {
    String url = "http://osam.page.link";
    final DynamicLinkParameters parameters = DynamicLinkParameters(
      uriPrefix: url,
      link: Uri.parse('$url/$docId'),
      androidParameters: AndroidParameters(
        packageName: "com.dotcoder.dynamic_link_example",
        minimumVersion: 0,
      ),
      iosParameters: IOSParameters(
        bundleId: "Bundle-ID",
        minimumVersion: '0',
      ),
      socialMetaTagParameters: SocialMetaTagParameters(
          description: '', imageUrl: Uri.parse("$image"), title: title),
    );
    final Uri dynamicUrl = await parameters.longDynamicLink;

    String desc = '${dynamicUrl.toString()}';

    await Share.share(
      desc,
      subject: title,
    );
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

  void getAllData() {
    getCategoryData();
    // getProducts();
  }

  onClickCategory(String s, int id) {
    Navigator.of(context).push(PageRouteBuilder(
        pageBuilder: (_, __, ___) => new MyListings(title: s, id: id),
        transitionDuration: Duration(milliseconds: 750),
        transitionsBuilder: (_, Animation<double> animation, __, Widget child) {
          return Opacity(
            opacity: animation.value,
            child: child,
          );
        }));
  }

  getCategoryData() async {
    var parameters = {
      'appkey': Api.appkey,
      'merchants': id.toString(),
      'offset': '0'
    };

    var response =
        await Api.getRequest(Api.merchants_product_listings, parameters);
    var data = jsonDecode(response.body);

    categories = data['categories'];

    // var subCategories = data['children'];

    // for (var i = 0; i < subCategories.length; i++) {
    //   var title = subCategories[i]['title'];
    //   var id = subCategories[i]['id'];
    //   categoryTile.add(SubCategoryTile(
    //     title: title,
    //     tap: () => {onClickCategory(title, id)},
    //   ));
    // }
    // setState(() {
    //   showSubCategories = true;
    // });

    setState(() {
      product_length = data['product_count'];
      total_products = data['total_products']['total'].toString();
    });
    products = data['products'];

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
      product.add(obj);
    }
    setState(() {
      loadFeaturedItems = true;
      _loading = false;
    });
  }

  _scrollListenerData() {
    if (_controller.position.pixels == _controller.position.maxScrollExtent) {
      // print("here inside");
      startLoader();
    }
  }

  void startLoader() {
    if (product_length < int.parse(total_products)) {
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
      'merchants': id.toString(),
      'offset': product_length.toString()
    };

    var response =
        await Api.getRequest(Api.merchants_product_listings, parameters);
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
        product.add(obj);
      }
      loadFeaturedItems = true;
      isLoading = !isLoading;
    });
  }

  getHomeData() async {
    var parameters = {
      'appkey': Api.appkey,
      'id': widget.id.toString(),
    };
    var response =
        await Api.getRequest(Api.get_products_by_category, parameters);
    var data = jsonDecode(response.body);
    setState(() {});
  }

  void _onShare(BuildContext context) async {
    // A builder is used to retrieve the context immediately
    // surrounding the ElevatedButton.
    //
    // The context's `findRenderObject` returns the first
    // RenderObject in its descendent tree when it's not
    // a RenderObjectWidget. The ElevatedButton's RenderObject
    // has its position and size after it's built.
    final box = context.findRenderObject() as RenderBox;

    await Share.share(text,
        subject: subject,
        sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size);
  }

  @override
  Widget build(BuildContext context) {
    MediaQueryData mediaQueryData = MediaQuery.of(context);
    double height = mediaQueryData.size.height;
    double width = mediaQueryData.size.width;
    int crossaxis;
    double itemHeight;
    double itemWidth;
    if (width > 800) {
      crossaxis = 4;
      itemWidth = width / 4;
    } else if (width > 550) {
      crossaxis = 3;
      itemWidth = width / 3;
    } else {
      crossaxis = 2;
      itemWidth = width / 2;
    }
    if (height > 1200) {
      itemHeight = height / 4.1;
    } else if (height > 950) {
      itemHeight = height / 3.6;
    } else if (height > 750) {
      itemHeight = height / 3.1;
    } else {
      itemHeight = height / 2.6;
    }
    tabController = new TabController(length: 2, vsync: this);

    var tabBarItem = new TabBar(
      tabs: [
        new Tab(
          icon: new Icon(
            Icons.grid_on,
            color: Colors.white,
          ),
        ),
        new Tab(
          icon: new Icon(
            Icons.list,
            color: Colors.white,
          ),
        ),
      ],
      controller: tabController,
      indicatorColor: Colors.white,
    );

    var listItem = new ListView.builder(
      itemCount: products.length,
      itemBuilder: (BuildContext context, int index) {
        return new ListTile(
          title: new Column(
            children: products.map((e) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.0),
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        // spreadRadius: 2,
                        blurRadius: 7,
                        offset: Offset(4, 4), // changes position of shadow
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(6.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          flex: 3,
                          child: Container(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10.0),
                              child: Image.network(
                                e["images"].toString(),
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 7,
                          child: InkWell(
                            onTap: () {
                              // Navigator.push(
                              //   context,
                              //   MaterialPageRoute(
                              //       builder: (context) => SingleProductView(
                              //             id: e["id"],
                              //             title: e["title"],
                              //             price: e["price"],
                              //           )),
                              // );
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(left: 15),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 10),
                                    child: Container(
                                      child: Text(
                                        e["title"].toString(),
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 10),
                                    child: Container(
                                      child: Row(
                                        children: [
                                          Text("Rs. "),
                                          Text(e["price"].toString()),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(right: 8.0),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: Api.primaryColor,
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.all(6.0),
                                            child: InkWell(
                                              onTap: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          EditProduct(
                                                            id: e["id"],
                                                          )),
                                                );
                                              },
                                              child: Row(
                                                children: [
                                                  Icon(
                                                    Icons.edit,
                                                    color: Colors.white,
                                                    size: 18,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        );
      },
    );

    var gridView = SingleChildScrollView(
      child: Column(
        children: [
          categories.length > 0
              ? GridView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 20.0,
                    // mainAxisSpacing: 5.0,
                    childAspectRatio: (itemWidth / itemHeight) * 0.88,
                  ),
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    return InkWell(
                      onTap: () => {
                        onClickCategory(
                            categories[index]['title'], categories[index]['id'])
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
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
                                    fontSize: 11, color: Colors.black),
                                textAlign: TextAlign.center,
                              ),
                              Text(
                                categories[index]['urdu_title'] ?? '',
                                style: TextStyle(
                                    fontSize: 11, color: Colors.black),
                                textAlign: TextAlign.center,
                              ),
                              Text(
                                '(' +
                                    (categories[index]['count_category']
                                            .toString() ??
                                        '0') +
                                    ')',
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
          new GridView.count(
              shrinkWrap: true,
              padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
              crossAxisSpacing: 10.0,
              mainAxisSpacing: 17.0,
              childAspectRatio: (itemWidth / itemHeight) * 0.85,
              crossAxisCount: crossaxis,
              primary: false,
              children: List.generate(
                products.length,
                (index) => ItemGrid(
                    gridItem: categoryProducts[index],
                    onExit: (value) {
                      // refreshAppBar();
                    }),
              ))
        ],
      ),
    );

    return new DefaultTabController(
      length: 2,
      child: new Scaffold(
        key: _scaffoldKey,
        appBar: new AppBar(
          centerTitle: true,
          title: Text(
            title + '(' + total_products.toString() + ')',
            style: TextStyle(color: Colors.white),
          ),
          actions: [
            IconButton(
                icon: Icon(
                  Icons.share_outlined,
                  color: Colors.white,
                ),
                onPressed: () async {
                  // buildDynamicLinks(title, null, id.toString());
                  // String generatedDeepLink =
                  await FirebaseDynamicLinkService.createDynamicLink(
                      false, widget);
                  // print(generatedDeepLink);
                })
          ],
          backgroundColor: Api.primaryColor,
          bottom: tabBarItem,
        ),
        body: LoadingOverlay(
          isLoading: _loading,
          progressIndicator: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Api.primaryColor),
          ),
          child: new TabBarView(
            controller: tabController,
            children: [
              gridView,
              listItem,
            ],
          ),
        ),
      ),
    );
  }
}

class ItemGrid extends StatefulWidget {
  /// Get data from HomeGridItem.....dart class
  ProductItem gridItem;
  ValueChanged onExit;
  ItemGrid({this.gridItem, this.onExit});

  @override
  _ItemGridState createState() => _ItemGridState();
}

class _ItemGridState extends State<ItemGrid> {
  LocalStorage storage = new LocalStorage('vadasada');

  final GlobalKey<ScaffoldState> _key = GlobalKey<ScaffoldState>();

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
      Navigator.of(context)
          .push(PageRouteBuilder(
              pageBuilder: (_, __, ___) => new productDetail(item),
              transitionDuration: Duration(milliseconds: 900),

              /// Set animation Opacity in route to detailProduk layout
              transitionsBuilder:
                  (_, Animation<double> animation, __, Widget child) {
                return Opacity(
                  opacity: animation.value,
                  child: child,
                );
              }))
          .then((value) => widget.onExit(value));
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
        // Navigator.of(context)
        //     .push(PageRouteBuilder(
        //         pageBuilder: (_, __, ___) => new productDetail(widget.gridItem),
        //         transitionDuration: Duration(milliseconds: 900),

        //         /// Set animation Opacity in route to detailProduk layout
        //         transitionsBuilder:
        //             (_, Animation<double> animation, __, Widget child) {
        //           return Opacity(
        //             opacity: animation.value,
        //             child: child,
        //           );
        //         }))
        //     .then((value) => widget.onExit(value));
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
                                image:
                                    NetworkImage(widget.gridItem.images.trim()),
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
                              child: Container(
                                width: width * 0.42,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      "Rs " +
                                          widget.gridItem.discounted.toString(),
                                      style: TextStyle(
                                          color: Api.primaryColor,
                                          fontWeight: FontWeight.w800,
                                          fontFamily: "Sans",
                                          fontSize: 13),
                                    ),
                                    Text(
                                      "Rs " + widget.gridItem.price.toString(),
                                      style: TextStyle(
                                          decoration:
                                              TextDecoration.lineThrough,
                                          color: Colors.black54,
                                          fontWeight: FontWeight.w600,
                                          fontFamily: "Sans",
                                          fontSize: 11.5),
                                    ),
                                  ],
                                ),
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
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      "Rs " + widget.gridItem.price.toString(),
                                      style: TextStyle(
                                          color: Api.primaryColor,
                                          fontWeight: FontWeight.w800,
                                          fontFamily: "Sans",
                                          fontSize: 13),
                                    ),
                                  ],
                                ),
                              ),
                            ),
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
          color: Color(0xFF5A6268),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4.5,
              spreadRadius: 1.0,
            )
          ],
        ),
        child: Center(
          child: InkWell(
            onTap: tap,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontFamily: "Sans"),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
