import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class AuthController extends GetxController {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController numberController = TextEditingController();
  final TextEditingController userNameController = TextEditingController();
  final TextEditingController otpController = TextEditingController();

  File? get image => profileImage.value;

  var profileImage = Rxn<File>();
  var isLoading = false.obs;
  var isPass = false.obs;

  Future<void> pickImage(ImageSource source) async {
    try {
      final pickedFile = await ImagePicker().pickImage(source: source);
      if (pickedFile != null) {
        profileImage.value = File(pickedFile.path);
        print("Image selected: ${pickedFile.path}"); // Debug print
        print("ProfileImage value: ${profileImage.value}"); // Debug print
      } else {
        print("No image selected");
      }
    } catch (e) {
      print("Error picking image: $e");
    }
  }

  String? getImagePath() {
    return profileImage.value?.path;
  }

  bool hasImage() {
    return profileImage.value != null;
  }

  void togglePass() {
    isPass.value = !isPass.value;
  }

  String? numberValidation(String? value) {
    if (value == null || value.isEmpty) {
      return "Number required";
    }
    return null;
  }

  String? otpValidation(String? value) {
    if (value == null || value.isEmpty) {
      return "OTP required for verification";
    }
    return null;
  }

  String? nameValidation(String? value) {
    if (value == null || value.isEmpty) {
      return "User Name required";
    }
    return null;
  }

  @override
  void onClose() {
    numberController.dispose();
    userNameController.dispose();
    otpController.dispose();
    super.onClose();
  }
}