import 'package:chatbox_app/Screens/logInScreen.dart';
import 'package:chatbox_app/const/appDurations.dart';
import 'package:chatbox_app/const/app_assets.dart';
import 'package:chatbox_app/const/colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

class Splashscreen extends StatefulWidget {
  const Splashscreen({super.key});

  @override
  State<Splashscreen> createState() => _SplashscreenState();
}

class _SplashscreenState extends State<Splashscreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 3),(){
      Get.offAll(
              ()=>Loginscreen(),
        transition: Transition.rightToLeft,
        duration: Duration(milliseconds: AppDurations.miliSeconds)
      );
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      body: Center(
        child: Image.asset(AppAssets.app_icon),
      ),
    );
  }
}
