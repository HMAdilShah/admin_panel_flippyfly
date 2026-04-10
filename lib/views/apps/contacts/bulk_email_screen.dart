// views/apps/contacts/bulk_email_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:get/get.dart';
import 'package:webkit/controller/mail_controller.dart';
import 'package:webkit/helpers/widgets/my_spacing.dart';
import 'package:webkit/helpers/widgets/my_text.dart';
import 'package:webkit/views/layouts/layout.dart';

class BulkEmailScreen extends StatelessWidget {
  final Color primary = const Color(0xFF835FFF);
  final Color background = const Color(0xFFEFF1FE);

  BulkEmailScreen({super.key});

  final MailController controller = Get.put(MailController());

  @override
  Widget build(BuildContext context) {
    return Layout(
      child: Container(
        color: background,
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Icon(LucideIcons.mail, color: primary, size: 24),
                  MySpacing.width(10),
                  MyText.titleLarge("Bulk Email", fontWeight: 700),
                ],
              ),
              MySpacing.height(24),

              // Templates
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10)],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    MyText.bodyMedium("Quick Templates", fontWeight: 700),
                    MySpacing.height(12),
                    Obx(() => Wrap(
                      spacing: 10,
                      runSpacing: 8,
                      children: controller.templates.keys.map((name) =>
                          ChoiceChip(
                            label: Text(name),
                            selected: controller.selectedTemplate.value == name,
                            selectedColor: primary,
                            labelStyle: TextStyle(
                              color: controller.selectedTemplate.value == name
                                  ? Colors.white
                                  : Colors.black87,
                            ),
                            onSelected: (_) => controller.applyTemplate(name),
                          ),
                      ).toList(),
                    )),
                  ],
                ),
              ),
              MySpacing.height(16),

              // Compose
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10)],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    MyText.bodyMedium("Compose Email", fontWeight: 700),
                    MySpacing.height(16),

                    // Subject
                    TextField(
                      controller: controller.subjectController,
                      decoration: InputDecoration(
                        labelText: 'Subject',
                        prefixIcon: Icon(LucideIcons.type, size: 18),
                        filled: true,
                        fillColor: background,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    MySpacing.height(12),

                    // Body
                    TextField(
                      controller: controller.bodyController,
                      maxLines: 10,
                      decoration: InputDecoration(
                        labelText: 'Email Body (HTML supported)',
                        alignLabelWithHint: true,
                        filled: true,
                        fillColor: background,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    MySpacing.height(20),

                    // Send Button
                    Obx(() => SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primary,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: controller.isSending.value
                            ? null
                            : controller.sendBulkEmail,
                        icon: controller.isSending.value
                            ? const SizedBox(
                            width: 18, height: 18,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2))
                            : const Icon(LucideIcons.send, color: Colors.white, size: 18),
                        label: Text(
                          controller.isSending.value
                              ? 'Sending...'
                              : 'Send to All Users',
                          style: const TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ),
                    )),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}