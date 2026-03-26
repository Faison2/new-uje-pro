import 'dart:convert';
import 'package:uje/services.dart';
import 'package:uje/model/candidate_model.dart';
import 'package:uje/model/proxyShareholder_model.dart';
import 'package:uje/model/proxyVoteModel.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:loader_overlay/loader_overlay.dart';

import 'home_screen.dart';
import 'constants/constants.dart';
import 'constants/ui_constants.dart';

class ProxyNormalVotePage extends StatefulWidget {
  final String cdsString;
  final String resNumber;
  final String resolution;
  final String resolutionSEQ;
  final String proxyNumber;
  // final String responseMessage;
  const ProxyNormalVotePage({
    Key? key,
    required this.cdsString,
    required this.resNumber,
    required this.resolution,
    required this.resolutionSEQ,
    required this.proxyNumber,
  }) : super(key: key);

  @override
  State<ProxyNormalVotePage> createState() => _ProxyNormalVotePageState();
}

class _ProxyNormalVotePageState extends State<ProxyNormalVotePage> {
  TextEditingController voterController = TextEditingController();
  String respRef = "";
  String responseMessage = "";

  //This is Handling data from the backend passing it to the frontend
  //

  String agmId = "";
  String company = "";
  String meetingInfo = "";
  String cdsString = "";
  String responseVoteMessage = "";
  String name = " ";
  String cdsNo = "";
  String shares = "";
  String regStatus = " ";
  String resolution1 = "";
  List resolutions = [];
  List nominees = [];
  bool isVisible = false;
  String nomineeName = "";
  List orderNumbers = [];
  List resolutionNumbers = [];
  String voteCode = "";
  int onSelected = 0;

  String resolutionSEQ = "";
  String proxyNumber = "";
  String vote = "";
  String shareholder = "";

  List<ShareholderModel> shareholders = [];
  List<CandidateModel> candidates = [];
  ProxyVoterModel proxyVoterModel = ProxyVoterModel();

  String resolutionText = "";
  String resolutionNo = "";
  String cardState = "";

  String voteStatus = "";

  @override
  void initState() {
    context.loaderOverlay.show();
    getShareholderList(widget.proxyNumber, widget.resNumber);
    context.loaderOverlay.hide();

    super.initState();
    voterController.addListener(() {
      respRef = voterController.text;
    });
  }

  getShareholderList(String proxyNumber, String resoNumber) async {
    String shareholderListUrl =
        "$baseApiUrl/getVoteProxyHolders";

    debugPrint("PROXY NUMBER: $proxyNumber");

    debugPrint("RESOLUTION: $resoNumber");

    final response = await http.post(
      Uri.parse(shareholderListUrl),
      body: {"ProxyCDSNo": proxyNumber, "ResNo": resoNumber},
    );

    if (response.statusCode == 200) {
      final responseJson = json.decode(response.body);

      if (responseJson[0]["responseCode"] == 4) {
        debugPrint('SUCCESSFUL!!! \n $responseJson');
        Fluttertoast.showToast(
          msg: "${responseJson[0]["responseMessage"]}",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.green[800],
          textColor: Colors.white,
          fontSize: 18.0,
          timeInSecForIosWeb: 3,
        );

        setState(() {
          responseVoteMessage = responseJson[0]["responseMessage"].toString();
        });

        context.loaderOverlay.hide();
      } else {
        for (int i = 0; i < responseJson.length; i++) {
          ShareholderModel shareholderModel =
              ShareholderModel.fromJson(responseJson[i]);

          shareholders.add(shareholderModel);
        }
        debugPrint(shareholders.toString());

        setState(() {
          resoNumber = responseJson[0]["resNo"].toString();
          debugPrint("Giving Null:  $resoNumber");
        });
        context.loaderOverlay.hide();
      }
    } else {
      debugPrint('Error failed to retrieve candidates');

      context.loaderOverlay.hide();
    }
    context.loaderOverlay.hide();
  }

  handleNormalVote(String cdsNumber, String resNumber, String voteType) async {
    String urlVoteNormalRes =
        "$baseApiUrl/CommitVoteNormalRes";

    debugPrint("CDS NUMBER $cdsNumber");

    final response = await http.post(Uri.parse(urlVoteNormalRes), body: {
      "CDSNo": cdsNumber,
      "ResolutionNumber": resNumber,
      "Vote": voteType
    });

    final responseJson = json.decode(response.body);
    if (response.statusCode == 200) {
      if (responseJson[0]["responseCode"] == 4) {
        debugPrint('SUCCESSFUL!!! \n $responseJson');
        Fluttertoast.showToast(
          msg: "${responseJson[0]["responseMessage"]}",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.green[800],
          textColor: Colors.white,
          fontSize: 18.0,
          timeInSecForIosWeb: 3,
        );

        setState(() {
          responseVoteMessage = responseJson[0]["responseMessage"].toString();
        });

        context.loaderOverlay.hide();
      }
      // ignore: avoid_print
      voteStatus = responseJson[0]["responseMesssage"].toString();
      debugPrint(" $responseJson");

      Fluttertoast.showToast(
        msg: "${responseJson[0]["responseMessage"]}",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.green[800],
        textColor: Colors.white,
        fontSize: 18.0,
        timeInSecForIosWeb: 3,
      );
      setState(() {
        voteStatus = responseJson[0]["responseMesssage"].toString();
      });
      context.loaderOverlay.hide();
    } else {
      Fluttertoast.showToast(
        msg: "${responseJson[0]["responseMessage"]}",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.green[800],
        textColor: Colors.white,
        fontSize: 18.0,
        timeInSecForIosWeb: 3,
      );
      context.loaderOverlay.hide();
    }
    getShareholderList(widget.proxyNumber, widget.resNumber);

    context.loaderOverlay.hide();
  }

  handleNormalVoteAll(
      String resolutionSEQ, String proxyNumber, String voteType) async {
    String urlVoteNormalResAll =
        "$baseApiUrl/CommitVoteNormalResALL";

    debugPrint(
        "RESOLUTION SEQUENCE   $resolutionSEQ ::::: PROXY NUMBER $proxyNumber  ::::: VOTETYPE $voteType");

    final response = await http.post(Uri.parse(urlVoteNormalResAll), body: {
      "resSEQ": resolutionSEQ,
      "ProxyCDS": proxyNumber,
      "Vote": voteType
    });

    final responseJson = json.decode(response.body);
    if (response.statusCode == 200) {
      if (responseJson[0]["responseCode"] == 4) {
        debugPrint('SUCCESSFUL!!! \n $responseJson');
        Fluttertoast.showToast(
          msg: "${responseJson[0]["responseMessage"]}",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.green[800],
          textColor: Colors.white,
          fontSize: 18.0,
          timeInSecForIosWeb: 3,
        );

        setState(() {
          responseVoteMessage = responseJson[0]["responseMessage"].toString();
        });

        context.loaderOverlay.hide();
      }
      // ignore: avoid_print
      voteStatus = responseJson[0]["responseMesssage"].toString();
      debugPrint(" $responseJson");

      Fluttertoast.showToast(
        msg: "${responseJson[0]["responseMessage"]}",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.green[800],
        textColor: Colors.white,
        fontSize: 18.0,
        timeInSecForIosWeb: 3,
      );
      setState(() {
        voteStatus = responseJson[0]["responseMesssage"].toString();
      });
      context.loaderOverlay.hide();
    } else {
      Fluttertoast.showToast(
        msg: "${responseJson[0]["responseMessage"]}",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.green[800],
        textColor: Colors.white,
        fontSize: 18.0,
        timeInSecForIosWeb: 3,
      );
      context.loaderOverlay.hide();
    }
    getShareholderList(widget.proxyNumber, widget.resNumber);
    context.loaderOverlay.hide();
  }

  @override
  Widget build(BuildContext context) {
    String resNumber = widget.resNumber;
    String resolution = widget.resolution;
    String proxyNumber = widget.proxyNumber;
    String resolutionSEQ = widget.resolutionSEQ;
    setState(() {
      voteCode = respRef;
    });
    final currentWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: const Text(" Normal Vote"),
        leading: new IconButton(
            icon: new Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              Navigator.of(context).pop();
              shareholders.clear();
            }),
      ),
      body: currentWidth <= 540
          ? SingleChildScrollView(
          scrollDirection: Axis.vertical,
          padding: const EdgeInsets.all(0.0),
          child: Column(
            children: [
              Text(
                resolution,
                style: TextStyle(
                    color: Colors.red,
                    fontSize: 21,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(
                height: 25,
              ),
              SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: SizedBox(
                  height: 800,
                  width: MediaQuery.of(context).size.width * 0.9,
                  child: Container(
                    child: SizedBox(
                      height: MediaQuery.of(context).size.height * 0.8,
                      width: MediaQuery.of(context).size.width * 0.9,
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                            child: Row(
                              children: [
                                Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(0, 0, 0, 0),
                                  child: MaterialButton(
                                      minWidth: 10,
                                      color: Colors.green[800],
                                      onPressed: () {
                                        handleNormalVoteAll(resolutionSEQ,
                                            proxyNumber, "1");
                                        shareholders.clear();
                                      },
                                      child: vote == "1"
                                          ? Row(
                                              children: const [
                                                Icon(Icons.check),
                                                Text("For(ALL)",
                                                    style: TextStyle(
                                                      fontSize: 10,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ))
                                              ],
                                            )
                                          : const Text("For(ALL)",
                                              style: TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                              ))),
                                ),
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                      10, 0, 10, 0),
                                  child: MaterialButton(
                                      minWidth: 10,
                                      color: Colors.red,
                                      onPressed: () {
                                        handleNormalVoteAll(resolutionSEQ,
                                            proxyNumber, "2");
                                        shareholders.clear();
                                      },
                                      child: vote == "2"
                                          ? Row(
                                              children: const [
                                                Icon(Icons.check),
                                                Text("Against(ALL)",
                                                    style: TextStyle(
                                                      fontSize: 10,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ))
                                              ],
                                            )
                                          : const Text("Against(ALL)",
                                              style: TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                              ))),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(0.0),
                                  child: MaterialButton(
                                      minWidth: 10,
                                      color: Colors.amber,
                                      onPressed: () {
                                        handleNormalVoteAll(resolutionSEQ,
                                            proxyNumber, "3");
                                        shareholders.clear();
                                      },
                                      child: vote == "3"
                                          ? Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceEvenly,
                                              children: const [
                                                Icon(Icons.check),
                                                Text("Abstain(ALL)",
                                                    style: TextStyle(
                                                      fontSize: 10,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ))
                                              ],
                                            )
                                          : const Text("Abstain(ALL)",
                                              style: TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                              ))),
                                ),
                                MaterialButton(
                                    minWidth: 5,
                                    elevation: 0.0,
                                    color: Colors.grey[50],
                                    onPressed: () {
                                      debugPrint("TEST CODE" + cdsString);
                                      context.loaderOverlay.show();

                                      setState(() {
                                        getShareholderList(
                                          proxyNumber,
                                          resNumber,
                                        );
                                        // getCandidateList(resNumber, cdsString);
                                      });
                                    },
                                    child: const Text("")),
                              ],
                            ),
                          ),
                          SingleChildScrollView(
                            scrollDirection: Axis.vertical,
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                              child: SizedBox(
                                height: 250,
                                child: Scrollbar(
                                  child: ListView.builder(
                                      itemCount: shareholders.length,
                                      itemBuilder: (context, index) {
                                        return shareholderItem(
                                            context,
                                            shareholders[index].shareholder!,
                                            shareholders[index].names!,
                                            shareholders[index].shares!,
                                            shareholders[index].vote!,
                                            shareholders[index].category!,
                                            resNumber,
                                            resolutionSEQ,
                                            proxyNumber,
                                            resolution);
                                      }),
                                ),
                              ),
                            ),
                          ),
                          MaterialButton(
                            height: 50,
                            minWidth: 150,
                            onPressed: () {
                              shareholders.clear();
                              showToast(context, "Voted successfully");
                              Navigator.pop(context);
                              // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> HomeScreen()));
                            },
                            color: Colors.green[800],
                            child: const Text("SUBMIT",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                )),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
                      ) //LANDSCAPE VIEW
          : Container(
              child: SingleChildScrollView(
                            scrollDirection: Axis.vertical,
                            padding: const EdgeInsets.all(32),
                            child: Column(
                              children: [
              Text(
                resolution,
                style: TextStyle(
                    color: Colors.red,
                    fontSize: 21,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(
                height: 25,
              ),
              SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: SizedBox(
                  height: 800,
                  width: MediaQuery.of(context).size.width * 0.9,
                  child: Container(
                    child: SizedBox(
                      height: MediaQuery.of(context).size.height * 0.8,
                      width: MediaQuery.of(context).size.width * 0.9,
                      child: Column(
                        children: [
                          Padding(
                            padding:
                                const EdgeInsets.fromLTRB(200, 0, 0, 0),
                            child: Row(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                      100, 0, 0, 0),
                                  child: MaterialButton(
                                      color: Colors.green[800],
                                      onPressed: () {
                                        handleNormalVoteAll(resolutionSEQ,
                                            proxyNumber, "1");
                                        shareholders.clear();
                                      },
                                      child: vote == "1"
                                          ? Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceEvenly,
                                              children: const [
                                                Icon(Icons.check),
                                                Text("For(ALL)",
                                                    style: TextStyle(
                                                      fontSize: 20,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ))
                                              ],
                                            )
                                          : const Text("For(ALL)",
                                              style: TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                              ))),
                                ),
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                      80, 0, 80, 0),
                                  child: MaterialButton(
                                      color: Colors.red,
                                      onPressed: () {
                                        handleNormalVoteAll(resolutionSEQ,
                                            proxyNumber, "2");
                                        shareholders.clear();
                                      },
                                      child: vote == "2"
                                          ? Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceEvenly,
                                              children: const [
                                                Icon(Icons.check),
                                                Text("Against(ALL)",
                                                    style: TextStyle(
                                                      fontSize: 20,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ))
                                              ],
                                            )
                                          : const Text("Against(ALL)",
                                              style: TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                              ))),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(2.0),
                                  child: MaterialButton(
                                      color: Colors.amber,
                                      onPressed: () {
                                        handleNormalVoteAll(resolutionSEQ,
                                            proxyNumber, "3");
                                        shareholders.clear();
                                      },
                                      child: vote == "3"
                                          ? Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceEvenly,
                                              children: const [
                                                Icon(Icons.check),
                                                Text("Abstain(ALL)",
                                                    style: TextStyle(
                                                      fontSize: 20,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ))
                                              ],
                                            )
                                          : const Text("Abstain(ALL)",
                                              style: TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                              ))),
                                ),
                                MaterialButton(
                                    elevation: 0.0,
                                    color: Colors.grey[50],
                                    onPressed: () {
                                      debugPrint("TEST CODE" + cdsString);
                                      context.loaderOverlay.show();

                                      setState(() {
                                        getShareholderList(
                                          proxyNumber,
                                          resNumber,
                                        );
                                        // getCandidateList(resNumber, cdsString);
                                      });
                                    },
                                    child: const Text("")),
                              ],
                            ),
                          ),
                          SingleChildScrollView(
                            scrollDirection: Axis.vertical,
                            child: SizedBox(
                              height: 450,
                              child: Scrollbar(
                                child: ListView.builder(
                                    itemCount: shareholders.length,
                                    itemBuilder: (context, index) {
                                      return shareholderItem(
                                          context,
                                          shareholders[index].shareholder!,
                                          shareholders[index].names!,
                                          shareholders[index].shares!,
                                          shareholders[index].vote!,
                                          shareholders[index].category!,
                                          resNumber,
                                          resolutionSEQ,
                                          proxyNumber,
                                          resolution);
                                    }),
                              ),
                            ),
                          ),
                          MaterialButton(
                            height: 50,
                            minWidth: 150,
                            onPressed: () {
                              shareholders.clear();

                              //showToast(context, "Voted successfully");
                              Navigator.pop(context);
                              //Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> HomeScreen()));
                            },
                            color: Colors.green[800],
                            child: const Text("SUBMIT",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                )),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
                              ],
                            ),
                          )),
    );
  }

  Widget shareholderItem(
      BuildContext context,
      String shareholder,
      String names,
      String shares,
      String vote,
      String category,
      String resNo,
      String resolutionSEQ,
      String proxyNumber,
      String resolution) {
    final currentWidth = MediaQuery.of(context).size.width;
    return currentWidth <= 540
        ? SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
              child: Row(
                children: [
                  Container(
                    width: 800,
                    child: Card(
                      elevation: 5.0,
                      child: Column(
                        children: [
                          Row(children: [
                            SizedBox(
                              width: 100,
                              child: Text(
                                names,
                                style: const TextStyle(fontSize: 11.0),
                              ),
                            ),
                            SizedBox(
                              width: 10,
                              child: Text(
                                shares,
                                style: const TextStyle(fontSize: 11.0),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(2.0),
                              child: MaterialButton(
                                  minWidth: 20,
                                  color: Colors.green[800],
                                  onPressed: () {
                                    handleNormalVote(
                                        shareholder, resNo, "1");
                                    shareholders.clear();
                                  },
                                  child: vote == "1"
                                      ? Row(
                                          children: const [
                                            Icon(Icons.check),
                                            Text("For",
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  fontWeight:
                                                      FontWeight.bold,
                                                ))
                                          ],
                                        )
                                      : const Text("For",
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                          ))),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(2.0),
                              child: MaterialButton(
                                  minWidth: 10,
                                  color: Colors.red,
                                  onPressed: () {
                                    handleNormalVote(
                                        shareholder, resNo, "2");
                                    shareholders.clear();
                                  },
                                  child: vote == "2"
                                      ? Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: const [
                                            Icon(Icons.check),
                                            Text("No",
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  fontWeight:
                                                      FontWeight.bold,
                                                ))
                                          ],
                                        )
                                      : const Text("No",
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                          ))),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.fromLTRB(0, 0, 10, 0),
                              child: MaterialButton(
                                  minWidth: 20,
                                  color: Colors.amber,
                                  onPressed: () {
                                    handleNormalVote(
                                        shareholder, resNo, "3");
                                    shareholders.clear();
                                  },
                                  child: vote == "3"
                                      ? Row(

                                          children: const [
                                            Icon(Icons.check),
                                            Text("Abstain",
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  fontWeight:
                                                      FontWeight.bold,
                                                ))
                                          ],
                                        )
                                      : const Text("Abstain",
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                          ))),
                            ),
                          ]),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ) //Landscape view
        : Container(
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(150, 20, 0, 0),
                  child: Row(
                    children: [
                      Container(
                        width: 1000,
                        child: Card(
                          elevation: 5.0,
                          child: Column(
                            children: [
                              Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    SizedBox(
                                      width: 400,
                                      child: Text(
                                        names,
                                        style: const TextStyle(fontSize: 17.0),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 150,
                                      child: Text(
                                        shares,
                                        style: const TextStyle(fontSize: 17.0),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(2.0),
                                      child: MaterialButton(
                                          color: Colors.green[800],
                                          onPressed: () {
                                            handleNormalVote(
                                                shareholder, resNo, "1");
                                            shareholders.clear();
                                          },
                                          child: vote == "1"
                                              ? Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceEvenly,
                                                  children: const [
                                                    Icon(Icons.check),
                                                    Text("Yes",
                                                        style: TextStyle(
                                                          fontSize: 18,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ))
                                                  ],
                                                )
                                              : const Text("Yes",
                                                  style: TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.bold,
                                                  ))),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(2.0),
                                      child: MaterialButton(
                                          color: Colors.red,
                                          onPressed: () {
                                            handleNormalVote(
                                                shareholder, resNo, "2");
                                            shareholders.clear();
                                          },
                                          child: vote == "2"
                                              ? Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceEvenly,
                                                  children: const [
                                                    Icon(Icons.check),
                                                    Text("Against",
                                                        style: TextStyle(
                                                          fontSize: 18,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ))
                                                  ],
                                                )
                                              : const Text("Against",
                                                  style: TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.bold,
                                                  ))),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(2.0),
                                      child: MaterialButton(
                                          color: Colors.amber,
                                          onPressed: () {
                                            handleNormalVote(
                                                shareholder, resNo, "3");
                                            shareholders.clear();
                                          },
                                          child: vote == "3"
                                              ? Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceEvenly,
                                                  children: const [
                                                    Icon(Icons.check),
                                                    Text("Abstain",
                                                        style: TextStyle(
                                                          fontSize: 18,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ))
                                                  ],
                                                )
                                              : const Text("Abstain",
                                                  style: TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.bold,
                                                  ))),
                                    ),
                                  ]),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ));
  }
}
