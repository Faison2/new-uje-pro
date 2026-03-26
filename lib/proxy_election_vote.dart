import 'dart:convert';
import 'package:uje/home_screen.dart';
import 'package:uje/constants/ui_constants.dart';
import 'package:uje/model/VoterModel.dart';
import 'package:uje/model/candidate_model.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:uje/services.dart';

import 'package:flutter/material.dart';
import 'package:loader_overlay/loader_overlay.dart';

import 'constants/constants.dart';

class ProxyElectionVotePage extends StatefulWidget {
  final String cdsString;
  final String resNumber;
  final String voteDetails;

  const ProxyElectionVotePage({
    Key? key,
    required this.cdsString,
    required this.resNumber,
    required this.voteDetails,
    // required this.responseMessage,
  }) : super(key: key);

  @override
  State<ProxyElectionVotePage> createState() => _ProxyElectionVotePageState();
}

class _ProxyElectionVotePageState extends State<ProxyElectionVotePage> {
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
    getCandidateList(widget.resNumber, widget.cdsString);
    super.initState();
  }

  getCandidateList(String resoNumber, String cdsNo) async {
    String candidateListUrl =
        "$baseApiUrl/getCandidateList";
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
    String voteUrl =
        "$baseApiUrl/CommitVoteElectionRes";
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
        if(responseJson[0]["responseMessage"] == "Already Voted"){
          showToast(context, responseJson[0]["responseMessage"]);

          setState(() {
            responseVoteMessage = responseJson[0]["responseMessage"].toString();
          });
        } else {
          showToast(context, "${responseJson[0]["responseMessage"]}");
          context.loaderOverlay.hide();
        }
        context.loaderOverlay.hide();
      }
    } else {
      debugPrint('Error failed');
      showToast(context, "Vote Failed:  ${responseJson[0]["responseMessage"]}");

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
          body: Container(
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Text(
                      voteDetails,
                      style: TextStyle(
                          color: Colors.red,
                          fontSize: 15,
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: SizedBox(

                        height: MediaQuery.of(context).size.height * 0.7,
                        width: MediaQuery.of(context).size.width,
                        child: Scrollbar(
                          child: ListView.builder(
                              itemCount: candidates.length,
                              itemBuilder: (context, index) {
                                return candidateTile(
                                    context,
                                    candidates[index].nomineeName!,
                                    cdsString,
                                    candidates[index].orderNumber!,
                                    candidates[index].resNo!,
                                    candidates[index].resExistingVote!);
                              }),
                        ),
                      ),
                    ),
                    MaterialButton(
                      height: 40,
                      minWidth: 150,
                      onPressed: () {
                        submitVote(context, widget.cdsString, widget.resNumber);
                        //showToast(context, "Voted successfully");
                        Navigator.pop(context);
                        candidates.clear();

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
              )),
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
    return Container(
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(), // Set the scroll physics
        child: SizedBox(
          height: 60,
          child: Card(
            elevation: 5.0,
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    height: 60,
                    width: 250,
                    child: Text(
                      nomineeName,
                      style: const TextStyle(fontSize: 15.0),
                    ),
                  ),
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(2.0),
                        child: MaterialButton(
                          height: 30,
                          minWidth: 90,
                          onPressed: () {
                            context.loaderOverlay.show();
                            postCandidateVote(cdsString, orderNumber, resolutionNumber, "1");
                            candidates.clear();
                          },
                          color: Colors.green[800],
                          child: resExistingVote == "1"
                              ? Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: const [
                              Icon(Icons.check),
                              Text(
                                "Yes",
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          )
                              : const Text(
                            "Yes",
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(2.0),
                        child: MaterialButton(
                          height: 30,
                          minWidth: 90,
                          onPressed: () {
                            context.loaderOverlay.show();
                            postCandidateVote(cdsString, orderNumber, resolutionNumber, "3");
                            candidates.clear();
                          },
                          color: Colors.amber[100],
                          child: const Text(
                            "Recast",
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
