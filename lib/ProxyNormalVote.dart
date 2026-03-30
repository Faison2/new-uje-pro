import 'dart:convert';
import 'package:uje/services.dart';
import 'package:uje/model/candidate_model.dart';
import 'package:uje/model/proxyShareholder_model.dart';
import 'package:uje/model/proxyVoteModel.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:loader_overlay/loader_overlay.dart';
import 'constants/constants.dart';
import 'constants/ui_constants.dart';

class ProxyNormalVotePage extends StatefulWidget {
  final String cdsString;
  final String resNumber;
  final String resolution;
  final String resolutionSEQ;
  final String proxyNumber;

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

class _ProxyNormalVotePageState extends State<ProxyNormalVotePage>
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

  String responseVoteMessage = "";
  String cdsString = "";
  String vote = "";
  List<ShareholderModel> shareholders = [];
  List<CandidateModel> candidates = [];
  ProxyVoterModel proxyVoterModel = ProxyVoterModel();
  String voteStatus = "";
  String respRef = "";

  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim =
        CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.loaderOverlay.show();
      getShareholderList(widget.proxyNumber, widget.resNumber);
    });
  }

  @override
  void dispose() {
    _animController.dispose();
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

  // ── API Methods ───────────────────────────────────────

  getShareholderList(String proxyNumber, String resoNumber) async {
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
      } else {
        shareholders.clear();
        for (int i = 0; i < responseJson.length; i++) {
          shareholders.add(ShareholderModel.fromJson(responseJson[i]));
        }
        setState(() {});
        _animController.forward(from: 0);
      }
    } else {
      debugPrint('Error failed to retrieve shareholders');
    }
    context.loaderOverlay.hide();
  }

  handleNormalVote(
      String cdsNumber, String resNumber, String voteType) async {
    String urlVoteNormalRes = "$baseApiUrl/CommitVoteNormalRes";
    final response = await http.post(
      Uri.parse(urlVoteNormalRes),
      body: {
        "CDSNo": cdsNumber,
        "ResolutionNumber": resNumber,
        "Vote": voteType
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
    getShareholderList(widget.proxyNumber, widget.resNumber);
  }

  handleNormalVoteAll(
      String resolutionSEQ, String proxyNumber, String voteType) async {
    String urlVoteNormalResAll = "$baseApiUrl/CommitVoteNormalResALL";
    final response = await http.post(
      Uri.parse(urlVoteNormalResAll),
      body: {
        "resSEQ": resolutionSEQ,
        "ProxyCDS": proxyNumber,
        "Vote": voteType
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
    getShareholderList(widget.proxyNumber, widget.resNumber);
  }

  // ── Build ─────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final String resNumber = widget.resNumber;
    final String resolution = widget.resolution;
    final String proxyNumber = widget.proxyNumber;
    final String resolutionSEQ = widget.resolutionSEQ;

    return Scaffold(
      backgroundColor: crdbBackground,
      appBar: AppBar(
        backgroundColor: crdbDarkGreen,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            shareholders.clear();
            Navigator.of(context).pop();
          },
        ),
        title: const Text(
          'Normal Vote',
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
      body: Column(
        children: [
          // ── Resolution Banner ─────────────────────
          Container(
            width: double.infinity,
            margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
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
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.how_to_vote,
                      color: Colors.white, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: crdbGreen.withOpacity(0.25),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                  color: crdbGreen.withOpacity(0.5)),
                            ),
                            child: Text(
                              'Res. $resNumber',
                              style: const TextStyle(
                                color: Color(0xFFB8F0B5),
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'Normal Resolution',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        resolution,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Vote ALL Buttons ──────────────────────
          Container(
            margin: const EdgeInsets.fromLTRB(16, 14, 16, 0),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: crdbSurface,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: crdbDarkGreen.withOpacity(0.07),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
              border: Border.all(color: crdbDivider),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 4,
                      height: 14,
                      decoration: BoxDecoration(
                        color: crdbDarkGreen,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'VOTE FOR ALL SHAREHOLDERS',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: crdbDarkGreen,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _bulkVoteButton(
                        label: 'FOR ALL',
                        icon: Icons.thumb_up_outlined,
                        activeColor: Colors.green[700]!,
                        bgColor: Colors.green.withOpacity(0.08),
                        isActive: vote == "1",
                        onTap: () {
                          handleNormalVoteAll(
                              resolutionSEQ, proxyNumber, "1");
                          setState(() => shareholders.clear());
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _bulkVoteButton(
                        label: 'ABSTAIN ALL',
                        icon: Icons.remove_circle_outline,
                        activeColor: Colors.amber[700]!,
                        bgColor: Colors.amber.withOpacity(0.08),
                        isActive: vote == "3",
                        onTap: () {
                          handleNormalVoteAll(
                              resolutionSEQ, proxyNumber, "3");
                          setState(() => shareholders.clear());
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _bulkVoteButton(
                        label: 'AGAINST ALL',
                        icon: Icons.thumb_down_outlined,
                        activeColor: Colors.red[600]!,
                        bgColor: Colors.red.withOpacity(0.07),
                        isActive: vote == "2",
                        onTap: () {
                          handleNormalVoteAll(
                              resolutionSEQ, proxyNumber, "2");
                          setState(() => shareholders.clear());
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ── Shareholders Section Label ─────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 8),
            child: Row(
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
                  'SHAREHOLDERS',
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
                    color: crdbGreen.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${shareholders.length} total',
                    style: const TextStyle(
                      fontSize: 11,
                      color: crdbGreen,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Shareholders List ─────────────────────
          Expanded(
            child: shareholders.isEmpty
                ? _emptyState()
                : FadeTransition(
              opacity: _fadeAnim,
              child: ListView.builder(
                padding:
                const EdgeInsets.fromLTRB(16, 0, 16, 16),
                itemCount: shareholders.length,
                itemBuilder: (context, index) {
                  return _shareholderTile(
                    context,
                    index,
                    shareholders[index].shareholder!,
                    shareholders[index].names!,
                    shareholders[index].shares!,
                    shareholders[index].vote!,
                    shareholders[index].category!,
                    resNumber,
                    resolutionSEQ,
                    proxyNumber,
                    resolution,
                  );
                },
              ),
            ),
          ),

          // ── Submit Button ─────────────────────────
          Container(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            decoration: BoxDecoration(
              color: crdbSurface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 10,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.check_circle_outline,
                    color: Colors.white, size: 20),
                label: const Text(
                  'SUBMIT VOTES',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: crdbDarkGreen,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  elevation: 3,
                ),
                onPressed: () {
                  shareholders.clear();
                  showToast(context, "Voted successfully");
                  Navigator.pop(context);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Empty State ───────────────────────────────────────

  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: const BoxDecoration(
              color: crdbBackground,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.people_outline,
                color: crdbDarkGreen, size: 34),
          ),
          const SizedBox(height: 14),
          const Text(
            'No Shareholders',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: crdbTextDark,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Shareholders will appear here once loaded.',
            style: TextStyle(fontSize: 13, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  // ── Bulk Vote Button ──────────────────────────────────

  Widget _bulkVoteButton({
    required String label,
    required IconData icon,
    required Color activeColor,
    required Color bgColor,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 46,
        decoration: BoxDecoration(
          color: isActive ? activeColor : bgColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isActive
                ? activeColor
                : activeColor.withOpacity(0.35),
            width: 1.2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isActive ? Icons.check : icon,
              color: isActive ? Colors.white : activeColor,
              size: 16,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.bold,
                color: isActive ? Colors.white : activeColor,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Shareholder Tile ──────────────────────────────────

  Widget _shareholderTile(
      BuildContext context,
      int index,
      String shareholder,
      String names,
      String shares,
      String existingVote,
      String category,
      String resNo,
      String resolutionSEQ,
      String proxyNumber,
      String resolution,
      ) {
    // Determine voted state color
    Color? votedColor;
    String votedLabel = '';
    if (existingVote == "1") {
      votedColor = Colors.green[600];
      votedLabel = 'For';
    } else if (existingVote == "2") {
      votedColor = Colors.red[600];
      votedLabel = 'Against';
    } else if (existingVote == "3") {
      votedColor = Colors.amber[700];
      votedLabel = 'Abstain';
    }

    final bool hasVoted = existingVote == "1" ||
        existingVote == "2" ||
        existingVote == "3";

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: hasVoted
            ? votedColor!.withOpacity(0.06)
            : crdbSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: hasVoted
              ? votedColor!.withOpacity(0.3)
              : crdbDivider,
          width: hasVoted ? 1.5 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: crdbDarkGreen.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: 12, vertical: 10),
        child: Column(
          children: [
            // Top row: index + name + shares + voted badge
            Row(
              children: [
                // Index circle
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: hasVoted
                        ? votedColor!.withOpacity(0.15)
                        : crdbBackground,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: TextStyle(
                        color: hasVoted ? votedColor : crdbDarkGreen,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                // Name & shares
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        names,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: crdbTextDark,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(Icons.bar_chart,
                              size: 11,
                              color: Colors.grey[500]),
                          const SizedBox(width: 3),
                          Text(
                            '$shares shares',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Voted badge
                if (hasVoted)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: votedColor!.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                          color: votedColor.withOpacity(0.4)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check_circle,
                            color: votedColor, size: 12),
                        const SizedBox(width: 4),
                        Text(
                          votedLabel,
                          style: TextStyle(
                            fontSize: 11,
                            color: votedColor,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            // Vote buttons row
            Row(
              children: [
                Expanded(
                  child: _voteButton(
                    label: 'FOR',
                    icon: Icons.thumb_up_outlined,
                    activeColor: Colors.green[700]!,
                    bgColor: Colors.green.withOpacity(0.07),
                    isActive: existingVote == "1",
                    onTap: () {
                      context.loaderOverlay.show();
                      handleNormalVote(shareholder, resNo, "1");
                      setState(() => shareholders.clear());
                    },
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: _voteButton(
                    label: 'ABSTAIN',
                    icon: Icons.remove_circle_outline,
                    activeColor: Colors.amber[700]!,
                    bgColor: Colors.amber.withOpacity(0.07),
                    isActive: existingVote == "3",
                    onTap: () {
                      context.loaderOverlay.show();
                      handleNormalVote(shareholder, resNo, "3");
                      setState(() => shareholders.clear());
                    },
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: _voteButton(
                    label: 'AGAINST',
                    icon: Icons.thumb_down_outlined,
                    activeColor: Colors.red[600]!,
                    bgColor: Colors.red.withOpacity(0.07),
                    isActive: existingVote == "2",
                    onTap: () {
                      context.loaderOverlay.show();
                      handleNormalVote(shareholder, resNo, "2");
                      setState(() => shareholders.clear());
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── Individual Vote Button ────────────────────────────

  Widget _voteButton({
    required String label,
    required IconData icon,
    required Color activeColor,
    required Color bgColor,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 40,
        decoration: BoxDecoration(
          color: isActive ? activeColor : bgColor,
          borderRadius: BorderRadius.circular(9),
          border: Border.all(
            color:
            isActive ? activeColor : activeColor.withOpacity(0.3),
            width: 1.2,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isActive ? Icons.check : icon,
              color: isActive ? Colors.white : activeColor,
              size: 14,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: isActive ? Colors.white : activeColor,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}