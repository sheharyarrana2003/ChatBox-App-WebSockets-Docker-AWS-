import 'dart:ui';

import 'package:flutter/src/painting/text_style.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'colors.dart';

class AppFonts{
  static TextStyle fBoldAuth30 = GoogleFonts.sora(fontSize: 30.sp,color: AppColors.blueColor,fontWeight: FontWeight.bold);
  static TextStyle fBold24=GoogleFonts.dmSans(fontWeight: FontWeight.bold,fontSize: 24.sp,);
  static TextStyle f20=GoogleFonts.dmSans(fontSize: 20.sp,);
  static TextStyle f18=GoogleFonts.dmSans(fontSize: 18.sp,);
  static TextStyle f16=GoogleFonts.dmSans(fontSize: 16.sp,);
  static TextStyle f14=GoogleFonts.dmSans(fontSize: 14.sp,);
  static TextStyle f12=GoogleFonts.dmSans(fontSize: 12.sp,);
}