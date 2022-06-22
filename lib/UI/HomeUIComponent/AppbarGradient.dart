import 'package:vadasada/Api/api.dart';
import 'package:flutter/material.dart';
import 'package:vadasada/UI/CartUIComponent/CartLayout.dart';
import 'package:vadasada/UI/HomeUIComponent/Search.dart';
import 'package:localstorage/localstorage.dart';

class AppbarGradient extends StatefulWidget {
  const AppbarGradient({Key key}) : super(key: key);

  @override
  _AppbarGradientState createState() => _AppbarGradientState();
}

class _AppbarGradientState extends State<AppbarGradient> {
  final LocalStorage storage = new LocalStorage('vadasada');
  var cartItem;
  int cartTotal;

  @override
  void initState() {
    refreshCartTotal();
    super.initState();
  }

  refreshCartTotal() {
    setState(() {
      int total = 0;
      cartItem = storage.getItem("cart") ?? [];
      // print(cartItem);
      if (cartItem.length > 0) {
        for (var i = 0; i < cartItem.length; i++) {
          // print(cartItem[i]);
          total += cartItem[i]['qty'];
        }
      }
      cartTotal = total;
    });
  }

  // refreshCartTotal(){

  // }

  /// Build Appbar in layout home
  @override
  Widget build(BuildContext context) {
    /// Create responsive height and padding
    final MediaQueryData media = MediaQuery.of(context);
    final double width = media.size.width;
    final double statusBarHeight = MediaQuery.of(context).padding.top;

    /// Create component in appbar
    return Container(
      decoration: BoxDecoration(color: Colors.white, boxShadow: [
        BoxShadow(
          color: Color(0xFF000000).withOpacity(0.4),
          blurRadius: 4.0,
          spreadRadius: 1.0,
//           offset: Offset(4.0, 10.0)
        )
      ]),
      padding: EdgeInsets.only(top: statusBarHeight),
      height: 58.0 + statusBarHeight,
//      decoration: BoxDecoration(
//        /// gradient in appbar
//          gradient: LinearGradient(
//              colors: [
//                const Api.primaryColor,
//                Colors.green[800],
//              ],
//              begin: const FractionalOffset(0.0, 0.0),
//              end: const FractionalOffset(1.0, 0.0),
//              stops: [0.5, 1.0],
//              tileMode: TileMode.clamp)
//      ),
//      color: Colors.white,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          InkWell(
              onTap: () => {Scaffold.of(context).openDrawer()},
              child: Icon(
                Icons.menu,
                color: Api.primaryColor,
                size: 30.0,
              )),

          /// if user click shape white in appbar navigate to search layout
          InkWell(
            onTap: () {
              Navigator.of(context).push(PageRouteBuilder(
                  pageBuilder: (_, __, ___) => searchAppbar(),

                  /// transtation duration in animation
                  transitionDuration: Duration(milliseconds: 750),

                  /// animation route to search layout
                  transitionsBuilder:
                      (_, Animation<double> animation, __, Widget child) {
                    return Opacity(
                      opacity: animation.value,
                      child: child,
                    );
                  }));
            },

            /// Create shape background white in appbar (background treva shop text)
            child: Container(
              margin: EdgeInsets.only(left: media.padding.left + 15),
              height: 37.0,
              width: width * 0.65,
              decoration: BoxDecoration(
                  color: Color(0xFFFFFFFF),
                  borderRadius: BorderRadius.all(Radius.circular(5.0)),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xFF000000).withOpacity(0.8),
                      blurRadius: 2.0,
                      spreadRadius: 0.5,
//           offset: Offset(4.0, 10.0)
                    )
                  ],
                  shape: BoxShape.rectangle),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Padding(padding: EdgeInsets.only(left: 12.0)),
                  Icon(
                    Icons.search,
                    color: Api.primaryColor,
                    size: 20.0,
                  ),
                  Padding(
                      padding: EdgeInsets.only(
                    left: 10.0,
                  )),
                  Padding(
                    padding: EdgeInsets.only(left: 0.0),
                    child: Text(
                      "Search here",
                      style: TextStyle(
                          fontFamily: "Popins",
                          color: Colors.black54,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.0,
                          fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
          ),

          /// Icon chat (if user click navigate to chat layout)
          // InkWell(
          //     onTap: () {
          //       Navigator.of(context).push(PageRouteBuilder(
          //           pageBuilder: (_, __, ___) => new Prescription()));
          //     },
          //     child: Icon(
          //       Icons.file_upload,
          //       color: Api.primaryColor,
          //       size: 30.0,
          //     )),

          /// Icon notification (if user click navigate to notification layout)
          InkWell(
            onTap: () {
              Navigator.of(context)
                  .push(
                      PageRouteBuilder(pageBuilder: (_, __, ___) => new cart()))
                  .then((value) => {refreshCartTotal()});
            },
            child: Stack(
              alignment: AlignmentDirectional(-3.0, -3.0),
              children: <Widget>[
                InkWell(
                  child: Icon(
                    Icons.shopping_cart,
                    color: Api.primaryColor,
                    size: 30.0,
                  ),
                ),
                CircleAvatar(
                  radius: 8.6,
                  backgroundColor: Colors.redAccent,
                  child: Text(
                    cartTotal.toString(),
                    style: TextStyle(fontSize: 13.0, color: Colors.white),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
