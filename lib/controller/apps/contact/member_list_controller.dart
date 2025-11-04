import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:webkit/controller/my_controller.dart';
import 'package:webkit/helpers/widgets/my_form_validator.dart';
import 'package:webkit/models/app_user.dart';
import 'package:webkit/models/discover.dart';
import 'package:webkit/models/opportunities.dart';
import 'package:webkit/models/post.dart';

class MemberListController extends MyController {
  List<Discover> discover = [];
  List<Opportunities> opportunities = [];

  MyFormValidator basicValidator = MyFormValidator();
  bool loading = false;

  @override
  void onInit() {
    super.onInit();

    Discover.dummyList.then((value) {
      discover = value.sublist(0, 7);
      update();
    });
    Opportunities.dummyList.then((value) {
      opportunities = value.sublist(0, 7);
      update();
    });
  }

  Future<List<AppUserModel>> fetchUsers() async {
    try {
      final snapshot = await FirebaseFirestore.instance.collection('users').get();
      final users = snapshot.docs.map((doc) {
        return AppUserModel.fromMap(doc.data());
      }).toList();
      return users.sublist(0, users.length);
    } catch (e) {
      throw Exception('Failed to load users: $e');
    }
  }

  Future<List<Post>> fetchPosts() async {
    final snapshot = await FirebaseFirestore.instance.collection('posts').get();
    return snapshot.docs.map((doc) => Post.fromMap(doc.data())).toList();
  }

  void goToDashboard() {
    Get.toNamed('/dashboard');
  }
}
