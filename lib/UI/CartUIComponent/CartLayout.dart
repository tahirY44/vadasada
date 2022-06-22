import 'package:vadasada/UI/LoginOrSignup/Login.dart';
import 'package:vadasada/Api/api.dart';
import 'package:flutter/material.dart';
import 'package:localstorage/localstorage.dart';
import 'package:vadasada/UI/CartUIComponent/Delivery.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class cart extends StatefulWidget {
  @override
  _cartState createState() => _cartState();
}

class _cartState extends State<cart> {
  final LocalStorage storage = new LocalStorage('vadasada');
  var empty_cart = [];
  var cart_list = [];
  var user;
  int total_amount = 0;

  @override
  void initState() {
    super.initState();
    setState(() {
      user = storage.getItem("user") ?? null;
      cart_list = storage.getItem('cart') ?? [];
    });
    updateTotal();
  }

  updateTotal() {
    int total = 0;
    for (var i = 0; i < cart_list.length; i++) {
      total += cart_list[i]['amount'];
    }
    setState(() {
      total_amount = total;
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
              "Cart",
              style: TextStyle(
                  fontFamily: "Gotik",
                  fontSize: 18.0,
                  color: Colors.white,
                  fontWeight: FontWeight.w700),
            ),
            elevation: 0.0,
            actions: <Widget>[
              InkWell(
                onTap: () {
                  setState(() {
                    storage.setItem("cart", empty_cart);
                    cart_list = [];
                  });
                },
                child: Container(
                  alignment: Alignment.center,
                  child: Row(
                    children: [
                      Text(
                        'Empty Cart',
                      ),
                      IconButton(
                        onPressed: null,
                        icon: Icon(Icons.remove_shopping_cart_outlined,
                            color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
            ]),

        ///
        ///
        /// Checking item value of cart
        ///
        ///
        body: cart_list.length > 0
            ? Column(
                children: [
                  Container(
                    color: Colors.black12,
                    width: width,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text("Note : Swipe left to remove from Cart",
                          textAlign: TextAlign.center),
                    ),
                  ),
                  Flexible(
                    child: ListView.builder(
                      itemCount: cart_list.length,
                      itemBuilder: (context, position) {
                        ///
                        /// Widget for list view slide delete
                        ///
                        return Slidable(
                          // actionPane: new SlidableDrawerActionPane(),
                          // actionExtentRatio: 0.25,
                          // secondaryActions: <Widget>[
                          //   new IconSlideAction(
                          //     key: Key(cart_list[position]['id'].toString()),
                          //     caption: 'Delete',
                          //     color: Colors.red,
                          //     icon: Icons.delete,
                          //     onTap: () {
                          //       setState(() {
                          //         cart_list.removeAt(position);
                          //         storage.setItem("cart", cart_list);
                          //       });
                          //       updateTotal();

                          //       ///
                          //       /// SnackBar show if cart delet
                          //       ///
                          //       Scaffold.of(context).showSnackBar(SnackBar(
                          //         content: Text("Items Cart Deleted"),
                          //         duration: Duration(seconds: 1),
                          //         backgroundColor: Colors.redAccent,
                          //       ));
                          //     },
                          //   ),
                          // ],
                          child: Padding(
                            padding: const EdgeInsets.only(
                                top: 3.5, left: 13.0, right: 13.0, bottom: 3.5),

                            /// Background Constructor for card
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black12.withOpacity(0.1),
                                    blurRadius: 3.5,
                                    spreadRadius: 0.4,
                                  )
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Padding(
                                          padding: EdgeInsets.only(
                                              left: 10.0,
                                              right: 10,
                                              top: 5,
                                              bottom: 5),

                                          /// Image item
                                          child: Container(
                                              decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  boxShadow: [
                                                    BoxShadow(
                                                        color: Colors.black12
                                                            .withOpacity(0.1),
                                                        blurRadius: 0.5,
                                                        spreadRadius: 0.1)
                                                  ]),
                                              child: Image.network(
                                                '${cart_list[position]["image"]}',
                                                // height: 130.0,
                                                width: 140.0,
                                                fit: BoxFit.contain,
                                              ))),
                                      Flexible(
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                              top: 5.0, left: 10.0, right: 5.0),
                                          child: Column(
                                            /// Text Information Item
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: <Widget>[
                                              Text(
                                                '${cart_list[position]["title"]}',
                                                maxLines: 2,
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w700,
                                                  fontFamily: "Sans",
                                                  color: Colors.black87,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              Padding(
                                                  padding: EdgeInsets.only(
                                                      top: 10.0)),
                                              cart_list[position][
                                                          'product_variation_type'] >
                                                      0
                                                  ? Text(
                                                      '${cart_list[position]["variation_1"]}',
                                                      style: TextStyle(
                                                        color: Colors.black54,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        fontSize: 12.0,
                                                      ),
                                                    )
                                                  : Container(),
                                              cart_list[position][
                                                          'product_variation_type'] >
                                                      1
                                                  ? Text(
                                                      '${cart_list[position]["variation_2"]}',
                                                      style: TextStyle(
                                                        color: Colors.black54,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        fontSize: 12.0,
                                                      ),
                                                    )
                                                  : Container(),
                                              Padding(
                                                  padding: EdgeInsets.only(
                                                      top: 10.0)),
                                              Text(cart_list[position]
                                                          ['dprice'] >
                                                      0
                                                  ? 'Rs ${cart_list[position]["dprice"]}'
                                                  : 'Rs ${cart_list[position]["price"]}'),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 18.0, left: 0.0),
                                                child: Container(
                                                  width: 112.0,
                                                  decoration: BoxDecoration(
                                                      color: Colors.white70,
                                                      border: Border.all(
                                                          color: Colors.black12
                                                              .withOpacity(
                                                                  0.1))),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceAround,
                                                    children: <Widget>[
                                                      /// Decrease of value item
                                                      InkWell(
                                                        onTap: () {
                                                          setState(() {
                                                            if (cart_list[
                                                                        position]
                                                                    ["qty"] >
                                                                1) {
                                                              cart_list[
                                                                      position]
                                                                  ["qty"] -= 1;
                                                              cart_list[
                                                                      position]
                                                                  [
                                                                  "amount"] = cart_list[
                                                                          position]
                                                                      ["qty"] *
                                                                  (cart_list[
                                                                                  position]
                                                                              [
                                                                              'dprice'] >
                                                                          0
                                                                      ? cart_list[
                                                                              position]
                                                                          [
                                                                          "dprice"]
                                                                      : cart_list[
                                                                              position]
                                                                          [
                                                                          "price"]);
                                                              storage.setItem(
                                                                  "cart",
                                                                  cart_list);
                                                            }
                                                          });
                                                          updateTotal();
                                                        },
                                                        child: Container(
                                                          height: 30.0,
                                                          width: 30.0,
                                                          decoration: BoxDecoration(
                                                              border: Border(
                                                                  right: BorderSide(
                                                                      color: Colors
                                                                          .black12
                                                                          .withOpacity(
                                                                              0.1)))),
                                                          child: Center(
                                                              child: Text("-")),
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                    .symmetric(
                                                                horizontal:
                                                                    18.0),
                                                        child: Text(
                                                            cart_list[position]
                                                                    ["qty"]
                                                                .toString()),
                                                      ),

                                                      /// Increasing value of item
                                                      InkWell(
                                                        onTap: () {
                                                          setState(() {
                                                            if (cart_list[
                                                                        position]
                                                                    ["qty"] <
                                                                10) {
                                                              cart_list[
                                                                      position]
                                                                  ["qty"] += 1;
                                                              cart_list[
                                                                      position]
                                                                  [
                                                                  "amount"] = cart_list[
                                                                          position]
                                                                      ["qty"] *
                                                                  (cart_list[
                                                                                  position]
                                                                              [
                                                                              'dprice'] >
                                                                          0
                                                                      ? cart_list[
                                                                              position]
                                                                          [
                                                                          "dprice"]
                                                                      : cart_list[
                                                                              position]
                                                                          [
                                                                          "price"]);
                                                              storage.setItem(
                                                                  "cart",
                                                                  cart_list);
                                                            }
                                                          });
                                                          updateTotal();
                                                        },
                                                        child: Container(
                                                          height: 30.0,
                                                          width: 28.0,
                                                          decoration: BoxDecoration(
                                                              border: Border(
                                                                  left: BorderSide(
                                                                      color: Colors
                                                                          .black12
                                                                          .withOpacity(
                                                                              0.1)))),
                                                          child: Center(
                                                              child: Text("+")),
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
                                    ],
                                  ),
                                  Padding(padding: EdgeInsets.only(top: 8.0)),
                                  // Divider(
                                  //   height: 2.0,
                                  //   color: Colors.black12,
                                  // ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                      scrollDirection: Axis.vertical,
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(color: Colors.white, boxShadow: [
                      BoxShadow(
                        color: Color(0xFF000000).withOpacity(0.4),
                        blurRadius: 4.0,
                        spreadRadius: 1.0,
//           offset: Offset(4.0, 10.0)
                      )
                    ]),
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.only(left: 10.0),

                            /// Total price of item buy
                            child: Text(
                              "Total : PKR " + total_amount.toString(),
                              style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 15.5,
                                  fontFamily: "Sans"),
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              checkoutCart(context);
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(right: 10.0),
                              child: Container(
                                height: 40.0,
                                width: 140.0,
                                decoration: BoxDecoration(
                                  color: Api.primaryColor,
                                ),
                                child: Center(
                                  child: Text(
                                    "CHECKOUT",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontFamily: "Sans",
                                        fontWeight: FontWeight.w600),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              )
            : noItemCart());
  }

  void checkoutCart(BuildContext context) {
    if (user == null) {
      Navigator.of(context)
          .push(PageRouteBuilder(pageBuilder: (_, __, ___) => loginScreen()));
    } else {
      Navigator.of(context)
          .push(PageRouteBuilder(pageBuilder: (_, __, ___) => delivery()));
    }
  }

  // _showMyDialog() {
  //   return showDialog(
  //     context: context,
  //     barrierDismissible: false, // user must tap button!
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         title: Text('Alert'),
  //         content: SingleChildScrollView(
  //           child: ListBody(
  //             children: <Widget>[
  //               Text('Please login to continue.'),
  //             ],
  //           ),
  //         ),
  //         actions: <Widget>[
  //           TextButton(
  //             child: Text('OK'),
  //             onPressed: () {
  //               Navigator.pop(context, 'Lost');
  //               Navigator.of(context).push(PageRouteBuilder(
  //                   pageBuilder: (_, __, ___) => loginScreen()));
  //             },
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }
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
              "Cart is Empty",
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
