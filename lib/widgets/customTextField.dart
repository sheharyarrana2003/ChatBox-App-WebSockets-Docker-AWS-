import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../const/colors.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String? hintText;
  final String? labelText;
  final IconData icon;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final int? maxlength;

  // New parameters
  final bool obscureText;
  final Widget? suffixIcon;
  final VoidCallback? onSuffixIconPressed;
  final bool readOnly;
  final TextInputAction? textInputAction;
  final void Function(String)? onChanged;
  final FocusNode? focusNode;

  const CustomTextField({
    super.key,
    required this.controller,
    this.hintText,
    this.labelText,
    required this.icon,
    this.keyboardType,
    this.validator,
    this.maxlength,

    // New parameters with defaults
    this.obscureText = false,
    this.suffixIcon,
    this.onSuffixIconPressed,
    this.readOnly = false,
    this.textInputAction,
    this.onChanged,
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      maxLength: maxlength,
      obscureText: obscureText,
      readOnly: readOnly,
      textInputAction: textInputAction,
      onChanged: onChanged,
      focusNode: focusNode,

      decoration: InputDecoration(
        hintText: hintText,
        labelText: labelText,

        // Prefix Icon
        prefixIcon: Icon(icon, color: AppColors.blueColor, size: 20.sp),

        // Suffix Icon (if provided)
        suffixIcon: suffixIcon != null
            ? GestureDetector(
          onTap: onSuffixIconPressed,
          child: suffixIcon,
        )
            : null,

        // Styling
        labelStyle: TextStyle(
          color: AppColors.blueColor,
          fontSize: 14.sp,
          fontWeight: FontWeight.w500,
        ),
        hintStyle: TextStyle(
          color: AppColors.blackColor.withOpacity(0.5),
          fontSize: 14.sp,
        ),

        filled: true,
        fillColor: AppColors.lightGrey,

        // Border
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: AppColors.lightGrey.withOpacity(0.9)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: AppColors.blueColor.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: AppColors.blueColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: Colors.red.shade400, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: Colors.red.shade700, width: 2),
        ),

        // Counter text styling
        counterStyle: TextStyle(
          fontSize: 10.sp,
          color: AppColors.blackColor.withOpacity(0.4),
        ),

        // Content padding
        contentPadding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
      ),

      style: TextStyle(
        fontSize: 14.sp,
        color: AppColors.blackColor,
        fontWeight: FontWeight.w400,
      ),

      cursorColor: AppColors.blueColor,
      cursorWidth: 1.5,
      cursorRadius: Radius.circular(4.r),
    );
  }
}