import 'dart:convert';

import 'package:uje/model/VoterModel.dart';
import 'package:uje/model/candidate_model.dart';
import 'package:uje/services.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:loader_overlay/loader_overlay.dart';

import 'constants/constants.dart';
import 'constants/ui_constants.dart';
import 'home_screen.dart';

class ShareholderElectionVoteScreen extends StatefulWidget {
  final String cdsString;
  final String resNumber;
  final String voteDetails;

  const ShareholderElectionVoteScreen({
    Key? key,
    required this.cdsString,
    required this.resNumber,
    required this.voteDetails,
  }) : super(key: key);

  @override
  State<ShareholderElectionVoteScreen> createState() =>
      _ShareholderElectionVoteScreenState();
}

class _ShareholderElectionVoteScreenState
    extends State<ShareholderElectionVoteScreen> {
  TextEditingController voterController = TextEditingController();
  String respRef = "";
  String responseMessage = "";

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
    getCandidateList(widget.resNumber, widget.cdsString);
    super.initState();
  }

  getCandidateList(String resoNumber, String cdsNo) async {
    String candidateListUrl = "$baseApiUrl/getCandidateList";
    final response = await http.post(
      Uri.parse(candidateListUrl),
      body: {"resNo": resoNumber, "CDSNo": cdsNo},
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
      });
    } else {
      debugPrint('Error failed to retrieve candidates');
    }
    context.loaderOverlay.hide();
  }

  postCandidateVote(
      String cdsNo, orderNumber, resolutionNumber, voteType) async {
    String voteUrl = "$baseApiUrl/CommitVoteElectionRes";
    final body = {
      "CDSNo": cdsNo,
      "ResolutionNumber": resolutionNumber,
      "Vote": orderNumber,
      "VoteType": voteType,
      "isShareholderorProxy": "Shareholder"
    };

    final response = await http.post(
      Uri.parse(voteUrl),
      body: body,
    );
    final responseJson = json.decode(response.body);
    if (response.statusCode == 200) {
      if (responseJson[0]["responseCode"] == 0) {
        if (responseJson[0]["responseMessage"] != "Already Voted") {
          showToast(context, responseJson[0]["responseMessage"]);
        } else {
          showToast(context, responseJson[0]["responseMessage"]);
        }
        context.loaderOverlay.hide();

        setState(() {
          responseVoteMessage = responseJson[0]["responseMessage"].toString();
        });

        context.loaderOverlay.hide();
      }
    } else {
      debugPrint('Error failed');
      showToast(context, responseJson[0]["responseMessage"]);
      context.loaderOverlay.hide();
    }
    getCandidateList(resolutionNumber, cdsNo);
    context.loaderOverlay.hide();
  }

  @override
  Widget build(BuildContext context) {
    String resNumber = widget.resNumber;
    String cdsString = widget.cdsString;
    String voteDetails = widget.voteDetails;

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
      body: SizedBox(
        height: screenHeight(context),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(2.0),
          child: Column(
            children: [
              Text(
                voteDetails,
                style: TextStyle(
                    color: Colors.red,
                    fontSize: 12,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(
                height: 10,
              ),
              Container(
                height: MediaQuery.of(context).size.height * 0.70,
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
              MaterialButton(
                height: 40,
                minWidth: 150,
                onPressed: () {
                  candidates.clear();
                  context.loaderOverlay.show();
                  submitVote(context, widget.cdsString, widget.resNumber);
                },
                color: Colors.green[800],
                child: const Text("SUBMIT",
                    style: TextStyle(
                      fontSize: 15,
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
              padding: const EdgeInsets.all(1.0),
              child: Row(
                children: [
                  SizedBox(
                    height: 60,
                    width: 120,
                    child: Text(
                      nomineeName,
                      style: Theme.of(context).textTheme.bodySmall!.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: Colors.black,
                      )
                    ),
                  ),
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(1.0),
                        child: MaterialButton(
                          height: 25,
                          minWidth: 25,
                          onPressed: () {
                            context.loaderOverlay.show();
                            postCandidateVote(
                                cdsString, orderNumber, resolutionNumber, "1");
                            candidates.clear();
                          },
                          color: Colors.green[800],
                          child: resExistingVote == "1"
                              ? Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: const [
                                    Icon(Icons.check, size: 15),
                                    Text(
                                      "Yes",
                                      style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                )
                              : const Text(
                                  "Yes",
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold),
                                ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(1.0),
                        child: MaterialButton(
                          height: 25,
                          minWidth: 25,
                          onPressed: () {
                            context.loaderOverlay.show();
                            postCandidateVote(
                                cdsString, orderNumber, resolutionNumber, "3");
                            candidates.clear();
                          },
                          color: Colors.amber[100],
                          child: const Text(
                            "Recast",
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ) // Portrait Layout
        : Container(
            height: 60,
            child: Card(
              elevation: 5.0,
              child: Padding(
                padding: const EdgeInsets.all(2.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.6,
                      child: Text(
                        nomineeName,
                          style: Theme.of(context).textTheme.bodySmall!.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: Colors.black,
                          )
                      )
                    ),
                    Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(2.0),
                          child: MaterialButton(
                            height: 40,
                            minWidth: 100,
                            onPressed: () {
                              context.loaderOverlay.show();
                              postCandidateVote(cdsString, orderNumber,
                                  resolutionNumber, "1");
                              candidates.clear();
                            },
                            color: Colors.green[800],
                            child: resExistingVote == "1"
                                ? Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: const [
                                      Icon(Icons.check, size: 15),
                                      Text(
                                        "Yes",
                                        style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  )
                                : const Text(
                                    "Yes",
                                    style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold),
                                  ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(2.0),
                          child: MaterialButton(
                            height: 40,
                            minWidth: 100,
                            onPressed: () {
                              context.loaderOverlay.show();
                              postCandidateVote(cdsString, orderNumber,
                                  resolutionNumber, "3");
                              candidates.clear();
                            },
                            color: Colors.amber[100],
                            child: const Text(
                              "Recast",
                              style: TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
  }
}
