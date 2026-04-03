import 'package:chatbox_app/models/callsModel.dart';
import 'package:get/get.dart';

class CallController extends GetxController{
  var callsList=<CallsModel>[].obs;
  var isLoading=false.obs;

  @override
  void onInit() {
    super.onInit();
    loadDummyCalls();
  }
  
  void loadDummyCalls(){
    callsList.value=List.generate(10, (index){
      return CallsModel(
        id: "call_$index",
        userName: _generateUserName(index),
        timestamp: _generateTimestamp(index),
        profileImageUrl: "https://randomuser.me/api/portraits/${index % 2 == 0 ? 'women' : 'men'}/${20 + index}.jpg"
      );
    });
  }
  String _generateUserName(int index) {
    final names = [
      'Alice Johnson', 'Bob Smith', 'Carol Davis', 'David Wilson',
      'Emma Brown', 'Frank Miller', 'Grace Taylor', 'Henry Clark',
      'Ivy Martinez', 'Jack Anderson', 'Kate Thompson', 'Liam Garcia',
      'Maya Rodriguez', 'Noah Lewis', 'Olivia Walker'
    ];
    return names[index % names.length];
  }
  String _generateTimestamp(int index) {
    final now = DateTime.now();
    if (index < 3) return '1 hour ago';
    if (index < 6) return '${index + 1} min ago';
    if (index < 10) return '${index - 5} hr ago';
    return '${index - 9} days ago';
  }
}