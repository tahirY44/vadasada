import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Api {
  static const Color primaryColor = Colors.black87;
  static const Color secondaryColor = Colors.white;
  static const Color thirdColor = Color(0xFFF37A20);
  static const String appkey = "2be110c443545ffa93ca41dc7d87af67";
  static const String baseURl = "www.new.vadasada.com";
  static const String httpBaseURL = "https://www.new.vadasada.com/";
  static const String baseImageURL = "https://www.new.vadasada.com/images";
  static const String login = "/app_services_new/get_login";
  static const String logout = "/app_services_new/get_logout";
  static const String signup = "/app_services_new/get_register";
  static const String register_fb = "/app_services_new/get_register_fb";
  static const String get_cities = "/app_services_new/get_cities";
  static const String signup_merchant =
      "/app_services_new/get_register_merchant";
  static const String merchants_product_listings =
      "/app_services_new/get_merhcnats_products";
  static const String product_store = "/app_services_new/product_store";
  static const String product_update = "/app_services_new/product_update";
  static const String menu_category = "/app_services_new/get_category_tree";
  static const String home_content = "/app_services_new/get_home_page_contents";
  static const String product_content = "/app_services_new/get_product_by_id";
  static const String category_product_content =
      "/app_services_new/get_category_data";
  static const String category_product_related =
      "/app_services_new/get_related_products_category";
  static const String brand_product_content =
      "/app_services_new/get_brand_data";
  static const String brand_product_related =
      "/app_services_new/get_products_by_brand";
  static const String search_product =
      "/app_services_new/get_search_result_new";
  static const String payment_methods = "/app_services_new/get_payment_method";
  static const String inquiry_type = "/app_services_new/get_inquiry_type";
  static const String store_info = "/app_services_new/get_store_info";
  static const String apply_coupon = "/app_services_new/get_coupon";
  static const String store_fcm_token = "/app_services_new/store_fcm_token";
  static const String submit_order = "/app_services_new/submit_order_ionic";
  static const String static_page = "/app_services_new/get_page";
  static const String contact_us = "/app_services_new/send_contactus_message";
  static const String user_orders = "/app_services_new/get_user_order";
  static const String reorder = "/app_services_new/reorder";
  static const String order_summary = "/app_services_new/get_order_summary";
  static const String update_password =
      "/app_services_new/update_user_password";
  static const String update_profile = "/app_services_new/update_user_profile";
  static const String add_to_wishlist = "/app_services_new/add_to_wishlist";
  static const String user_wishlist = "/app_services_new/get_user_wishlist";
  static const String get_products_by_category =
      "/app_services_new/get_products_by_category";

  static const String active_version = "/app_services_new/get_active_version";
  // static const String play_store_link =
  // "https://play.google.com/store/apps/details?id=pk.com.hamzastore&hl=en";
  // static const String app_store_link =
  //     "itms-apps://apps.apple.com/us/app/id1544078203?mt=8";
  static const String delete_wishlist =
      "/app_services_new/remove_from_wishlist";
  static const String upload_prescription =
      "/app_services_new/upload_prescription";
  static const String forgot_password = "/app_services_new/forgot_password";

  static Future<List> getApiDataArray(api, cond, parameter) async {
    try {
      var parameters;
      if (parameter == null) {
        parameters = {'appkey': Api.appkey};
      } else {
        parameters = parameter;
      }
      final uri = Uri.https(baseURl, api, parameters);
      var data;
      http.Response response = await http.get(uri);
      data = json.decode(response.body);
      if (cond == 1) {
        return [data];
      } else {
        return data;
      }
    } catch (err) {}
    //  final items item;
  }

  static Future<http.Response> getRequest(api, parameters) async {
    // try {
    var parameter;
    if (parameters == null) {
      parameter = {'appkey': appkey};
    } else {
      parameter = parameters;
    }
    // print(parameter);
    final uri = Uri.https(baseURl, api, parameter);
    // print(uri);
    var response = await http.get(uri);
    return response;
    // } catch (err) {}
  }

  static Future<http.Response> postRequest(api, form) async {
    var body = json.encode(form);
    // print(httpBaseURL);
    var response = await http.post(Uri.parse(httpBaseURL + api),
        headers: {"Content-Type": "application/json"}, body: body);
    return response;
  }

  static Future<http.Response> postImageRequest(api, form) async {
    var body = form;
    var response = await http.post(Uri.parse(httpBaseURL + api), body: body);
    return response;
  }
}
