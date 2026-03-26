import 'dart:convert';
import 'package:uje/model/VoterModel.dart';
import 'package:uje/model/candidate_model.dart';
import 'package:uje/services.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:loader_overlay/loader_overlay.dart';
import 'constants/constants.dart';
import 'constants/ui_constants.dart';

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
    extends State<ShareholderElectionVoteScreen>
    with SingleTickerProviderStateMixin {
  // ── UJE Brand Colors ──────────────────────────────────
  static const Color ujeBlue = Color(0xFF1A5CB8);
  static const Color ujeGold = Color(0xFFC9A227);
  static const Color ujeLightBlue = Color(0xFFE8F0FB);
  static const Color ujeBackground = Color(0xFFF4F6FB);
  static const Color ujeDark = Color(0xFF1A2340);

  String responseVoteMessage = "";
  List<CandidateModel> candidates = [];
  String voteType = "";

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
    getCandidateList(widget.resNumber, widget.cdsString);
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  // ── API Methods ───────────────────────────────────────

  getCandidateList(String resoNumber, String cdsNo) async {
    String candidateListUrl = "$baseApiUrl/getCandidateList";
    final response = await http.post(
      Uri.parse(candidateListUrl),
      body: {"resNo": resoNumber, "CDSNo": cdsNo},
    );
    if (response.statusCode == 200) {
      final responseJson = json.decode(response.body);
      for (int i = 0; i < responseJson.length; i++) {
        candidates.add(CandidateModel.fromJson(responseJson[i]));
      }
      setState(() {});
      _animController.forward(from: 0);
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
    final response = await http.post(Uri.parse(voteUrl), body: body);
    final responseJson = json.decode(response.body);
    if (response.statusCode == 200) {
      if (responseJson[0]["responseCode"] == 0) {
        showToast(context, responseJson[0]["responseMessage"]);
        setState(() {
          responseVoteMessage =
              responseJson[0]["responseMessage"].toString();
        });
      }
    } else {
      showToast(context, responseJson[0]["responseMessage"]);
    }
    context.loaderOverlay.hide();
    candidates.clear();
    getCandidateList(resolutionNumber, cdsNo);
  }

  // ── Build ─────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ujeBackground,
      appBar: AppBar(
        backgroundColor: ujeBlue,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
            context.loaderOverlay.hide();
          },
        ),
        title: const Text(
          'Election Vote',
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
                colors: [ujeGold, Color(0xFFFFE082)],
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // ── Resolution Info Banner ────────────────
          Container(
            width: double.infinity,
            margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [ujeBlue, Color(0xFF0D3A7A)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: ujeBlue.withOpacity(0.25),
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
                              color: ujeGold.withOpacity(0.25),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                  color: ujeGold.withOpacity(0.5)),
                            ),
                            child: Text(
                              'Res. ${widget.resNumber}',
                              style: const TextStyle(
                                color: Color(0xFFFFE082),
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
                            child: Text(
                              '${candidates.length} Candidates',
                              style: const TextStyle(
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
                        widget.voteDetails,
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

          // ── Section Label ─────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 16,
                  decoration: BoxDecoration(
                    color: ujeGold,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'CANDIDATES',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: ujeGold,
                    letterSpacing: 1.0,
                  ),
                ),
                const Spacer(),
                if (candidates.isNotEmpty)
                  Text(
                    '${candidates.where((c) => c.resExistingVote == "1").length} voted',
                    style: const TextStyle(
                      fontSize: 11,
                      color: Colors.green,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
              ],
            ),
          ),

          // ── Candidates List ───────────────────────
          Expanded(
            child: candidates.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.people_outline,
                      size: 48,
                      color: Colors.grey.withOpacity(0.4)),
                  const SizedBox(height: 12),
                  Text(
                    'Loading candidates...',
                    style: TextStyle(
                        color: Colors.grey[400], fontSize: 14),
                  ),
                ],
              ),
            )
                : FadeTransition(
              opacity: _fadeAnim,
              child: ListView.builder(
                padding:
                const EdgeInsets.fromLTRB(16, 0, 16, 16),
                itemCount: candidates.length,
                itemBuilder: (context, index) {
                  return _candidateTile(
                    context,
                    index,
                    candidates[index].nomineeName!,
                    widget.cdsString,
                    candidates[index].orderNumber!,
                    candidates[index].resNo!,
                    candidates[index].resExistingVote!,
                  );
                },
              ),
            ),
          ),

          // ── Submit Button ─────────────────────────
          Container(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            decoration: BoxDecoration(
              color: Colors.white,
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
                  backgroundColor: ujeBlue,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  elevation: 3,
                ),
                onPressed: () {
                  candidates.clear();
                  context.loaderOverlay.show();
                  submitVote(context, widget.cdsString,
                      widget.resNumber);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Candidate Tile ────────────────────────────────────

  Widget _candidateTile(
      BuildContext context,
      int index,
      String nomineeName,
      String cdsString,
      String orderNumber,
      String resolutionNumber,
      String resExistingVote,
      ) {
    final bool hasVoted = resExistingVote == "1";

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: hasVoted ? ujeLightBlue : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: hasVoted
              ? ujeBlue.withOpacity(0.35)
              : ujeBlue.withOpacity(0.1),
          width: hasVoted ? 1.5 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: ujeBlue.withOpacity(hasVoted ? 0.1 : 0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: 14, vertical: 12),
        child: Row(
          children: [
            // Index / voted avatar
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: hasVoted
                    ? ujeBlue
                    : Colors.grey.withOpacity(0.1),
                shape: BoxShape.circle,
                border: Border.all(
                  color: hasVoted
                      ? ujeBlue
                      : Colors.grey.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Center(
                child: hasVoted
                    ? const Icon(Icons.how_to_vote,
                    color: Colors.white, size: 18)
                    : Text(
                  '${index + 1}',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Name
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    nomineeName,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: hasVoted ? ujeBlue : ujeDark,
                      height: 1.3,
                    ),
                  ),
                  if (hasVoted) ...[
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        Icon(Icons.check_circle,
                            color: Colors.green[600],
                            size: 12),
                        const SizedBox(width: 4),
                        Text(
                          'Vote cast',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.green[600],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(width: 8),

            // Vote button
            SizedBox(
              height: 36,
              child: ElevatedButton.icon(
                icon: Icon(
                  hasVoted ? Icons.check : Icons.how_to_vote_outlined,
                  size: 14,
                  color: Colors.white,
                ),
                label: Text(
                  hasVoted ? 'Voted' : 'Vote',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                  hasVoted ? Colors.green[600] : ujeBlue,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  elevation: hasVoted ? 0 : 2,
                  padding:
                  const EdgeInsets.symmetric(horizontal: 12),
                ),
                onPressed: () {
                  context.loaderOverlay.show();
                  postCandidateVote(
                      cdsString, orderNumber, resolutionNumber, "1");
                },
              ),
            ),

            const SizedBox(width: 6),

            // Recast button
            SizedBox(
              height: 36,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  side: BorderSide(
                      color: Colors.amber[600]!, width: 1.2),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  padding:
                  const EdgeInsets.symmetric(horizontal: 10),
                ),
                onPressed: () {
                  context.loaderOverlay.show();
                  postCandidateVote(
                      cdsString, orderNumber, resolutionNumber, "3");
                },
                child: Text(
                  'Recast',
                  style: TextStyle(
                    color: Colors.amber[700],
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}