import 'package:flutter/material.dart';

class TopCategorySold extends StatelessWidget {
  const TopCategorySold({
    key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          color: Colors.transparent,
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          alignment: Alignment.centerLeft,
          child: Text(
            'Top Categories - Items Sold',
            style: TextStyle(
                color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold
                // fontWeight: FontWeight.bold,
                ),
          ),
        ),
        // SizedBox(height: 20),
        TopItems(
          tableTexthead1: 'Category',
          tableTexthead2: 'Sold',
          tableTexthead3: 'Total',
          tableText1: 'Baby, ',
          tableText2: '1',
          tableText3: '39',
        ),
      ],
    );
  }
}

class TopItems extends StatelessWidget {
  final String tableTexthead1;
  final String tableTexthead2;
  final String tableTexthead3;
  final String tableText1;
  final String tableText2;
  final String tableText3;
  const TopItems({
    key,
    this.tableTexthead1 = '',
    this.tableTexthead2 = '',
    this.tableTexthead3 = '',
    this.tableText1 = '',
    this.tableText2 = '',
    this.tableText3 = '',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20),
      child: Table(
        defaultColumnWidth: FixedColumnWidth(120.0),
        border: TableBorder.all(
            color: Colors.black, style: BorderStyle.solid, width: 1),
        children: [
          TableRow(children: [
            Column(children: [
              Container(
                padding: EdgeInsets.symmetric(vertical: 5),
                child: Text(tableTexthead1,
                    style:
                        TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold)),
              )
            ]),
            Column(children: [
              Container(
                padding: EdgeInsets.symmetric(vertical: 5),
                child: Text(tableTexthead2,
                    style:
                        TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold)),
              )
            ]),
            Column(children: [
              Container(
                padding: EdgeInsets.symmetric(vertical: 5),
                child: Text(tableTexthead3,
                    style:
                        TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold)),
              )
            ]),
          ]),
          TableRow(children: [
            Column(
              children: [
                Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    height: 40,
                    alignment: Alignment.center,
                    child: Text(tableText1)),
              ],
            ),
            Column(
              children: [
                Container(
                    height: 40,
                    alignment: Alignment.center,
                    child: Text(tableText2)),
              ],
            ),
            Column(
              children: [
                Container(
                    height: 40,
                    alignment: Alignment.center,
                    child: Text(tableText3)),
              ],
            ),
          ]),
          TableRow(children: [
            Column(
              children: [
                Container(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    height: 40,
                    alignment: Alignment.center,
                    child: Text(tableText1)),
              ],
            ),
            Column(
              children: [
                Container(
                    height: 40,
                    alignment: Alignment.center,
                    child: Text(tableText2)),
              ],
            ),
            Column(
              children: [
                Container(
                    height: 40,
                    alignment: Alignment.center,
                    child: Text(tableText3)),
              ],
            ),
          ]),
          TableRow(children: [
            Column(
              children: [
                Container(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    height: 40,
                    alignment: Alignment.center,
                    child: Text(tableText1)),
              ],
            ),
            Column(
              children: [
                Container(
                    height: 40,
                    alignment: Alignment.center,
                    child: Text(tableText2)),
              ],
            ),
            Column(
              children: [
                Container(
                    height: 40,
                    alignment: Alignment.center,
                    child: Text(tableText3)),
              ],
            ),
          ]),
        ],
      ),
    );
  }
}
