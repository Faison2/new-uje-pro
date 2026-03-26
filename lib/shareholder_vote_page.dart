import 'dart:convert';
import 'package:uje/shareholder_election_vote_all.dart';
import 'package:uje/constants/constants.dart';
import 'package:uje/model/VoterModel.dart';
import 'package:uje/model/candidate_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:loader_overlay/loader_overlay.dart';

import 'constants/ui_constants.dart';

class ShareholderVotePage extends StatefulWidget {
  // final String responseMessage;
  const ShareholderVotePage({
    Key? key,
    // required this.responseMessage,
  }) : super(key: key);

  @override
  State<ShareholderVotePage> createState() => _ShareholderVotePageState();
}

class _ShareholderVotePageState extends State<ShareholderVotePage> {
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

  String voteType = "";
  List<CandidateModel> candidates = [];
  String resolutionText = "";
  String resolutionNo = "";
  String cardState = "";

  String voteStatus = "";

  @override
  void initState() {
    super.initState();
    voterController.addListener(() {
      cdsNo = voterController.text;
    });
  }

  getResolutions(String cdsNo) async {
    String urlAllDetails =
        '$baseApiUrl/getVoteDetails';
    debugPrint("CDS No. is: $cdsNo");
    cardState = cdsNo;

    final response = await http.post(
      Uri.parse(urlAllDetails),
      body: {"CDSNo": cdsNo},
    );

    if (response.statusCode == 200 || response.statusCode == 400) {
      final responseJson = json.decode(response.body);
      if (responseJson[0]["responseCode"] == 4) {
        Fluttertoast.showToast(
            msg: "${responseJson[0]["responseMessage"]}",
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            textColor: Colors.white,
            fontSize: 18.0);
        context.loaderOverlay.hide();
        debugPrint(responseJson[0]["responseMessage"]);
        return responseJson[0]["responseMessage"].toString();
      } else if (responseJson[0]["responseCode"] == 2) {
        debugPrint(responseJson[0]["responseMessage"]);
        showToast(context, responseJson[0]["responseMessage"]);
        context.loaderOverlay.hide();
        return responseJson[0]["responseMessage"].toString();
      } else if (responseJson[0]["responseCode"] == 6 ||
          responseJson[0]["resItem"].length == null) {
        // ignore: avoid_print
        voterModel = VoterModel.fromJson(responseJson[0]);

        for (int? i = 0; i! < responseJson[0]["resItem"].length; i++) {
          debugPrint(responseJson[0]["resItem"][i].toString());
          resolutions.add(responseJson[0]["resItem"][i]);
          // voterModel.resItem?.add(responseJson[0]["resItem"][i]);
        }

        setState(() {
          cdsString = "${voterModel.cDSNo}";
          meetingInfo = "Meeting Information: ${voterModel.meetingInfo}";
          name = "${voterModel.names}";
          shares = "${voterModel.shares}";
          regStatus = "${voterModel.regStatus}";
          company = "${voterModel.company}";

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
          fontSize: 18.0);
      context.loaderOverlay.hide();
    }
    context.loaderOverlay.hide();
  }

  handleNormalResVote(String cdsNo, String resNumber, String vote) async {
    String urlVoteNormalRes =
        "$baseApiUrl/CommitVoteNormalRes";
    debugPrint("Vote Code is $cdsNo");
    final response = await http.post(Uri.parse(urlVoteNormalRes),
        body: {"CDSNo": cdsNo, "ResolutionNumber": resNumber, "Vote": vote});

    final responseJson = json.decode(response.body);
    if (response.statusCode == 200 || response.statusCode == 400) {
      // ignore: avoid_print
      voteStatus = responseJson[0]["responseMesssage"].toString();

      Fluttertoast.showToast(
          msg: "${responseJson[0]["responseMessage"]}",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.green[800],
          textColor: Colors.white,
          fontSize: 18.0);
      context.loaderOverlay.hide();
      setState(() {
        voteStatus = responseJson[0]["responseMessage"].toString();
      });
    } else {
      Fluttertoast.showToast(
          msg: "${responseJson[0]["responseMessage"]}",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.green[800],
          textColor: Colors.white,
          fontSize: 18.0);
      context.loaderOverlay.hide();
    }
    getResolutions(cdsNo);
  }

  getCandidateList(String resoNumber, String cdsNo) async {
    String candidateListUrl =
        "$baseApiUrl/getCandidateList";
    debugPrint("TESTING PURPOSES: $resoNumber");
    final response = await http.post(
      Uri.parse(candidateListUrl),
      body: {"resNo": resoNumber, "CDSNo": cdsNo},
    );

    if (response.statusCode == 200 || response.statusCode == 400) {
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

  postCandidateVote(
      String cdsNo, orderNumber, resolutionNumber, voteType) async {
    String voteUrl =
        "$baseApiUrl/CommitVoteElectionRes";

    final body = {
      "CDSNo": cdsNo,
      "ResolutionNumber": resolutionNumber,
      "Vote": orderNumber,
      "VoteType": voteType,
      "isShareholderorProxy": "Shareholder"
    };
    debugPrint(body.toString());

    final response = await http.post(
      Uri.parse(voteUrl),
      body: body,
    );
    final responseJson = json.decode(response.body);
    if (response.statusCode == 200 || response.statusCode == 400) {
      if (responseJson[0]["responseCode"] == 0) {
        debugPrint('SUCCESSFUL!!! \n $responseJson');
        Fluttertoast.showToast(
            msg: "${responseJson[0]["responseMessage"]}",
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.green[800],
            textColor: Colors.white,
            fontSize: 18.0);
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
          backgroundColor: Colors.green[800],
          textColor: Colors.white,
          fontSize: 18.0);

      context.loaderOverlay.hide();
    }
    context.loaderOverlay.hide();
  }

  @override
  Widget build(BuildContext context) {
    setState(() {
      cdsNo = cdsString;
    });
    return Scaffold(
      appBar: AppBar(
        title: const Text("Shareholder Details"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(4.0),
        child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(
            height: 25,
          ),
          // Text("You have successfully Registered! $responseMessage"),

          TextField(
            controller: voterController,
            onChanged: (text) {
              if (text == cdsNo) {}
            },
            decoration: InputDecoration(
              labelText: "Enter CDS No.",
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
            ),
          ),
          SizedBox(height: 10,),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              MaterialButton(
                  height: 50,
                  minWidth: 120,
                  color: Colors.green[800],
                  onPressed: () {
                    context.loaderOverlay.show();
                    getResolutions(cdsNo);
                    // setState(() {});
                  },
                  child: const Text("Search",
                      style: TextStyle(
                        fontSize: 23,
                        fontWeight: FontWeight.bold,
                      ))),
              MaterialButton(
                  color: Colors.red,
                  height: 50,
                  minWidth: 120,
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
                        fontSize: 23,
                        fontWeight: FontWeight.bold,
                      ))),
            ],
          ),
          SizedBox(height: 20,),
          //STARTING HERE
          SizedBox(
            // height: 100,
            width: screenWidth(context) ,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                shareHolderDetails("Name:", name),
                shareHolderDetails("CDS No:", cdsString),
                shareHolderDetails("Company", company),
                shareHolderDetails("Shares", shares),
                shareHolderDetails("Status", regStatus),
              ],
            ),
          ),
          const SizedBox(
            height: 20,
          ),

          isVisible
              ? SizedBox(
                height: MediaQuery.of(context).size.height * 0.5,
                width: MediaQuery.of(context).size.width,
                child: ListView.builder(
                    itemCount: voterModel.resItem!.length,
                    itemBuilder: (context, index) {
                      return voteTile(
                          context,
                          voterModel.resItem![index].resText!,
                          voterModel.resItem![index].resType!,
                          voterModel.resItem![index].resNo!,
                          voterModel.resItem![index].resExistingVote!,
                          voteType);
                    }),
              )
              : const SizedBox(),
        ],
                ),
              ),
      ),
    );
  }

  Future<void> _showCandidateListDialog(BuildContext context, String cdsString,
      String resolution, String voteType) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(resolution),
          content: SizedBox(
            height: 600,
            width: 700,
            child: ListView.builder(
              itemCount: candidates.length,
              itemBuilder: (context, index) {
                return candidateItem(
                  context,
                  candidates[index].nomineeName!,
                  cdsString,
                  candidates[index].orderNumber!,
                  candidates[index].resNo!,
                  candidates[index].resExistingVote!,
                );
              },
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                candidates.clear();
                // Navigator.of(context).pop();
                Navigator.pop(context, true);
              },
            ),
          ],
        );
      },
    );
  }

  Widget candidateItem(
    BuildContext context,
    String nomineeName,
    String cdsString,
    String orderNumber,
    String resolutionNumber,
    String resExistingVote,
  ) {
    return Card(
      elevation: 5.0,
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child:
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          SizedBox(
            width: 400,
            child: Text(
              nomineeName,
              style: const TextStyle(fontSize: 10.0),
            ),
          ),
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.all(2.0),
                child: MaterialButton(
                    onPressed: () {
                      context.loaderOverlay.show();
                      postCandidateVote(
                          cdsString, orderNumber, resolutionNumber, "1");

                      _showCandidateListDialog(
                          context, cdsString, resolutionNumber, voteType);
                    },
                    color: Colors.green[800],
                    child: resExistingVote == "1"
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: const [
                              Icon(Icons.check),
                              Text("Yes",
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ))
                            ],
                          )
                        : const Text("Yes",
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ))),
              ), Padding(
                padding: const EdgeInsets.all(8.0),
                child: MaterialButton(
                    onPressed: () {
                      context.loaderOverlay.show();
                      postCandidateVote(
                          cdsString, orderNumber, resolutionNumber, "3");
                    },
                    color: Colors.amber[100],
                    child: const Text("Recast")),
              ),
            ],
          ),
        ]),
      ),
    );
  }

  Widget shareHolderDetails(String detailTitle, String detail) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          flex: 1,
          child: const SizedBox(
          ),
        ),
        Expanded(
          flex: 2,
          child: Text(
            detailTitle,
            textAlign: TextAlign.left,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          flex: 2,
          child: Text(
            detail,
            textAlign: TextAlign.left,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget voteTile(BuildContext context, String voteDetails, String type,
      String resNumber, String resExistingVote, voteType) {
    return SingleChildScrollView(
      child: type == "Normal Resolution"
          ? Card(
        child: SizedBox(
            width: 100,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  SizedBox(
                    width: 10,
                    child: Text(
                      resNumber,
                      style: const TextStyle(fontSize: 10.0),
                    ),
                  ),
                  SizedBox(
                    width: 90,
                    child: Text(
                      voteDetails,
                      style: const TextStyle(fontSize: 10.0),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: MaterialButton(
                      height: 25,
                      minWidth: 30,
                      color: Colors.green[800],
                      onPressed: () {
                        handleNormalResVote(cdsString, resNumber, "1");
                        Future.delayed(const Duration(milliseconds: 500), () {
                          setState(() {
                            onSelected = 1;
                          });
                        });
                      },
                      child: resExistingVote == "1"
                          ? Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: const [
                          Icon(Icons.check),
                          Text("For", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold))
                        ],
                      )
                          : const Text("For", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: MaterialButton(
                      height: 25,
                      minWidth: 30,
                      color: Colors.amber,
                      onPressed: () {
                        handleNormalResVote(cdsString, resNumber, "3");
                        Future.delayed(const Duration(milliseconds: 500), () {
                          setState(() {
                            onSelected = 3;
                          });
                        });
                      },
                      child: resExistingVote == "3"
                          ? Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: const [
                          Icon(Icons.check),
                          Text("Abstain", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold))
                        ],
                      )
                          : const Text("Abstain", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: MaterialButton(
                      height: 25,
                      minWidth: 20,
                      color: Colors.red,
                      onPressed: () {
                        handleNormalResVote(cdsString, resNumber, "2");
                        Future.delayed(const Duration(milliseconds: 500), () {
                          setState(() {
                            onSelected = 2;
                          });
                        });
                      },
                      child: resExistingVote == "2"
                          ? Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: const [
                          Icon(Icons.check),
                          Text("Against", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold))
                        ],
                      )
                          : const Text("Against", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            )),
      )
          : Card(
        child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.7,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  SizedBox(
                    width: 10,
                    child: Text(
                      resNumber,
                      style: const TextStyle(fontSize: 10.0),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      voteDetails,
                      style: const TextStyle(fontSize: 10.0),
                    ),
                  ),
                  const SizedBox(
                    width: 10.0,
                  ),
                  MaterialButton(
                    height: 50,
                    minWidth: 90,
                    color: Colors.green[800],
                    onPressed: () {
                      getCandidateList(resNumber, cdsString);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ShareholderElectionVoteScreen(
                            resNumber: resNumber,
                            cdsString: cdsNo,
                            voteDetails: voteDetails,
                          ),
                        ),
                      );
                    },
                    child: const Text("Elect", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  ),
                ],
              )),
        ),
      ),
    );
  }
}
