import 'dart:convert';
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
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
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:loader_overlay/loader_overlay.dart';
import 'constants/ui_constants.dart';

class ProxyVotePage extends StatefulWidget {
  const ProxyVotePage({Key? key}) : super(key: key);

  @override
  State<ProxyVotePage> createState() => _ProxyVotePageState();
}

class _ProxyVotePageState extends State<ProxyVotePage>
    with SingleTickerProviderStateMixin {
  // ── Coop Bank Tanzania Brand Colors ───────────────────
  static const Color coopGreen      = Color(0xFF3AA935);
  static const Color coopDarkBlue   = Color(0xFF123B73);
  static const Color coopMidBlue    = Color(0xFF1E5FB0);
  static const Color coopLightGreen = Color(0xFF5FC257);
  static const Color coopBackground = Color(0xFFF2F6FB);
  static const Color coopSurface    = Color(0xFFFFFFFF);
  static const Color coopDivider    = Color(0xFFD6E4F5);
  static const Color coopTextDark   = Color(0xFF0D1F33);

  TextEditingController voterController = TextEditingController();
  String respRef = "";
  String responseMessage = "";
  String agmId = "";
  String company = "";
  String meetingInfo = "";
  String cdsString = "";
  String responseVoteMessage = "";
  String name = "";
  String cdsNo = "";
  String shares = "";
  String regStatus = "";
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

  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    shareholders = [];
    shareholders.clear();
    voterController.addListener(() {
      respRef = voterController.text;
    });
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    voterController.dispose();
    super.dispose();
  }

  // ── API Methods ───────────────────────────────────────

  handleVote(String voteCode) async {
    String urlAllDetails = '$baseApiUrl/getVoteDetails';
    cardState = voteCode;
    final response = await http.post(
      Uri.parse(urlAllDetails),
      body: {"VoteCode": voteCode},
    );
    if (response.statusCode == 200) {
      final responseJson = json.decode(response.body);
      if (responseJson[0]["responseCode"] == 4) {
        _showToast(responseJson[0]["responseMessage"]);
        return responseJson[0]["responseMessage"].toString();
      } else if (responseJson[0]["responseCode"] == 2) {
        _showToast(responseJson[0]["responseMessage"]);
        return responseJson[0]["responseMessage"].toString();
      } else if (responseJson[0]["responseCode"] == 6) {
        proxyVoterModel = ProxyVoterModel.fromJson(responseJson[0]);
        for (int i = 0; i < responseJson[0]["resItem"].length; i++) {
          resolutions.add(responseJson[0]["resItem"][i]);
        }
        setState(() {
          cdsString = "${proxyVoterModel.cDSNo}";
          meetingInfo =
          "Meeting Information: ${proxyVoterModel.meetingInfo}";
          company = "${proxyVoterModel.resItem![0]}";
          isVisible = true;
        });
        _animController.forward(from: 0);
        context.loaderOverlay.hide();
      }
    } else {
      _showToast("Failed to retrieve data");
      context.loaderOverlay.hide();
    }
    context.loaderOverlay.hide();
  }

  getResolutions(String proxyNumber) async {
    String urlResolutions = "$baseApiUrl/getVoteDetailsProxy";
    final response = await http.post(
      Uri.parse(urlResolutions),
      body: {"CDSNo": proxyNumber},
    );
    final responseJson = json.decode(response.body);
    if (response.statusCode == 200) {
      if (responseJson[0]["responseCode"] == 0) {
        voteStatus = responseJson[0]["responseMesssage"].toString();
        proxyVoterModel = ProxyVoterModel.fromJson(responseJson[0]);
        if (responseJson[0]["resItem"] != null) {
          for (int i = 0; i < responseJson[0]["resItem"].length; i++) {
            resolutions.add(responseJson[0]["resItem"][i]);
          }
          setState(() {
            name = "${proxyVoterModel.names}";
            proxyNumber =
                responseJson[0]["ProxyCDSNo"].toString();
            isVisible = true;
          });
          _animController.forward(from: 0);
          context.loaderOverlay.hide();
        } else {
          _showToast("No resolutions at the moment");
          context.loaderOverlay.hide();
        }
      } else {
        _showToast(responseJson[0]["responseMessage"]);
        setState(() {
          responseVoteMessage =
              responseJson[0]["responseMessage"].toString();
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
        _showToast(responseJson[0]["responseMessage"]);
        setState(() {
          responseVoteMessage =
              responseJson[0]["responseMessage"].toString();
        });
        context.loaderOverlay.hide();
      } else {
        for (int i = 0; i < responseJson.length; i++) {
          holders.add(ShareholderModel.fromJson(responseJson[i]));
        }
        context.loaderOverlay.hide();
        return holders;
      }
    } else {
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
        _showToast(responseJson[0]["responseMessage"]);
        context.loaderOverlay.hide();
      }
      int len = responseJson.length;
      for (int i = 0; i < len; i++) {
        candidates.add(CandidateModel.fromJson(responseJson[i]));
      }
      setState(() {
        resoNumber = responseJson[0]["resNo"].toString();
      });
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
        _showToast(responseJson[0]["responseMessage"]);
        setState(() {
          responseVoteMessage =
              responseJson[0]["responseMessage"].toString();
        });
        context.loaderOverlay.hide();
      }
      int len = responseJson.length;
      for (int i = 0; i < len; i++) {
        candidates.add(CandidateModel.fromJson(responseJson[i]));
      }
      setState(() {
        resoNumber = responseJson[0]["resNo"].toString();
      });
    }
    context.loaderOverlay.hide();
  }

  handleNormalVote(
      String cdsNumber, String resNumber, String voteType) async {
    String urlVoteNormalRes = "$baseApiUrl/CommitVoteNormalRes";
    final deviceInfo = await _getDeviceInfo();

    final response = await http.post(
      Uri.parse(urlVoteNormalRes),
      body: {
        "CDSNo": cdsNumber,
        "ResolutionNumber": resNumber,
        "Vote": voteType,
        "DeviceId": deviceInfo['deviceId'],
        "DevicePlatform": deviceInfo['platform'],
        "DeviceModel": deviceInfo['model'],
        "OSVersion": deviceInfo['osVersion'],
      },
    );
    final responseJson = json.decode(response.body);
    if (response.statusCode == 200) {
      _showToast(responseJson[0]["responseMessage"]);
      setState(() {
        voteStatus = responseJson[0]["responseMesssage"].toString();
      });
    } else {
      _showToast(responseJson[0]["responseMessage"]);
    }
    context.loaderOverlay.hide();
  }

  handleElectionVote(String cdsNumber, orderNumber, resolutionNumber,
      voteType) async {
    String voteUrl = "$baseApiUrl/CommitVoteElectionRes";
    final deviceInfo = await _getDeviceInfo();

    final response = await http.post(
      Uri.parse(voteUrl),
      body: {
        "CDSNo": cdsNo,
        "ResolutionNumber": resolutionNumber,
        "Vote": orderNumber,
        "VoteType": voteType,
        "isShareholderorProxy": "Proxy",
        "DeviceId": deviceInfo['deviceId'],
        "DevicePlatform": deviceInfo['platform'],
        "DeviceModel": deviceInfo['model'],
        "OSVersion": deviceInfo['osVersion'],
      },
    );
    final responseJson = json.decode(response.body);
    if (response.statusCode == 200) {
      if (responseJson[0]["responseCode"] == 0) {
        _showToast(responseJson[0]["responseMessage"]);
      }
    } else {
      _showToast(responseJson[0]["responseMessage"]);
    }
    context.loaderOverlay.hide();
  }

  handleNormalVoteAll(
      String resolutionSEQ, String proxyNumber, String voteType) async {
    String urlVoteNormalResAll = "$baseApiUrl/CommitVoteNormalResALL";
    final deviceInfo = await _getDeviceInfo();

    final response = await http.post(
      Uri.parse(urlVoteNormalResAll),
      body: {
        "resSEQ": resolutionSEQ,
        "ProxyCDS": proxyNumber,
        "Vote": voteType,
        "DeviceId": deviceInfo['deviceId'],
        "DevicePlatform": deviceInfo['platform'],
        "DeviceModel": deviceInfo['model'],
        "OSVersion": deviceInfo['osVersion'],
      },
    );
    final responseJson = json.decode(response.body);
    if (response.statusCode == 200) {
      _showToast(responseJson[0]["responseMessage"]);
      setState(() {
        voteStatus = responseJson[0]["responseMesssage"].toString();
      });
    } else {
      _showToast(responseJson[0]["responseMessage"]);
    }
    context.loaderOverlay.hide();
  }

  handleElectionVoteAll(String resolutionSEQ, String proxyNumber,
      String orderNumber, String voteType) async {
    String urlVoteNormalResAll = "$baseApiUrl/VoteForProxyResElectALL";
    final deviceInfo = await _getDeviceInfo();

    final response = await http.post(
      Uri.parse(urlVoteNormalResAll),
      body: {
        "resSEQ": resolutionSEQ,
        "ProxyCDS": proxyNumber,
        "Vote": orderNumber,
        "VoteType": voteType,
        "DeviceId": deviceInfo['deviceId'],
        "DevicePlatform": deviceInfo['platform'],
        "DeviceModel": deviceInfo['model'],
        "OSVersion": deviceInfo['osVersion'],
      },
    );
    final responseJson = json.decode(response.body);
    if (response.statusCode == 200) {
      _showToast(responseJson[0]["responseMessage"]);
      setState(() {
        voteStatus = responseJson[0]["responseMesssage"].toString();
      });
    } else {
      _showToast(responseJson[0]["responseMessage"]);
    }
    context.loaderOverlay.hide();
  }

  // ── Helper ────────────────────────────────────────────

  Future<Map<String, String>> _getDeviceInfo() async {
    final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    Map<String, String> info = {};
    try {
      if (Platform.isAndroid) {
        AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
        info = {
          'platform': 'Android',
          'model': androidInfo.model ?? 'Unknown',
          'osVersion': androidInfo.version.release ?? 'Unknown',
          'deviceId': androidInfo.id ?? 'unknown',
        };
      } else if (Platform.isIOS) {
        IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
        info = {
          'platform': 'iOS',
          'model': iosInfo.model ?? 'Unknown',
          'osVersion': iosInfo.systemVersion ?? 'Unknown',
          'deviceId': iosInfo.identifierForVendor ?? 'unknown',
        };
      }
    } catch (e) {
      debugPrint('Device info error: $e');
    }
    return info;
  }

  void _showToast(String msg) {
    Fluttertoast.showToast(
      msg: msg,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: coopDarkBlue,
      textColor: Colors.white,
      fontSize: 14.0,
      timeInSecForIosWeb: 3,
    );
  }

  void _clearAll() {
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
  }


  // ── Build ─────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    voteCode = respRef;
    return Scaffold(
      backgroundColor: coopBackground,
      appBar: AppBar(
        backgroundColor: coopDarkBlue,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        title: const Text(
          'Proxy Voting',
          style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Colors.white),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: Container(
            height: 4,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [coopLightGreen, coopGreen],
              ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Search Card ───────────────────────────
            Container(
              decoration: BoxDecoration(
                color: coopSurface,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: coopDarkBlue.withOpacity(0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Card header
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: coopDarkBlue.withOpacity(0.06),
                      borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(16)),
                      border: Border(
                          bottom: BorderSide(
                              color: coopDarkBlue.withOpacity(0.1),
                              width: 1)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 4,
                          height: 16,
                          decoration: BoxDecoration(
                            color: coopDarkBlue,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'PROXY LOOKUP',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: coopDarkBlue,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        // CDS Input
                        TextFormField(
                          controller: voterController,
                          style: const TextStyle(
                              fontSize: 14, color: coopTextDark),
                          decoration: InputDecoration(
                            labelText: 'Proxy CDS Number',
                            hintText: 'Enter your proxy CDS No.',
                            labelStyle: TextStyle(
                                color: coopDarkBlue.withOpacity(0.7),
                                fontSize: 13),
                            prefixIcon: const Icon(
                                Icons.badge_outlined,
                                color: coopDarkBlue,
                                size: 20),
                            filled: true,
                            fillColor: coopBackground,
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 14),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                  color: coopDarkBlue.withOpacity(0.2)),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                  color: coopDarkBlue.withOpacity(0.25)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(
                                  color: coopDarkBlue, width: 1.5),
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        // Search & Clear Buttons
                        Row(
                          children: [
                            Expanded(
                              child: SizedBox(
                                height: 46,
                                child: ElevatedButton.icon(
                                  icon: const Icon(Icons.search,
                                      color: Colors.white, size: 18),
                                  label: const Text('Search',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15)),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: coopDarkBlue,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                        BorderRadius.circular(10)),
                                    elevation: 2,
                                  ),
                                  onPressed: () {
                                    context.loaderOverlay.show();
                                    getResolutions(respRef);
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: SizedBox(
                                height: 46,
                                child: OutlinedButton.icon(
                                  icon: const Icon(
                                      Icons.clear_all_rounded,
                                      color: Colors.redAccent,
                                      size: 18),
                                  label: const Text('Clear',
                                      style: TextStyle(
                                          color: Colors.redAccent,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15)),
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(
                                        color: Colors.redAccent,
                                        width: 1.2),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                        BorderRadius.circular(10)),
                                  ),
                                  onPressed: _clearAll,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ── Proxy Info Banner (visible after search) ──
            if (isVisible && name.isNotEmpty) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [coopDarkBlue, coopMidBlue],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: coopDarkBlue.withOpacity(0.25),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.person_outline,
                          color: Colors.white, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'PROXY NAME',
                            style: TextStyle(
                              color: Colors.white60,
                              fontSize: 10,
                              letterSpacing: 1.0,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: coopGreen.withOpacity(0.25),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: coopGreen.withOpacity(0.5)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.how_to_vote,
                              color: Color(0xFFB8F0B5), size: 14),
                          const SizedBox(width: 4),
                          Text(
                            '${proxyVoterModel.resItem?.length ?? 0} Resolutions',
                            style: const TextStyle(
                              color: Color(0xFFB8F0B5),
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // ── Resolutions List ──────────────────────
            if (isVisible) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Container(
                    width: 4,
                    height: 16,
                    decoration: BoxDecoration(
                      color: coopGreen,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'RESOLUTIONS',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: coopGreen,
                      letterSpacing: 1.0,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              FadeTransition(
                opacity: _fadeAnim,
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: proxyVoterModel.resItem?.length ?? 0,
                  itemBuilder: (context, index) {
                    return _resolutionTile(
                      context,
                      index,
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
            ],
          ],
        ),
      ),
    );
  }

  // ── Resolution Tile ───────────────────────────────────

  Widget _resolutionTile(
      BuildContext context,
      int index,
      String voteDetails,
      String type,
      String resNumber,
      String resolutionSEQ,
      String proxyNumber,
      String vote,
      String shareholder,
      ) {
    final bool isElection = type != "Normal Resolution";

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: coopSurface,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: coopDarkBlue.withOpacity(0.07),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: coopDivider),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Resolution header row
            Row(
              children: [
                // Index badge
                Container(
                  width: 30,
                  height: 30,
                  decoration: const BoxDecoration(
                    color: coopDarkBlue,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                // Resolution number chip
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: coopBackground,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'Res. $resNumber',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: coopDarkBlue,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Type badge
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: isElection
                        ? coopGreen.withOpacity(0.12)
                        : Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    isElection ? 'Election' : 'Normal',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: isElection ? coopMidBlue : Colors.green[700],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            // Resolution text
            Text(
              voteDetails,
              style: const TextStyle(
                fontSize: 14,
                color: coopTextDark,
                height: 1.4,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 14),
            // Vote button
            SizedBox(
              width: double.infinity,
              height: 42,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.how_to_vote_outlined,
                    color: Colors.white, size: 16),
                label: const Text(
                  'CAST VOTE',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    letterSpacing: 0.8,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: coopDarkBlue,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  elevation: 2,
                ),
                onPressed: () async {
                  context.loaderOverlay.show();
                  if (isElection) {
                    shareholders = await getShareholderList(
                        respRef, resNumber);
                  }
                  Future.delayed(
                      const Duration(milliseconds: 500), () {
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
              ),
            ),
          ],
        ),
      ),
    );
  }
}