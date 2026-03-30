import 'package:uje/proxy_election_vote.dart';
import 'package:uje/ProxyNormalVote.dart';
import 'package:uje/model/proxyShareholder_model.dart';
import 'package:flutter/material.dart';
import 'package:loader_overlay/loader_overlay.dart';

import '../Home_Screen.dart';

Future<void> showShareholderListDialog(
    BuildContext context,
    String voteCode,
    String resolution,
    String resNumber,
    String resolutionSEQ,
    String proxyNumber,
    String type,
    String vote,
    String shareholder,
    List<ShareholderModel> shareholders) async {
  return type == "Normal Resolution"
      ? Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => ProxyNormalVotePage(
                  resNumber: resNumber,
                  cdsString: shareholder,
                  resolution: resolution,
                  resolutionSEQ: resolutionSEQ,
                  proxyNumber: proxyNumber)),
        )
      : showDialog<void>(
          context: context,
          barrierDismissible: false, // user must tap button!
          builder: (BuildContext context) {
            return Container(
              child: AlertDialog(
                title: Text(resolution,
                    style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.red)),
                content: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height,
                    width: MediaQuery.of(context).size.width,
                    child: Column(
                      children: [
                        SingleChildScrollView(
                          scrollDirection: Axis.vertical,
                          child: SizedBox(
                            height: MediaQuery.of(context).size.height * 0.6,
                            child: ListView.builder(
                              itemCount: shareholders.length,
                              itemBuilder: (context, index) {
                                return SingleChildScrollView(
                                    scrollDirection: Axis.vertical,
                                    child: shareholderItem(
                                        context,
                                        shareholders[index].shareholder!,
                                        shareholders[index].names!,
                                        shareholders[index].shares!,
                                        shareholders[index].vote!,
                                        shareholders[index].category!,
                                        resNumber,
                                        resolutionSEQ,
                                        proxyNumber,
                                        resolution));
                              },
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                actions: <Widget>[
                  TextButton(
                    child: const Text('Back',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        )),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            );
          },
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
      ? Card(
          elevation: 5.0,
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    height: 30,
                    width: 100,
                    child: Text(
                      names,
                      style: const TextStyle(fontSize: 10.0),
                    ),
                  ),
                  MaterialButton(
                      height: 35,
                      minWidth: 40,
                      onPressed: () {
                        context.loaderOverlay.show();

                        // getCandidateList(resNo, shareholder);

                        Future.delayed(const Duration(milliseconds: 700), () {
                          context.loaderOverlay.hide();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ProxyElectionVotePage(
                                    resNumber: resNo,
                                    cdsString: shareholder,
                                    voteDetails: resolution)),
                          );
                        });
                      },
                      color: Colors.green[800],
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: const [
                          Text("Elect",
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ))
                        ],
                      ))
                ]),
          ),
        ) //Dialog landscape view
      : Container(
          child: Card(
          elevation: 5.0,
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    width: 400,
                    child: Text(
                      names,
                      style: const TextStyle(fontSize: 19.0),
                    ),
                  ),
                  MaterialButton(
                      height: 43,
                      minWidth: 110,
                      onPressed: () {
                        context.loaderOverlay.show();

                        // getCandidateList(resNo, shareholder);

                        Future.delayed(const Duration(milliseconds: 700), () {
                          // _showCandidateListDialog(
                          //     context, voteCode, shareholder, resolution1);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ProxyElectionVotePage(
                                    resNumber: resNo,
                                    cdsString: shareholder,
                                    voteDetails: resolution)),
                          );
                          context.loaderOverlay.hide();
                        });
                      },
                      color: Colors.green[800],
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: const [
                          Text("Elect",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ))
                        ],
                      ))
                ]),
          ),
        ));
}
