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
  }) : super(key: key);

  @override
  State<ProxyElectionVotePage> createState() => _ProxyElectionVotePageState();
}

class _ProxyElectionVotePageState extends State<ProxyElectionVotePage>
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
  String responseVoteMessage = "";
  List<CandidateModel> candidates = [];

  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
    ));

    getCandidateList(widget.resNumber, widget.cdsString);
  }

  @override
  void dispose() {
    _animController.dispose();
    voterController.dispose();
    super.dispose();
  }

  Future<void> getCandidateList(String resoNumber, String cdsNo) async {
    final url = Uri.parse("$baseApiUrl/getCandidateList");
    final response = await http.post(url, body: {
      "resNo": resoNumber,
      "CDSNo": cdsNo,
    });

    if (response.statusCode == 200) {
      final responseJson = json.decode(response.body);
      final List<CandidateModel> loaded = [];
      for (int i = 0; i < responseJson.length; i++) {
        loaded.add(CandidateModel.fromJson(responseJson[i]));
      }
      setState(() {
        candidates = loaded;
      });
      _animController.forward(from: 0);
    } else {
      debugPrint('Error: failed to retrieve candidates');
    }
    context.loaderOverlay.hide();
  }

  Future<void> postCandidateVote(
      String cdsNo, String orderNumber, String resolutionNumber, String voteType) async {
    final url = Uri.parse("$baseApiUrl/CommitVoteElectionRes");
    final body = {
      "CDSNo": cdsNo,
      "ResolutionNumber": resolutionNumber,
      "Vote": orderNumber,
      "VoteType": voteType,
      "isShareholderorProxy": "Proxy",
    };

    final response = await http.post(url, body: body);
    final responseJson = json.decode(response.body);

    if (response.statusCode == 200 && responseJson[0]["responseCode"] == 0) {
      final msg = responseJson[0]["responseMessage"].toString();
      showToast(context, msg);
      if (msg == "Already Voted") {
        setState(() => responseVoteMessage = msg);
      }
    } else {
      showToast(context, "Vote Failed: ${responseJson[0]["responseMessage"]}");
    }

    await getCandidateList(resolutionNumber, cdsNo);
    context.loaderOverlay.hide();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: crdbBackground,
      appBar: AppBar(
        backgroundColor: crdbDarkGreen,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Colors.white, size: 20),
          onPressed: () {
            Navigator.pop(context);
            context.loaderOverlay.hide();
          },
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Election Vote',
              style: TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.3,
              ),
            ),
            Text(
              'CRDB Bank Plc',
              style: TextStyle(
                color: Color(0xFFB8F0B5),
                fontSize: 10,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.4,
              ),
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(3),
          child: Container(
            height: 3,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  crdbLightGreen,
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // ── Vote Details Banner ──────────────────────────
          if (widget.voteDetails.isNotEmpty)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: crdbBackground,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                    color: crdbGreen.withOpacity(0.5), width: 1.2),
                boxShadow: [
                  BoxShadow(
                    color: crdbDarkGreen.withOpacity(0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 2),
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: crdbGreen.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.info_outline_rounded,
                        color: crdbDarkGreen, size: 16),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      widget.voteDetails,
                      style: const TextStyle(
                        color: crdbTextDark,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // ── Candidates Header ────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
            child: Row(
              children: [
                const Icon(Icons.people_alt_rounded,
                    size: 15, color: crdbDarkGreen),
                const SizedBox(width: 8),
                const Text(
                  'CANDIDATES',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: crdbDarkGreen,
                    letterSpacing: 1.8,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    height: 1,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          crdbDarkGreen.withOpacity(0.4),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: crdbDarkGreen.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${candidates.length} candidate${candidates.length == 1 ? '' : 's'}',
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: crdbDarkGreen,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Candidate List ───────────────────────────────
          Expanded(
            child: candidates.isEmpty
                ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.hourglass_top_rounded,
                      size: 40, color: Colors.grey[300]),
                  const SizedBox(height: 12),
                  Text(
                    'Loading candidates...',
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            )
                : FadeTransition(
              opacity: _fadeAnim,
              child: SlideTransition(
                position: _slideAnim,
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                  itemCount: candidates.length,
                  separatorBuilder: (_, __) =>
                  const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    return _CandidateCard(
                      nominee: candidates[index].nomineeName ?? '',
                      orderNumber: candidates[index].orderNumber ?? '',
                      resolutionNumber: candidates[index].resNo ?? '',
                      existingVote:
                      candidates[index].resExistingVote ?? '',
                      cdsString: widget.cdsString,
                      index: index,
                      onVote: (orderNumber, resolutionNumber, voteType) {
                        context.loaderOverlay.show();
                        postCandidateVote(
                          widget.cdsString,
                          orderNumber,
                          resolutionNumber,
                          voteType,
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ),

          // ── Submit Button ────────────────────────────────
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            decoration: BoxDecoration(
              color: crdbSurface,
              boxShadow: [
                BoxShadow(
                  color: crdbDarkGreen.withOpacity(0.08),
                  blurRadius: 16,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: crdbDarkGreen,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: () {
                  submitVote(context, widget.cdsString, widget.resNumber);
                  Navigator.pop(context);
                  candidates.clear();
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.check_circle_outline_rounded,
                        color: Colors.white, size: 20),
                    SizedBox(width: 10),
                    Text(
                      'SUBMIT VOTE',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Candidate Card ────────────────────────────────────────
class _CandidateCard extends StatefulWidget {
  final String nominee;
  final String orderNumber;
  final String resolutionNumber;
  final String existingVote;
  final String cdsString;
  final int index;
  final void Function(String orderNumber, String resolutionNumber,
      String voteType) onVote;

  const _CandidateCard({
    required this.nominee,
    required this.orderNumber,
    required this.resolutionNumber,
    required this.existingVote,
    required this.cdsString,
    required this.index,
    required this.onVote,
  });

  @override
  State<_CandidateCard> createState() => _CandidateCardState();
}

class _CandidateCardState extends State<_CandidateCard> {
  static const Color crdbDarkGreen  = Color(0xFF1E7A1A);
  static const Color crdbMidGreen   = Color(0xFF2D9128);
  static const Color crdbGreen      = Color(0xFF3AAA35);
  static const Color crdbSurface    = Color(0xFFFFFFFF);
  static const Color crdbDivider    = Color(0xFFD4EDDA);

  bool get hasVotedYes => widget.existingVote == "1";

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: crdbSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: hasVotedYes
              ? const Color(0xFF1B7B3A).withOpacity(0.35)
              : crdbDivider,
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: crdbDarkGreen.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            // ── Avatar ──
            Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [crdbMidGreen, crdbDarkGreen],
                ),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  widget.nominee.isNotEmpty
                      ? widget.nominee[0].toUpperCase()
                      : '?',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // ── Name ──
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.nominee,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0D2B0C),
                      height: 1.2,
                    ),
                  ),
                  if (hasVotedYes) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: const [
                        Icon(Icons.check_circle_rounded,
                            size: 12, color: Color(0xFF1B7B3A)),
                        SizedBox(width: 4),
                        Text(
                          'Voted',
                          style: TextStyle(
                            fontSize: 11,
                            color: Color(0xFF1B7B3A),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),

            // ── Action Buttons ──
            Row(
              children: [
                // Yes
                _VoteButton(
                  label: 'Yes',
                  icon: hasVotedYes ? Icons.check_rounded : null,
                  isSelected: hasVotedYes,
                  selectedColor: const Color(0xFF1B7B3A),
                  defaultColor: const Color(0xFFE8F5E9),
                  defaultTextColor: const Color(0xFF1B7B3A),
                  onTap: () => widget.onVote(
                      widget.orderNumber, widget.resolutionNumber, "1"),
                ),
                const SizedBox(width: 8),
                // Recast
                _VoteButton(
                  label: 'Recast',
                  isSelected: false,
                  selectedColor: crdbGreen,
                  defaultColor: const Color(0xFFEAF7EA),
                  defaultTextColor: crdbDarkGreen,
                  onTap: () => widget.onVote(
                      widget.orderNumber, widget.resolutionNumber, "3"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Vote Button ───────────────────────────────────────────
class _VoteButton extends StatefulWidget {
  final String label;
  final IconData? icon;
  final bool isSelected;
  final Color selectedColor;
  final Color defaultColor;
  final Color defaultTextColor;
  final VoidCallback onTap;

  const _VoteButton({
    required this.label,
    this.icon,
    required this.isSelected,
    required this.selectedColor,
    required this.defaultColor,
    required this.defaultTextColor,
    required this.onTap,
  });

  @override
  State<_VoteButton> createState() => _VoteButtonState();
}

class _VoteButtonState extends State<_VoteButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.92 : 1.0,
        duration: const Duration(milliseconds: 120),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: widget.isSelected
                ? widget.selectedColor
                : widget.defaultColor,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: widget.isSelected
                  ? widget.selectedColor
                  : widget.defaultTextColor.withOpacity(0.3),
              width: 1.2,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.icon != null) ...[
                Icon(
                  widget.icon,
                  size: 14,
                  color: widget.isSelected
                      ? Colors.white
                      : widget.defaultTextColor,
                ),
                const SizedBox(width: 4),
              ],
              Text(
                widget.label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: widget.isSelected
                      ? Colors.white
                      : widget.defaultTextColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}