import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:image_picker/image_picker.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:sweetalert/sweetalert.dart';
import 'package:vadasada/Api/api.dart';
import 'package:vadasada/UI/LoginOrSignup/LoginAnimation.dart';
import 'package:localstorage/localstorage.dart';
import 'package:http/http.dart' as http;
import 'package:image_cropper/image_cropper.dart';
import 'package:fdottedline/fdottedline.dart';

class AddProduct extends StatefulWidget {
  @override
  _AddProductState createState() => _AddProductState();
}

class _AddProductState extends State<AddProduct> with TickerProviderStateMixin {
  //Animation Declaration
  AnimationController sanimationController;
  AnimationController animationControllerScreen;
  final LocalStorage storage = new LocalStorage('vadasada');
  Animation animationScreen;
  var tap = 0;
  final titleController = TextEditingController();
  final productSkuController = TextEditingController();
  final priceController = TextEditingController();
  final discountedController = TextEditingController();
  // final emailController = TextEditingController();
  // final passwordController = TextEditingController();
  bool loadCatergory = false;
  String category, title, sku, price, discounted, city, city_title;
  List<String> cities_title = [];
  List<String> cities_id = [];

  List<int> file;
  String _filePath;
  String _filename;
  File _image;
  bool _loading = false;

  final _formKey = GlobalKey<FormState>();

  /// Set AnimationController to initState
  @override
  void initState() {
    sanimationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 800))
          ..addStatusListener((statuss) {
            if (statuss == AnimationStatus.dismissed) {
              setState(() {
                tap = 0;
              });
            }
          });
    // TODO: implement initState
    super.initState();
    getCategory();
    titleController.addListener(_titleValue);
    productSkuController.addListener(_productSkuValue);
    priceController.addListener(_priceValue);
    discountedController.addListener(_discountedValue);
  }

  final ImagePicker imagePicker = ImagePicker();
  File image;
  List<File> multipleImages = [];

  // void selectImages() async {
  //   final selectedImages = await imagePicker.pickMultiImage();
  //   if (selectedImages.isNotEmpty) {
  //     imageFileList.addAll(selectedImages);
  //   }
  //   print(imageFileList);
  //   print("Image List Length:" + imageFileList.length.toString());
  //   setState(() {});
  // }

  getCategory() async {
    var response = await Api.getRequest(Api.menu_category, null);
    var data = jsonDecode(response.body);

    if (data != 0) {
      for (var row in data) {
        cities_title.add(row["title"]);
        cities_id.add(row["id"].toString());
      }
      // for (var i = 0; i < data.length; i++) {
      //   var id = data[i]['id'];
      //   var title = data[i]['title'];
      //   setState(() {
      //     cityData.add(selectItem(id, title));
      //   });
      // }
    }

    setState(() {
      loadCatergory = true;
    });
  }

  /// Dispose animationController
  @override
  void dispose() {
    titleController.dispose();
    productSkuController.dispose();
    priceController.dispose();
    discountedController.dispose();
    super.dispose();
    sanimationController.dispose();
  }

  _titleValue() {
    setState(() {
      title = titleController.text;
    });
  }

  _productSkuValue() {
    setState(() {
      sku = productSkuController.text;
    });
  }

  _priceValue() {
    setState(() {
      price = priceController.text;
    });
  }

  _discountedValue() {
    setState(() {
      discounted = discountedController.text;
    });
  }

  Widget _textFromField(
      bool password,
      String email,
      // IconData icon,
      TextInputType inputType,
      TextEditingController controller,
      FocusScopeNode node,
      bool isNext) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 30.0),
      child: Container(
        height: 60.0,
        alignment: AlignmentDirectional.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14.0),
          color: Colors.white,
          // boxShadow: [BoxShadow(blurRadius: 10.0, color: Colors.black12)],
          border: Border.all(width: 0.50, color: Colors.black),
        ),
        padding:
            EdgeInsets.only(left: 20.0, right: 30.0, top: 0.0, bottom: 0.0),
        child: Theme(
          data: ThemeData(
            hintColor: Colors.transparent,
          ),
          child: isNext
              ? TextField(
                  controller: controller,
                  obscureText: password,
                  decoration: InputDecoration(
                      border: InputBorder.none,
                      labelText: email,
                      // icon: Icon(
                      //   icon,
                      //   color: Colors.black38,
                      // ),
                      labelStyle: TextStyle(
                          fontSize: 15.0,
                          fontFamily: 'Sans',
                          letterSpacing: 0.3,
                          color: Colors.black38,
                          fontWeight: FontWeight.w600)),
                  keyboardType: inputType,
                  onEditingComplete: () => node.nextFocus(),
                )
              : TextField(
                  controller: controller,
                  obscureText: password,
                  decoration: InputDecoration(
                      border: InputBorder.none,
                      labelText: email,
                      // icon: Icon(
                      //   icon,
                      //   color: Colors.black38,
                      // ),
                      labelStyle: TextStyle(
                          fontSize: 15.0,
                          fontFamily: 'Sans',
                          letterSpacing: 0.3,
                          color: Colors.black38,
                          fontWeight: FontWeight.w600)),
                  keyboardType: inputType,
                  onSubmitted: (_) => node.unfocus(),
                ),
        ),
      ),
    );
  }

  /// Playanimation set forward reverse
  Future<Null> _PlayAnimation() async {
    try {
      await sanimationController.forward();
      await sanimationController.reverse();
    } on TickerCanceled {}
  }

  void getFilePath() async {
    FilePickerResult result =
        await FilePicker.platform.pickFiles(type: FileType.image);

    if (result.files.length > 0) {
      if (result != null) {
        PlatformFile file = result.files.first;

        setState(() {
          _filename = file.name;
          // cropImage(file);
          _filePath = file.path;
        });
      } else {
        // User canceled the picker
      }
    } else {
      SweetAlert.show(context,
          subtitle: "Unable to process this image. Kindly select another image",
          confirmButtonColor: Color(0xFFF28C00),
          style: SweetAlertStyle.error);
    }
  }

  // void getMultipleFilePath() async {
  //   List<XFile> picked = await imagePicker.pickMultiImage();
  //   setState(() {
  //     multipleImages = picked.map((e) => File(e.path)).toList();
  //   });
  // }

  // void cropImage(file) async {
  //   File croppedFile = await ImageCropper().cropImage(
  //       sourcePath: file.path,
  //       aspectRatioPresets: Platform.isAndroid
  //           ? [
  //               CropAspectRatioPreset.square,
  //               CropAspectRatioPreset.ratio3x2,
  //               CropAspectRatioPreset.original,
  //               CropAspectRatioPreset.ratio4x3,
  //               CropAspectRatioPreset.ratio16x9
  //             ]
  //           : [
  //               CropAspectRatioPreset.original,
  //               CropAspectRatioPreset.square,
  //               CropAspectRatioPreset.ratio3x2,
  //               CropAspectRatioPreset.ratio4x3,
  //               CropAspectRatioPreset.ratio5x3,
  //               CropAspectRatioPreset.ratio5x4,
  //               CropAspectRatioPreset.ratio7x5,
  //               CropAspectRatioPreset.ratio16x9
  //             ],
  //       androidUiSettings: AndroidUiSettings(
  //           toolbarTitle: 'Cropper',
  //           toolbarColor: Color(0xFFF28C00),
  //           toolbarWidgetColor: Colors.white,
  //           initAspectRatio: CropAspectRatioPreset.original,
  //           lockAspectRatio: false),
  //       iosUiSettings: IOSUiSettings(
  //         title: 'Cropper',
  //       ));

  //   if (croppedFile != null) {
  //     // imageFile = croppedFile;
  //     setState(() {
  //       _image = croppedFile;
  //       _filePath = croppedFile.path;
  //     });
  //   }
  // }

  void getImage() async {
    XFile file = await imagePicker.pickImage(source: ImageSource.gallery);

    if (file != null) {
      setState(() {
        // cropImage(file);
      });
    }
  }

  void takeImage() async {
    XFile file = await imagePicker.pickImage(
        source: ImageSource.camera, imageQuality: 30);
    if (file != null) {
      setState(() {
        // cropImage(file);
      });
    }
  }

  addProduct(context) async {
    setState(() {
      _loading = true;
    });
    var user = storage.getItem("user");
    if (_formKey.currentState?.validate()) {
      Map<String, String> headers = {"Content-Type": "multipart/form-data"};
      var request = http.MultipartRequest(
          'POST', Uri.parse(Api.httpBaseURL + Api.product_store));
      request.headers.addAll(headers);
      request.fields['appkey'] = Api.appkey;
      request.fields['title'] = title;
      request.fields['product_sku'] = sku;
      request.fields['price'] = price;
      request.fields['discounted_price'] = discounted;
      request.fields['category'] = category;
      request.fields['merchant'] = user['id'].toString();

      List<MultipartFile> newList = new List<MultipartFile>();
      for (int i = 0; i < multipleImages.length; i++) {
        File imageFile = File(multipleImages[i].path);
        var stream = File(imageFile.path).readAsBytes().asStream();
        var length = File(imageFile.path).lengthSync();
        var multipartFile = new http.MultipartFile(
            "uploadfiles[]", stream, length,
            filename: imageFile.path.split("/").last);
        newList.add(multipartFile);
      }
      request.files.addAll(newList);

      // request.files.add(http.MultipartFile(
      //     'uploadfiles',
      //     File(_filePath).readAsBytes().asStream(),
      //     File(_filePath).lengthSync(),
      //     filename: _filePath.split("/").last));

      var res = await request.send();
      var responseData = await res.stream.toBytes();
      var responseString = String.fromCharCodes(responseData);

      var data = jsonDecode(responseString);

      var message = data['msg'];
      var error = data['error'];

      setState(() {
        _loading = false;
      });
      if (error == 0) {
        // storage.setItem("user", data['user']);
        _showDialog(message, 1, true);
        // setState(() {
        //   tap = 1;
        // });
        // new LoginAnimation(
        //   animationController: sanimationController.view,
        // );
        // _PlayAnimation();
        // return tap;
      } else {
        _showDialog(context, message, error);
      }
    }
  }

  _showDialog(dynamic message, dynamic messageType, bool isFinal) {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return SimpleDialog(
            children: <Widget>[
              Container(
                padding: EdgeInsets.only(top: 30.0, right: 60.0, left: 60.0),
                height: 110.0,
                decoration: BoxDecoration(
                    color: Colors.white,
                    image: DecorationImage(
                        image:
                            (messageType.runtimeType == int && messageType > 0)
                                ? AssetImage("assets/img/success.png")
                                : AssetImage("assets/img/error.png"),
                        fit: BoxFit.contain)),
              ),
              Center(
                  child: Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Text(
                  (messageType.runtimeType == int && messageType > 0)
                      ? "Success"
                      : "Error",
                  style: _txtCustomHead,
                ),
              )),
              Center(
                  child: Padding(
                padding: const EdgeInsets.only(
                    top: 10.0, bottom: 20.0, left: 20.0, right: 20.0),
                child: Text(
                  message,
                  style: _txtCustomSub,
                ),
              )),
              Center(
                  child: Padding(
                padding: const EdgeInsets.only(
                    top: 15.0, bottom: 10.0, left: 20.0, right: 20.0),
                child: InkWell(
                  onTap: () {
                    Navigator.pop(context, 'Lost');
                    if (isFinal) {
                      _formKey.currentState.reset();
                      // city_title = category = null;
                      setState(() {
                        titleController.clear();
                        productSkuController.clear();
                        priceController.clear();
                        discountedController.clear();
                        city_title = category = null;
                      });
                    }
                  },
                  child: Text(
                    "OK",
                  ),
                ),
              ))
            ],
          );
        });
  }

  /// Component Widget layout UI
  @override
  Widget build(BuildContext context) {
    // MediaQueryData mediaQueryData = MediaQuery.of(context);
    // mediaQueryData.devicePixelRatio;
    // mediaQueryData.size.height;
    // mediaQueryData.size.width;
    MediaQueryData mediaQueryData = MediaQuery.of(context);
    double size = mediaQueryData.size.height;
    double width = mediaQueryData.size.width;
    FocusScopeNode node = FocusScope.of(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Api.primaryColor,
        centerTitle: true,
        title: Text(
          'Add Product',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: LoadingOverlay(
          isLoading: _loading,
          progressIndicator: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Api.primaryColor),
          ),
          child: GestureDetector(
            onTap: () {
              FocusScopeNode currentFocus = FocusScope.of(context);
              if (!currentFocus.hasPrimaryFocus) {
                currentFocus.unfocus();
              }
            },
            child: Stack(
              children: <Widget>[
                Container(
                  child: Container(
                    /// Set component layout
                    child: ListView(
                      padding: EdgeInsets.all(0.0),
                      children: <Widget>[
                        Form(
                          key: _formKey,
                          child: Stack(
                            alignment: AlignmentDirectional.bottomCenter,
                            children: <Widget>[
                              Column(
                                children: <Widget>[
                                  Container(
                                    alignment: AlignmentDirectional.topCenter,
                                    child: Column(
                                      children: <Widget>[
                                        Padding(
                                            padding: EdgeInsets.symmetric(
                                          vertical: 20.0,
                                        )),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 10, horizontal: 15),
                                          child: Container(
                                              height: 100,
                                              width: 350,
                                              child: FDottedLine(
                                                color: Colors.grey,
                                                strokeWidth: 2.0,
                                                dottedLength: 10.0,
                                                space: 2.0,
                                                corner:
                                                    FDottedLineCorner.all(20),
                                                child: InkWell(
                                                  onTap: () {
                                                    // getFilePath();
                                                    showModalBottomSheet(
                                                      context: context,
                                                      builder: (context) =>
                                                          Container(
                                                        height: 150,
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceEvenly,
                                                          children: [
                                                            Column(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .center,
                                                              children: [
                                                                InkWell(
                                                                  onTap:
                                                                      () async {
                                                                    List<XFile>
                                                                        picked =
                                                                        await imagePicker
                                                                            .pickMultiImage();
                                                                    setState(
                                                                        () {
                                                                      multipleImages = picked
                                                                          .map((e) =>
                                                                              File(e.path))
                                                                          .toList();
                                                                    });
                                                                    // getImage();
                                                                    // Navigator.of(
                                                                    //         context)
                                                                    //     .pop();
                                                                  },
                                                                  child:
                                                                      Container(
                                                                    height: 70,
                                                                    width: 70,
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      color: Theme.of(
                                                                              context)
                                                                          .dividerColor,
                                                                      border: Border.all(
                                                                          color: Theme.of(context)
                                                                              .dividerColor,
                                                                          width:
                                                                              2.5),
                                                                      shape: BoxShape
                                                                          .circle,
                                                                    ),
                                                                    child:
                                                                        Center(
                                                                      child:
                                                                          Icon(
                                                                        Icons
                                                                            .photo_library,
                                                                        size:
                                                                            30,
                                                                        color: Colors
                                                                            .white,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                                Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                              .all(
                                                                          8.0),
                                                                  child: Text(
                                                                      "Choose Image"),
                                                                ),
                                                              ],
                                                            ),
                                                            Column(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .center,
                                                              children: [
                                                                InkWell(
                                                                  onTap: () {
                                                                    takeImage();
                                                                    Navigator.of(
                                                                            context)
                                                                        .pop();
                                                                  },
                                                                  child:
                                                                      Container(
                                                                    height: 70,
                                                                    width: 70,
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      color: Theme.of(
                                                                              context)
                                                                          .dividerColor,
                                                                      border: Border.all(
                                                                          color: Theme.of(context)
                                                                              .dividerColor,
                                                                          width:
                                                                              2.5),
                                                                      shape: BoxShape
                                                                          .circle,
                                                                    ),
                                                                    child:
                                                                        Center(
                                                                      child:
                                                                          Icon(
                                                                        Icons
                                                                            .photo_camera,
                                                                        size:
                                                                            30,
                                                                        color: Colors
                                                                            .white,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                                Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                              .all(
                                                                          8.0),
                                                                  child: Text(
                                                                      "Take Image"),
                                                                ),
                                                              ],
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      enableDrag: false,
                                                    );
                                                  },
                                                  child: multipleImages.length >
                                                          0
                                                      ? Column(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          children: [
                                                            Container(
                                                              height: 100,
                                                              width: 350,
                                                              child: ClipRRect(
                                                                child: Center(
                                                                  child: Text(
                                                                      '${multipleImages.length} images selected'),
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        )
                                                      : Column(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          children: [
                                                            Container(
                                                              child: Icon(
                                                                Icons
                                                                    .upload_sharp,
                                                                size: 30.0,
                                                              ),
                                                            ),
                                                            Container(
                                                              alignment:
                                                                  Alignment
                                                                      .center,
                                                              child: Text(
                                                                "Upload Images",
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        14),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                ),
                                              )),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 30.0),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                'Category',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                ),
                                              ),
                                              Text(
                                                'قسم',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 30.0),
                                          child: Container(
                                            // width: width * 0.8,
                                            decoration: BoxDecoration(
                                              color: Color(0xFFFFFFFF),
                                            ),
                                            child: DropdownSearch<String>(
                                              selectedItem: city_title,
                                              // dropdownDecoratorProps:
                                              //     DropDownDecoratorProps(
                                              //   border: OutlineInputBorder(),
                                              //   focusedBorder:
                                              //       OutlineInputBorder(
                                              //     borderSide: const BorderSide(
                                              //         color: Color(0xFFF28C00)),
                                              //   ),
                                              // ),
                                              // mode: Mode.BOTTOM_SHEET,
                                              // items: cities_title,
                                              // hint: "Select One",
                                              // onChanged: (value) {
                                              //   var index =
                                              //       cities_title.indexOf(value);
                                              //   setState(() {
                                              //     category = cities_id[index];
                                              //     city_title = value;
                                              //   });
                                              // },
                                              // showSearchBox: true,
                                            ),
                                          ),
                                        ),
                                        Padding(
                                            padding: EdgeInsets.symmetric(
                                                vertical: 5.0)),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 30.0),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                'Title',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                ),
                                              ),
                                              Text(
                                                'دکھانے کا نام',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 30.0),
                                          child: TextFormField(
                                            controller: titleController,
                                            onEditingComplete: () =>
                                                node.nextFocus(),
                                            style: TextStyle(
                                              letterSpacing: 0.3,
                                              color: Colors.black,
                                            ),
                                            decoration: const InputDecoration(
                                              errorStyle: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 13,
                                              ),
                                              fillColor: Colors.white,
                                              filled: true,
                                              focusedBorder: OutlineInputBorder(
                                                borderSide: const BorderSide(
                                                  color: Colors.black,
                                                  width: 1,
                                                ),
                                              ),
                                              enabledBorder:
                                                  const OutlineInputBorder(
                                                borderRadius: BorderRadius.all(
                                                  Radius.circular(6),
                                                ),
                                                borderSide: const BorderSide(
                                                  color: Colors.black,
                                                  width: 0.5,
                                                ),
                                              ),
                                              border:
                                                  const OutlineInputBorder(),
                                              isDense: true,
                                              contentPadding:
                                                  EdgeInsets.fromLTRB(
                                                      10, 20, 10, 0),
                                              hintText: 'Enter Your Title',
                                              hintStyle: TextStyle(
                                                fontSize: 12,
                                                color: Colors.black,
                                              ),
                                            ),
                                            validator: (value) {
                                              if (value?.isEmpty) {
                                                return "Title cannot be empty";
                                              }
                                              return null;
                                            },
                                            onChanged: (value) {
                                              title = value;
                                              setState(() {});
                                            },
                                          ),
                                        ),
                                        Padding(
                                            padding: EdgeInsets.symmetric(
                                                vertical: 5.0)),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 30.0),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                'Product Sku',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                ),
                                              ),
                                              Text(
                                                'دکھانے کا نام',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 30.0),
                                          child: TextFormField(
                                            controller: productSkuController,
                                            onEditingComplete: () =>
                                                node.nextFocus(),
                                            style: TextStyle(
                                              letterSpacing: 0.3,
                                              color: Colors.black,
                                            ),
                                            decoration: const InputDecoration(
                                              errorStyle: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 13,
                                              ),
                                              fillColor: Colors.white,
                                              filled: true,
                                              focusedBorder: OutlineInputBorder(
                                                borderSide: const BorderSide(
                                                  color: Colors.black,
                                                  width: 1,
                                                ),
                                              ),
                                              enabledBorder:
                                                  const OutlineInputBorder(
                                                borderRadius: BorderRadius.all(
                                                  Radius.circular(6),
                                                ),
                                                borderSide: const BorderSide(
                                                  color: Colors.black,
                                                  width: 0.5,
                                                ),
                                              ),
                                              border:
                                                  const OutlineInputBorder(),
                                              isDense: true,
                                              contentPadding:
                                                  EdgeInsets.fromLTRB(
                                                      10, 20, 10, 0),
                                              hintText:
                                                  'Enter Your Product Sku',
                                              hintStyle: TextStyle(
                                                fontSize: 12,
                                                color: Colors.black,
                                              ),
                                            ),
                                            validator: (value) {
                                              if (value?.isEmpty) {
                                                return "Product Sku cannot be empty";
                                              }
                                              return null;
                                            },
                                            onChanged: (value) {
                                              sku = value;
                                              setState(() {});
                                            },
                                          ),
                                        ),
                                        Padding(
                                            padding: EdgeInsets.symmetric(
                                                vertical: 5.0)),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 30.0),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                'Price',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                ),
                                              ),
                                              Text(
                                                'قیمت',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 30.0),
                                          child: TextFormField(
                                            controller: priceController,
                                            onEditingComplete: () =>
                                                node.nextFocus(),
                                            style: TextStyle(
                                              letterSpacing: 0.3,
                                              color: Colors.black,
                                            ),
                                            decoration: const InputDecoration(
                                              errorStyle: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 13,
                                              ),
                                              fillColor: Colors.white,
                                              filled: true,
                                              focusedBorder: OutlineInputBorder(
                                                borderSide: const BorderSide(
                                                  color: Colors.black,
                                                  width: 1,
                                                ),
                                              ),
                                              enabledBorder:
                                                  const OutlineInputBorder(
                                                borderRadius: BorderRadius.all(
                                                  Radius.circular(6),
                                                ),
                                                borderSide: const BorderSide(
                                                  color: Colors.black,
                                                  width: 0.5,
                                                ),
                                              ),
                                              border:
                                                  const OutlineInputBorder(),
                                              isDense: true,
                                              contentPadding:
                                                  EdgeInsets.fromLTRB(
                                                      10, 20, 10, 0),
                                              hintText: 'Enter Your Price',
                                              hintStyle: TextStyle(
                                                fontSize: 12,
                                                color: Colors.black,
                                              ),
                                            ),
                                            validator: (value) {
                                              if (value?.isEmpty) {
                                                return "Price cannot be empty";
                                              }
                                              return null;
                                            },
                                            keyboardType: TextInputType.number,
                                            onChanged: (value) {
                                              price = value;
                                              setState(() {});
                                            },
                                          ),
                                        ),
                                        Padding(
                                            padding: EdgeInsets.symmetric(
                                                vertical: 5.0)),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 30.0),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                'Discounted Price',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                ),
                                              ),
                                              Text(
                                                'رعایتی قیمت',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 30.0),
                                          child: TextFormField(
                                            controller: discountedController,
                                            onEditingComplete: () =>
                                                node.nextFocus(),
                                            style: TextStyle(
                                              letterSpacing: 0.3,
                                              color: Colors.black,
                                            ),
                                            decoration: const InputDecoration(
                                              errorStyle: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 13,
                                              ),
                                              fillColor: Colors.white,
                                              filled: true,
                                              focusedBorder: OutlineInputBorder(
                                                borderSide: const BorderSide(
                                                  color: Colors.black,
                                                  width: 1,
                                                ),
                                              ),
                                              enabledBorder:
                                                  const OutlineInputBorder(
                                                borderRadius: BorderRadius.all(
                                                  Radius.circular(6),
                                                ),
                                                borderSide: const BorderSide(
                                                  color: Colors.black,
                                                  width: 0.5,
                                                ),
                                              ),
                                              border:
                                                  const OutlineInputBorder(),
                                              isDense: true,
                                              contentPadding:
                                                  EdgeInsets.fromLTRB(
                                                      10, 20, 10, 0),
                                              hintText:
                                                  'Enter Your Discounted Price',
                                              hintStyle: TextStyle(
                                                fontSize: 12,
                                                color: Colors.black,
                                              ),
                                            ),
                                            validator: (value) {
                                              if (value?.isEmpty) {
                                                return "Discounted Price cannot be empty";
                                              }
                                              return null;
                                            },
                                            keyboardType: TextInputType.number,
                                            onChanged: (value) {
                                              discounted = value;
                                              setState(() {});
                                            },
                                          ),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.only(
                                              top: mediaQueryData.padding.top +
                                                  100.0,
                                              bottom: 0.0),
                                        )
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              tap == 0
                                  ? InkWell(
                                      splashColor: Colors.yellow,
                                      onTap: () {
                                        addProduct(context);
                                      },
                                      child: buttonBlackBottom(),
                                    )
                                  : new LoginAnimation(
                                      animationController:
                                          sanimationController.view,
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
      ),
    );
  }
}

/// textfromfield custom class
class textFromField extends StatelessWidget {
  bool password;
  String email;
  IconData icon;
  TextInputType inputType;

  textFromField({this.email, this.icon, this.inputType, this.password});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 30.0),
      child: Container(
        height: 60.0,
        alignment: AlignmentDirectional.center,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14.0),
            color: Colors.white,
            boxShadow: [BoxShadow(blurRadius: 10.0, color: Colors.black12)]),
        padding:
            EdgeInsets.only(left: 20.0, right: 30.0, top: 0.0, bottom: 0.0),
        child: Theme(
          data: ThemeData(
            hintColor: Colors.transparent,
          ),
          child: TextFormField(
            obscureText: password,
            decoration: InputDecoration(
                border: InputBorder.none,
                labelText: email,
                icon: Icon(
                  icon,
                  color: Colors.black38,
                ),
                labelStyle: TextStyle(
                    fontSize: 15.0,
                    fontFamily: 'Sans',
                    letterSpacing: 0.3,
                    color: Colors.black38,
                    fontWeight: FontWeight.w600)),
            keyboardType: inputType,
          ),
        ),
      ),
    );
  }
}

///ButtonBlack class
class buttonBlackBottom extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(30.0),
      child: Container(
        height: 55.0,
        width: 600.0,
        child: Text(
          "Save Product",
          style: TextStyle(
              color: Colors.white,
              letterSpacing: 0.2,
              fontFamily: "Sans",
              fontSize: 18.0,
              fontWeight: FontWeight.w800),
        ),
        alignment: FractionalOffset.center,
        decoration: BoxDecoration(
            boxShadow: [BoxShadow(color: Colors.black38, blurRadius: 15.0)],
            borderRadius: BorderRadius.circular(30.0),
            color: Api.primaryColor),
      ),
    );
  }
}

/// Custom Text Header for Dialog after user succes payment
var _txtCustomHead = TextStyle(
  color: Colors.black54,
  fontSize: 23.0,
  fontWeight: FontWeight.w600,
  fontFamily: "Gotik",
);

/// Custom Text Description for Dialog after user succes payment
var _txtCustomSub = TextStyle(
  color: Colors.black38,
  fontSize: 15.0,
  fontWeight: FontWeight.w500,
  fontFamily: "Gotik",
);

/// Card Popup if success payment
_showDialog(BuildContext ctx, dynamic message, dynamic messageType) {
  showDialog(
    context: ctx,
    barrierDismissible: true,
    builder: (_) => new SimpleDialog(
      children: <Widget>[
        Container(
          padding: EdgeInsets.only(top: 30.0, right: 60.0, left: 60.0),
          height: 110.0,
          decoration: BoxDecoration(
              color: Colors.white,
              image: DecorationImage(
                  image: AssetImage("assets/img/error.png"),
                  fit: BoxFit.contain)),
        ),
        Center(
            child: Padding(
          padding: const EdgeInsets.only(top: 16.0),
          child: Text(
            "Error",
            style: _txtCustomHead,
          ),
        )),
        Center(
            child: Padding(
          padding: const EdgeInsets.only(
              top: 10.0, bottom: 40.0, left: 20.0, right: 20.0),
          child: Text(
            message,
            style: _txtCustomSub,
          ),
        )),
      ],
    ),
  );
}
