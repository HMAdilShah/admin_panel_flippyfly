// controller/apps/contact/mail_controller.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MailController extends GetxController {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  final subjectController = TextEditingController();
  final bodyController = TextEditingController();

  RxBool isSending = false.obs;
  RxString selectedTemplate = ''.obs;
  RxInt sentCount = 0.obs;

  final Map<String, Map<String, String>> templates = {
    'Plan Approved': {
      'subject': 'Your Flipi Plan Has Been Approved!',
      'html': '<h2>Congratulations!</h2><p>Your Flipi plan is now active.</p>',
    },
    'Payment Reminder': {
      'subject': 'Payment Reminder - Flipi Plan',
      'html': '<h2>Payment Due Soon</h2><p>Your monthly Flipi payment is due.</p>',
    },
    'Welcome': {
      'subject': 'Welcome to Flipifly!',
      'html': '<h2>Welcome!</h2><p>Start creating your plan today!</p>',
    },
  };

  void applyTemplate(String name) {
    final t = templates[name]!;
    subjectController.text = t['subject']!;
    bodyController.text = t['html']!;
    selectedTemplate.value = name;
  }

  Future<void> sendBulkEmail() async {
    if (subjectController.text.isEmpty || bodyController.text.isEmpty) {
      Get.snackbar('Error', 'Subject and body are required',
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    isSending.value = true;
    sentCount.value = 0;

    try {
      final users = await _db.collection('users').get();
      final batch = _db.batch();

      for (final user in users.docs) {
        final email = user.data()['email'];
        if (email != null && email.toString().isNotEmpty) {
          final ref = _db.collection('mail').doc();
          batch.set(ref, {
            'to': email,
            'message': {
              'subject': subjectController.text,
              'html': bodyController.text,
            },
            'createdAt': FieldValue.serverTimestamp(),
          });
          sentCount.value++;
        }
      }

      await batch.commit();
      Get.snackbar(
        'Success',
        'Email sent to ${sentCount.value} users!',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      subjectController.clear();
      bodyController.clear();
      selectedTemplate.value = '';
    } catch (e) {
      Get.snackbar('Error', e.toString(),
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isSending.value = false;
    }
  }

  @override
  void onClose() {
    subjectController.dispose();
    bodyController.dispose();
    super.onClose();
  }
}