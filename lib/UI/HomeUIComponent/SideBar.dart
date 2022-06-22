import 'package:flutter/material.dart';
import 'package:vadasada/UI/HomeUIComponent/CategoryDetail.dart';

class SideBar extends StatefulWidget {
  List<Widget> items;

  SideBar({this.items});

  @override
  _SideBarState createState() => _SideBarState(items: this.items);
}

class _SideBarState extends State<SideBar> {
  List<Widget> items;

  _SideBarState({this.items});

  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        // Important: Remove any padding from the ListView.
        padding: EdgeInsets.only(top: 0),
        children: items,
      ),
    );
  }
}

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
