import 'dart:io';
import 'package:chatbox_app/Screens/signUpScreen.dart';
import 'package:chatbox_app/Screens/mainScreen.dart';
import 'package:chatbox_app/const/appDurations.dart';
import 'package:chatbox_app/controllers/profile_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../Screens/otpScreen.dart';
import '../Services/emailAuthService.dart';
import '../Services/shared_pref_session.dart';
import '../Services/socket_service.dart';
import '../models/profile_model.dart'; // Import Profile model

class AuthController extends GetxController {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  // Updated controllers for email auth
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final TextEditingController userNameController = TextEditingController();
  final TextEditingController otpController = TextEditingController();

  // Use EmailAuthService instead of SupaBaseOTP
  final EmailAuthService emailAuth = EmailAuthService(client: Supabase.instance.client);

  File? get image => profileImage.value;

  var user = Rxn<User>();
  var profileImage = Rxn<File>();
  var isLoading = false.obs;
  var isPass = false.obs;
  var isLoginMode = true.obs; // true = login, false = signup
  var savedProfile = Rxn<Profile>(); // Store the full profile
  final ProfileController profileController = Get.find<ProfileController>();


  @override
  void onInit() {
    super.onInit();
    // Check for saved session when controller initializes
    _checkSavedSession();
  }

  /// Check if user is already logged in from LocalStorage
  Future<void> _checkSavedSession() async {
    try {
      final isLoggedIn = await LocalStorageService.isLoggedIn();
      final savedUserId = await LocalStorageService.getUserId();
      final profile = await LocalStorageService.getSavedProfile();

      if (isLoggedIn && savedUserId != null) {
        print('📱 Found saved session for user: $savedUserId');

        if (profile != null) {
          savedProfile.value = profile;
          print('✅ Restored profile: ${savedProfile.value!.username}');
        }

        // Check if Supabase session is still valid
        final currentUser = Supabase.instance.client.auth.currentUser;

        if (currentUser != null) {
          user.value = currentUser;
          print('✅ Supabase session is valid');
        } else {
          // Supabase session expired, but we have local data
          print('⚠️ Supabase session expired');
        }
      }
    } catch (e) {
      print('Error checking saved session: $e');
    }
  }

  /// Save user session after successful login
  Future<void> _saveUserSession({
    required String userId,
    required String email, // Changed from phoneNumber
    Profile? profile,
    String? authToken,
  }) async {
    await LocalStorageService.saveUserSession(
      userId: userId,
      email: email, // Changed from phoneNumber
      profileData: profile?.toMap(),
      authToken: authToken,
    );

    if (profile != null) {
      savedProfile.value = profile;
    }
  }

  /// Check if user is logged in (for splash screen)
  Future<bool> isUserLoggedIn() async {
    return await LocalStorageService.isLoggedIn();
  }

  /// Get saved user ID
  Future<String?> getSavedUserId() async {
    return await LocalStorageService.getUserId();
  }

  /// Get saved profile
  Future<Profile?> getSavedProfile() async {
    return await LocalStorageService.getSavedProfile();
  }

  /// Toggle between login and signup modes
  void toggleMode() {
    isLoginMode.value = !isLoginMode.value;
    clearFields();
  }

  /// Clear all fields
  void clearFields() {
    emailController.clear();
    passwordController.clear();
    confirmPasswordController.clear();
    userNameController.clear();
    otpController.clear();
  }

  /// Sign up with email and password
  Future<void> signUpWithEmail() async {
    try {
      isLoading.value = true;

      // 1. Create auth user with email/password
      final response = await emailAuth.signUpWithPassword(
        email: emailController.text.trim(),
        password: passwordController.text,
        userData: {
          'username': userNameController.text.trim(),
        },
      );

      final userId = response.user?.id;
      user.value = response.user;

      if (userId == null) throw Exception("User ID not found");
      print("User Id: $userId");
      print("Email: ${emailController.text.trim()}");

      // 2. Create profile using global profileController (FIXED)
      final profile = await profileController.createMyProfile(
        userId: userId,
        email: emailController.text.trim(), // Changed from phoneNumber
        name: userNameController.text.trim(),
        avatarFile: profileImage.value,
        avatarFileExtension: _getFileExtension(profileImage.value),
      );

      // 3. Save session to LocalStorage
      await _saveUserSession(
        userId: userId,
        email: emailController.text.trim(), // Changed from phoneNumber
        profile: profile,
        authToken: response.session?.accessToken,
      );

      // 4. Connect to socket server with the full profile
      if (profile != null) {
        final socketService = Get.find<SocketService>();
        await socketService.connect(profile);
      }

      // 5. Navigate to OTP verification screen
      Get.to(() => EmailVerificationScreen(email: emailController.text.trim()));

    } on EmailAuthException catch (e) {
      Get.snackbar(
        "Sign Up Failed",
        emailAuth.getUserFriendlyErrorMessage(e),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } catch (e) {
      print("Sign Up Error: $e");
      Get.snackbar(
        "Error",
        "Failed to create account.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Sign in with email and password - FIXED
  Future<void> signInWithEmail() async {
    try {
      isLoading.value = true;

      // 1. Sign in with email/password
      final response = await emailAuth.signInWithPassword(
        email: emailController.text.trim(),
        password: passwordController.text,
      );

      final userId = response.user?.id;
      user.value = response.user;

      if (userId == null) throw Exception("User ID not found");
      print("User Id: $userId");
      print("Email: ${emailController.text.trim()}");

      // 2. ✅ FIX: Await profile fetch - don't use cached value
      final profile = await profileController.getMyProfile();
      print("📄 Profile loaded: ${profile?.username ?? 'No profile'}");

      // 3. Save session to LocalStorage
      await _saveUserSession(
        userId: userId,
        email: emailController.text.trim(),
        profile: profile,
        authToken: response.session?.accessToken,
      );

      // 4. Connect to socket server with the full profile
      if (profile != null) {
        final socketService = Get.find<SocketService>();
        await socketService.connect(profile);
      }

      // 5. Check if email is verified
      if (response.user?.emailConfirmedAt == null) {
        Get.to(() => EmailVerificationScreen(email: emailController.text.trim()));
      } else {
        Get.offAll(() => MainNavigation());
      }

    } on EmailAuthException catch (e) {
      Get.snackbar(
        "Sign In Failed",
        emailAuth.getUserFriendlyErrorMessage(e),
        backgroundColor: Colors.red,
      );
    } catch (e) {
      print("Sign In Error: $e");
      Get.snackbar("Error", "Failed to sign in.");
    } finally {
      isLoading.value = false;
    }
  }

  /// Send OTP (magic link) to email
  Future<void> sendEmailOTP() async {
    try {
      isLoading.value = true;

      final email = emailController.text.trim();

      // Validate email
      if (!emailAuth.isValidEmail(email)) {
        Get.snackbar(
          "Invalid Email",
          "Please enter a valid email address",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      await emailAuth.sendEmailOTP(email);

      // Save email temporarily
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('temp_email', email);

      // Navigate to OTP screen
      Get.to(
            () => EmailVerificationScreen(email: email),
        transition: Transition.rightToLeft,
        duration: Duration(milliseconds: AppDurations.miliSeconds),
      );

    } on EmailAuthException catch (e) {
      Get.snackbar(
        "Error",
        emailAuth.getUserFriendlyErrorMessage(e),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  /// Verify email OTP and navigate to main screen
  Future<void> verifyEmailOTP(String email, String otp) async {
    // Validate OTP first
    final otpError = validateOTP(otp);
    if (otpError != null) {
      Get.snackbar(
        "Invalid OTP",
        otpError,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    try {
      isLoading.value = true;

      // 1. Verify OTP
      final credential = await emailAuth.verifyEmailOTP(
        email: email,
        token: otp,
      );

      final userId = credential?.id;
      user.value = credential;

      if (userId == null) throw Exception("User ID not found");
      print("User Id: $userId");
      print("Email: $email");

      // 2. Get profile using global profileController (FIXED)
      var profile = profileController.profile.value;

      // If no profile exists, create one (user might have username from signup or need to enter it)
      if (profile == null && userNameController.text.isNotEmpty) {
        profile = await profileController.createMyProfile(
          userId: userId,
          email: email, // Changed from phoneNumber
          name: userNameController.text.trim(),
          avatarFile: profileImage.value,
          avatarFileExtension: _getFileExtension(profileImage.value),
        );
      }

      // 3. Save session to LocalStorage
      await _saveUserSession(
        userId: userId,
        email: email, // Changed from phoneNumber
        profile: profile,
        authToken: credential?.email,
      );

      // Clear temporary data
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('temp_email');

      // 4. Connect to socket server with the full profile
      if (profile != null) {
        final socketService = Get.find<SocketService>();
        await socketService.connect(profile);
      }

      Get.offAll(() => MainNavigation());

    } on EmailAuthException catch (e) {
      Get.snackbar(
        "Verification Failed",
        emailAuth.getUserFriendlyErrorMessage(e),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } catch (e) {
      print("OTP Verification Error: $e");
      Get.snackbar(
        "Error",
        "Failed to verify code.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Send password reset email
  Future<void> sendPasswordResetEmail() async {
    try {
      isLoading.value = true;

      final email = emailController.text.trim();

      if (!emailAuth.isValidEmail(email)) {
        Get.snackbar(
          "Invalid Email",
          "Please enter a valid email address",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      await emailAuth.sendPasswordResetEmail(email);

      Get.snackbar(
        "Password Reset",
        "Check your email for reset instructions",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  /// Sign out user
  Future<void> signOut() async {
    try {
      isLoading.value = true;

      // Sign out from Supabase
      await emailAuth.signOut();

      // Clear local session
      await LocalStorageService.clearUserSession();

      // Clear user data
      user.value = null;
      profileImage.value = null;
      savedProfile.value = null;
      emailController.clear();
      passwordController.clear();
      confirmPasswordController.clear();
      userNameController.clear();
      otpController.clear();

      // Navigate to login
      Get.offAll(() => SignupScreen());

      Get.snackbar(
        "Success",
        "Logged out successfully",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

    } catch (e) {
      print('Sign out error: $e');
      Get.snackbar(
        "Error",
        "Failed to sign out",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Resend verification email
  Future<void> resendVerificationEmail() async {
    try {
      isLoading.value = true;

      final email = emailController.text.trim();

      if (email.isEmpty && savedProfile.value != null) {
        // Use email from saved profile
        await emailAuth.resendVerificationEmail(savedProfile.value!.email!);
      } else if (email.isNotEmpty) {
        await emailAuth.resendVerificationEmail(email);
      } else {
        throw Exception("No email provided");
      }

      Get.snackbar(
        "Email Sent",
        "Verification email has been resent",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  /// Refresh email verification status
  Future<bool> refreshEmailVerification() async {
    return await emailAuth.refreshEmailVerificationStatus();
  }

  String? _getFileExtension(File? file) {
    if (file == null) return null;
    final String path = file.path;
    final String ext = path.split('.').last.toLowerCase();
    if (['jpg', 'jpeg', 'png', 'webp', 'gif'].contains(ext)) {
      return ext;
    }
    return null;
  }

  Future<void> pickImage(ImageSource source) async {
    try {
      final pickedFile = await ImagePicker().pickImage(source: source);
      if (pickedFile != null) {
        profileImage.value = File(pickedFile.path);
        print("Image selected: ${pickedFile.path}");
        print("ProfileImage value: ${profileImage.value}");
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

  // Updated validators for email
  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return "Email required";
    }
    if (!GetUtils.isEmail(value)) {
      return "Invalid email format";
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return "Password required";
    }
    if (value.length < 6) {
      return "Password must be at least 6 characters";
    }
    return null;
  }

  String? validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return "Please confirm password";
    }
    if (value != passwordController.text) {
      return "Passwords do not match";
    }
    return null;
  }

  String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return "Username required";
    }
    if (value.length < 3) {
      return "Username must be at least 3 characters";
    }
    return null;
  }

  // Enhanced OTP validator
  String? validateOTP(String? value) {
    if (value == null || value.isEmpty) {
      return "Verification code is required";
    }

    // Remove any spaces or special characters
    final cleaned = value.replaceAll(RegExp(r'\s+'), '');

    if (cleaned.length < 8) {
      return "Code must be 8 digits";
    }

    if (cleaned.length > 8) {
      return "Code must be exactly 8 digits";
    }

    // Check if it contains only digits
    if (!RegExp(r'^\d+$').hasMatch(cleaned)) {
      return "Code should contain only numbers";
    }

    return null;
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    userNameController.dispose();
    otpController.dispose();
    super.onClose();
  }
}