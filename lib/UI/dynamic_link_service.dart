import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';

FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;

class FirebaseDynamicLinkService {
  static Future<String> createDynamicLink(bool short, storyData) async {
    String _linkMessage;

    final DynamicLinkParameters parameters = DynamicLinkParameters(
      uriPrefix: 'Write your uriPrefix here',
      link: Uri.parse('Link you want to parse'),
      androidParameters: AndroidParameters(
        packageName: 'your package name',
        minimumVersion: 125,
      ),
    );

    Uri url;
    if (short) {
      final Uri shortLink = await parameters.link;
      url = shortLink;
    } else {
      url = await parameters.link;
    }

    _linkMessage = url.toString();
    return _linkMessage;
  }

  static Future<void> initDynamicLink(BuildContext context) async {
    FirebaseDynamicLinks.instance.onLink.listen((dynamicLinkData) {
      final Uri deepLink = dynamicLinkData.link;
      var isStory = deepLink.pathSegments.contains('storyData');
      // TODO :Modify Accordingly
      if (isStory) {
        String id = deepLink.queryParameters['id'];
        // TODO :Modify Accordingly
        if (deepLink != null) {
          // TODO : Navigate to your pages accordingly here
        } else {
          return null;
        }
      }
    }).onError((error) {
      print('link error');
    });

    final PendingDynamicLinkData data =
        await FirebaseDynamicLinks.instance.getInitialLink();
    try {
      final Uri deepLink = data.link;
      var isStory = deepLink.pathSegments.contains('storyData');
      if (isStory) {
        // TODO :Modify Accordingly
        String id = deepLink.queryParameters['id']; // TODO :Modify Accordingly
        // TODO : Navigate to your pages accordingly here
      }
    } catch (e) {
      print('No deepLink found');
    }
  }
}
