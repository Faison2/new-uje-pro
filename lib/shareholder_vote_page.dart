import 'dart:convert';
import 'package:uje/shareholder_election_vote_all.dart';
import 'package:uje/constants/constants.dart';
import 'package:uje/model/VoterModel.dart';
import 'package:uje/model/candidate_model.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:loader_overlay/loader_overlay.dart';
import 'constants/ui_constants.dart';

class ShareholderVotePage extends StatefulWidget {
  const ShareholderVotePage({Key? key}) : super(key: key);

  @override
  State<ShareholderVotePage> createState() =>
      _ShareholderVotePageState();
}

class _ShareholderVotePageState extends State<ShareholderVotePage>
    with SingleTickerProviderStateMixin {
  // ── CRDB Brand Colors ──────────────────────────────────
  static const Color crdbGreen      = Color(0xFF3AAA35);
  static const Color crdbDarkGreen  = Color(0xFF1E7A1A);
  static const Color crdbMidGreen   = Color(0xFF2D9128);
  static const Color crdbLightGreen = Color(0xFF57C752);
  static const Color crdbBackground = Color(0xFFF2FAF2);
  static const Color crdbSurface    = Color(0xFFFFFFFF);
  static const Color crdbDivider    = Color(0xFFD4EDDA);
  static const Color crdbTextDark   = Color(0xFF0D2B0C);

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
  bool isVisible = false;
  String voteCode = "";
  VoterModel voterModel = VoterModel();
  int onSelected = 0;
  String voteType = "";
  List<CandidateModel> candidates = [];
  String resolutionText = "";
  String resolutionNo = "";
  String cardState = "";
  String voteStatus = "";

  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    voterController.addListener(() {
      cdsNo = voterController.text;
    });
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim =
        CurvedAnimation(parent: _animController, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _animController.dispose();
    voterController.dispose();
    super.dispose();
  }

  // ── Helpers ───────────────────────────────────────────

  void _showToast(String msg) {
    Fluttertoast.showToast(
      msg: msg,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: crdbDarkGreen,
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

  // ── API Methods ───────────────────────────────────────

  getResolutions(String cdsNo) async {
    String urlAllDetails = '$baseApiUrl/getVoteDetails';
    cardState = cdsNo;

    final response = await http.post(
      Uri.parse(urlAllDetails),
      body: {"CDSNo": cdsNo},
    );

    if (response.statusCode == 200 || response.statusCode == 400) {
      final responseJson = json.decode(response.body);
      if (responseJson[0]["responseCode"] == 4) {
        _showToast(responseJson[0]["responseMessage"]);
        context.loaderOverlay.hide();
        return responseJson[0]["responseMessage"].toString();
      } else if (responseJson[0]["responseCode"] == 2) {
        _showToast(responseJson[0]["responseMessage"]);
        context.loaderOverlay.hide();
        return responseJson[0]["responseMessage"].toString();
      } else if (responseJson[0]["responseCode"] == 6 ||
          responseJson[0]["resItem"].length == null) {
        voterModel = VoterModel.fromJson(responseJson[0]);
        for (int? i = 0; i! < responseJson[0]["resItem"].length; i++) {
          resolutions.add(responseJson[0]["resItem"][i]);
        }
        setState(() {
          cdsString = "${voterModel.cDSNo}";
          meetingInfo =
          "Meeting Information: ${voterModel.meetingInfo}";
          name = "${voterModel.names}";
          shares = "${voterModel.shares}";
          regStatus = "${voterModel.regStatus}";
          company = "${voterModel.company}";
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

  handleNormalResVote(
      String cdsNo, String resNumber, String vote) async {
    String urlVoteNormalRes = "$baseApiUrl/CommitVoteNormalRes";
    final response = await http.post(
      Uri.parse(urlVoteNormalRes),
      body: {
        "CDSNo": cdsNo,
        "ResolutionNumber": resNumber,
        "Vote": vote
      },
    );
    final responseJson = json.decode(response.body);
    if (response.statusCode == 200 || response.statusCode == 400) {
      _showToast(responseJson[0]["responseMessage"]);
      setState(() {
        voteStatus = responseJson[0]["responseMessage"].toString();
      });
    } else {
      _showToast(responseJson[0]["responseMessage"]);
    }
    context.loaderOverlay.hide();
    getResolutions(cdsNo);
  }

  getCandidateList(String resoNumber, String cdsNo) async {
    String candidateListUrl = "$baseApiUrl/getCandidateList";
    final response = await http.post(
      Uri.parse(candidateListUrl),
      body: {"resNo": resoNumber, "CDSNo": cdsNo},
    );
    if (response.statusCode == 200 || response.statusCode == 400) {
      final responseJson = json.decode(response.body);
      for (int i = 0; i < responseJson.length; i++) {
        candidates.add(CandidateModel.fromJson(responseJson[i]));
      }
      setState(() {
        resoNumber = responseJson[0]["resNo"].toString();
      });
    }
    context.loaderOverlay.hide();
  }

  postCandidateVote(
      String cdsNo, orderNumber, resolutionNumber, voteType) async {
    String voteUrl = "$baseApiUrl/CommitVoteElectionRes";
    final response = await http.post(
      Uri.parse(voteUrl),
      body: {
        "CDSNo": cdsNo,
        "ResolutionNumber": resolutionNumber,
        "Vote": orderNumber,
        "VoteType": voteType,
        "isShareholderorProxy": "Shareholder"
      },
    );
    final responseJson = json.decode(response.body);
    if (response.statusCode == 200 || response.statusCode == 400) {
      if (responseJson[0]["responseCode"] == 0) {
        _showToast(responseJson[0]["responseMessage"]);
        setState(() {
          responseVoteMessage =
              responseJson[0]["responseMessage"].toString();
        });
      }
    } else {
      _showToast(
          "Vote Failed: ${responseJson[0]["responseMessage"]}");
    }
    context.loaderOverlay.hide();
  }

  // ── Build ─────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    cdsNo = cdsString;
    return Scaffold(
      backgroundColor: crdbBackground,
      appBar: AppBar(
        backgroundColor: crdbDarkGreen,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        title: const Text(
          'Shareholder Voting',
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
                colors: [crdbLightGreen, crdbGreen],
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
            _buildSearchCard(),

            // ── Shareholder Info Banner ───────────────
            if (isVisible && name.isNotEmpty) ...[
              const SizedBox(height: 16),
              _buildShareholderBanner(),
            ],

            // ── Resolutions Section ───────────────────
            if (isVisible) ...[
              const SizedBox(height: 20),
              Row(
                children: [
                  Container(
                    width: 4,
                    height: 16,
                    decoration: BoxDecoration(
                      color: crdbGreen,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'RESOLUTIONS',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: crdbGreen,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: crdbGreen.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${voterModel.resItem?.length ?? 0} items',
                      style: const TextStyle(
                        fontSize: 11,
                        color: crdbGreen,
                        fontWeight: FontWeight.w600,
                      ),
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
                  itemCount: voterModel.resItem?.length ?? 0,
                  itemBuilder: (context, index) {
                    return _resolutionTile(
                      context,
                      index,
                      voterModel.resItem![index].resText!,
                      voterModel.resItem![index].resType!,
                      voterModel.resItem![index].resNo!,
                      voterModel.resItem![index].resExistingVote!,
                      voteType,
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

  // ── Search Card ───────────────────────────────────────

  Widget _buildSearchCard() {
    return Container(
      decoration: BoxDecoration(
        color: crdbSurface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: crdbDarkGreen.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: crdbDarkGreen.withOpacity(0.06),
              borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16)),
              border: Border(
                  bottom: BorderSide(
                      color: crdbDarkGreen.withOpacity(0.1), width: 1)),
            ),
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 16,
                  decoration: BoxDecoration(
                    color: crdbDarkGreen,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'SHAREHOLDER LOOKUP',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: crdbDarkGreen,
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
                  style: const TextStyle(fontSize: 14, color: crdbTextDark),
                  decoration: InputDecoration(
                    labelText: 'CDS Number',
                    hintText: 'Enter your CDS No.',
                    labelStyle: TextStyle(
                        color: crdbDarkGreen.withOpacity(0.7),
                        fontSize: 13),
                    prefixIcon: const Icon(Icons.badge_outlined,
                        color: crdbDarkGreen, size: 20),
                    filled: true,
                    fillColor: crdbBackground,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 14),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                          color: crdbDarkGreen.withOpacity(0.2)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                          color: crdbDarkGreen.withOpacity(0.25)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(
                          color: crdbDarkGreen, width: 1.5),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                // Buttons
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
                            backgroundColor: crdbDarkGreen,
                            shape: RoundedRectangleBorder(
                                borderRadius:
                                BorderRadius.circular(10)),
                            elevation: 2,
                          ),
                          onPressed: () {
                            context.loaderOverlay.show();
                            getResolutions(cdsNo);
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
    );
  }

  // ── Shareholder Banner ────────────────────────────────

  Widget _buildShareholderBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [crdbDarkGreen, crdbMidGreen],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: crdbDarkGreen.withOpacity(0.25),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Top row: avatar + name + status badge
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.person_outline,
                    color: Colors.white, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'SHAREHOLDER',
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
                  color: regStatus.toLowerCase().contains('reg')
                      ? Colors.green.withOpacity(0.25)
                      : Colors.orange.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: regStatus.toLowerCase().contains('reg')
                        ? Colors.green.withOpacity(0.6)
                        : Colors.orange.withOpacity(0.6),
                  ),
                ),
                child: Text(
                  regStatus.isEmpty ? 'Active' : regStatus,
                  style: TextStyle(
                    color: regStatus.toLowerCase().contains('reg')
                        ? Colors.greenAccent[100]
                        : Colors.orange[100],
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Divider
          Container(height: 1, color: Colors.white.withOpacity(0.15)),
          const SizedBox(height: 14),
          // Info grid
          Row(
            children: [
              Expanded(
                  child: _infoChip(Icons.numbers, 'CDS No.', cdsString)),
              const SizedBox(width: 10),
              Expanded(
                  child: _infoChip(Icons.business, 'Company', company)),
              const SizedBox(width: 10),
              Expanded(
                  child: _infoChip(Icons.bar_chart, 'Shares', shares)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoChip(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.white60, size: 11),
              const SizedBox(width: 4),
              Text(
                label,
                style: const TextStyle(
                    color: Colors.white60,
                    fontSize: 10,
                    letterSpacing: 0.5),
              ),
            ],
          ),
          const SizedBox(height: 3),
          Text(
            value.isEmpty ? '—' : value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
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
      String resExistingVote,
      voteType,
      ) {
    final bool isNormal = type == "Normal Resolution";

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: crdbSurface,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: crdbDarkGreen.withOpacity(0.07),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: crdbDivider),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header chips row
            Row(
              children: [
                // Index badge
                Container(
                  width: 30,
                  height: 30,
                  decoration: const BoxDecoration(
                    color: crdbDarkGreen,
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
                const SizedBox(width: 8),
                _chip('Res. $resNumber', crdbDarkGreen, crdbBackground),
                const SizedBox(width: 6),
                _chip(
                  isNormal ? 'Normal' : 'Election',
                  isNormal ? Colors.green[700]! : crdbMidGreen,
                  isNormal
                      ? Colors.green.withOpacity(0.1)
                      : crdbGreen.withOpacity(0.12),
                ),
                if (resExistingVote.isNotEmpty &&
                    resExistingVote != "0") ...[
                  const Spacer(),
                  const Icon(Icons.check_circle,
                      color: Colors.green, size: 18),
                  const SizedBox(width: 4),
                  const Text(
                    'Voted',
                    style: TextStyle(
                        color: Colors.green,
                        fontSize: 11,
                        fontWeight: FontWeight.w600),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 10),
            // Resolution text
            Text(
              voteDetails,
              style: const TextStyle(
                fontSize: 14,
                color: crdbTextDark,
                height: 1.4,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 14),
            // Vote actions
            isNormal
                ? _normalVoteButtons(resNumber, resExistingVote)
                : _electionVoteButton(resNumber, voteDetails),
          ],
        ),
      ),
    );
  }

  Widget _chip(String label, Color textColor, Color bgColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: textColor,
        ),
      ),
    );
  }

  // ── Normal Resolution Vote Buttons ────────────────────

  Widget _normalVoteButtons(
      String resNumber, String resExistingVote) {
    return Row(
      children: [
        Expanded(
          child: _voteButton(
            label: 'FOR',
            icon: Icons.thumb_up_outlined,
            activeColor: Colors.green[700]!,
            inactiveColor: Colors.green.withOpacity(0.08),
            isActive: resExistingVote == "1",
            onTap: () {
              context.loaderOverlay.show();
              handleNormalResVote(cdsString, resNumber, "1");
              Future.delayed(const Duration(milliseconds: 500),
                      () => setState(() => onSelected = 1));
            },
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _voteButton(
            label: 'YES',
            icon: Icons.remove_circle_outline,
            activeColor: Colors.amber[700]!,
            inactiveColor: Colors.amber.withOpacity(0.08),
            isActive: resExistingVote == "3",
            onTap: () {
              context.loaderOverlay.show();
              handleNormalResVote(cdsString, resNumber, "3");
              Future.delayed(const Duration(milliseconds: 500),
                      () => setState(() => onSelected = 3));
            },
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _voteButton(
            label: 'NO',
            icon: Icons.thumb_down_outlined,
            activeColor: Colors.red[600]!,
            inactiveColor: Colors.red.withOpacity(0.07),
            isActive: resExistingVote == "2",
            onTap: () {
              context.loaderOverlay.show();
              handleNormalResVote(cdsString, resNumber, "2");
              Future.delayed(const Duration(milliseconds: 500),
                      () => setState(() => onSelected = 2));
            },
          ),
        ),
      ],
    );
  }

  Widget _voteButton({
    required String label,
    required IconData icon,
    required Color activeColor,
    required Color inactiveColor,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 46,
        decoration: BoxDecoration(
          color: isActive ? activeColor : inactiveColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isActive
                ? activeColor
                : activeColor.withOpacity(0.3),
            width: 1.2,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isActive)
              const Icon(Icons.check, color: Colors.white, size: 14),
            if (!isActive)
              Icon(icon,
                  color: activeColor.withOpacity(0.8), size: 14),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: isActive ? Colors.white : activeColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Election Vote Button ──────────────────────────────

  Widget _electionVoteButton(
      String resNumber, String voteDetails) {
    return SizedBox(
      width: double.infinity,
      height: 44,
      child: ElevatedButton.icon(
        icon: const Icon(Icons.how_to_vote_outlined,
            color: Colors.white, size: 16),
        label: const Text(
          'ELECT CANDIDATE',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 13,
            letterSpacing: 0.8,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: crdbGreen,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10)),
          elevation: 2,
        ),
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
      ),
    );
  }

  // ── Candidate Dialog ──────────────────────────────────

  Future<void> _showCandidateListDialog(BuildContext context,
      String cdsString, String resolution, String voteType) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16)),
          title: Text(
            resolution,
            style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: crdbDarkGreen,
                fontSize: 15),
          ),
          content: SizedBox(
            height: 500,
            width: double.maxFinite,
            child: ListView.builder(
              itemCount: candidates.length,
              itemBuilder: (context, index) {
                return _candidateItem(
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
          actions: [
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: crdbDarkGreen.withOpacity(0.4)),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () {
                candidates.clear();
                Navigator.pop(context, true);
              },
              child: const Text('Close',
                  style: TextStyle(color: crdbDarkGreen)),
            ),
          ],
        );
      },
    );
  }

  Widget _candidateItem(
      BuildContext context,
      String nomineeName,
      String cdsString,
      String orderNumber,
      String resolutionNumber,
      String resExistingVote,
      ) {
    final bool hasVoted = resExistingVote == "1";

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: hasVoted ? crdbBackground : crdbSurface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: hasVoted
              ? crdbGreen.withOpacity(0.3)
              : crdbDivider,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: hasVoted
                  ? crdbDarkGreen
                  : Colors.grey.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              hasVoted ? Icons.how_to_vote : Icons.person_outline,
              color: hasVoted ? Colors.white : Colors.grey,
              size: 18,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              nomineeName,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: hasVoted ? crdbDarkGreen : crdbTextDark,
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Vote button
          SizedBox(
            height: 34,
            child: ElevatedButton.icon(
              icon: Icon(
                  hasVoted ? Icons.check : Icons.how_to_vote_outlined,
                  size: 14,
                  color: Colors.white),
              label: Text(
                hasVoted ? 'Voted' : 'Vote',
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor:
                hasVoted ? Colors.green[600] : crdbDarkGreen,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                elevation: hasVoted ? 0 : 2,
                padding: const EdgeInsets.symmetric(horizontal: 10),
              ),
              onPressed: () {
                context.loaderOverlay.show();
                postCandidateVote(
                    cdsString, orderNumber, resolutionNumber, "1");
                _showCandidateListDialog(
                    context, cdsString, resolutionNumber, voteType);
              },
            ),
          ),
          const SizedBox(width: 6),
          // Recast button
          SizedBox(
            height: 34,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: crdbGreen, width: 1.2),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                padding: const EdgeInsets.symmetric(horizontal: 10),
              ),
              onPressed: () {
                context.loaderOverlay.show();
                postCandidateVote(
                    cdsString, orderNumber, resolutionNumber, "3");
              },
              child: Text(
                'Recast',
                style: TextStyle(
                    color: crdbMidGreen,
                    fontSize: 12,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}