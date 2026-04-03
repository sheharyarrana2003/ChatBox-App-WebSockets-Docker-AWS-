import 'package:chatbox_app/Screens/splashScreen.dart';
import 'package:chatbox_app/const/app_bindings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'controllers/authController.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://ntqiqncldnadankiapoi.supabase.co',
    debug: true,
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im50cWlxbmNsZG5hZGFua2lhcG9pIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzI4NzEwNTIsImV4cCI6MjA4ODQ0NzA1Mn0.Bz4grgwwYFRVsAERwRBrrLDdIjQkTR3HL_JNHW3NJWI',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_,child){
        return GetMaterialApp(
          title: 'Chat Room',
          debugShowCheckedModeBanner: false,
          home: child,
          initialBinding: AppBindings(),
        );
      },
      child: Splashscreen(),
    );
  }
}
