import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:get/get.dart';
import 'package:webkit/helpers/theme/app_style.dart';
import 'package:webkit/helpers/utils/ui_mixins.dart';
import 'package:webkit/helpers/widgets/my_button.dart';
import 'package:webkit/helpers/widgets/my_container.dart';
import 'package:webkit/helpers/widgets/my_spacing.dart';
import 'package:webkit/helpers/widgets/my_text.dart';
import 'package:webkit/helpers/widgets/responsive.dart';
import 'package:webkit/views/layouts/layout.dart';

class HowItWorks extends StatefulWidget {
  const HowItWorks({super.key});

  @override
  State<HowItWorks> createState() => _HowItWorksState();
}

class _HowItWorksState extends State<HowItWorks> with UIMixin {
  final Color primary = const Color(0xFF835FFF);
  final Color background = const Color(0xFFF5F6FA);
  final Color accentPink = const Color(0xFFF71E64);
  final Color darkText = const Color(0xFF1C1C1E);

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  String? editId;

  Future<void> _addOrUpdateSection() async {
    final title = _titleController.text.trim();
    final description = _descController.text.trim();

    if (title.isEmpty || description.isEmpty) {
      Get.snackbar("Missing Info", "Please add title and description",
          backgroundColor: accentPink.withOpacity(0.1),
          colorText: accentPink);
      return;
    }

    try {
      if (editId != null) {
        await FirebaseFirestore.instance
            .collection("how_it_works")
            .doc(editId)
            .update({
          "title": title,
          "description": description,
          "updatedAt": FieldValue.serverTimestamp(),
        });
        Get.snackbar("Updated", "Section updated successfully",
            backgroundColor: primary.withOpacity(0.1), colorText: primary);
      } else {
        await FirebaseFirestore.instance.collection("how_it_works").add({
          "title": title,
          "description": description,
          "createdAt": FieldValue.serverTimestamp(),
        });
        Get.snackbar("Added", "New section added successfully",
            backgroundColor: primary.withOpacity(0.1), colorText: primary);
      }

      _titleController.clear();
      _descController.clear();
      setState(() => editId = null);
    } catch (e) {
      Get.snackbar("Error", e.toString(),
          backgroundColor: accentPink.withOpacity(0.1),
          colorText: accentPink);
    }
  }

  Future<void> _deleteSection(String id) async {
    try {
      await FirebaseFirestore.instance.collection("how_it_works").doc(id).delete();
      Get.snackbar("Deleted", "Section deleted successfully",
          backgroundColor: accentPink.withOpacity(0.08),
          colorText: accentPink);
    } catch (e) {
      Get.snackbar("Error", e.toString(),
          backgroundColor: accentPink.withOpacity(0.1),
          colorText: accentPink);
    }
  }

  void _setEditMode(QueryDocumentSnapshot doc) {
    setState(() {
      editId = doc.id;
      _titleController.text = doc['title'];
      _descController.text = doc['description'];
    });
  }

  int _getCrossAxisCount(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width >= 1100) return 3;
    if (width >= 700) return 2;
    return 1;
  }

  @override
  Widget build(BuildContext context) {
    return Layout(
      child: Container(
        color: background,
        padding: MySpacing.xy(flexSpacing, flexSpacing),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MyText.titleLarge("⚙️ How It Works",
                  color: darkText, fontWeight: 700),
              MySpacing.height(20),

              // --- Existing Sections ---
              MyContainer(
                color: Colors.white,
                borderRadiusAll: 20,
                paddingAll: 24,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    MyText.titleMedium("Current Sections",
                        fontWeight: 600, color: darkText),
                    MySpacing.height(16),
                    StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection("how_it_works")
                          .orderBy("createdAt", descending: false)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        } else if (!snapshot.hasData ||
                            snapshot.data!.docs.isEmpty) {
                          return Center(
                            child: MyText.bodyMedium("No sections available yet"),
                          );
                        }

                        final sections = snapshot.data!.docs;
                        final crossAxisCount = _getCrossAxisCount(context);

                        return GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                          SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: crossAxisCount,
                            crossAxisSpacing: 20,
                            mainAxisSpacing: 20,
                            childAspectRatio: 1.4,
                          ),
                          itemCount: sections.length,
                          itemBuilder: (context, index) {
                            final doc = sections[index];
                            final title = doc['title'];
                            final desc = doc['description'];

                            return Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  )
                                ],
                              ),
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: MyText.titleSmall(
                                          title,
                                          color: darkText,
                                          fontWeight: 700,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.edit,
                                                size: 18, color: Colors.blue),
                                            onPressed: () => _setEditMode(doc),
                                          ),
                                          IconButton(
                                            icon: const Icon(LucideIcons.trash_2,
                                                size: 18, color: Colors.redAccent),
                                            onPressed: () =>
                                                _deleteSection(doc.id),
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                  MySpacing.height(8),
                                  Expanded(
                                    child: MyText.bodyMedium(
                                      desc,
                                      color: Colors.grey[700],
                                      maxLines: 4,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),

              MySpacing.height(40),

              // --- Add or Edit Section ---
              MyContainer(
                color: Colors.white,
                borderRadiusAll: 20,
                paddingAll: 24,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    MyText.titleMedium(
                        editId == null
                            ? "Add New Section"
                            : "Edit Section",
                        fontWeight: 600,
                        color: darkText),
                    MySpacing.height(20),
                    TextField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        labelText: "Title",
                        filled: true,
                        fillColor: background,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: primary),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: primary, width: 2),
                        ),
                      ),
                    ),
                    MySpacing.height(16),
                    TextField(
                      controller: _descController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        labelText: "Description",
                        filled: true,
                        fillColor: background,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: primary),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: primary, width: 2),
                        ),
                      ),
                    ),
                    MySpacing.height(24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (editId != null)
                          MyButton(
                            onPressed: () {
                              setState(() {
                                editId = null;
                                _titleController.clear();
                                _descController.clear();
                              });
                            },
                            backgroundColor: Colors.grey[300],
                            borderRadiusAll: 12,
                            padding: MySpacing.xy(24, 14),
                            child: MyText.bodyMedium("Cancel",
                                color: darkText, fontWeight: 600),
                          ),
                        MySpacing.width(16),
                        MyButton(
                          onPressed: _addOrUpdateSection,
                          backgroundColor: primary,
                          borderRadiusAll: 12,
                          padding: MySpacing.xy(24, 14),
                          child: MyText.bodyMedium(
                              editId == null ? "Add Section" : "Update Section",
                              color: Colors.white,
                              fontWeight: 600),
                        ),
                      ],
                    ),
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
