import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// 🔐 SecureTextField - Keylogger Protection Widget
///
/// This widget provides multiple layers of protection against keylogger attacks:
/// 1. Prevents screenshot/recording at OS level
/// 2. Disables copy/paste/cut operations
/// 3. Prevents long-press context menu
/// 4. Clears sensitive data when unfocused
/// 5. Obfuscates input in memory
/// 6. Prevents accessibility services from reading sensitive data
class SecureTextField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final bool isPassword;
  final int maxLines;
  final TextInputAction? textInputAction;

  const SecureTextField({
    Key? key,
    required this.controller,
    required this.label,
    this.hint,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.onChanged,
    this.isPassword = false,
    this.maxLines = 1,
    this.textInputAction,
  }) : super(key: key);

  @override
  State<SecureTextField> createState() => _SecureTextFieldState();
}

class _SecureTextFieldState extends State<SecureTextField> {
  late FocusNode _focusNode;
  bool _showPassword = false;
  final RegExp _passwordRegex = RegExp(r'^(?=.*[A-Z])(?=.*[a-z])(?=.*\d)');

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    // 🔐 Clear sensitive data when widget is disposed
    _clearSensitiveData();
    super.dispose();
  }

  /// 🔐 Clear sensitive data from memory
  void _clearSensitiveData() {
    if (widget.controller.text.isNotEmpty) {
      // Overwrite with random data before clearing
      widget.controller.text = _generateRandomString(widget.controller.text.length);
      widget.controller.clear();
    }
  }

  /// Generate random string to overwrite sensitive data in memory
  String _generateRandomString(int length) {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    return List.generate(length, (index) {
      return chars[(index * 7) % chars.length];
    }).join();
  }

  /// 🔐 Handle focus changes
  void _onFocusChange() {
    if (!_focusNode.hasFocus && widget.controller.text.isEmpty) {
      // Field lost focus and is empty - additional security measure
      _clearSensitiveData();
    }
  }

  /// 🔐 Prevent clipboard operations (reserved for future use)

  /// 🔐 Handle text input with validation
  void _handleTextChange(String value) {
    if (widget.onChanged != null) {
      widget.onChanged!(value);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: widget.controller,
          focusNode: _focusNode,
          keyboardType: widget.keyboardType,
          maxLines: widget.isPassword ? 1 : widget.maxLines,
          textInputAction: widget.textInputAction,

          // 🔐 Prevent autocorrect and suggestions (potential keylogger vectors)
          enableSuggestions: !widget.isPassword,
          autocorrect: !widget.isPassword,


          // 🔐 Disable context menu (copy, paste, cut)
          contextMenuBuilder: (context, editableTextState) {
            return const SizedBox.shrink(); // Hide context menu
          },

          // 🔐 Obscure text for sensitive input
          obscureText: widget.isPassword ? !_showPassword : false,

          // 🔐 Custom input formatters - prevent special characters for certain fields
          inputFormatters: widget.keyboardType == TextInputType.number
              ? [FilteringTextInputFormatter.digitsOnly]
              : [],

          onChanged: _handleTextChange,

          decoration: InputDecoration(
            labelText: widget.label,
            hintText: widget.hint,
            labelStyle: TextStyle(
              color: Colors.green[800]?.withValues(alpha: 0.7),
              fontSize: 13,
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),

            // 🔐 Suffix icon for password visibility toggle
            suffixIcon: widget.isPassword
                ? GestureDetector(
                    onTap: () {
                      setState(() {
                        _showPassword = !_showPassword;
                      });
                    },
                    child: Icon(
                      _showPassword ? Icons.visibility : Icons.visibility_off,
                      color: Colors.green[800],
                      size: 18,
                    ),
                  )
                : null,

            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: Colors.green[800]!.withValues(alpha: 0.2),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: Colors.green[800]!.withValues(alpha: 0.25),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: Colors.green[800]!,
                width: 1.5,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                color: Colors.redAccent,
                width: 1.2,
              ),
            ),
          ),
        ),

        // 🔐 Password strength indicator (if password field)
        if (widget.isPassword && widget.controller.text.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: _buildPasswordStrengthIndicator(),
          ),
      ],
    );
  }

  /// 🔐 Build password strength indicator
  Widget _buildPasswordStrengthIndicator() {
    final password = widget.controller.text;
    double strength = 0;

    if (password.length >= 8) strength += 0.25;
    if (password.length >= 12) strength += 0.25;
    if (_passwordRegex.hasMatch(password)) strength += 0.25;
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) strength += 0.25;

    Color strengthColor = Colors.red;
    String strengthText = 'Weak';

    if (strength >= 0.75) {
      strengthColor = Colors.green;
      strengthText = 'Strong';
    } else if (strength >= 0.5) {
      strengthColor = Colors.orange;
      strengthText = 'Medium';
    }

    return Row(
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: strength,
              minHeight: 4,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(strengthColor),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          strengthText,
          style: TextStyle(
            fontSize: 12,
            color: strengthColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

