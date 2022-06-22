import 'dart:convert';

import 'package:vadasada/Api/api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:vadasada/Library/Accordion/accordion.dart';
import 'package:loading_overlay/loading_overlay.dart';

class faqs extends StatefulWidget {
  @override
  _faqsState createState() => _faqsState();
}

class _faqsState extends State<faqs> {
  var page_data = '';
  bool _loading = false;
  bool loadAccordionData = false;

  List<Widget> accordionData = [];

  getData() async {
    var parameters = {'appkey': Api.appkey, 'slug': 'faqs'};

    var response = await Api.getRequest(Api.static_page, parameters);
    var data = jsonDecode(response.body);
    for (var i = 0; i < data.length; i++) {
      var title = data[i]['question'];
      var content = data[i]['answer'];
      accordionData.add(Accordion(
        title: title,
        content: content,
      ));
    }

    setState(() {
      loadAccordionData = true;
      _loading = false;
    });
  }

  @override
  void initState() {
    setState(() {
      _loading = true;
    });
    getData();
    super.initState();
  }

  @override
  static var _txtCustomHead = TextStyle(
    color: Colors.black54,
    fontSize: 17.0,
    fontWeight: FontWeight.w600,
    fontFamily: "Gotik",
  );

  static var _txtCustomSub = TextStyle(
    color: Colors.black38,
    fontSize: 15.0,
    fontWeight: FontWeight.w500,
    fontFamily: "Gotik",
  );

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Api.primaryColor,
        title: Text(
          "FAQs",
          style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 15.0,
              color: Colors.white,
              fontFamily: "Gotik"),
        ),
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
        elevation: 0.0,
      ),
      body: LoadingOverlay(
        isLoading: _loading,
        progressIndicator: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Api.primaryColor),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            // child: Container(),
            child: Column(children: loadAccordionData ? accordionData : []),
          ),
        ),
      ),
    );
  }
}
