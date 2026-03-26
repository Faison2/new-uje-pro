// ignore_for_file: prefer_const_constructors
import 'package:uje/services.dart';
import 'package:uje/widgets/confirm_registration.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:loader_overlay/loader_overlay.dart';

import 'constants/constants.dart';
import 'model/register_model.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  TextEditingController controller = TextEditingController();
  TextEditingController mobileNumberController = TextEditingController();
  final GlobalKey<FormState> registrationKey2 = GlobalKey<FormState>();
  late TextEditingController tinNumberController;
  late TextEditingController bankController;
  late TextEditingController accountNumberController;

  String text = " ";
  String shareholderNumber = "";
  String registrationStatus = "";
  String voteCode = "";
  String voterName = "";
  String voterCodeString = "";
  String phoneNumber = "";

  @override
  void initState() {
    super.initState();
    controller.addListener(() {
      shareholderNumber = controller.text;
    });
    mobileNumberController.addListener(() {
      phoneNumber = mobileNumberController.text;
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

  bool _isShown = true;
  String bankName = "Bank";
  bool hasSearched = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("REGISTER SHAREHOLDER"),
      ),
      body: Center(
        child: Container(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(
                    height: 20,
                  ),
                  Image.asset('assets/images/logo.PNG'),
                  SizedBox(
                    height: 20,
                  ),
                  Container(
                    // width: 600,
                    width: screenWidth(context) * 0.8,
                    child: TextFormField(
                      controller: controller,
                      onChanged: (value){
                        setState(() {
                          hasSearched = false;
                        });
                      },
                      decoration: InputDecoration(
                        labelText: "Enter CDS No.",
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20)),
                      ),
                    ),
                  ),
                  SizedBox(height: 20,),

                  hasSearched? FutureBuilder(
                      future: checkName( controller.text, context),
                      // future: confirmName(context, controller.text),
                      builder: (context, AsyncSnapshot<String> snapshot){
                        {
                          if(snapshot.connectionState == ConnectionState.done){
                            if (snapshot.data != null) {
                              return Text(snapshot.data!);
                            } else {
                              return SizedBox();
                            }
                          } else {
                            return SizedBox();
                          }
                        }
                      })
                      : SizedBox(),

                  SizedBox(height: 10,),

                  CupertinoButton(
                      child: Text('Search',
                        style: Theme.of(context).textTheme.bodyLarge!.copyWith(color: Colors.black,
                            fontWeight: FontWeight.bold),),
                      onPressed: () {
                        context.loaderOverlay.show();
                        // checkName( controller.text);
                        setState((){
                          hasSearched = true;

                        });
                      }),

                  hasSearched? SizedBox(
                    height: hasSearched? 250: 0,
                    width: screenWidth(context) * 0.9,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        AnimatedContainer(
                          duration: const Duration(seconds: 2),
                          curve: Curves.bounceInOut,
                          height: hasSearched? 50: 0,
                          child: TextFormField(
                            controller: tinNumberController,
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
                                // FutureBuilder(
                                //     future: getBanks(context),
                                //     builder: (context, AsyncSnapshot<List<String>> snapshot){
                                //       if(snapshot.connectionState == ConnectionState.done){
                                //         // if(snapshot.hasData){
                                //         return SizedBox(
                                //           // width: screenWidth(context) * 0.6,
                                //           child: DropdownButtonFormField(
                                //             decoration: const InputDecoration(
                                //                 filled: true),
                                //             value: bankName,
                                //             icon: const Icon(Icons.keyboard_arrow_down),
                                //             items: snapshot.data!.map((item) {
                                //               return DropdownMenuItem(
                                //                   value: item, child: Text(item));
                                //             }).toList(),
                                //             onChanged: (String? newValue) {
                                //               if(newValue.toString() != bankName) {
                                //                 setState(() {
                                //                   bankName = newValue.toString();
                                //                 });
                                //               }
                                //             },
                                //           ),
                                //         );
                                //         // }
                                //         // else {
                                //         //   // showConnectionErrorToast(context);
                                //         //   return const LinearProgressIndicator();
                                //         // }
                                //       }
                                //       else{
                                //         return  const LinearProgressIndicator();
                                //       }
                                //     }),

                                SizedBox(
                                  // width: screenWidth(context) * 0.6,
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
                                  height: hasSearched? 50: 0,
                                  child: TextFormField(
                                    controller: mobileNumberController,
                                    decoration: InputDecoration(
                                      labelText: "Enter Mobile No.",
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
                        ),
                        SizedBox(height: 5,),
                        AnimatedContainer(
                          duration: const Duration(seconds: 2),
                          curve: Curves.bounceInOut,
                          height: hasSearched? 50: 0,
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
                  ) : SizedBox(),

                  ElevatedButton(
                      onPressed: () {
                          if (_isShown == true) {
                            if(registrationKey2.currentState!.validate()){
                              RegisterModel model = RegisterModel(
                                  shareholderNumber: controller.text,
                                  mobileNumber: mobileNumberController.text,
                                  tin: tinNumberController.text,
                                  bank: bankName,
                                  accountNumber: accountNumberController.text);
                              showMyDialog(context, model);
                            }
                          } else {
                            return null;
                          }
                      },
                      style: ElevatedButton.styleFrom(
                          minimumSize: Size(
                              150, 50) // put the width and height you want
                          ),
                      child: Text("REGISTER",

                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: Colors.black,
                            fontWeight: FontWeight.bold),)),
                ],
              ),
            )),
      ),
    );
  }
}
