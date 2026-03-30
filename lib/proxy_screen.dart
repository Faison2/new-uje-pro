import 'dart:convert';
import 'package:uje/services.dart';
import 'package:uje/constants/ui_constants.dart';
import 'package:uje/model/proxy_shareholder_add.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:loader_overlay/loader_overlay.dart';
import 'constants/constants.dart';

class ProxyPage extends StatefulWidget {
  const ProxyPage({Key? key}) : super(key: key);

  @override
  State<ProxyPage> createState() => _ProxyPageState();
}

class _ProxyPageState extends State<ProxyPage> {
  // ── UJE Brand Colors ──────────────────────────────────
  static const Color ujeBlue = Color(0xFF1A5CB8);
  static const Color ujeGold = Color(0xFFC9A227);
  static const Color ujeLightBlue = Color(0xFFE8F0FB);
  static const Color ujeBackground = Color(0xFFF4F6FB);
  static const Color ujeDark = Color(0xFF1A2340);

  TextEditingController cdsNumberController = TextEditingController();
  TextEditingController shareHolderController = TextEditingController();
  TextEditingController proxyNameController = TextEditingController();
  TextEditingController postShareholderCdsController = TextEditingController();
  TextEditingController proxyNumberController = TextEditingController();
  TextEditingController controller = TextEditingController();
  TextEditingController mobileNumberController = TextEditingController();
  final GlobalKey<FormState> registrationKey2 = GlobalKey<FormState>();
  late TextEditingController tinNumberController;
  late TextEditingController bankController;
  late TextEditingController accountNumberController;

  bool isShareholder = false;
  String bankName = "Bank";
  String shareholderNumber = "";
  String cdsNo = "";
  String proxyName = "";
  String registrationStatus = "";
  String voteCode = "";
  String voterName = "";
  String voterCodeString = "";
  String shareholderProxyName = "";
  String proxyNumber = "";
  String proxyType = "";
  String shareholderProxyCDS = "";
  String phoneNumber = "";

  final List<String> data = <String>[];
  final List<String> cdsNumbers = <String>[];

  @override
  void initState() {
    super.initState();
    cdsNumberController.addListener(() {
      cdsNo = cdsNumberController.text;
    });
    proxyNameController.addListener(() {
      proxyName = proxyNameController.text;
    });
    proxyNumberController.addListener(() {
      if (isShareholder) {
        mobileNumberController.text = proxyNumberController.text;
      }
      phoneNumber = proxyNumberController.text;
    });
    bankController = TextEditingController();
    accountNumberController = TextEditingController();
    tinNumberController = TextEditingController();
    mobileNumberController = TextEditingController();
  }

  @override
  void dispose() {
    bankController.dispose();
    controller.dispose();
    accountNumberController.dispose();
    tinNumberController.dispose();
    mobileNumberController.dispose();
    super.dispose();
  }

  // ── API Methods ───────────────────────────────────────

  shareholderName(String cdsNo) async {
    debugPrint("ShareHolderNumber is $cdsNo");
    final response = await http.post(
      Uri.parse("$baseApiUrl/register"),
      body: {"ShareholderNumber": cdsNo, "RegAction": "GetDetails"},
    );
    final responseJson = json.decode(response.body);
    setState(() {
      shareHolderController.text =
          responseJson[0]["responseMessage"].toString();
    });
    context.loaderOverlay.hide();
  }

  confirmName(String shareholderNumber) async {
    String nameConfirmUrl = '$baseApiUrl/RegisterGetDetailsProxy';
    final response = await http.post(
      Uri.parse(nameConfirmUrl),
      body: {
        "ShareholderNumber": shareholderNumber,
        "RegAction": "GetDetails"
      },
    );
    final responseJson = json.decode(response.body);
    setState(() {
      voterName = responseJson[0]["responseMessage"].toString();
      shareHolderController.text = voterName;
      cdsNumberController.text = shareholderNumber;
      proxyNameController.text = voterName;
    });
    context.loaderOverlay.hide();
  }

  addProxyShareholders(AddProxyShareholderModel model) async {
    String api = '$baseApiUrl/ADDProxyShareholders';
    final response = await http.post(
      Uri.parse(api),
      body: {
        "CDSNo": model.cdsNo,
        "ProxyName": model.proxyName,
        "MobileNumber": model.mobileNumber,
        "TIN": model.tin,
        "Bank": model.bank,
        "BankAccountNumber": model.accountNumber,
      },
    );
    var responseJson = json.decode(response.body);
    if (response.statusCode == 200) {
      if (responseJson[0]["responseCode"] == 0) {
        setState(() {
          data.add(shareHolderController.text);
          cdsNumbers.add(cdsNo);
          cdsNumberController.text = "";
          shareHolderController.text = "";
          tinNumberController.text = "";
          accountNumberController.text = "";
          bankName = "Bank";
          mobileNumberController.text = "";
        });
        showToast(context, responseJson[0]["responseMessage"]);
      } else {
        showToast(context, responseJson[0]["responseMessage"]);
      }
    } else {
      showToast(context, responseJson[0]["responseMessage"]);
    }
  }

  void addValue(AddProxyShareholderModel model) {
    if (shareHolderController.text == '') {
      _showStyledAlert('Please search and confirm a Shareholder Name.');
    } else if (data.contains(shareHolderController.text)) {
      _showUjeToast("Shareholder already added to the list");
    } else if (proxyNameController.text == '') {
      _showUjeToast("Please enter a Proxy Name");
    } else if (cdsNumberController.text == '') {
      _showUjeToast("Please enter a CDS Number");
    } else if (registrationStatus == 'Missing CDSNo') {
      _showUjeToast("Please enter a valid CDS Number");
    } else {
      addProxyShareholders(model);
    }
  }

  void _showUjeToast(String msg) {
    Fluttertoast.showToast(
      msg: msg,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: ujeBlue,
      textColor: Colors.white,
      fontSize: 14.0,
      timeInSecForIosWeb: 3,
    );
  }

  void _showStyledAlert(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        title: const Text('Notice',
            style: TextStyle(
                fontWeight: FontWeight.bold, color: ujeBlue)),
        content: Text(message),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: ujeBlue,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('OK',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _showProxyNumberDialog(
      BuildContext context, String proxyNumber) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16)),
          title: const Text('Registration Successful',
              style: TextStyle(
                  fontWeight: FontWeight.bold, color: ujeBlue)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle,
                  color: Colors.green, size: 50),
              const SizedBox(height: 16),
              const Text('Your Proxy Number is:',
                  style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: ujeLightBlue,
                  borderRadius: BorderRadius.circular(12),
                  border:
                  Border.all(color: ujeBlue.withOpacity(0.3)),
                ),
                child: Text(
                  proxyNumber,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: ujeBlue,
                    letterSpacing: 2,
                  ),
                ),
              ),
            ],
          ),
          actions: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: ujeBlue,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('OK',
                    style: TextStyle(
                        color: Colors.white, fontSize: 16)),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        );
      },
    );
  }

  // ── Helper Widgets ────────────────────────────────────

  Widget _sectionCard({required String title, required Widget child}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: ujeBlue.withOpacity(0.07),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: ujeBlue.withOpacity(0.06),
              borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16)),
              border: Border(
                  bottom: BorderSide(
                      color: ujeBlue.withOpacity(0.1), width: 1)),
            ),
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 16,
                  decoration: BoxDecoration(
                    color: ujeBlue,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: ujeBlue,
                    letterSpacing: 1.0,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: child,
          ),
        ],
      ),
    );
  }

  Widget _styledField({
    required TextEditingController controller,
    required String label,
    String? hint,
    bool enabled = true,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: const TextStyle(fontSize: 14, color: ujeDark),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: TextStyle(
            color: ujeBlue.withOpacity(0.7), fontSize: 13),
        filled: true,
        fillColor:
        enabled ? Colors.white : const Color(0xFFF0F4FF),
        contentPadding: const EdgeInsets.symmetric(
            horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide:
          BorderSide(color: ujeBlue.withOpacity(0.2)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide:
          BorderSide(color: ujeBlue.withOpacity(0.25)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide:
          const BorderSide(color: ujeBlue, width: 1.5),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
              color: Colors.grey.withOpacity(0.2)),
        ),
      ),
    );
  }

  Widget _searchButton(
      {required VoidCallback? onPressed, bool enabled = true}) {
    return SizedBox(
      height: 38,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: const Icon(Icons.search, size: 16, color: Colors.white),
        label: const Text('Search',
            style: TextStyle(color: Colors.white, fontSize: 13)),
        style: ElevatedButton.styleFrom(
          backgroundColor: enabled ? ujeBlue : Colors.grey[400],
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8)),
          elevation: enabled ? 2 : 0,
        ),
      ),
    );
  }

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
          'Proxy Registration',
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
        child: Form(
          key: registrationKey2,
          child: Column(
            children: [
              // ── 1. Proxy Type Toggle ──────────────────
              _sectionCard(
                title: 'PROXY TYPE',
                child: Container(
                  decoration: BoxDecoration(
                    color: isShareholder
                        ? ujeLightBlue
                        : const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isShareholder
                          ? ujeBlue.withOpacity(0.3)
                          : Colors.grey.withOpacity(0.2),
                    ),
                  ),
                  child: SwitchListTile(
                    value: isShareholder,
                    activeColor: ujeBlue,
                    onChanged: (value) =>
                        setState(() => isShareholder = value),
                    title: const Text(
                      'Are you a Shareholder Proxy?',
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: ujeDark),
                    ),
                    subtitle: Text(
                      isShareholder
                          ? 'Acting as a shareholder proxy'
                          : 'Acting as a non-shareholder proxy',
                      style: TextStyle(
                          fontSize: 12,
                          color: isShareholder
                              ? ujeBlue
                              : Colors.grey[500]),
                    ),
                  ),
                ),
              ),

              // ── 2. Shareholder Proxy CDS ──────────────
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: isShareholder ? null : 0,
                child: isShareholder
                    ? _sectionCard(
                  title: 'SHAREHOLDER PROXY DETAILS',
                  child: Column(
                    children: [
                      _styledField(
                        controller:
                        postShareholderCdsController,
                        label: 'CDS Number',
                        hint: 'Enter your CDS No.',
                        enabled: isShareholder,
                      ),
                      const SizedBox(height: 10),
                      Align(
                        alignment: Alignment.centerRight,
                        child: _searchButton(
                          enabled: isShareholder,
                          onPressed: isShareholder
                              ? () {
                            context.loaderOverlay
                                .show();
                            confirmName(
                                postShareholderCdsController
                                    .text);
                          }
                              : null,
                        ),
                      ),
                    ],
                  ),
                )
                    : const SizedBox.shrink(),
              ),

              // ── 3. Proxy Details ──────────────────────
              _sectionCard(
                title: 'PROXY DETAILS',
                child: Column(
                  children: [
                    _styledField(
                      controller: proxyNameController,
                      label: 'Proxy Full Name',
                      hint: 'Enter proxy name',
                      maxLines: 2,
                    ),
                    const SizedBox(height: 12),
                    _styledField(
                      controller: proxyNumberController,
                      label: 'Phone Number',
                      hint: 'e.g. 0712345678',
                      keyboardType: TextInputType.phone,
                    ),
                  ],
                ),
              ),

              // ── 4. Add Shareholder ────────────────────
              _sectionCard(
                title: 'ADD SHAREHOLDER',
                child: Column(
                  children: [
                    _styledField(
                      controller: cdsNumberController,
                      label: 'Shareholder CDS Number',
                      hint: 'Enter shareholder CDS No.',
                    ),
                    const SizedBox(height: 10),
                    Align(
                      alignment: Alignment.centerRight,
                      child: _searchButton(
                        onPressed: () {
                          context.loaderOverlay.show();
                          shareholderName(cdsNo);
                        },
                      ),
                    ),
                    const SizedBox(height: 12),
                    _styledField(
                      controller: shareHolderController,
                      label: "Shareholder's Name",
                      enabled: false,
                    ),
                  ],
                ),
              ),

              // ── 5. Banking & Verification (optional) ──
              _sectionCard(
                title: 'BANKING & VERIFICATION (OPTIONAL)',
                child: Column(
                  children: [
                    _styledField(
                      controller: tinNumberController,
                      label: 'TIN Number (Optional)',
                      hint: 'Enter TIN No.',
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 12),
                    // Bank Dropdown — no validator
                    DropdownButtonFormField<String>(
                      value: bankName,
                      decoration: InputDecoration(
                        labelText: 'Select Bank (Optional)',
                        labelStyle: TextStyle(
                            color: ujeBlue.withOpacity(0.7),
                            fontSize: 13),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding:
                        const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 12),
                        border: OutlineInputBorder(
                          borderRadius:
                          BorderRadius.circular(10),
                          borderSide: BorderSide(
                              color: ujeBlue.withOpacity(0.2)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius:
                          BorderRadius.circular(10),
                          borderSide: BorderSide(
                              color:
                              ujeBlue.withOpacity(0.25)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius:
                          BorderRadius.circular(10),
                          borderSide: const BorderSide(
                              color: ujeBlue, width: 1.5),
                        ),
                      ),
                      icon: const Icon(
                          Icons.keyboard_arrow_down,
                          color: ujeBlue),
                      items: banks.map((item) {
                        return DropdownMenuItem(
                            value: item, child: Text(item));
                      }).toList(),
                      onChanged: (String? newValue) {
                        if (newValue != null &&
                            newValue != bankName) {
                          setState(() => bankName = newValue);
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    _styledField(
                      controller: mobileNumberController,
                      label: 'Mobile Number (Optional)',
                      hint: 'Enter mobile No.',
                    ),
                    const SizedBox(height: 12),
                    _styledField(
                      controller: accountNumberController,
                      label: 'Account Number (Optional)',
                      hint: 'Enter account No.',
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 14),

                    // ── Add Shareholder Button ────────────
                    SizedBox(
                      width: double.infinity,
                      height: 44,
                      child: ElevatedButton.icon(
                        icon: const Icon(
                            Icons.add_circle_outline,
                            color: Colors.white,
                            size: 18),
                        label: const Text('Add Shareholder',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ujeGold,
                          shape: RoundedRectangleBorder(
                              borderRadius:
                              BorderRadius.circular(10)),
                          elevation: 2,
                        ),
                        onPressed: () {
                          AddProxyShareholderModel model =
                          AddProxyShareholderModel(
                            cdsNumberController.text,
                            proxyNameController.text,
                            mobileNumberController.text,
                            tinNumberController.text,
                            bankName,
                            accountNumberController.text,
                          );
                          addValue(model);
                        },
                      ),
                    ),
                  ],
                ),
              ),

              // ── 6. Added Shareholders List ────────────
              if (data.isNotEmpty)
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: ujeBlue.withOpacity(0.2)),
                    boxShadow: [
                      BoxShadow(
                        color: ujeBlue.withOpacity(0.06),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.people_alt_outlined,
                              color: ujeBlue, size: 16),
                          const SizedBox(width: 6),
                          Text(
                            'ADDED SHAREHOLDERS (${data.length})',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: ujeBlue,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      ...data.asMap().entries.map((entry) {
                        return Container(
                          margin:
                          const EdgeInsets.only(bottom: 6),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: ujeLightBlue,
                            borderRadius:
                            BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 24,
                                height: 24,
                                decoration: const BoxDecoration(
                                  color: ujeBlue,
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    '${entry.key + 1}',
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 11,
                                        fontWeight:
                                        FontWeight.bold),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  entry.value,
                                  style: const TextStyle(
                                      fontSize: 13,
                                      color: ujeDark,
                                      fontWeight:
                                      FontWeight.w500),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                ),

              // ── 7. Register Button ────────────────────
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ujeBlue,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    elevation: 3,
                  ),
                  onPressed: () async {
                    if (proxyNameController.text.isEmpty) {
                      _showUjeToast(
                          "Please enter a Proxy Name!");
                    } else if (data.isEmpty) {
                      _showUjeToast(
                          "Please add at least 1 Shareholder!");
                    } else {
                      if (!isShareholder) {
                        setState(() {
                          proxyType = "NonShareholderProxy";
                          if (shareholderProxyCDS.isEmpty) {
                            shareholderProxyCDS = "0";
                          }
                        });
                      } else {
                        setState(() {
                          proxyType = "ShareholderProxy";
                          shareholderProxyCDS =
                              postShareholderCdsController.text;
                        });
                      }
                      context.loaderOverlay.show();
                      String proxyNumb = await postProxyName(
                          proxyName,
                          proxyType,
                          phoneNumber,
                          shareholderProxyCDS,
                          context);
                      Future.delayed(
                          const Duration(milliseconds: 400),
                              () {
                            if (proxyNumb != "") {
                              _showProxyNumberDialog(
                                  context, proxyNumb);
                            }
                          });
                      setState(() {
                        cdsNumberController.text = "";
                        shareHolderController.text = "";
                        proxyNameController.text = "";
                        data.clear();
                      });
                    }
                  },
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.how_to_reg,
                          color: Colors.white, size: 20),
                      SizedBox(width: 10),
                      Text(
                        'REGISTER PROXY',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}