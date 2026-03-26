// To parse this JSON data, do
//
//     final registerResponseModel = registerResponseModelFromJson(jsonString);

import 'dart:convert';

RegisterResponseModel registerResponseModelFromJson(String str) => RegisterResponseModel.fromJson(json.decode(str));

String registerResponseModelToJson(RegisterResponseModel data) => json.encode(data.toJson());

class RegisterResponseModel {
  RegisterResponseModel({
    this.responseCode,
    this.responseMessage,
    this.respRef,
  });

  final int? responseCode;
  final String? responseMessage;
  final String? respRef;

  factory RegisterResponseModel.fromJson(Map<String, dynamic> json) => RegisterResponseModel(
    responseCode: json["responseCode"],
    responseMessage: json["responseMessage"],
    respRef: json["respRef"],
  );

  Map<String, dynamic> toJson() => {
    "responseCode": responseCode,
    "responseMessage": responseMessage,
    "respRef": respRef,
  };
}
