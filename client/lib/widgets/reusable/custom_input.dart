import 'package:client/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomInputField extends StatefulWidget {
  final TextEditingController controller;
  final String labelText;
  final bool obscureText;
  final String? Function(String?)? validator;
  final IconData? prefixIcon;
  final TextInputType? keyboardType;
  final String? hintText;

  const CustomInputField({
    Key? key,
    required this.controller,
    required this.labelText,
    this.obscureText = false,
    this.validator,
    this.prefixIcon,
    this.keyboardType,
    this.hintText,
  }) : super(key: key);

  @override
  _CustomInputFieldState createState() => _CustomInputFieldState();
}

class _CustomInputFieldState extends State<CustomInputField>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _focusAnimation;
  late Animation<Color?> _colorAnimation;

  bool _isFocused = false;
  bool _isObscured = false;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _isObscured = widget.obscureText;

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _focusAnimation = Tween<double>(
      begin: 1.0,
      end: 1.02,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _colorAnimation = ColorTween(
      begin: Colors.white.withOpacity(0.05),
      end: primaryColor.withOpacity(0.1),
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });

      if (_isFocused) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  IconData _getDefaultPrefixIcon() {
    if (widget.labelText.toLowerCase().contains('email')) {
      return Icons.email_outlined;
    } else if (widget.labelText.toLowerCase().contains('password')) {
      return Icons.lock_outline;
    } else if (widget.labelText.toLowerCase().contains('username') ||
        widget.labelText.toLowerCase().contains('name')) {
      return Icons.person_outline;
    } else if (widget.labelText.toLowerCase().contains('phone')) {
      return Icons.phone_outlined;
    }
    return Icons.text_fields_outlined;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _focusAnimation.value,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  _colorAnimation.value ?? Colors.white.withOpacity(0.05),
                  Colors.white.withOpacity(0.02),
                ],
              ),
              border: Border.all(
                color: _isFocused
                    ? primaryColor.withOpacity(0.6)
                    : Colors.white.withOpacity(0.1),
                width: _isFocused ? 2 : 1,
              ),
              boxShadow: _isFocused
                  ? [
                      BoxShadow(
                        color: primaryColor.withOpacity(0.2),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
            ),
            child: TextFormField(
              controller: widget.controller,
              focusNode: _focusNode,
              obscureText: _isObscured,
              keyboardType: widget.keyboardType,
              style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
              decoration: InputDecoration(
                labelText: widget.labelText,
                hintText: widget.hintText,

                // Label styling
                labelStyle: GoogleFonts.inter(
                  color: _isFocused ? primaryColor : Colors.white60,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),

                // Hint styling
                hintStyle: GoogleFonts.inter(
                  color: Colors.white38,
                  fontSize: 16,
                ),

                // Prefix icon
                prefixIcon: Container(
                  margin: const EdgeInsets.only(left: 4, right: 8),
                  child: Icon(
                    widget.prefixIcon ?? _getDefaultPrefixIcon(),
                    color: _isFocused ? primaryColor : Colors.white60,
                    size: 22,
                  ),
                ),

                // Suffix icon for password visibility
                suffixIcon: widget.obscureText
                    ? Container(
                        margin: const EdgeInsets.only(right: 4),
                        child: IconButton(
                          onPressed: () {
                            setState(() {
                              _isObscured = !_isObscured;
                            });
                          },
                          icon: Icon(
                            _isObscured
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: _isFocused ? primaryColor : Colors.white60,
                            size: 22,
                          ),
                        ),
                      )
                    : null,

                // Border styling
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: BorderRadius.circular(16),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: BorderRadius.circular(16),
                ),
                errorBorder: OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: BorderRadius.circular(16),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: BorderRadius.circular(16),
                ),

                // Padding and fill
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 20,
                  horizontal: 20,
                ),
                filled: true,
                fillColor: Colors.transparent,

                // Error styling
                errorStyle: GoogleFonts.inter(
                  color: Colors.red.shade400,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              cursorColor: primaryColor,
              cursorWidth: 2,
              cursorRadius: const Radius.circular(2),
              validator: widget.validator,
            ),
          ),
        );
      },
    );
  }
}
