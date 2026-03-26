import 'dart:convert';

import 'package:uje/model/candidate_model.dart';
import 'package:flutter/material.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:http/http.dart' as http;

import 'constants/constants.dart';
import 'constants/ui_constants.dart';

class ShowCandidatesPage extends StatefulWidget {
  const ShowCandidatesPage({Key? key}) : super(key: key);

  @override
  State<ShowCandidatesPage> createState() => _ShowCandidatesPageState();
}

class _ShowCandidatesPageState extends State<ShowCandidatesPage> {
  List<CandidateModel> candidates = [];
  String responseVoteMessage = "";
  String cdsString = "";

  postCandidateVote(
      String cdsNo, orderNumber, resolutionNumber, voteType) async {
    String voteUrl =
        "$baseApiUrl/CommitVoteElectionRes";

    final body = {
      "CDSNo": cdsNo,
      "ResolutionNumber": resolutionNumber,
      "Vote": orderNumber,
      "VoteType": voteType,
      "isShareholderorProxy": "test"
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
        setState(() {
          responseVoteMessage = responseJson[0]["responseMessage"].toString();
        });
        context.loaderOverlay.hide();
      }
    } else {
      showToast(context, responseJson[0]["responseMessage"]);

      context.loaderOverlay.hide();
    }
    context.loaderOverlay.hide();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
          scrollDirection: Axis.vertical,
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
            width: 250,
            child: Text(
              nomineeName,
              style: const TextStyle(fontSize: 10.0),
            ),
          ),
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: MaterialButton(
                    onPressed: () {
                      context.loaderOverlay.show();
                      postCandidateVote(
                          cdsString, orderNumber, resolutionNumber, "1");
                    },
                    color: Colors.green[800],
                    child: resExistingVote == "1"
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: const [Icon(Icons.check), Text("Yes")],
                          )
                        : const Text("Yes")),
              ),
              // Padding(
              //   padding: const EdgeInsets.all(8.0),
              //   child: MaterialButton(
              //       onPressed: () {
              //         context.loaderOverlay.show();
              //         postCandidateVote(
              //             cdsString, orderNumber, resolutionNumber, "2");
              //       },
              //       color: Colors.amber,
              //       child: resExistingVote == "2"
              //           ? Row(
              //               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              //               children: const [Icon(Icons.clear), Text("No")],
              //             )
              //           : const Text("No")),
              // ),
              Padding(
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
}
