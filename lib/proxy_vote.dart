import 'dart:convert';
import 'package:uje/services.dart';
import 'package:uje/ProxyElectAll.dart';
import 'package:uje/proxy_election_vote.dart';
import 'package:uje/ProxyNormalVote.dart';
import 'package:uje/constants/constants.dart';
import 'package:uje/model/candidate_model.dart';
import 'package:uje/model/proxyShareholder_model.dart';
import 'package:uje/model/proxyVoteModel.dart';
import 'package:uje/widgets/shareholder_list_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:loader_overlay/loader_overlay.dart';

import 'constants/ui_constants.dart';

class ProxyVotePage extends StatefulWidget {
  // final String responseMessage;
  const ProxyVotePage({
    Key? key,
    // required this.responseMessage,
  }) : super(key: key);

  @override
  State<ProxyVotePage> createState() => _ProxyVotePageState();
}

class _ProxyVotePageState extends State<ProxyVotePage> {
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
    super.initState();
    shareholders = [];
    shareholders.clear();
    voterController.addListener(() {
      respRef = voterController.text;
    });
  }

  handleVote(String voteCode) async {
    String urlAllDetails = '$baseApiUrl/getVoteDetails';
    debugPrint("Vote Code is $voteCode");
    cardState = voteCode;

    final response = await http.post(
      Uri.parse(urlAllDetails),
      body: {"VoteCode": voteCode},
    );

    if (response.statusCode == 200) {
      final responseJson = json.decode(response.body);
      if (responseJson[0]["responseCode"] == 4) {
        showToast(context, responseJson[0]["responseMessage"]);
        debugPrint(responseJson[0]["responseMessage"]);
        return responseJson[0]["responseMessage"].toString();
      } else if (responseJson[0]["responseCode"] == 2) {
        showToast(context, responseJson[0]["responseMessage"]);
        return responseJson[0]["responseMessage"].toString();
      } else if (responseJson[0]["responseCode"] == 6) {
        // ignore: avoid_print
        proxyVoterModel = ProxyVoterModel.fromJson(responseJson[0]);

        for (int i = 0; i < responseJson[0]["resItem"].length; i++) {
          debugPrint(responseJson[0]["resItem"][i].toString());
          resolutions.add(responseJson[0]["resItem"][i]);
          // voterModel.resItem?.add(responseJson[0]["resItem"][i]);
        }

        setState(() {
          cdsString = "${proxyVoterModel.cDSNo}";
          meetingInfo = "Meeting Information: ${proxyVoterModel.meetingInfo}";
          company = "${proxyVoterModel.resItem![0]}";

          isVisible = true;
        });
        context.loaderOverlay.hide();
      }
    } else {
      Fluttertoast.showToast(
        msg: "Failed To Retrieve Data",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.green[800],
        textColor: Colors.white,
        fontSize: 18.0,
        timeInSecForIosWeb: 3,
      );
      context.loaderOverlay.hide();
    }
    context.loaderOverlay.hide();
  }

  getResolutions(String proxyNumber) async {
    String urlResolutions = "$baseApiUrl/getVoteDetailsProxy";
    debugPrint("Proxy Number is: $proxyNumber");

    final response = await http.post(Uri.parse(urlResolutions), body: {
      "CDSNo": proxyNumber,
    });

    final responseJson = json.decode(response.body);
    if (response.statusCode == 200) {
      if (responseJson[0]["responseCode"] == 0) {
        voteStatus = responseJson[0]["responseMesssage"].toString();
        debugPrint("$responseJson");

        proxyVoterModel = ProxyVoterModel.fromJson(responseJson[0]);
        if (responseJson[0]["resItem"] != null) {
          for (int i = 0; i < responseJson[0]["resItem"].length; i++) {
            resolutions.add(responseJson[0]["resItem"][i]);
          }
          setState(() {
            name = "${proxyVoterModel.names}";
            proxyNumber = responseJson[0]["ProxyCDSNo"].toString();
            isVisible = true;
          });
          context.loaderOverlay.hide();
        } else {
          showToast(context, "No resolutions at the moment");
          context.loaderOverlay.hide();
        }
      } else {
        showToast(context, responseJson[0]["responseMessage"]);
        setState(() {
          responseVoteMessage = responseJson[0]["responseMessage"].toString();
        });
        context.loaderOverlay.hide();
      }
    }
  }

  getShareholderList(String proxyNumber, String resoNumber) async {
    List<ShareholderModel> holders = [];
    String shareholderListUrl = "$baseApiUrl/getVoteProxyHolders";
    final response = await http.post(
      Uri.parse(shareholderListUrl),
      body: {"ProxyCDSNo": proxyNumber, "ResNo": resoNumber},
    );

    if (response.statusCode == 200) {
      final responseJson = json.decode(response.body);

      if (responseJson[0]["responseCode"] == 4) {
        showToast(context, responseJson[0]["responseMessage"]);

        setState(() {
          responseVoteMessage = responseJson[0]["responseMessage"].toString();
        });

        context.loaderOverlay.hide();
      } else {
        for (int i = 0; i < responseJson.length; i++) {
          ShareholderModel shareholderModel =
              ShareholderModel.fromJson(responseJson[i]);
          holders.add(shareholderModel);
        }

        context.loaderOverlay.hide();
        return holders;
      }
    } else {
      debugPrint('Error failed to retrieve candidates');
      context.loaderOverlay.hide();
      return [];
    }
  }

  getCandidateList(String resoNumber, String cdsNo) async {
    String candidateListUrl = "$baseApiUrl/getCandidateList";
    final response = await http.post(
      Uri.parse(candidateListUrl),
      body: {"resNo": resoNumber, "CDSNo": cdsNo},
    );

    if (response.statusCode == 200) {
      final responseJson = json.decode(response.body);
      if (responseJson[0]["responseCode"] == 4) {
        showToast(context, responseJson[0]["responseMessage"]);
        context.loaderOverlay.hide();
      }

      // debugPrint("This a list of Candidates: ${responseJson.length}");
      int candidateslength = responseJson.length;
      for (int i = 0; i < candidateslength; i++) {
        CandidateModel candidateModel =
            CandidateModel.fromJson(responseJson[i]);
        candidates.add(candidateModel);
      }
      resoNumber = responseJson[0]["resNo"].toString();

      setState(() {
        resoNumber = responseJson[0]["resNo"].toString();
      });
    } else {
      debugPrint('Error failed to retrieve candidates');
    }
    context.loaderOverlay.hide();
  }

  getAllCandidateList(String resoNumber) async {
    String candidateListUrl = "$baseApiUrl/getCandidateListProxyALL";
    final response = await http.post(
      Uri.parse(candidateListUrl),
      body: {"resNo": resoNumber},
    );

    if (response.statusCode == 200) {
      final responseJson = json.decode(response.body);

      if (responseJson[0]["responseCode"] == 4) {
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
      debugPrint("This a list of Candidates: ${responseJson.length}");
      int candidateslength = responseJson.length;
      for (int i = 0; i < candidateslength; i++) {
        CandidateModel candidateModel =
            CandidateModel.fromJson(responseJson[i]);
        candidates.add(candidateModel);
      }

      resoNumber = responseJson[0]["resNo"].toString();

      setState(() {
        resoNumber = responseJson[0]["resNo"].toString();
        // debugPrint("THIS IS A RESOLUTION NUMBER : " + resoNumber);
      });
    } else {
      debugPrint('Error failed to retrieve candidates');
    }
    context.loaderOverlay.hide();
  }

  handleNormalVote(String cdsNumber, String resNumber, String voteType) async {
    String urlVoteNormalRes = "$baseApiUrl/CommitVoteNormalRes";

    // debugPrint("CDS NUMBER $cdsNumber");

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
      // debugPrint(" $responseJson");

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
    context.loaderOverlay.hide();
  }

  handleElectionVote(
      String cdsNumber, orderNumber, resolutionNumber, voteType) async {
    String voteUrl = "$baseApiUrl/CommitVoteElectionRes";

    final body = {
      "CDSNo": cdsNo,
      "ResolutionNumber": resolutionNumber,
      "Vote": orderNumber,
      "VoteType": voteType,
      "isShareholderorProxy": "Proxy"
    };
    debugPrint(body.toString());

    final response = await http.post(
      Uri.parse(voteUrl),
      body: body,
    );
    final responseJson = json.decode(response.body);
    if (response.statusCode == 200) {
      if (responseJson[0]["responseCode"] == 0) {
        showToast(context, responseJson[0]["responseMessage"]);

        context.loaderOverlay.hide();
      }
    } else {
      debugPrint('Error failed');
      showToast(context, responseJson[0]["responseMessage"]);
      context.loaderOverlay.hide();
    }
    // HandleVote(respRef);
    context.loaderOverlay.hide();
  }

  handleNormalVoteAll(
      String resolutionSEQ, String proxyNumber, String voteType) async {
    String urlVoteNormalResAll = "$baseApiUrl/CommitVoteNormalResALL";

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
        // debugPrint('SUCCESSFUL!!! \n $responseJson');
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
    context.loaderOverlay.hide();
  }

  handleElectionVoteAll(String resolutionSEQ, String proxyNumber,
      String orderNumber, String voteType) async {
    String urlVoteNormalResAll = "$baseApiUrl/VoteForProxyResElectALL";

    // debugPrint(
    //     "RESOLUTION SEQUENCE   $resolutionSEQ ::::: PROXY NUMBER $proxyNumber  ::::: VOTETYPE $orderNumber");

    final response = await http.post(Uri.parse(urlVoteNormalResAll), body: {
      "resSEQ": resolutionSEQ,
      "ProxyCDS": proxyNumber,
      "Vote": orderNumber,
      "VoteType": voteType
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
    context.loaderOverlay.hide();
  }

  @override
  Widget build(BuildContext context) {
    setState(() {
      voteCode = respRef;
    });
    return Scaffold(
        appBar: AppBar(
          title: const Text("Resolutions"),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(0.0),
          child: Column(
            children: [
              const SizedBox(
                height: 25,
              ),
              // Text("You have successfully Registered! $responseMessage"),

              Container(
                width: 900,
                child: TextField(
                  controller: voterController,
                  onChanged: (text) {
                    if (text == respRef) {}
                  },
                  decoration: InputDecoration(
                    labelText: "Enter Proxy CDS Number",
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20)),
                  ),
                ),
              ),
              SizedBox(
                height: 15,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: MaterialButton(
                        color: Colors.green[800],
                        height: 50,
                        minWidth: 100,
                        onPressed: () {
                          context.loaderOverlay.show();
                          Future.delayed(Duration(seconds: 5), () {
                            getResolutions(respRef);
                          });
                        },
                        child: const Text("Search",
                            style: TextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.bold,
                            ))),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: MaterialButton(
                        color: Colors.red,
                        height: 50,
                        minWidth: 100,
                        onPressed: () {
                          setState(() {
                            isVisible = false;
                            resolutions.clear();
                            voterController.text = "";

                            cdsString = "";
                            meetingInfo = "";
                            name = "";
                            shares = "";
                            regStatus = "";
                            company = "";
                          });
                        },
                        child: const Text(" Clear",
                            style: TextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.bold,
                            ))),
                  ),
                ],
              ),
              //STARTING HERE
              proxyDetails("Proxy Name:", name),
              const SizedBox(
                height: 20,
              ),

              isVisible
                  ? SizedBox(
                height: MediaQuery.of(context).size.height * 0.5, // Set a fixed height for the SizedBox
                width: MediaQuery.of(context).size.width,
                child: SingleChildScrollView(
                  child: ListView.builder(
                    shrinkWrap: true, // Allow ListView to take the height of its children
                    physics: NeverScrollableScrollPhysics(), // Disable ListView scrolling
                    itemCount: proxyVoterModel.resItem!.length,
                    itemBuilder: (context, index) {
                      return voteTile(
                        context,
                        proxyVoterModel.resItem![index].resText!,
                        proxyVoterModel.resItem![index].resType!,
                        proxyVoterModel.resItem![index].resNo!,
                        proxyVoterModel.resItem![index].sEQ!,
                        voteCode,
                        vote,
                        shareholder,
                      );
                    },
                  ),
                ),
              )
                  : const SizedBox(),


            ],
          ),
        ));
  }

  void onPress(int id) {
    if (id == 1) {}
  }

  Widget proxyDetails(String detailTitle, String detail) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          detailTitle,
          textAlign: TextAlign.left,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontSize: 16),
        ),
        const SizedBox(
          width: 20,
        ),
        Text(
          detail,
          textAlign: TextAlign.left,
          style: TextStyle(fontSize: 16),
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget voteTile(
      BuildContext context,
      String voteDetails,
      String type,
      String resNumber,
      String resolutionSEQ,
      String proxyNumber,
      String vote,
      String shareholder,
      ) {
    return Container(
      width: MediaQuery.of(context).size.width,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              SizedBox(
                width: 100,  // Fixed width for the resolution number
                child: Text(
                  resNumber,
                  style: const TextStyle(fontSize: 18.0),
                ),
              ),
              Expanded(
                child: Text(
                  voteDetails,
                  style: const TextStyle(fontSize: 19.0),
                ),
              ),
              MaterialButton(
                color: Colors.green[800],
                height: 50,
                minWidth: 120,
                onPressed: () async {
                  context.loaderOverlay.show();

                  if (type != "Normal Resolution") {
                    shareholders = await getShareholderList(respRef, resNumber);
                  }
                  Future.delayed(const Duration(milliseconds: 500), () {
                    showShareholderListDialog(
                      context,
                      voteCode,
                      voteDetails,
                      resNumber,
                      resolutionSEQ,
                      proxyNumber,
                      type,
                      vote,
                      shareholder,
                      shareholders,
                    );
                  });
                },
                child: const Text(
                  "Vote",
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
