
import 'package:flutter/material.dart';

// String baseApiUrl = "https://cregtest.crdbbank.co.tz/AppAPI/Home";



String baseApiUrl = "https://creg.crdbbank.co.tz/APPAPI/Home";
//String baseApiUrl = "https://cregtest.crdbbank.co.tz/APPAPI/Home";

List<String> banks = [];

Size screenSize(BuildContext context) {
  return MediaQuery.of(context).size;
}

double screenHeight(BuildContext context, {double dividedBy = 1}) {
  return screenSize(context).height / dividedBy;
}
double screenWidth(BuildContext context, {double dividedBy = 1}) {
  return screenSize(context).width / dividedBy;
}
