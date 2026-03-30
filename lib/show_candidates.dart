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
  // ── UJE Brand Colors ──────────────────────────────────
  static const Color ujeBlue = Color(0xFF1A5CB8);
  static const Color ujeGold = Color(0xFFC9A227);
  static const Color ujeLightBlue = Color(0xFFE8F0FB);
  static const Color ujeBackground = Color(0xFFF4F6FB);
  static const Color ujeDark = Color(0xFF1A2340);

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
    final response =
    await http.post(Uri.parse(voteUrl), body: body);
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
      backgroundColor: ujeBackground,
      appBar: AppBar(
        backgroundColor: ujeBlue,
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
                colors: [ujeGold, Color(0xFFFFE082)],
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
            padding:
            const EdgeInsets.fromLTRB(16, 20, 16, 8),
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
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: ujeBlue.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${candidates.length} total',
                    style: const TextStyle(
                      fontSize: 11,
                      color: ujeBlue,
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
                padding:
                const EdgeInsets.fromLTRB(16, 4, 16, 24),
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
            decoration: BoxDecoration(
              color: ujeLightBlue,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.people_outline,
                color: ujeBlue, size: 38),
          ),
          const SizedBox(height: 16),
          const Text(
            'No Candidates',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: ujeDark,
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
                      color: hasVoted ? ujeBlue : ujeDark,
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