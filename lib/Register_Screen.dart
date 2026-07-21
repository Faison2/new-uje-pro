// ignore_for_file: prefer_const_constructors
import 'package:uje/services.dart';
import 'package:uje/widgets/confirm_registration.dart';
import 'package:uje/widgets/secure_text_field.dart';
import 'package:uje/services/keylogger_protection_service.dart';
import 'package:flutter/material.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'constants/constants.dart';
import 'model/register_model.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
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

  TextEditingController controller = TextEditingController();
  TextEditingController mobileNumberController = TextEditingController();
  final GlobalKey<FormState> registrationKey2 = GlobalKey<FormState>();
  late TextEditingController tinNumberController;
  late TextEditingController bankController;
  late TextEditingController accountNumberController;

  String text = "";
  String shareholderNumber = "";
  String registrationStatus = "";
  String voteCode = "";
  String voterName = "";
  String voterCodeString = "";
  String phoneNumber = "";
  String bankName = "Bank";
  bool hasSearched = false;
  bool _isShown = true;

  // ── Registration check future ──────────────────────────
  Future<bool>? _registrationFuture;

  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    // 🔐 Initialize keylogger protection
    KeyloggerProtectionService().initialize();

    controller.addListener(() {
      shareholderNumber = controller.text;
    });
    mobileNumberController.addListener(() {
      phoneNumber = mobileNumberController.text;
    });
    bankController = TextEditingController();
    accountNumberController = TextEditingController();
    tinNumberController = TextEditingController();
    mobileNumberController = TextEditingController();

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnim =
        CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(
        CurvedAnimation(parent: _animController, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _animController.dispose();
    bankController.dispose();
    controller.dispose();
    accountNumberController.dispose();
    tinNumberController.dispose();
    mobileNumberController.dispose();
    super.dispose();
  }

  // ── Styled field helper ───────────────────────────────

  Widget _styledField({
    required TextEditingController ctrl,
    required String label,
    String? hint,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
  }) {
    return TextFormField(
      controller: ctrl,
      keyboardType: keyboardType,
      onChanged: onChanged,
      validator: validator,
      style: const TextStyle(fontSize: 14, color: coopTextDark),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle:
        TextStyle(color: coopDarkBlue.withOpacity(0.7), fontSize: 13),
        filled: true,
        fillColor: coopSurface,
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide:
          BorderSide(color: coopDarkBlue.withOpacity(0.2)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide:
          BorderSide(color: coopDarkBlue.withOpacity(0.25)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: coopDarkBlue, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide:
          const BorderSide(color: Colors.redAccent, width: 1.2),
        ),
      ),
    );
  }

  // ── Section card helper ───────────────────────────────

  Widget _sectionCard({required String title, required Widget child}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: coopSurface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: coopDarkBlue.withOpacity(0.07),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: coopDarkBlue.withOpacity(0.06),
              borderRadius:
              const BorderRadius.vertical(top: Radius.circular(16)),
              border: Border(
                  bottom: BorderSide(
                      color: coopDarkBlue.withOpacity(0.1), width: 1)),
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
                Text(
                  title,
                  style: const TextStyle(
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
            child: child,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: coopBackground,
      appBar: AppBar(
        backgroundColor: coopDarkBlue,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        title: const Text(
          'Shareholder Registration',
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
          children: [
            // ── Logo Card ─────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                  vertical: 20, horizontal: 24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [coopDarkBlue, coopMidBlue],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: coopDarkBlue.withOpacity(0.25),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Logo
                  Container(
                    decoration: BoxDecoration(
                      color: coopSurface,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    child: Image.asset(
                      'assets/images/logo.PNG',
                      width: 140,
                      height: 60,
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'Shareholder Registration',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: coopGreen.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: coopGreen.withOpacity(0.5), width: 1),
                    ),
                    child: const Text(
                      'Enter your CDS number to get started',
                      style: TextStyle(
                        color: Color(0xFFB8F0B5),
                        fontSize: 11,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ── CDS Search Card ───────────────────────
            _sectionCard(
              title: 'SHAREHOLDER LOOKUP',
              child: Column(
                children: [
                  // 🔐 CDS Number - Using SecureTextField for keylogger protection
                  SecureTextField(
                    controller: controller,
                    label: 'CDS Number',
                    hint: 'Enter your CDS No.',
                    onChanged: (_) => setState(() {
                      hasSearched = false;
                      _registrationFuture = null;
                    }),
                  ),
                  const SizedBox(height: 10),

                  // ── Name result from FutureBuilder ────
                  if (hasSearched)
                    FutureBuilder(
                      future: checkName(controller.text, context),
                      builder: (context,
                          AsyncSnapshot<String> snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.done) {
                          if (snapshot.data != null &&
                              snapshot.data!.isNotEmpty) {
                            return Container(
                              width: double.infinity,
                              margin:
                              const EdgeInsets.only(bottom: 10),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 12),
                              decoration: BoxDecoration(
                                color: coopBackground,
                                borderRadius:
                                BorderRadius.circular(10),
                                border: Border.all(
                                    color: coopGreen.withOpacity(0.35)),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                      Icons.person_pin_outlined,
                                      color: coopDarkBlue,
                                      size: 18),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      snapshot.data!,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: coopDarkBlue,
                                      ),
                                    ),
                                  ),
                                  const Icon(Icons.check_circle,
                                      color: Colors.green, size: 16),
                                ],
                              ),
                            );
                          }
                        }
                        return const SizedBox.shrink();
                      },
                    ),

                  // ── Already Registered Banner ─────────
                  if (hasSearched && _registrationFuture != null)
                    FutureBuilder<bool>(
                      future: _registrationFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.done &&
                            snapshot.data == true) {
                          return Container(
                            width: double.infinity,
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF3CD),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                  color: const Color(0xFFFFCC02),
                                  width: 1.2),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.info_outline,
                                    color: Color(0xFF856404), size: 18),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Shareholder Already Registered',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF856404),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),

                  // ── Search Button ─────────────────────
                  SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.search,
                          color: Colors.white, size: 18),
                      label: const Text(
                        'Search',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 15),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: coopDarkBlue,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        elevation: 2,
                      ),
                      onPressed: () {
                        context.loaderOverlay.show();
                        setState(() {
                          hasSearched = true;
                          // Kick off registration check in parallel
                          _registrationFuture =
                              isAlreadyRegistered(controller.text);
                        });
                        _animController.forward(from: 0);
                      },
                    ),
                  ),
                ],
              ),
            ),

            // ── Registration Details (shown after search) ──
            if (hasSearched) ...[
              FutureBuilder<bool>(
                future: _registrationFuture,
                builder: (context, snapshot) {
                  // Hide the form entirely if already registered
                  if (snapshot.connectionState == ConnectionState.done &&
                      snapshot.data == true) {
                    return const SizedBox.shrink();
                  }
                  return FadeTransition(
                    opacity: _fadeAnim,
                    child: SlideTransition(
                      position: _slideAnim,
                      child: Form(
                        key: registrationKey2,
                        child: _sectionCard(
                          title: 'REGISTRATION DETAILS',
                          child: Column(
                            children: [
                              // 🔐 TIN (Optional) - Using SecureTextField for keylogger protection
                              SecureTextField(
                                controller: tinNumberController,
                                label: 'TIN Number (Optional)',
                                hint: 'Enter TIN No.',
                                keyboardType: TextInputType.number,
                              ),
                              const SizedBox(height: 12),

                              // Bank Dropdown
                              DropdownButtonFormField<String>(
                                value: bankName,
                                decoration: InputDecoration(
                                  labelText: 'Select Bank',
                                  labelStyle: TextStyle(
                                      color:
                                      coopDarkBlue.withOpacity(0.7),
                                      fontSize: 13),
                                  filled: true,
                                  fillColor: coopSurface,
                                  contentPadding:
                                  const EdgeInsets.symmetric(
                                      horizontal: 14, vertical: 14),
                                  border: OutlineInputBorder(
                                    borderRadius:
                                    BorderRadius.circular(10),
                                    borderSide: BorderSide(
                                        color: coopDarkBlue
                                            .withOpacity(0.2)),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius:
                                    BorderRadius.circular(10),
                                    borderSide: BorderSide(
                                        color: coopDarkBlue
                                            .withOpacity(0.25)),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius:
                                    BorderRadius.circular(10),
                                    borderSide: const BorderSide(
                                        color: coopDarkBlue,
                                        width: 1.5),
                                  ),
                                ),
                                icon: const Icon(
                                    Icons.keyboard_arrow_down,
                                    color: coopDarkBlue),
                                items: banks.map((item) {
                                  return DropdownMenuItem(
                                      value: item,
                                      child: Text(item));
                                }).toList(),
                                onChanged: (String? newValue) {
                                  if (newValue != null &&
                                      newValue != bankName) {
                                    setState(
                                            () => bankName = newValue);
                                  }
                                },
                              ),
                              const SizedBox(height: 12),

                              // 🔐 Mobile Number (Required) - Using SecureTextField for keylogger protection
                              SecureTextField(
                                controller: mobileNumberController,
                                label: 'Mobile Number',
                                hint: 'e.g. 0712345678',
                                keyboardType: TextInputType.phone,
                                validator: (val) =>
                                (val == null || val.isEmpty)
                                    ? 'Please enter a Mobile Number'
                                    : null,
                              ),
                              const SizedBox(height: 12),

                              // 🔐 Account Number (Optional) - Using SecureTextField for keylogger protection
                              SecureTextField(
                                controller: accountNumberController,
                                label: 'Account Number (Optional)',
                                hint: 'Enter account No.',
                                keyboardType: TextInputType.number,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],

            // ── Register Button ───────────────────────
            // Hide register button if already registered
            if (hasSearched && _registrationFuture != null)
              FutureBuilder<bool>(
                future: _registrationFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done &&
                      snapshot.data == true) {
                    return const SizedBox.shrink();
                  }
                  return _buildRegisterButton();
                },
              )
            else
              _buildRegisterButton(),

            const SizedBox(height: 16),

            // Footer
            Text(
              '© ${DateTime.now().year} Coop Bank Tanzania',
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[400],
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRegisterButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton.icon(
        icon: const Icon(Icons.how_to_reg,
            color: Colors.white, size: 20),
        label: const Text(
          'REGISTER',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: coopDarkBlue,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14)),
          elevation: 3,
        ),
        onPressed: () {
          if (_isShown) {
            if (registrationKey2.currentState!.validate()) {
              RegisterModel model = RegisterModel(
                  shareholderNumber: controller.text,
                  mobileNumber: mobileNumberController.text,
                  tin: tinNumberController.text,
                  bank: bankName,
                  accountNumber: accountNumberController.text);
              showMyDialog(context, model);
            }
          }
        },
      ),
    );
  }
}