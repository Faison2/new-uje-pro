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

class _ShowCandidatesPageState extends State<ShowCandidatesPage>
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

  List<CandidateModel> candidates = [];
  String responseVoteMessage = "";
  String cdsString = "";

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
    if (candidates.isNotEmpty) {
      _animController.forward();
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  // ── API ───────────────────────────────────────────────

  postCandidateVote(
      String cdsNo, orderNumber, resolutionNumber, voteType) async {
    String voteUrl = "$baseApiUrl/CommitVoteElectionRes";
    final body = {
      "CDSNo": cdsNo,
      "ResolutionNumber": resolutionNumber,
      "Vote": orderNumber,
      "VoteType": voteType,
      "isShareholderorProxy": "test"
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
  }

  // ── Build ─────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: crdbBackground,
      appBar: AppBar(
        backgroundColor: crdbDarkGreen,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        title: const Text(
          'Candidates',
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
      body: candidates.isEmpty
          ? _emptyState()
          : Column(
        children: [
          // ── Header strip ──────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
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
                  'CANDIDATES',
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
                    '${candidates.length} total',
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

          // ── Candidates list ───────────────────
          Expanded(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                itemCount: candidates.length,
                itemBuilder: (context, index) {
                  return _candidateTile(
                    context,
                    index,
                    candidates[index].nomineeName!,
                    cdsString,
                    candidates[index].orderNumber!,
                    candidates[index].resNo!,
                    candidates[index].resExistingVote!,
                  );
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
            width: 80,
            height: 80,
            decoration: const BoxDecoration(
              color: crdbBackground,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.people_outline,
                color: crdbDarkGreen, size: 38),
          ),
          const SizedBox(height: 16),
          const Text(
            'No Candidates',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: crdbTextDark,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Candidates will appear here once loaded.',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[500],
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
        color: hasVoted ? crdbBackground : crdbSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: hasVoted
              ? crdbGreen.withOpacity(0.35)
              : crdbDivider,
          width: hasVoted ? 1.5 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: crdbDarkGreen.withOpacity(hasVoted ? 0.1 : 0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            // Index / voted avatar
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: hasVoted
                    ? crdbDarkGreen
                    : Colors.grey.withOpacity(0.1),
                shape: BoxShape.circle,
                border: Border.all(
                  color: hasVoted
                      ? crdbDarkGreen
                      : Colors.grey.withOpacity(0.2),
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

            // Name + voted label
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    nomineeName,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: hasVoted ? crdbDarkGreen : crdbTextDark,
                      height: 1.3,
                    ),
                  ),
                  if (hasVoted) ...[
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        Icon(Icons.check_circle,
                            color: Colors.green[600], size: 12),
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
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                  hasVoted ? Colors.green[600] : crdbDarkGreen,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  elevation: hasVoted ? 0 : 2,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
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