import 'dart:convert';

import 'package:uje/constants/ui_constants.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:loader_overlay/loader_overlay.dart';

void httpErrorHandler(
    {required http.Response response,
    required BuildContext context,
    required VoidCallback onSuccess}) {
  switch (response.statusCode) {
    case 200:
      context.loaderOverlay.hide();
      onSuccess();
      break;
    case 400:
      context.loaderOverlay.hide();
      debugPrint(jsonDecode(response.body).toString());
      showToast(
          context,
          jsonDecode(response.body)['message'] ??
              "An error occurred, please try again later.");
      break;
    case 500:
      context.loaderOverlay.hide();
      debugPrint(jsonDecode(response.body).toString());
      showToast(context, "An error occurred, please try again later.");
      break;
    default:
      debugPrint(response.body);
      // showConnectionErrorToast(context);
  }
}
