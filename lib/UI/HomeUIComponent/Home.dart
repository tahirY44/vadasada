import 'dart:async';
import 'dart:convert';

import 'package:vadasada/Library/carousel_pro/carousel_pro.dart';
import 'package:vadasada/ListItem/CategoryItem.dart';
import 'package:vadasada/ListItem/cartItem.dart';
import 'package:vadasada/UI/AcountUIComponent/AboutApps.dart';
import 'package:vadasada/UI/AcountUIComponent/ExchangePolicy.dart';
import 'package:vadasada/UI/AcountUIComponent/faqs.dart';
import 'package:vadasada/UI/AcountUIComponent/privacyPolicy.dart';
import 'package:vadasada/UI/AcountUIComponent/shippingDelivery.dart';
import 'package:vadasada/UI/CartUIComponent/CartLayout.dart';
import 'package:vadasada/UI/HomeUIComponent/ContactUs.dart';
import 'package:vadasada/UI/HomeUIComponent/Search.dart';
import 'package:flutter/material.dart';
import 'package:vadasada/UI/HomeUIComponent/AppbarGradient.dart';
import 'package:flutter/services.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:localstorage/localstorage.dart';
import 'package:vadasada/UI/HomeUIComponent/CategoryDetail.dart';
import 'package:vadasada/UI/HomeUIComponent/BrandDetail.dart';
import 'package:vadasada/ListItem/ProductItem.dart';
import 'package:vadasada/UI/HomeUIComponent/productDetail.dart';
import 'package:vadasada/Api/api.dart';
import 'package:vadasada/UI/HomeUIComponent/SideBar.dart';
import 'package:connectivity/connectivity.dart';
import 'package:marquee/marquee.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sliver_tools/sliver_tools.dart';

import 'dart:math';

import 'package:package_info_plus/package_info_plus.dart';

class Menu extends StatefulWidget {
  @override
  _MenuState createState() => _MenuState();
}

/// Component all widget in home
class _MenuState extends State<Menu> with TickerProviderStateMixin {
  /// Declare class GridItem from HomeGridItemReoomended.dart in folder ListItem

  final LocalStorage storage = new LocalStorage('vadasada');

  var rng = new Random();
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<ConnectivityResult> _connectivitySubscription;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  var cartItem;
  int cartTotal;

  bool isStarted = false;
  var data;
  var bannerImages;
  bool bannerShow = false;
  var categoryData;
  var sliderData;
  var welcome_text;
  bool loadWelcomeText = false;

  var categories = [];
  List<Widget> sideBarMenu = [];
  List<Widget> banner = [];
  List<Widget> category = [];
  // List<Widget> categoryTiles = [];
  List<Widget> categoryProductData = [];
  List<Widget> special = [];
  List<Widget> brand = [];
  List<CategoryItem> categoryTiles = [];
  List<ProductItem> featured = [];
  List<ProductItem> popular = [];
  List<ProductItem> childrenKid = [];
  List<ProductItem> categoryProducts = [];
  ScrollController _controller;
  int initialData = 0;
  int product_length = 0;
  int total_products = 0;
  int category_id = 0;

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

  var slider = [];

  List<Color> colorlist = [
    Colors.brown,
    Colors.purple,
    Colors.yellow,
    Colors.orange,
    Colors.cyan,
    Colors.green,
    Colors.amber,
    Colors.red
  ];

  Color activeColor;

  bool _loading = false,
      noInternet = false,
      showMenuItems = false,
      showSlider = false,
      showBanners = false,
      loadSideBar = false,
      loadBrand = false,
      loadCategoryData = false,
      loadMainCategory = false,
      loadSpecialItems = false,
      loadFeaturedItems = false,
      loadPopularItems = false,
      loadCategoryProducts = false;

  _scrollListenerData() {
    if (_controller.offset >= _controller.position.maxScrollExtent &&
        !_controller.position.outOfRange) {
      startLoader();
    }
  }

  void startLoader() {
    if (product_length < total_products) {
      loadModeData();
    }
  }

  loadModeData() async {
    setState(() {
      loadCategoryProducts = false;
      // _controller.animateTo(_controller.position.maxScrollExtent,
      //     duration: Duration(milliseconds: 50), curve: Curves.ease);
    });
    var parameters = {
      'appkey': Api.appkey,
      'category': category_id.toString(),
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
      loadCategoryProducts = true;
    });
  }

  fetchData(index) async {
    setState(() {
      for (var i = 0; i < categoryTiles.length; i++) {
        categoryTiles[i].isActive = false;
      }
      categoryTiles[index].isActive = true;
      loadCategoryProducts = false;
    });
    var parameters = {
      'appkey': Api.appkey,
      'category': category_id.toString(),
      'offset': product_length.toString()
    };

    var response =
        await Api.getRequest(Api.category_product_content, parameters);
    var data = jsonDecode(response.body);
    var products = data['products'];
    total_products = data['total_products']['total'];

    setState(() {
      categoryProducts = [];
      product_length = data['product_count'];
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
      _controller.animateTo(_controller.position.minScrollExtent,
          duration: Duration(milliseconds: 1000), curve: Curves.ease);
      loadCategoryProducts = true;
    });
  }

  /// Set for StartStopPress CountDown
  ///
  getStoreInfo() async {
    var response = await Api.getRequest(Api.store_info, null);
    var data = jsonDecode(response.body);
    setState(() {
      welcome_text = data['welcome_text'];
      loadWelcomeText = true;
    });
    storage.setItem("store_info", data);
  }

  List<Widget> sideChildren(data, double index) {
    var title = data['title'];
    double count = 10 * index;
    var id = data['id'];
    List<Widget> children = [];

    children.add(Padding(
      padding: EdgeInsets.only(left: count),
      child: ListTile(
        visualDensity: VisualDensity(horizontal: -4, vertical: -4),
        title: Text("View All"),
        onTap: () {
          Navigator.pop(context);
          onClickCategory(title, id);
        },
      ),
    ));

    var sub_data = data["children"];
    for (var i = 0; i < sub_data.length; i++) {
      if (sub_data[i]["children"].length > 0) {
        var title = sub_data[i]['title'];

        List<Widget> children2 = sideChildren(sub_data[i], index + 1);

        children.add(Padding(
          padding: EdgeInsets.only(left: count),
          child: ExpansionTile(title: Text(title), children: children2),
        ));
      } else {
        var title = sub_data[i]['title'];
        var id = sub_data[i]['id'];
        children.add(Padding(
          padding: EdgeInsets.only(left: count),
          child: ListTile(
            title: Text(title),
            onTap: () {
              Navigator.pop(context);
              onClickCategory(title, id);
            },
          ),
        ));
      }
    }
    return children;
  }

  getData() async {
    // PackageInfo packageInfo = await PackageInfoPlus.fromPlatform();

    var response = await Api.getRequest(Api.menu_category, null);
    var data = jsonDecode(response.body);
    // data = data["data"];

    // print("${data}");

    sideBarMenu.add(SizedBox(
      height: 165,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 40, 20, 0),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Container(
                  height: 110,
                  width: MediaQuery.of(context).size.width * 0.4,
                  child: Image.asset("assets/img/company_logo.png",
                      fit: BoxFit.fill)),
              Padding(
                padding: const EdgeInsets.only(left: 150),
                child: Text(
                  "",
                  style: TextStyle(fontSize: 10),
                  textAlign: TextAlign.right,
                ),
              )
            ]),
      ),
    ));
    sideBarMenu.add(ListTile(
      leading: Icon(
        Icons.info,
        size: 20,
      ),
      title: Text("Return / Exchange"),
      onTap: () {
        Navigator.pop(context);
        Navigator.of(context).push(PageRouteBuilder(
            pageBuilder: (_, __, ___) => new exchangePolicy()));
      },
    ));
    sideBarMenu.add(ListTile(
      leading: Icon(
        Icons.local_shipping,
        size: 20,
      ),
      title: Text("Shipping & Delivery"),
      onTap: () {
        Navigator.pop(context);
        Navigator.of(context).push(PageRouteBuilder(
            pageBuilder: (_, __, ___) => new shippingDelivery()));
      },
    ));
    sideBarMenu.add(ListTile(
      leading: Icon(
        Icons.help,
        size: 20,
      ),
      title: Text("FAQs"),
      onTap: () {
        Navigator.pop(context);
        Navigator.of(context)
            .push(PageRouteBuilder(pageBuilder: (_, __, ___) => new faqs()));
      },
    ));
    sideBarMenu.add(ListTile(
      leading: Icon(
        Icons.policy,
        size: 20,
      ),
      title: Text("Privacy Policy"),
      onTap: () {
        Navigator.pop(context);
        Navigator.of(context).push(
            PageRouteBuilder(pageBuilder: (_, __, ___) => new privacyPolicy()));
      },
    ));
    sideBarMenu.add(ListTile(
      leading: Icon(
        Icons.contact_support,
        size: 20,
      ),
      title: Text("Contact Us"),
      onTap: () {
        Navigator.pop(context);
        Navigator.of(context).push(
            PageRouteBuilder(pageBuilder: (_, __, ___) => new contactUs()));
      },
    ));

    for (var i = 0; i < data.length; i++) {
      if (data[i]["children"].length > 0) {
        var title = data[i]['title'];
        var img_url = data[i]['icon'];

        List<Widget> children = sideChildren(data[i], 1);

        sideBarMenu.add(ExpansionTile(
            leading: Image.network(
              img_url,
              height: 19.2,
            ),
            title: Text(title),
            children: children));
      } else {
        var title = data[i]['title'];
        var id = data[i]['id'];
        var img_url = data[i]['icon'];
        sideBarMenu.add(
          ListTile(
            leading: Image.network(
              img_url,
              height: 19.2,
            ),
            title: Text(title),
            onTap: () {
              Navigator.pop(context);
              onClickCategory(title, id);
            },
          ),
        );
      }
    }

    setState(() {
      loadSideBar = true;
    });
  }

  setBannerView() {
    double width = MediaQuery.of(context).size.width;
    List<Widget> row_child = [];
    setState(() {
      if (bannerImages.length % 2 == 0) {
        for (var i = 0; i < bannerImages.length; i++) {
          row_child.add(Container(
            width: width * .5,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5),
              child: InkWell(
                onTap: () {
                  if (bannerImages[i]["type"] == 1) {
                    String s = bannerImages[i]["title"];
                    int id = bannerImages[i]["selected_id"];
                    onClickCategory(s, id);
                  }
                  if (bannerImages[i]["type"] == 2) {
                    var id = bannerImages[i]['selected_id'];
                    var title = bannerImages[i]['title'];

                    var image = Api.baseImageURL + "noimage.jpg";
                    var price = 0;
                    var discount = 0;
                    var number = id.toString() + rng.nextInt(9999).toString();
                    ProductItem obj = new ProductItem(
                        id: id,
                        title: title,
                        images: image,
                        heroId: number,
                        price: price,
                        discounted: discount);
                    onClickProduct(obj);
                  }
                  if (bannerImages[i]["type"] == 3) {
                    String s = bannerImages[i]["title"];
                    int id = bannerImages[i]["selected_id"];
                    onClickBrand(s, id);
                  }
                },
                child: ClipRRect(
                  child: Image.network(bannerImages[i]['images']),
                ),
              ),
            ),
          ));
          if (i % 2 != 0) {
            banner.add(Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Row(children: row_child)));
            row_child = [];
          }
        }
      } else {
        banner.add(Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5.0),
          child: Container(
            child: InkWell(
              onTap: () {
                if (bannerImages[0]["type"] == 1) {
                  String s = bannerImages[0]["title"];
                  int id = bannerImages[0]["selected_id"];
                  onClickCategory(s, id);
                }
                if (bannerImages[0]["type"] == 2) {
                  var id = bannerImages[0]['selected_id'];
                  var title = bannerImages[0]['title'];

                  var image = Api.baseImageURL + "noimage.jpg";
                  var price = 0;
                  var discount = 0;
                  var number = id.toString() + rng.nextInt(9999).toString();
                  ProductItem obj = new ProductItem(
                      id: id,
                      title: title,
                      images: image,
                      heroId: number,
                      price: price,
                      discounted: discount);
                  onClickProduct(obj);
                }
                if (bannerImages[0]["type"] == 3) {
                  String s = bannerImages[0]["title"];
                  int id = bannerImages[0]["selected_id"];
                  onClickBrand(s, id);
                }
              },
              child: ClipRRect(
                child: Image.network(bannerImages[0]['images']),
              ),
            ),
          ),
        ));
        for (var i = 1; i < bannerImages.length; i++) {
          row_child.add(Container(
            width: width * .5,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5),
              child: InkWell(
                onTap: () {
                  if (bannerImages[i]["type"] == 1) {
                    String s = bannerImages[i]["title"];
                    int id = bannerImages[i]["selected_id"];
                    onClickCategory(s, id);
                  }
                  if (bannerImages[i]["type"] == 2) {
                    var id = bannerImages[i]['selected_id'];
                    var title = bannerImages[i]['title'];

                    var image = Api.baseImageURL + "noimage.jpg";
                    var price = 0;
                    var discount = 0;
                    var number = id.toString() + rng.nextInt(9999).toString();
                    ProductItem obj = new ProductItem(
                        id: id,
                        title: title,
                        images: image,
                        heroId: number,
                        price: price,
                        discounted: discount);
                    onClickProduct(obj);
                  }
                  if (bannerImages[i]["type"] == 3) {
                    String s = bannerImages[i]["title"];
                    int id = bannerImages[i]["selected_id"];
                    onClickBrand(s, id);
                  }
                },
                child: ClipRRect(
                  child: Image.network(bannerImages[i]['images']),
                ),
              ),
            ),
          ));
          if (i % 2 == 0) {
            banner.add(Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Row(children: row_child)));
            row_child = [];
          }
        }
      }
      showBanners = true;
    });
  }

  getHomeData() async {
    var response = await Api.getRequest(Api.home_content, null);

    var data = jsonDecode(response.body);

    setState(() {
      bannerImages = data['banners'];
      // showBanners = true;
    });

    setBannerView();

    categories = data['categories'];
    // setState(() {
    //   categoryData = data['category_data'];
    // });
    var category_banner = data['category_side_banners'];
    // var count_banner = data['category_side_banners'].length;
    var count = 0;
    var featureData = data['top_selling'];
    var popularData = data['trending'];
    setState(() {
      sliderData = data['slider'];
    });

    var brandData = data['brands'];
    for (var i = 0; i < sliderData.length; i++) {
      var image = sliderData[i]['images'];
      slider.add(NetworkImage(image));
    }
    setState(() {
      showSlider = true;
    });

    List<Widget> sub = [];
    category.add(Padding(padding: EdgeInsets.only(left: 10.0)));

    for (var i = 0; i < categories.length; i++) {
      var image = categories[i]['icon'];
      var title = categories[i]['title'];
      var id = categories[i]['id'];
      CategoryItem obj = new CategoryItem(
          id: id, title: title, isActive: i == 0 ? true : false);
      categoryTiles.add(obj);
      // categoryTiles.add(SubCategoryTile(
      //     title: title,
      //     tap: () {
      //       // print('object');
      //       setState(() {
      //         category_id = categories[i]['id'];
      //         product_length = 0;
      //         total_products = 0;
      //         loadCategoryProducts = false;
      //         fetchData();
      //         // activeColor = colorlist[i];
      //       });
      //     }));
      // categoryTiles.add(Padding(padding: EdgeInsets.only(left: 2.0)));
      category.add(CategoryTile(
          image: image, title: title, tap: () => {onClickCategory(title, id)}));
      category.add(Padding(padding: EdgeInsets.only(left: 10.0)));
    }
    setState(() {
      loadMainCategory = true;
    });

    var products = data['products_by_category']['products'];

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
    setState(() {
      // category_id = data['products_by_category']['products'][0]['category_id'];
      // product_length = data['products_by_category']['product_count'];
      // total_products = data['products_by_category']['total_products']['total'];
      // loadCategoryProducts = true;
    });

    for (var i = 0; i < popularData.length; i++) {
      var id = popularData[i]['id'];
      var title = popularData[i]['title'];
      var image = popularData[i]['images'];
      var price = popularData[i]['price'];
      var discounted = popularData[i]['discounted'];
      var is_variation = popularData[i]['is_variation'];
      var number = id.toString() + rng.nextInt(9999).toString();
      ProductItem obj = new ProductItem(
          id: id,
          title: title,
          images: image,
          heroId: number,
          price: price,
          discounted: discounted,
          is_variation: is_variation);
      popular.add(obj);
    }
    setState(() {
      loadPopularItems = true;
    });

    for (var i = 0; i < featureData.length; i++) {
      var id = featureData[i]['id'];
      var title = featureData[i]['title'];
      var image = featureData[i]['images'];
      var price = featureData[i]['price'];
      var discount = featureData[i]['discounted'];
      var is_variation = featureData[i]['is_variation'];
      var number = id.toString() + rng.nextInt(9999).toString();
      ProductItem obj = new ProductItem(
          id: id,
          title: title,
          images: image,
          heroId: number,
          price: price,
          discounted: discount,
          is_variation: is_variation);
      featured.add(obj);
    }
    setState(() {
      loadFeaturedItems = true;
    });

    // for (var i = 0; i < categoryData.length; i++) {
    //   if (count < count_banner) {
    //     if (category_banner[count]['sort'] == i) {
    //       List<Widget> cat_banner =
    //           setCatBannerView(category_banner[count]['children']);
    //       categoryProductData.add(Padding(
    //         padding: EdgeInsets.symmetric(vertical: 10),
    //         child: Container(
    //           child: Column(
    //             children: cat_banner,
    //           ),
    //         ),
    //       ));
    //       count = count + 1;
    //     }
    //   }

    //   List<ProductItem> categoryProduct = [];
    //   String title = categoryData[i]['title'];
    //   int id = categoryData[i]['id'];
    //   String thumbnail = categoryData[i]["thumbnail"];
    //   var products = categoryData[i]['products'];
    //   for (var j = 0; j < products.length; j++) {
    //     var id = products[j]['id'];
    //     var title = products[j]['title'];
    //     var image = products[j]['images'];
    //     var price = products[j]['price'];
    //     var discounted = products[j]['discounted'];
    //     var number = id.toString() + rng.nextInt(9999).toString();
    //     ProductItem obj = new ProductItem(
    //         id: id,
    //         title: title,
    //         images: image,
    //         heroId: number,
    //         price: price,
    //         discounted: discounted);
    //     categoryProduct.add(obj);
    //   }
    //   categoryProductData.add(
    //       _categoryDataTile(context, title, id, thumbnail, categoryProduct));
    // }

    // setState(() {
    //   loadCategoryData = true;
    // });

    brand.add(Padding(padding: EdgeInsets.only(left: 10.0)));
    for (var i = 0; i < brandData.length; i++) {
      var image = brandData[i]['images'];
      var title = brandData[i]['title'];
      var id = brandData[i]['id'];
      brand.add(BrandTile(image: image, tap: () => {onClickBrand(title, id)}));
      brand.add(Padding(padding: EdgeInsets.only(left: 10.0)));
    }
    setState(() {
      loadBrand = true;
      _loading = false;
    });
  }

  List<Widget> setCatBannerView(data) {
    double width = MediaQuery.of(context).size.width;
    List<Widget> row_child = [];
    List<Widget> col_child = [];
    if (data.length % 2 == 0) {
      for (var i = 0; i < data.length; i++) {
        row_child.add(Container(
          width: width * .5,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            child: InkWell(
              onTap: () {
                if (data[i]["type"] == 1) {
                  String s = data[i]["title"];
                  int id = data[i]["selected_id"];
                  onClickCategory(s, id);
                }
                if (data[i]["type"] == 2) {
                  var id = data[i]['selected_id'];
                  var title = data[i]['title'];
                  var image = Api.baseImageURL + "noimage.jpg";
                  var price = 0;
                  var discount = 0;
                  var number = id.toString() + rng.nextInt(9999).toString();
                  ProductItem obj = new ProductItem(
                      id: id,
                      title: title,
                      images: image,
                      heroId: number,
                      price: price,
                      discounted: discount);
                  onClickProduct(obj);
                }
                if (data[i]["type"] == 1) {
                  String s = data[i]["title"];
                  int id = data[i]["selected_id"];
                  onClickCategory(s, id);
                }
              },
              child: ClipRRect(
                child: Image.network(data[i]['images']),
              ),
            ),
          ),
        ));
        if (i % 2 != 0) {
          col_child.add(Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Row(children: row_child)));
          row_child = [];
        }
      }
    } else {
      col_child.add(Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5.0),
        child: Container(
          child: InkWell(
            onTap: () {
              if (data[0]["type"] == 1) {
                String s = data[0]["title"];
                int id = data[0]["selected_id"];
                onClickCategory(s, id);
              }
              if (data[0]["type"] == 2) {
                var id = data[0]['selected_id'];
                var title = data[0]['title'];
                var image = Api.baseImageURL + "noimage.jpg";
                var price = 0;
                var discount = 0;
                var number = id.toString() + rng.nextInt(9999).toString();
                ProductItem obj = new ProductItem(
                    id: id,
                    title: title,
                    images: image,
                    heroId: number,
                    price: price,
                    discounted: discount);
                onClickProduct(obj);
              }
            },
            child: ClipRRect(
              child: Image.network(data[0]['images']),
            ),
          ),
        ),
      ));
      for (var i = 1; i < data.length; i++) {
        row_child.add(Container(
          width: width * .5,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            child: InkWell(
              onTap: () {
                if (data[i]["type"] == 1) {
                  String s = data[i]["title"];
                  int id = data[i]["selected_id"];
                  onClickCategory(s, id);
                }
                if (data[i]["type"] == 2) {
                  var id = data[i]['selected_id'];
                  var title = data[i]['title'];
                  var image = Api.baseImageURL + "noimage.jpg";
                  var price = 0;
                  var discount = 0;
                  var number = id.toString() + rng.nextInt(9999).toString();
                  ProductItem obj = new ProductItem(
                      id: id,
                      title: title,
                      images: image,
                      heroId: number,
                      price: price,
                      discounted: discount);
                  onClickProduct(obj);
                }
              },
              child: ClipRRect(
                child: Image.network(data[i]['images']),
              ),
            ),
          ),
        ));
        if (i % 2 == 0) {
          col_child.add(Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Row(children: row_child)));
          row_child = [];
        }
      }
    }
    return col_child;
  }

  /// To set duration initState auto start if FlashSale Layout open
  @override
  void initState() {
    // TODO: implement initState
    _controller = ScrollController();
    _controller.addListener(_scrollListenerData);
    super.initState();
    setState(() {
      activeColor = colorlist[0];
    });
    // initConnectivity();
    // _connectivitySubscription =
    //     _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
    getAllData();
  }

  @override
  dispose() {
    super.dispose();
    // _connectivitySubscription.cancel();
  }

  void getAllData() {
    setState(() {
      _loading = true;
    });
    refreshAppBar();
    getStoreInfo();
    getHomeData();
    getData();
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

  void refreshAppBar() {
    setState(() {
      // storage.deleteItem("cart");
      int total = 0;
      cartItem = storage.getItem("cart") ?? [];
      if (cartItem.length > 0) {
        for (var i = 0; i < cartItem.length; i++) {
          total += cartItem[i]['qty'];
        }
      }
      cartTotal = total;
    });
  }

  @override
  Widget build(BuildContext context) {
    MediaQueryData mediaQueryData = MediaQuery.of(context);
    double width = mediaQueryData.size.width;
    double height = mediaQueryData.size.height;
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    int crossaxis;
    double itemWidth;
    double itemHeight;
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
      itemHeight = height / 4;
    } else if (height > 950) {
      itemHeight = height / 3.5;
    } else if (height > 750) {
      itemHeight = height / 3;
    } else {
      itemHeight = height / 2.5;
    }
//    double itemHeight = mediaQueryData.size.height / 3;
//    double itemWidth = mediaQueryData.size.width / 2;

    /// Navigation to categoryDetail.dart if user Click icon in Category

    /// Declare device Size
    var deviceSize = MediaQuery.of(context).size;

    /// ListView a WeekPromotion Component
    var PromoHorizontalList = Container(
      color: Colors.white,
      height: 200.0,
      padding: EdgeInsets.only(bottom: 40.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
              padding: EdgeInsets.only(left: 20.0, top: 15.0, bottom: 3.0),
              child: Text(
                "Amazing Brands",
                style: TextStyle(
                    fontSize: 15.0,
                    fontFamily: "Sans",
                    fontWeight: FontWeight.w700),
              )),
          Expanded(
            child: ListView(
                shrinkWrap: true,
                padding: EdgeInsets.only(top: 10),
                scrollDirection: Axis.horizontal,
                children: brand),
          ),
        ],
      ),
    );

    /// FlashSale component
    var FlashSell = Container(
      height: 300.0,
      decoration: BoxDecoration(
        /// To set Gradient in flashSale background
        gradient: LinearGradient(
            colors: [Api.primaryColor, Colors.red[900], Colors.red[400]]),
      ),

      /// To set FlashSale Scrolling horizontal
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: loadSpecialItems
            ? special
            : <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(
                          left: mediaQueryData.padding.left + 20),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Image.asset(
                          "assets/img/flashsaleicon.png",
                          height: deviceSize.height * 0.087,
                        ),
                        Text(
                          "ON-Fire",
                          style: TextStyle(
                            fontFamily: "Popins",
                            fontSize: 30.0,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          "Products",
                          style: TextStyle(
                            fontFamily: "Sans",
                            fontSize: 28.0,
                            fontWeight: FontWeight.w400,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    )
                  ],
                ),
                Padding(padding: EdgeInsets.only(left: 40.0)),
              ],
      ),
    );

    return Scaffold(
      appBar: AppBar(
        brightness: Brightness.light,
        iconTheme: IconThemeData(
          color: Colors.white, //change your color here
        ),
        actions: <Widget>[
          InkWell(
            onTap: () {
              Navigator.of(context)
                  .push(PageRouteBuilder(
                      pageBuilder: (_, __, ___) => new searchAppbar()))
                  .then((res) => {refreshAppBar()});
            },
            child: IconButton(
              onPressed: null,
              icon: Icon(Icons.search, color: Colors.white),
            ),
          ),
          // InkWell(
          //   onTap: () {
          //     Navigator.of(context)
          //         .push(
          //             PageRouteBuilder(pageBuilder: (_, __, ___) => new cart()))
          //         .then((res) => {refreshAppBar()});
          //   },
          //   child: Stack(
          //     alignment: AlignmentDirectional(-1.0, -0.8),
          //     children: <Widget>[
          //       IconButton(
          //           onPressed: null,
          //           icon: Icon(
          //             Icons.shopping_cart,
          //             color: Colors.white,
          //           )),
          //       CircleAvatar(
          //         radius: 10.0,
          //         backgroundColor: Colors.red,
          //         child: Text(
          //           cartTotal.toString(),
          //           style: TextStyle(color: Colors.white, fontSize: 13.0),
          //         ),
          //       ),
          //     ],
          //   ),
          // ),
        ],
        elevation: 0.5,
        centerTitle: true,
        backgroundColor: Api.primaryColor,
        title: Text(
          "Vada Sada",
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: Colors.white,
            fontSize: 17.0,
            fontFamily: "Gotik",
          ),
        ),
      ),

      /// Use Stack to costume a appbar
      drawer: loadSideBar ? new SideBar(items: sideBarMenu) : Drawer(),
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: LoadingOverlay(
          isLoading: _loading,
          progressIndicator: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Api.primaryColor),
          ),
          child: CustomScrollView(
              // controller: _controller,
              slivers: [
                MultiSliver(
                  children: <Widget>[
                    loadWelcomeText
                        ? SizedBox(
                            height: 30.0,
                            child: Marquee(
                              text:
                                  '${welcome_text}                                                                     ',
                            ),
                          )
                        : Container(),
                    GridView.builder(
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 10.0,
                        // mainAxisSpacing: 5.0,
                        childAspectRatio: (itemWidth / itemHeight) * 1.12,
                      ),
                      itemCount: categories.length,
                      itemBuilder: (context, index) {
                        return InkWell(
                          onTap: () => {
                            onClickCategory(categories[index]['title'],
                                categories[index]['id'])
                          },
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 3.0),
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
                    ),
                    showBanners
                        ? Padding(
                            padding: EdgeInsets.only(bottom: 10),
                            child: Container(
                              child: Column(children: banner),
                            ),
                          )
                        : Container(),
                    Padding(
                      padding: EdgeInsets.only(bottom: 10.0),
                      child: loadFeaturedItems
                          ? SingleChildScrollView(
                              child: Container(
                                color: Colors.white,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 20.0, top: 20.0),
                                      child: Text(
                                        "Featured Products",
                                        style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 17.0,
                                        ),
                                      ),
                                    ),

                                    /// To set GridView item
                                    GridView.count(
                                        shrinkWrap: true,
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 10.0, vertical: 20.0),
                                        crossAxisSpacing: 10.0,
                                        mainAxisSpacing: 17.0,
                                        childAspectRatio:
                                            (itemWidth / itemHeight) * 0.85,
                                        crossAxisCount: crossaxis,
                                        primary: false,
                                        children: List.generate(
                                          featured.length,
                                          (index) => ItemGrid(
                                              gridItem: featured[index],
                                              onExit: (value) {
                                                refreshAppBar();
                                              }),
                                        ))
                                  ],
                                ),
                              ),
                            )
                          : Row(),
                    ),
                    loadMainCategory
                        ? Padding(
                            padding: const EdgeInsets.only(top: 5.0),
                            child: Container(
                              // color: Api.primaryColor,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text("Powered By "),
                                  Image.asset("assets/img/mim-logo.png")
                                ],
                              ),
                            ),
                          )
                        : Container(),

                    // SliverPadding(
                    //   padding: EdgeInsets.all(4).copyWith(top: 0),
                    //   sliver: MultiSliver(
                    //     pushPinnedChildren: true,
                    //     children: [
                    //       SliverStack(insetOnOverlap: true, children: [
                    //         SliverPositioned.fill(top: 16, child: Container()),
                    //         MultiSliver(children: [
                    //           SliverPinnedHeader(
                    //               child: Padding(
                    //             padding: const EdgeInsets.only(top: 4),
                    //             child: Container(
                    //               height: 70.0,
                    //               color: Colors.white,
                    //               child: Column(
                    //                 crossAxisAlignment: CrossAxisAlignment.start,
                    //                 children: <Widget>[
                    //                   Expanded(
                    //                       child: ListView.builder(
                    //                           scrollDirection: Axis.horizontal,
                    //                           itemCount: categoryTiles.length,
                    //                           itemBuilder: (BuildContext context,
                    //                               int index) {
                    //                             return Padding(
                    //                               padding:
                    //                                   const EdgeInsets.symmetric(
                    //                                       horizontal: 2.0),
                    //                               child: SubCategoryTile(
                    //                                   title: categoryTiles[index]
                    //                                       .title,
                    //                                   isActive:
                    //                                       categoryTiles[index]
                    //                                           .isActive,
                    //                                   tap: () {
                    //                                     setState(() {
                    //                                       category_id =
                    //                                           categoryTiles[index]
                    //                                               .id;
                    //                                       product_length = 0;
                    //                                       total_products = 0;
                    //                                       fetchData(index);
                    //                                     });
                    //                                   }),
                    //                             );
                    //                           }))
                    //                 ],
                    //               ),
                    //             ),
                    //           )),
                    //           SliverClip(
                    //             child: MultiSliver(
                    //               children: <Widget>[
                    //                 // loadCategoryProducts
                    //                 //     ?
                    //                 Container(
                    //                   height: height * 0.75,
                    //                   child: LoadingOverlay(
                    //                     isLoading: !loadCategoryProducts,
                    //                     child: SingleChildScrollView(
                    //                       controller: _controller,
                    //                       physics: ScrollPhysics(),
                    //                       child: Column(
                    //                         children: [
                    //                           GridView.builder(
                    //                             physics: ScrollPhysics(),
                    //                             shrinkWrap: true,
                    //                             padding: EdgeInsets.symmetric(
                    //                                 horizontal: 10.0,
                    //                                 vertical: 20.0),
                    //                             gridDelegate:
                    //                                 SliverGridDelegateWithFixedCrossAxisCount(
                    //                               crossAxisSpacing: 10.0,
                    //                               mainAxisSpacing: 17.0,
                    //                               childAspectRatio:
                    //                                   (itemWidth / itemHeight),
                    //                               crossAxisCount: 2,
                    //                             ),
                    //                             primary: false,
                    //                             itemCount:
                    //                                 categoryProducts.length,
                    //                             itemBuilder:
                    //                                 (BuildContext context,
                    //                                     int index) {
                    //                               return GestureDetector(
                    //                                   child: ItemGrid(
                    //                                       onExit: (value) {
                    //                                         refreshAppBar();
                    //                                       },
                    //                                       gridItem:
                    //                                           categoryProducts[
                    //                                               index]));
                    //                             },
                    //                           ),
                    //                         ],
                    //                       ),
                    //                     ),
                    //                   ),
                    //                 ),
                    //               ],
                    //             ),
                    //           ),
                    //         ])
                    //       ]),
                    //     ],
                    //   ),
                    // ),

                    // if (loadBrand) ...[PromoHorizontalList],
                  ],
                ),
              ]),

          /// Get a class AppbarGradient
          /// This is a Appbar in home activity
          // AppbarGradient(key: UniqueKey())
        ),
      ),
    );
  }

  Widget _categoryDataTile(BuildContext context, String title, int id,
      String thumbnail, List<ProductItem> childrenKid) {
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
      itemHeight = (height / 4) - 25;
    } else if (height > 950) {
      itemHeight = (height / 3.5) - 25;
    } else if (height > 750) {
      itemHeight = (height / 3) - 25;
    } else {
      itemHeight = (height / 2.5) - 25;
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 10),
          child: InkWell(
            onTap: () {
              onClickCategory(title, id);
            },
            child: Text(
              title,
              style: TextStyle(
                  // decoration: TextDecoration.underline,
                  // decorationColor: Api.primaryColor,
                  fontWeight: FontWeight.w700,
                  fontSize: 17.0),
            ),
          ),
        ),
        Container(
          height: itemHeight,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Expanded(
                  child: ListView.builder(
                      padding: EdgeInsets.symmetric(vertical: 5.0),
                      scrollDirection: Axis.horizontal,
                      itemCount: childrenKid.length + 1,
                      itemBuilder: (BuildContext context, int Index) {
                        if (Index == 0) {
                          return Container(
                            height: itemHeight - 15,
                            child: InkWell(
                              onTap: () {
                                onClickCategory(title, id);
                              },
                              child: ClipRRect(
                                child: Image.network(thumbnail),
                              ),
                            ),
                          );
                        } else {
                          return _itemGrid(context, childrenKid[Index - 1]);
                        }
                      }))
            ],
          ),
        ),
      ],
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
      itemHeight = (height / 4) - 25;
    } else if (height > 950) {
      itemHeight = (height / 3.5) - 25;
    } else if (height > 750) {
      itemHeight = (height / 3) - 25;
    } else {
      itemHeight = (height / 2.5) - 25;
    }
    return Padding(
      padding: const EdgeInsets.only(left: 5.0, right: 5.0),
      child: InkWell(
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
          width: itemWidth * 0.9,
          height: itemHeight,
          decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(width: 1, color: Colors.black26),
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
                          height: itemHeight * 0.65,
                          width: itemWidth * 0.9,
                          decoration: BoxDecoration(
                              color: Colors.white,
                              image: DecorationImage(
                                  image: NetworkImage(gridItem.images),
                                  fit: BoxFit.fill)),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: itemHeight * 0.15,
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
                      height: itemHeight * 0.17,
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
                                          decoration:
                                              TextDecoration.lineThrough,
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
                                    child: Text(
                                        "Rs " + gridItem.price.toString(),
                                        style: TextStyle(
                                            color: Api.primaryColor,
                                            fontWeight: FontWeight.w800,
                                            fontFamily: "Sans",
                                            fontSize: 13)),
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

  MediaQueryData getMediaQueryData() {
    return MediaQuery.of(context);
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

  onClickBrand(String s, int id) {
    Navigator.of(context).push(PageRouteBuilder(
        pageBuilder: (_, __, ___) => new brandDetail(title: s, id: id),
        transitionDuration: Duration(milliseconds: 750),
        transitionsBuilder: (_, Animation<double> animation, __, Widget child) {
          return Opacity(
            opacity: animation.value,
            child: child,
          );
        }));
  }

  onClickProduct(ProductItem item) {
    Navigator.of(context).push(PageRouteBuilder(
        pageBuilder: (_, __, ___) => new productDetail(item),
        transitionDuration: Duration(milliseconds: 900),

        /// Set animation Opacity in route to detailProduk layout
        transitionsBuilder: (_, Animation<double> animation, __, Widget child) {
          return Opacity(
            opacity: animation.value,
            child: child,
          );
        }));
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

class BrandTile extends StatelessWidget {
  BrandTile({this.image, this.tap});

  final image;
  GestureTapCallback tap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: tap,
        child: Container(
          height: 120,
          width: 120,
          decoration: BoxDecoration(
              image: DecorationImage(
                  image: NetworkImage(image), fit: BoxFit.contain)),
        ));
  }
}

class CategoryTile extends StatelessWidget {
  CategoryTile({this.image, this.title, this.tap});

  final image, title;
  GestureTapCallback tap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: tap,
        child: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Container(
            width: 100,
            child: Column(
              children: [
                Container(
                  height: 90,
                  width: 90,
                  decoration: BoxDecoration(
                      image: DecorationImage(
                          image: NetworkImage(image), fit: BoxFit.contain)),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    title,
                    style: TextStyle(fontSize: 11, color: Colors.black54),
                    textAlign: TextAlign.center,
                  ),
                )
              ],
            ),
          ),
        ));
  }
}

/// ItemGrid in bottom item "Recomended" item
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
        Navigator.of(context)
            .push(PageRouteBuilder(
                pageBuilder: (_, __, ___) => new productDetail(widget.gridItem),
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
                                    // IconButton(
                                    //   icon: Icon(Icons.shopping_cart_outlined),
                                    //   onPressed: () {
                                    //     _addItem(widget.gridItem);
                                    //   },
                                    // )
                                  ],
                                ),
                              ),
                            ),
                            // Padding(
                            //   padding: EdgeInsets.only(left: 10.0),
                            //   child: Text(
                            //       "Rs " + widget.gridItem.discounted.toString(),
                            //       style: TextStyle(
                            //           color: Api.primaryColor,
                            //           fontWeight: FontWeight.w800,
                            //           fontFamily: "Sans",
                            //           fontSize: 13)),
                            // ),
                            // Padding(
                            //   padding: EdgeInsets.only(left: 10.0),
                            //   child: Text(
                            //     "Rs " + widget.gridItem.price.toString(),
                            //     style: TextStyle(
                            //         decoration: TextDecoration.lineThrough,
                            //         color: Colors.black54,
                            //         fontWeight: FontWeight.w600,
                            //         fontFamily: "Sans",
                            //         fontSize: 11.5),
                            //   ),
                            // ),
                            // IconButton(
                            //   icon: Icon(Icons.shopping_cart_outlined),
                            //   onPressed: () {
                            //     _addItem(widget.gridItem);
                            //   },
                            // )
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
                                    // IconButton(
                                    //   icon: Icon(Icons.shopping_cart_outlined),
                                    //   onPressed: () {
                                    //     _addItem(widget.gridItem);
                                    //   },
                                    // )
                                  ],
                                ),
                              ),
                            ),
                          ],
                  ),
                ),
                // Container(
                //   height: itemHeight * 0.17,
                //   alignment: Alignment.center,
                //   child: SizedBox(
                //     width: double.infinity,
                //     child: ElevatedButton.icon(
                //       style: ElevatedButton.styleFrom(
                //         primary: Api.primaryColor,
                //       ),
                //       onPressed: () {
                //         _addItem(widget.gridItem);
                //       },
                //       icon: Icon(
                //         // <-- Icon
                //         Icons.shopping_bag_outlined,
                //         size: 20.0,
                //       ),
                //       label: Text('Add to Cart'), // <-- Text
                //     ),
                //   ),
                // )
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

/// Component FlashSaleItem
class flashSaleItem extends StatelessWidget {
  final String image;
  final String title;
  final int normalprice;
  final int discountprice;

  flashSaleItem({this.image, this.title, this.normalprice, this.discountprice});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            InkWell(
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
                height: 240.0,
                width: 145.0,
//                color: Colors.white,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(
                      height: 160.0,
                      width: 145.0,
                      child: Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(7.0),
                                topRight: Radius.circular(7.0)),
                            image: DecorationImage(
                                image: NetworkImage(image),
                                fit: BoxFit.contain)),
                      ),
                    ),
                    Padding(
                      padding:
                          EdgeInsets.only(left: 8.0, right: 3.0, top: 15.0),
                      child: Text(title,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              fontFamily: "Sans")),
                    ),
                    Row(children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(left: 10.0, top: 5.0),
                        child: Text("Rs " + discountprice.toString(),
                            style: TextStyle(
                                fontSize: 12.0,
                                color: Api.primaryColor,
                                fontWeight: FontWeight.w800,
                                fontFamily: "Sans")),
                      ),
                      normalprice > 0
                          ? Padding(
                              padding: EdgeInsets.only(left: 10.0, top: 5.0),
                              child: Text("Rs " + normalprice.toString(),
                                  style: TextStyle(
                                      fontSize: 10.5,
                                      decoration: TextDecoration.lineThrough,
                                      color: Colors.black54,
                                      fontWeight: FontWeight.w600,
                                      fontFamily: "Sans")),
                            )
                          : Container()
                    ]),
                  ],
                ),
              ),
            )
          ],
        )
      ],
    );
  }
}

/// Component category item bellow FlashSale
class CategoryItemValue extends StatelessWidget {
  String image, title;
  GestureTapCallback tap;

  CategoryItemValue({
    this.image,
    this.title,
    this.tap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: tap,
      child: Container(
        height: 105.0,
        width: 160.0,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(3.0)),
          image: DecorationImage(image: NetworkImage(image), fit: BoxFit.cover),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(3.0)),
            color: Colors.black.withOpacity(0.25),
          ),
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Center(
                child: Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontFamily: "Berlin",
                fontSize: 18.5,
                letterSpacing: 0.7,
                fontWeight: FontWeight.w800,
              ),
            )),
          ),
        ),
      ),
    );
  }
}

/// Component item Menu icon bellow a ImageSlider
class CategoryIconValue extends StatelessWidget {
  String icon, title;
  GestureTapCallback tap;

  CategoryIconValue({this.icon, this.tap, this.title});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: tap,
      child: Column(
        children: <Widget>[
          Image.network(
            icon,
            height: 19.2,
          ),
          Padding(padding: EdgeInsets.only(top: 7.0)),
          Text(
            title,
            style: TextStyle(
              fontFamily: "Sans",
              fontSize: 10.0,
              fontWeight: FontWeight.w500,
            ),
          )
        ],
      ),
    );
  }
}

class SubCategoryTile extends StatelessWidget {
  SubCategoryTile({this.title, this.tap, this.isActive});

  final String title;
  bool isActive;
  GestureTapCallback tap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: Container(
        decoration: BoxDecoration(
          color: isActive ? Api.secondaryColor : Api.primaryColor,
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
