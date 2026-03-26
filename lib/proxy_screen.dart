import 'dart:convert';
import 'package:uje/services.dart';
import 'package:uje/constants/ui_constants.dart';
import 'package:uje/model/proxy_shareholder_add.dart';
import 'package:uje/services.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:loader_overlay/loader_overlay.dart';

import 'constants/constants.dart';

class ProxyPage extends StatefulWidget {
  const ProxyPage({Key? key}) : super(key: key);

  @override
  State<ProxyPage> createState() => _ProxyPageState();
}

class _ProxyPageState extends State<ProxyPage> {
  TextEditingController cdsNumberController = TextEditingController();
  TextEditingController shareHolderController = TextEditingController();
  TextEditingController proxyNameController = TextEditingController();
  TextEditingController postShareholderCdsController = TextEditingController();
  TextEditingController proxyNumberController = TextEditingController();

  TextEditingController controller = TextEditingController();
  TextEditingController mobileNumberController = TextEditingController();
  final GlobalKey<FormState> registrationKey2 = GlobalKey<FormState>();
  late TextEditingController tinNumberController;
  late TextEditingController bankController;
  late TextEditingController accountNumberController;

  bool isShareholder = false;
  String bankName = "Bank";
  String shareholderNumber = "";
  String cdsNo = "";
  String proxyName = "";
  String registrationStatus = "";
  String voteCode = "";
  String voterName = "";
  String voterCodeString = "";
  String shareholderProxyName = "";
  String proxyNumber = "";
  String proxyType = "";
  String shareholderProxyCDS = "";
  String phoneNumber = "";


  shareholderName(String cdsNo) async {
    debugPrint("ShareHolderNumber is $cdsNo");
    final response = await http.post(
      Uri.parse("$baseApiUrl/register"),
      body: {"ShareholderNumber": cdsNo, "RegAction": "GetDetails"},
    );
    final responseJson = json.decode(response.body);

    setState(() {
      shareHolderController.text = responseJson[0]["responseMessage"].toString();
    });

    context.loaderOverlay.hide();
  }



  Future<void> _showProxyNumberDialog(
      BuildContext context, String proxyNumber) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Your Proxy Number is :"),
          content: SizedBox(
            height: 200,
            width: 300,
            child: Center(
                child: Text(
              proxyNumber,
              style: TextStyle(fontSize: 17, color: Colors.red),
            )),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  addProxyShareholders(AddProxyShareholderModel model) async {
    String api = '$baseApiUrl/ADDProxyShareholders';
    final response = await http.post(
      Uri.parse(api),
      body: {
        "CDSNo": model.cdsNo,
        "ProxyName": model.proxyName,
        "MobileNumber": model.mobileNumber,
        "TIN": model.tin,
        "Bank": model.bank,
        "BankAccountNumber": model.accountNumber,
      },
    );
    var responseJson = json.decode(response.body);
    if (response.statusCode == 200) {
      if(responseJson[0]["responseCode"] == 0){
        setState(() {
          data.add(shareHolderController.text);
          cdsNumbers.add(cdsNo);
          cdsNumberController.text = "";
          shareHolderController.text = "";
          tinNumberController.text = "";
          accountNumberController.text = "";
          bankName = "Bank";
          mobileNumberController.text = "";
        });
        showToast(context, responseJson[0]["responseMessage"]);
      } else{
        showToast(context, responseJson[0]["responseMessage"]);
      }
      // if (responseJson[0]["responseCode"] == 4) {
      //   showToast(context, "${responseJson[0]["responseMessage"]}");
      //   return responseJson[0]["responseMessage"].toString();
      // } else if (responseJson[0]["responseCode"] == 2) {
      //   debugPrint(responseJson[0]["responseMessage"]);
      //   showToast(context, "${responseJson[0]["responseMessage"]}");
      //   setState(() {
      //     registrationStatus = responseJson[0]["responseMessage"].toString();
      //   });
      //   return responseJson[0]["responseMessage"].toString();
      // }
    } else {
      showToast(context, responseJson[0]["responseMessage"]);
    }
  }


  confirmName(String shareholderNumber) async {
    String nameConfirmUrl =
        '$baseApiUrl/RegisterGetDetailsProxy';

    debugPrint("ShareHolderNumber is $shareholderNumber");
    Map data = {
      "ShareholderNumber": shareholderNumber,
      "RegAction": "GetDetails"
    };

    final response = await http.post(
      Uri.parse(nameConfirmUrl),
      body: data,
    );
    final responseJson = json.decode(response.body);
    setState(() {
      voterName = responseJson[0]["responseMessage"].toString();
      shareHolderController.text = voterName;
      cdsNumberController.text = shareholderNumber;
      proxyNameController.text = voterName;
    });
    context.loaderOverlay.hide();
  }

  @override
  void initState() {
    super.initState();
    cdsNumberController.addListener(() {
      cdsNo = cdsNumberController.text;
    });
    proxyNameController.addListener(() {
      proxyName = proxyNameController.text;
    });
    proxyNumberController.addListener(() {
      if(isShareholder) {
        mobileNumberController.text = proxyNumberController.text;
      }
      phoneNumber = proxyNumberController.text;

    });

    bankController = TextEditingController();
    accountNumberController = TextEditingController();
    tinNumberController = TextEditingController();
    mobileNumberController = TextEditingController();
  }

  @override
  void dispose() {
    bankController.dispose();
    controller.dispose();
    accountNumberController.dispose();
    tinNumberController.dispose();
    mobileNumberController.dispose();
    super.dispose();
  }

  final List<String> data = <String>[];
  final List<String> cdsNumbers = <String>[];

  showAlert(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: new Text('Please Enter Shareholder Name.'),
          actions: <Widget>[
            MaterialButton(
              child: new Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void addValue(AddProxyShareholderModel model) {
    if (shareHolderController.text == '') {
      showAlert(context);
    } else if (data.contains(shareHolderController.text)) {
      Fluttertoast.showToast(
        msg: "ShareHolder Already Added to the list",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.green[800],
        textColor: Colors.white,
        fontSize: 18.0,
        timeInSecForIosWeb: 3,
      );
    } else if (proxyNameController.text == '') {
      debugPrint("Please Enter Proxy Name");
      Fluttertoast.showToast(
        msg: "Please Enter Proxy Name",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.green[800],
        textColor: Colors.white,
        fontSize: 18.0,
        timeInSecForIosWeb: 3,
      );
    } else if (cdsNumberController.text == '') {
      debugPrint("Please Enter CDS Number");
      Fluttertoast.showToast(
        msg: "Please Enter CDS Number",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.green[800],
        textColor: Colors.white,
        fontSize: 18.0,
        timeInSecForIosWeb: 3,
      );
    } else if (registrationStatus == 'Missing CDSNo') {
      debugPrint("Please Enter CDSNo");
      Fluttertoast.showToast(
        msg: "Please Enter CDSNo",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.green[800],
        textColor: Colors.white,
        fontSize: 18.0,
        timeInSecForIosWeb: 3,
      );
    } else {
      // setState(() {
      //   data.add(shareHolderController.text);
      //   cdsNumbers.add(cdsNo);
      // });
      addProxyShareholders(model);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Proxy Representative"),
      ),
      body: SizedBox(
          width: screenWidth(context),
          height: screenHeight(context),
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Column(
                    children: <Widget>[
                      SizedBox(height: 10,),
                      SizedBox(
                        height: 60,
                        width: MediaQuery.of(context).size.width * 0.8,
                        child: SwitchListTile(
                          value: isShareholder,
                          onChanged: (value) {
                            setState(() {
                              isShareholder = value;
                            });
                          },
                          title: const Text(
                              'Are you a shareholder Proxy?'),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Center(
                              child: Text(
                                "Enter CDSNo.: ",
                              ),
                            ),
                          ),
                          SizedBox(width: 10,),
                          Expanded(
                            child: TextField(
                              enabled: isShareholder,
                              controller:
                                  postShareholderCdsController,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(),
                                hintText: 'CDSNo.',
                              ),
                            ),
                          ),
                        ],
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: MaterialButton(
                          color: isShareholder? Colors.green: Colors.grey,
                            child:  Text('Search',),
                            onPressed: () {
                              if(isShareholder){
                                  context.loaderOverlay.show();
                                  confirmName(
                                      postShareholderCdsController.text);
                                }
                              }),
                      ),
                      SizedBox(height: 10,),
                      Row(
                        children: [
                          Expanded(
                            child: Center(
                              child: Text(
                                "Enter Proxy Name: ",
                              ),
                            ),
                          ),
                          Expanded(
                            child: TextField(
                              controller: proxyNameController,
                              maxLines: 3,
                              decoration: InputDecoration(
                                // enabled: !isShareholder,
                                border: OutlineInputBorder(),
                                hintText: 'Proxy Name',
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10,),
                      Row(
                        children: [
                          Expanded(
                            child: Center(
                              child: Text(
                                "Enter Phone Number: ",
                              ),
                            ),
                          ),
                          Expanded(
                            child: TextField(
                              controller: proxyNumberController,
                              keyboardType:  TextInputType.number,
                              decoration: InputDecoration(
                                // enabled: !isShareholder,
                                border: OutlineInputBorder(),
                                hintText: 'Phone Number',
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10,),
                      Row(
                        children: [
                          Expanded(
                            child: Center(
                              child: Text(
                                "Add Shareholder CDSNo.: ",
                                textAlign: TextAlign.left,
                              ),
                            ),
                          ),
                          Expanded(
                            child: TextField(
                              controller: cdsNumberController,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(),
                                hintText: 'CDS No.',
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10,),
                      Align(
                        alignment: Alignment.centerRight,
                        child: MaterialButton(
                          color: Colors.green[800],
                            child: const Text('Search'),
                            onPressed: () {
                              context.loaderOverlay.show();
                              shareholderName(cdsNo);
                            }),
                      ),

                      Row(
                        children: [
                          Expanded(
                            child: Center(
                              child: Text(
                                "Shareholder's Name: ",
                              ),
                            ),
                          ),
                          Expanded(
                            child: TextField(
                              controller: shareHolderController,
                              decoration:
                              InputDecoration(hintText: 'Name'),
                              enabled: false,
                            ),
                          ),

                        ],
                      ),

                      SizedBox(
                        height: 250,
                        width: screenWidth(context),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            AnimatedContainer(
                              duration: const Duration(seconds: 2),
                              curve: Curves.bounceInOut,
                              height: 50,
                              child: TextFormField(
                                controller: tinNumberController,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  labelText: "Enter TIN No.",
                                  border:
                                  OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                                ),
                                validator: (val) {
                                  if (val == null || val.isEmpty) {
                                    return "Please enter a TIN Number";
                                  }
                                  return null;
                                },
                              ),
                            ),
                            SizedBox(
                              child: Form(
                                key: registrationKey2,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    // SizedBox(
                                    //   child: FutureBuilder(
                                    //       future: getBanks(context),
                                    //       builder: (context, AsyncSnapshot<List<String>> snapshot){
                                    //         if(snapshot.connectionState == ConnectionState.done){
                                    //           // if(snapshot.hasData){
                                    //           return Padding(
                                    //             padding: const EdgeInsets.symmetric(horizontal: 2.0),
                                    //             child: SizedBox(
                                    //               width: screenWidth(context),
                                    //               child: DropdownButtonFormField(
                                    //                 decoration: const InputDecoration(
                                    //                     filled: true),
                                    //                 value: bankName,
                                    //                 icon: const Icon(Icons.keyboard_arrow_down),
                                    //                 items: snapshot.data!.map((item) {
                                    //                   return DropdownMenuItem(
                                    //                       value: item, child: Text(item));
                                    //                 }).toList(),
                                    //                 onChanged: (String? newValue) {
                                    //                   if(newValue.toString() != bankName) {
                                    //                     setState(() {
                                    //                       bankName = newValue.toString();
                                    //                     });
                                    //                   }
                                    //                 },
                                    //               ),
                                    //             ),
                                    //           );
                                    //         }
                                    //         else{
                                    //           return  const LinearProgressIndicator();
                                    //         }
                                    //       }),
                                    // ),
                                    SizedBox(
                                      width: screenWidth(context),
                                      child: DropdownButtonFormField(
                                        decoration: const InputDecoration(
                                            filled: true),
                                        value: bankName,
                                        icon: const Icon(Icons.keyboard_arrow_down),
                                        items: banks.map((item) {
                                          return DropdownMenuItem(
                                              value: item, child: Text(item));
                                        }).toList(),
                                        onChanged: (String? newValue) {
                                          if(newValue.toString() != bankName) {
                                            setState(() {
                                              bankName = newValue.toString();
                                            });
                                          }
                                        },
                                      ),
                                    ),
                                    SizedBox(height: 10,),
                                    AnimatedContainer(
                                      duration: const Duration(seconds: 2),
                                      curve: Curves.bounceInOut,
                                      height: 50,
                                      child: TextFormField(
                                        controller: mobileNumberController,
                                        decoration: InputDecoration(
                                          labelText: "Enter Mobile No.",
                                          border:
                                          OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                                        ),
                                        validator: (val) {
                                          if (val == null || val.isEmpty) {
                                            return "Please enter a Mobile No.";
                                          }
                                          return null;
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            AnimatedContainer(
                              duration: const Duration(seconds: 2),
                              curve: Curves.bounceInOut,
                              height: 50,
                              child: TextFormField(
                                controller: accountNumberController,
                                decoration: InputDecoration(
                                  labelText: "Enter Account No.",
                                  border:
                                  OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                                ),
                                validator: (val) {
                                  if (val == null || val.isEmpty) {
                                    return "Please enter a Account Number";
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                      ),

                      Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Container(
                            // margin:
                            // const EdgeInsets.fromLTRB(47, 25, 9, 10),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green[800],
                                textStyle: TextStyle(fontSize: 20),
                              ),
                              child: Text(
                                '+',
                              ),
                              onPressed: () {
                                if(registrationKey2.currentState!.validate()){
                                  AddProxyShareholderModel model = AddProxyShareholderModel(
                                      cdsNumberController.text, proxyNameController.text,
                                      mobileNumberController.text, tinNumberController.text, bankName, accountNumberController.text);
                                  addValue(model);
                                }

                              },
                            ),
                          ),
                        ],
                      ),


                      Container(
                        width: 380,
                        height: 100,
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.black)),

                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              '${data.join("  " "\n")}   ',
                              style: TextStyle(
                                  fontSize: 13, color: Colors.blue),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                        // ),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      ElevatedButton(
                          onPressed: () async {
                            if (proxyNameController.text.isEmpty) {
                              Fluttertoast.showToast(
                                  msg: "Please Enter Proxy Name!",
                                  gravity: ToastGravity.BOTTOM,
                                  backgroundColor:
                                  Colors.green[800],
                                  textColor: Colors.white,
                                  fontSize: 18.0);
                            } else if (data.isEmpty) {
                              Fluttertoast.showToast(
                                  msg:
                                  "Please Enter At least 1 Shareholder!",
                                  gravity: ToastGravity.BOTTOM,
                                  backgroundColor:
                                  Colors.green[800],
                                  textColor: Colors.white,
                                  fontSize: 18.0);
                            } else {
                              if (!isShareholder) {
                                setState(() {
                                  proxyType = "NonShareholderProxy";
                                  if (shareholderProxyCDS.isEmpty) {
                                    shareholderProxyCDS = "0";
                                  }
                                  debugPrint(
                                      "Proxy Type: $proxyType shareholder CDSNo.:  $shareholderProxyCDS");
                                });
                              } else {
                                setState(() {
                                  proxyType = "ShareholderProxy";
                                  shareholderProxyCDS =
                                      postShareholderCdsController
                                          .text;
                                  debugPrint(
                                      "Proxy Type: $proxyType shareholder CDSNo.:  $shareholderProxyCDS");
                                });
                              }

                              context.loaderOverlay.show();
                              String proxyNumb = await postProxyName(proxyName, proxyType,
                                  phoneNumber, shareholderProxyCDS, context);
                              Future.delayed(const Duration(milliseconds: 400),
                                      () {
                                    if(proxyNumb != ""){
                                      _showProxyNumberDialog(
                                          context, proxyNumb);
                                    }

                                  });
                              setState(() {
                                cdsNumberController.text = "";
                                shareHolderController.text = "";
                                proxyNameController.text = "";
                                data.clear();
                              });
                            }

                          },
                          child: Text("REGISTER")),
                    ],
                  ),
                ),
              )),
    );
  }
}
