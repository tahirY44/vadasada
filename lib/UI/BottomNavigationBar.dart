import 'package:localstorage/localstorage.dart';
import 'package:vadasada/Api/api.dart';
import 'package:flutter/material.dart';
import 'package:vadasada/UI/CartUIComponent/CartLayout.dart';
import 'package:vadasada/UI/HomeUIComponent/Home.dart';
import 'package:vadasada/UI/AcountUIComponent/Profile.dart';
import 'package:vadasada/UI/LoginOrSignup/SellRegister.dart';
import 'package:vadasada/UI/products/AddProduct.dart';
// import 'package:vadasada/UI/LoginOrSignup/SellLogin.dart';
// import 'package:vadasada/UI/products/AddProduct.dart';
import 'package:vadasada/UI/products/MyListings.dart';
import 'package:vadasada/UI/products/sell.dart';

class bottomNavigationBar extends StatefulWidget {
  @override
  _bottomNavigationBarState createState() => _bottomNavigationBarState();
}

class _bottomNavigationBarState extends State<bottomNavigationBar> {
  int currentIndex = 0;
  bool login = false;
  final LocalStorage storage = new LocalStorage('vadasada');

  void initState() {
    if (storage.getItem('user') != null) {
      login = true;
    }
    super.initState();
  }

  /// Set a type current number a layout class
  Widget callPage(int current) {
    var user = storage.getItem('user');
    // switch (current) {
    //   case 0:
    //     return new Menu();
    //     break;
    //   case 1:
    //     return new MyListings(title: 'My Products', id: user['id']);
    //     break;
    //   case 2:
    //     return new profil();
    //     break;
    //   default:
    //     return Menu();
    // }
    if (storage.getItem('user') != null) {
      switch (current) {
        case 0:
          return new Menu();
          break;
        case 1:
          return new AddProduct();
          break;
        case 2:
          return new MyListings(title: 'My Products', id: user['id']);
          break;
        case 3:
          return new profil();
          break;
        default:
          return Menu();
      }
    } else {
      switch (current) {
        case 0:
          return new Menu();
          break;
        case 1:
          return new SellRegister();
          break;
        case 2:
          return new profil();
          break;
        default:
          return Menu();
      }
    }
  }

  /// Build BottomNavigationBar Widget
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: callPage(currentIndex),
        bottomNavigationBar: Theme(
            data: Theme.of(context).copyWith(
                canvasColor: Colors.white,
                textTheme: Theme.of(context).textTheme.copyWith(
                    caption:
                        TextStyle(color: Colors.black54.withOpacity(0.50)))),
            child: BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              currentIndex: currentIndex,
              fixedColor: Api.primaryColor,
              onTap: (value) {
                currentIndex = value;
                setState(() {});
              },
              items: login
                  ? ([
                      BottomNavigationBarItem(
                        icon: Icon(
                          Icons.home,
                          size: 23.0,
                        ),
                        label: "Home",
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(
                          Icons.add,
                          size: 23.0,
                        ),
                        label: "Sell",
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(
                          Icons.inbox_rounded,
                          size: 23.0,
                        ),
                        label: "My Listing",
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(
                          Icons.person,
                          size: 23.0,
                        ),
                        label: "Acount",
                      ),
                    ])
                  : ([
                      BottomNavigationBarItem(
                        icon: Icon(
                          Icons.home,
                          size: 23.0,
                        ),
                        label: "Home",
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(
                          Icons.add,
                          size: 23.0,
                        ),
                        label: "Sell",
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(
                          Icons.person,
                          size: 23.0,
                        ),
                        label: "Acount",
                      ),
                    ]),
            )));
  }
}
