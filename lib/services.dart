


import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:uje/constants/constants.dart';
import 'package:flutter/material.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:http/http.dart' as http;
import 'Home_Screen.dart';
import 'constants/error_handling.dart';
import 'constants/ui_constants.dart';
import 'model/register_model.dart';
import 'model/register_response.dart';


register(BuildContext context, RegisterModel model) async {
  String api = '$baseApiUrl/register';
  try{
    final response = await http.post(
      Uri.parse(api),
      body: {
        "ShareholderNumber": model.shareholderNumber,
        "RegAction": "Register",
        "MobileNumber": model.mobileNumber,
        "TIN": model.tin,
        "Bank": model.bank,
        "BankAccountNumber": model.accountNumber,
      },
    );
    var responseJson = json.decode(response.body);
    httpErrorHandler(
        response: response,
        context: context,
        onSuccess: (){
          showToast(context, responseJson[0]['responseMessage']);
          Navigator.push(context, MaterialPageRoute(builder: (context)=> HomeScreen()));
        });

  } catch(e){
    context.loaderOverlay.hide();
    debugPrint(e.toString());
  }
}

Future<String> confirmName(BuildContext context, String shareholderNumber) async {
  String api = '$baseApiUrl/register';
  String shareholderName = "";
  try {
    final response = await http.post(
      Uri.parse(api),
      body: {
        "ShareholderNumber": shareholderNumber,
        "RegAction": "GetDetails"
      },

    );
    httpErrorHandler(
        response: response,
        context: context,
        onSuccess: () {
          List data = jsonDecode(response.body);
          for(Map<String, dynamic> i in data){
            RegisterResponseModel model = RegisterResponseModel.fromJson(i);
            shareholderName = model.responseMessage!;
          }
        });
  } catch(e){
    context.loaderOverlay.hide();
    debugPrint("ERROR: " + e.toString());
    showToast(context, "Something went wrong, please try again later.");
  }
  return shareholderName;
}

Future<String> checkName(String shareholderNumber, BuildContext context) async{
  Dio dio = Dio();
  try{
    final response = await dio.post("$baseApiUrl/register",
        data: {
          "ShareholderNumber": shareholderNumber,
          "RegAction": "GetDetails"
        },
        options: Options(
            headers: {
              "content-type": "application/json"
            }
        )
    );
    context.loaderOverlay.hide();
    if(response.statusCode == HttpStatus.ok){
      if(response.data[0]["responseCode"] == 0){
        RegisterResponseModel model = RegisterResponseModel.fromJson(response.data[0]);
        String shareholderName = model.responseMessage!;

        return shareholderName;
      } else {
        return response.data[0]["responseMessage"];
      }
    } else return "An error occurred, please try again later";
  } catch(e){
    debugPrint(e.toString());
    rethrow;
  }
}


Future<List<String>> getBanks(BuildContext context) async {
  List<String> bankNames = ["Bank"];
  try{
    final uri = Uri.parse("$baseApiUrl/getBanksList");
    final response = await http.get(uri);
    var data = jsonDecode(response.body);
    for(String element in data){
      bankNames.add(element);
    }

    banks.addAll(bankNames);
    debugPrint("banks retrieved");
    return bankNames;
  } catch(e){
    debugPrint(e.toString());
    rethrow;
  }
}

Future<List<String>> fetchBanks() async {
  final Dio _dio = Dio();
  try{

    final url = "$baseApiUrl/getBanksList";

    final response = await _dio.get(url, options: Options(headers: {
      "content-type": "application/json"
    }));

    if(response.statusCode == HttpStatus.ok){
      List<String> bankNames = [];
      for (int i =0; i< response.data.length; i++){
        bankNames.add(response.data[i]);
      }
      banks.addAll(bankNames);
      return bankNames;
    } else return ["Failed to get banks"];
  } catch(e){
    debugPrint(e.toString());
  }
  return ["Failed to get banks"];
}

Future<void> submitVote(BuildContext context, String cdsNumber, String resolutionNumber) async {
  final url = Uri.parse("$baseApiUrl/SubmitVote");
  final body = {
    "CDSNo": cdsNumber,
    "ResolutionNumber": resolutionNumber
  };
  
  final response = await http.post(url, body: body);

  httpErrorHandler(response: response,
      context: context,
      onSuccess: (){
        context.loaderOverlay.hide();
        debugPrint(response.body);
        final responseJson = jsonDecode(response.body);
        if(responseJson[0]["responseCode"] == 0){
          showToast(context, responseJson[0]["responseMessage"]);
          Navigator.pop(context);
        } else{
          showToast(context, responseJson[0]["responseMessage"]);
        }
      });
}

Future<String> postProxyName(String proxyName, String proxyType, String phone,
    String shareholderProxyCDS, BuildContext context) async {
  String proxyNumber = "";
  String proxyNameUrl =
      "$baseApiUrl/CommitProxyRegistration";

  final response = await http.post(
    Uri.parse(proxyNameUrl),
    body: {
      "ProxyName": proxyName,
      "ProxyType": proxyType,
      "MobileNumber": phone,
      "ShareholderProxyCDS": shareholderProxyCDS
    },
  );
  httpErrorHandler(response: response,
      context: context,
      onSuccess: (){
        final responseJson = json.decode(response.body);
        debugPrint("$responseJson");
        if(responseJson[0]["respRef"].toString() != ""){
          proxyNumber = responseJson[0]["respRef"].toString();
          showToast(context, responseJson[0]["responseMessage"]);
        } else {
          showToast(context, responseJson[0]["responseMessage"]);
        }
      });

  return proxyNumber;
}
