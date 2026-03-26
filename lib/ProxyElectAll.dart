import 'dart:convert';
import 'package:uje/constants/constants.dart';
import 'package:uje/model/VoterModel.dart';
import 'package:uje/model/candidate_model.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:uje/services.dart';
import 'package:flutter/material.dart';
import 'package:loader_overlay/loader_overlay.dart';

import 'home_screen.dart';
import 'constants/ui_constants.dart';

class ProxyElectionAllVotePage extends StatefulWidget {
  final String cdsString;
  final String resNumber;
  final String voteDetails;
  final String resolutionSEQ;
  final String proxyNumber;

  const ProxyElectionAllVotePage({
    Key? key,
    required this.cdsString,
    required this.resNumber,
    required this.voteDetails,
    required this.resolutionSEQ,
    required this.proxyNumber,

    // required this.responseMessage,
  }) : super(key: key);

  @override
  State<ProxyElectionAllVotePage> createState() =>
      _ProxyElectionAllVotePageState();
}

class _ProxyElectionAllVotePageState extends State<ProxyElectionAllVotePage> {
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
  VoterModel voterModel = VoterModel();
  int onSelected = 0;
  String resNumber = "";

  String voteType = "";
  List<CandidateModel> candidates = [];
  String resolutionText = "";
  String resolutionNo = "";
  String cardState = "";

  String voteStatus = "";

  @override
  void initState() {
    getAllCandidateList(widget.resNumber);
    super.initState();
  }

  getAllCandidateList(String resoNumber) async {
    String candidateListUrl =
        "$baseApiUrl/getCandidateListProxyALL";
    debugPrint("TESTING PURPOSES: $resoNumber");
    final response = await http.post(
      Uri.parse(candidateListUrl),
      body: {"resNo": resoNumber},
    );

    if (response.statusCode == 200) {
      final responseJson = json.decode(response.body);

      for (int i = 0; i < responseJson.length; i++) {
        CandidateModel candidateModel =
            CandidateModel.fromJson(responseJson[i]);
        candidates.add(candidateModel);
      }
      resoNumber = responseJson[0]["resNo"].toString();

      setState(() {
        resoNumber = responseJson[0]["resNo"].toString();
        debugPrint("$responseJson");
      });
    } else {
      debugPrint('Error failed to retrieve candidates');
    }
    context.loaderOverlay.hide();
  }

  handleElectionVoteAll(String resolutionSEQ, String proxyNumber,
      String orderNumber, String voteType) async {
    String voteUrl =
        "$baseApiUrl/VoteForProxyResElectALL";
    // debugPrint("Resolution Number: $resoNumber");

    debugPrint(
        "RESOLUTION SEQUENCE   $resolutionSEQ ::::: PROXY NUMBER $proxyNumber  ::::: VOTETYPE $orderNumber");

    final response = await http.post(
      Uri.parse(voteUrl),
      body: {
        "resSEQ": resolutionSEQ,
        "ProxyCDS": proxyNumber,
        "Vote": orderNumber,
        "VoteType": voteType
      },
    );
    final responseJson = json.decode(response.body);
    if (response.statusCode == 200) {
      if (responseJson[0]["responseCode"] == 0) {
        debugPrint('SUCCESSFUL!!! \n $responseJson');
        Fluttertoast.showToast(
            msg: "${responseJson[0]["responseMessage"]}",
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.grey,
            textColor: Colors.black,
            fontSize: 12.0);
        context.loaderOverlay.hide();

        setState(() {
          responseVoteMessage = responseJson[0]["responseMessage"].toString();
        });

        context.loaderOverlay.hide();
      }
    } else {
      debugPrint('Error failed');
      Fluttertoast.showToast(
          msg: "Vote Failed:  ${responseJson[0]["responseMessage"]}",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.grey,
          textColor: Colors.black,
          fontSize: 12.0);

      context.loaderOverlay.hide();
    }
    getAllCandidateList(widget.resNumber);
    context.loaderOverlay.hide();
  }

  @override
  Widget build(BuildContext context) {
    String resNumber = widget.resNumber;
    String cdsString = widget.cdsString;
    String voteDetails = widget.voteDetails;
    final currentWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
          title: const Text("Election Vote"),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
              context.loaderOverlay.hide();
            },
          )),
      body: currentWidth <= 540
          ? SingleChildScrollView(
              scrollDirection: Axis.vertical,
              padding: const EdgeInsets.all(4.0),
              child: Column(
                children: [
                  Text(
                    voteDetails,
                    style: TextStyle(
                        color: Colors.red,
                        fontSize: 13,
                        fontWeight: FontWeight.bold),
                  ),
                  MaterialButton(
                      elevation: 0.0,
                      color: Colors.grey[50],
                      onPressed: () {
                        context.loaderOverlay.show();

                        setState(() {
                          // getCandidateList(resNumber, cdsString);

                          getAllCandidateList(resNumber);
                        });
                      },
                      child: const Text("")),
                  const SizedBox(
                    height: 10,
                  ),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SizedBox(
                      height: MediaQuery.of(context).size.height * 0.4,
                      width: MediaQuery.of(context).size.width,
                      child: ListView.builder(
                          itemCount: candidates.length,
                          itemBuilder: (context, index) {
                            return candidateTile(
                              context,
                              candidates[index].nomineeName!,
                              cdsString,
                              candidates[index].orderNumber!,
                              candidates[index].resNo!,
                              candidates[index].resExistingVote!,
                            );
                          }),
                    ),
                  ),
                  MaterialButton(
                    height: 60,
                    minWidth: 150,
                    onPressed: () {
                      candidates.clear();
                      showToast(context, "Voted successfully");
                      Navigator.pop(context);
                    },
                    color: Colors.green[800],
                    child: const Text("SUBMIT",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        )),
                  )
                ],
              ),
            ) // landscape view
          : Container(
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                padding: const EdgeInsets.all(4.0),
                child: Column(
                  children: [
                    Text(
                      voteDetails,
                      style: TextStyle(
                          color: Colors.red,
                          fontSize: 13,
                          fontWeight: FontWeight.bold),
                    ),
                    MaterialButton(
                        elevation: 0.0,
                        color: Colors.grey[50],
                        onPressed: () {
                          context.loaderOverlay.show();

                          setState(() {
                            // getCandidateList(resNumber, cdsString);

                            getAllCandidateList(resNumber);
                          });
                        },
                        child: const Text("")),
                    const SizedBox(
                      height: 20,
                    ),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: SizedBox(
                        height: MediaQuery.of(context).size.height * 0.4,
                        width: MediaQuery.of(context).size.width,
                        child: ListView.builder(
                            itemCount: candidates.length,
                            itemBuilder: (context, index) {
                              return candidateTile(
                                context,
                                candidates[index].nomineeName!,
                                cdsString,
                                candidates[index].orderNumber!,
                                candidates[index].resNo!,
                                candidates[index].resExistingVote!,
                              );
                            }),
                      ),
                    ),
                    MaterialButton(
                      height: 60,
                      minWidth: 150,
                      onPressed: () {
                        candidates.clear();
                        showToast(context, "Voted successfully");
                        Navigator.pop(context);
                      },
                      color: Colors.green[800],
                      child: const Text("SUBMIT",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          )),
                    )
                  ],
                ),
              ),
            ),
    );
  }

  Widget candidateTile(
    BuildContext context,
    String nomineeName,
    String cdsString,
    String orderNumber,
    String resolutionNumber,
    String resExistingVote,
  ) {
    final currentWidth = MediaQuery.of(context).size.width;

    return currentWidth <= 540
        ? Card(
            elevation: 5.0,
            child: Padding(
              padding: const EdgeInsets.all(0.0),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      width: 150,
                      child: Text(
                        nomineeName,
                        style: const TextStyle(fontSize: 11.0),
                      ),
                    ),
                    Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(2.0),
                          child: MaterialButton(
                              height: 30,
                              minWidth: 30,
                              onPressed: () {
                                context.loaderOverlay.show();
                                handleElectionVoteAll(widget.resolutionSEQ,
                                    widget.proxyNumber, orderNumber, "1");
                                // postCandidateVote(
                                //     cdsString, orderNumber, resolutionNumber, "1");
                                candidates.clear();
                              },
                              color: Colors.green[800],
                              child: resExistingVote == "1"
                                  ? Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: const [
                                        Icon(Icons.check),
                                        Text("Yes",
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                            ))
                                      ],
                                    )
                                  : const Text("Yes",
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ))),
                        ),
                        // Padding(
                        //   padding: const EdgeInsets.all(2.0),
                        //   child: MaterialButton(
                        //       height: 30,
                        //       minWidth: 30,
                        //       onPressed: () {
                        //         context.loaderOverlay.show();
                        //         handleElectionVoteAll(widget.resolutionSEQ,
                        //             widget.proxyNumber, orderNumber, "2");
                        //         candidates.clear();
                        //       },
                        //       color: Colors.amber,
                        //       child: resExistingVote == "2"
                        //           ? Row(
                        //               children: const [
                        //                 Icon(Icons.clear),
                        //                 Text("No",
                        //                     style: TextStyle(
                        //                       fontSize: 11,
                        //                       fontWeight: FontWeight.bold,
                        //                     ))
                        //               ],
                        //             )
                        //           : const Text("No",
                        //               style: TextStyle(
                        //                 fontSize: 11,
                        //                 fontWeight: FontWeight.bold,
                        //               ))),
                        // ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: MaterialButton(
                              height: 30,
                              minWidth: 30,
                              onPressed: () {
                                context.loaderOverlay.show();
                                handleElectionVoteAll(widget.resolutionSEQ,
                                    widget.proxyNumber, orderNumber, "3");
                                candidates.clear();
                              },
                              color: Colors.amber[100],
                              child: const Text("Recast",
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ))),
                        ),
                      ],
                    ),
                  ]),
            ),
          ) //LANDSCAPE PRESENTATION
        : Container(
            child: Card(
            elevation: 5.0,
            child: Padding(
              padding: const EdgeInsets.all(0.0),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      width: 500,
                      child: Text(
                        nomineeName,
                        style: const TextStyle(fontSize: 19.0),
                      ),
                    ),
                    Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: MaterialButton(
                              height: 50,
                              minWidth: 120,
                              onPressed: () {
                                context.loaderOverlay.show();
                                handleElectionVoteAll(widget.resolutionSEQ,
                                    widget.proxyNumber, orderNumber, "1");
                                // postCandidateVote(
                                //     cdsString, orderNumber, resolutionNumber, "1");
                                candidates.clear();
                              },
                              color: Colors.green[800],
                              child: resExistingVote == "1"
                                  ? Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: const [
                                        Icon(Icons.check),
                                        Text("Yes",
                                            style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                            ))
                                      ],
                                    )
                                  : const Text("Yes",
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ))),
                        ),
                        // Padding(
                        //   padding: const EdgeInsets.all(8.0),
                        //   child: MaterialButton(
                        //       height: 50,
                        //       minWidth: 120,
                        //       onPressed: () {
                        //         context.loaderOverlay.show();
                        //         handleElectionVoteAll(widget.resolutionSEQ,
                        //             widget.proxyNumber, orderNumber, "2");
                        //         candidates.clear();
                        //       },
                        //       color: Colors.amber,
                        //       child: resExistingVote == "2"
                        //           ? Row(
                        //               mainAxisAlignment:
                        //                   MainAxisAlignment.spaceEvenly,
                        //               children: const [
                        //                 Icon(Icons.clear),
                        //                 Text("No",
                        //                     style: TextStyle(
                        //                       fontSize: 20,
                        //                       fontWeight: FontWeight.bold,
                        //                     ))
                        //               ],
                        //             )
                        //           : const Text("No",
                        //               style: TextStyle(
                        //                 fontSize: 20,
                        //                 fontWeight: FontWeight.bold,
                        //               ))),
                        // ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: MaterialButton(
                              height: 50,
                              minWidth: 120,
                              onPressed: () {
                                context.loaderOverlay.show();
                                handleElectionVoteAll(widget.resolutionSEQ,
                                    widget.proxyNumber, orderNumber, "3");
                                candidates.clear();
                              },
                              color: Colors.amber[100],
                              child: const Text("Recast",
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ))),
                        ),
                      ],
                    ),
                  ]),
            ),
          ));
  }
}
