import 'package:chatbox_app/controllers/contactController.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Services
import '../Services/chat_service.dart';
import '../Services/contact_service.dart';
import '../Services/profile_service.dart';
import '../Services/socket_service.dart';
import '../Services/supabase_storage_service.dart';

// Controllers
import '../controllers/authController.dart';
import '../controllers/chatController.dart';
import '../controllers/profile_controller.dart';

class AppBindings extends Bindings {
  @override
  void dependencies() {
    print('📦 Registering dependencies...');

    // ========================================
    // 1. CORE DEPENDENCIES (No dependencies)
    // ========================================
    Get.put<SupabaseClient>(Supabase.instance.client, permanent: true);
    print('✅ SupabaseClient registered');

    // ========================================
    // 2. SERVICES (May depend on Core)
    // ========================================
    Get.put(SupabaseStorageService(), permanent: true);
    print('✅ SupabaseStorageService registered');

    Get.put(ProfileService(), permanent: true);
    print('✅ ProfileService registered');

    Get.put(SocketService(), permanent: true);
    print('✅ SocketService registered');

    Get.put(ChatService(), permanent: true);
    print('✅ ChatService registered');

    Get.put(ContactsService(), permanent: true);
    print('✅ ContactsService registered');

    // ========================================
    // 3. CONTROLLERS (May depend on Services)
    // ========================================
    // ⚠️ IMPORTANT: ProfileController must be registered BEFORE AuthController
    // because AuthController needs ProfileController in its onInit()

    Get.put(ProfileController(), permanent: true);
    print('✅ ProfileController registered');

    Get.put(AuthController(), permanent: true);
    print('✅ AuthController registered');

    Get.put(ContactsController(), permanent: true);
    print('✅ ContactsController registered');

    Get.put(ChatController(), permanent: true);
    print('✅ ChatController registered');
  }
}