import 'package:get/get.dart';
import '../models/statusModel.dart';

class StatusController extends GetxController {
  var statusList = <StatusModel>[].obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadDummyStatuses();
  }

  // Get my status (always first if exists)
  StatusModel? get myStatus {
    try {
      return statusList.firstWhere((status) => status.isMyStatus);
    } catch (e) {
      return null;
    }
  }

  // Get other users' statuses
  List<StatusModel> get otherStatuses {
    return statusList.where((status) => !status.isMyStatus).toList();
  }

  // Get recent statuses only (within 24 hours)
  List<StatusModel> get recentStatuses {
    return statusList.where((status) => status.isRecent).toList();
  }

  // Load dummy data (replace with Supabase later)
  void loadDummyStatuses() {
    final dummyStatuses = <StatusModel>[
      // My status (always first)
      StatusModel(
        id: 'my_status',
        userName: 'My Status',
        profileImageUrl: 'https://randomuser.me/api/portraits/men/1.jpg',
        timestamp: DateTime.now().subtract(Duration(hours: 2)),
        isViewed: false,
        isMyStatus: true,
        statusCount: 3,
        statusType: 'image',
      ),
    ];

    // Add other users' statuses
    for (int i = 0; i < 12; i++) {
      dummyStatuses.add(StatusModel(
        id: 'status_$i',
        userName: _generateUserName(i),
        profileImageUrl: "https://randomuser.me/api/portraits/${i % 2 == 0 ? 'women' : 'men'}/${20 + i}.jpg",
        timestamp: DateTime.now().subtract(Duration(hours: i + 1, minutes: i * 5)),
        isViewed: i % 3 == 0,
        isMyStatus: false,
        statusCount: (i % 3) + 1,
        statusType: _getRandomStatusType(i),
      ));
    }

    statusList.value = dummyStatuses;
  }

  // Future method for Supabase integration
  Future<void> loadStatusesFromSupabase() async {
    try {
      isLoading.value = true;
      // TODO: Implement Supabase query
      // final response = await supabaseClient.from('statuses').select();
      // statusList.value = response.map((json) => StatusModel.fromJson(json)).toList();

      await Future.delayed(Duration(seconds: 1)); // Simulate API call
      loadDummyStatuses(); // Remove this when implementing Supabase
    } catch (e) {
      Get.snackbar('Error', 'Failed to load statuses: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Add new status
  void addStatus(String imagePath, String statusType) {
    final newStatus = StatusModel(
      id: 'status_${DateTime.now().millisecondsSinceEpoch}',
      userName: 'My Status',
      profileImageUrl: imagePath,
      timestamp: DateTime.now(),
      isViewed: false,
      isMyStatus: true,
      statusCount: 1,
      statusType: statusType,
    );

    // Remove old my status if exists and add new one
    statusList.removeWhere((status) => status.isMyStatus);
    statusList.insert(0, newStatus);
  }

  // Mark status as viewed
  void markAsViewed(String statusId) {
    final statusIndex = statusList.indexWhere((status) => status.id == statusId);
    if (statusIndex != -1) {
      statusList[statusIndex] = statusList[statusIndex].copyWith(isViewed: true);
    }
  }

  // Delete status (only my status)
  void deleteStatus(String statusId) {
    if (statusList.any((status) => status.id == statusId && status.isMyStatus)) {
      statusList.removeWhere((status) => status.id == statusId);
    }
  }

  // Helper methods for dummy data
  String _generateUserName(int index) {
    final names = [
      'Alice Johnson', 'Bob Smith', 'Carol Davis', 'David Wilson',
      'Emma Brown', 'Frank Miller', 'Grace Taylor', 'Henry Clark',
      'Ivy Martinez', 'Jack Anderson', 'Kate Thompson', 'Liam Garcia'
    ];
    return names[index % names.length];
  }

  String _getRandomStatusType(int index) {
    final types = ['image', 'video', 'text'];
    return types[index % types.length];
  }
}