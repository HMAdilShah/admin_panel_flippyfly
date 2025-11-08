import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:webkit/helpers/theme/app_style.dart';
import 'package:webkit/helpers/utils/ui_mixins.dart';
import 'package:webkit/helpers/widgets/my_button.dart';
import 'package:webkit/helpers/widgets/my_container.dart';
import 'package:webkit/helpers/widgets/my_spacing.dart';
import 'package:webkit/helpers/widgets/my_text.dart';
import 'package:webkit/helpers/widgets/responsive.dart';
import 'package:webkit/views/layouts/layout.dart';

class BannerManagement extends StatefulWidget {
  const BannerManagement({super.key});

  @override
  State<BannerManagement> createState() => _BannerManagementState();
}

class _BannerManagementState extends State<BannerManagement> with UIMixin {
  final Color primary = const Color(0xFF835FFF);
  final Color background = const Color(0xFFF5F6FA);
  final Color accentPink = const Color(0xFFF71E64);
  final Color darkText = const Color(0xFF1C1C1E);

  final ImagePicker _picker = ImagePicker();
  Uint8List? selectedImageBytes;
  final TextEditingController _linkController = TextEditingController();
  bool isUploading = false;

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() => selectedImageBytes = bytes);
    }
  }

  Future<void> _uploadBanner() async {
    if (selectedImageBytes == null || _linkController.text.trim().isEmpty) {
      Get.snackbar(
        "Missing Info",
        "Please select image and add action link",
        backgroundColor: accentPink.withOpacity(0.1),
        colorText: accentPink,
      );
      return;
    }

    setState(() => isUploading = true);
    try {
      final fileName = "banner_${DateTime.now().millisecondsSinceEpoch}.jpg";
      final storageRef = FirebaseStorage.instance.ref().child("banners/$fileName");
      await storageRef.putData(selectedImageBytes!);
      final downloadUrl = await storageRef.getDownloadURL();

      await FirebaseFirestore.instance.collection("banners").add({
        "imageUrl": downloadUrl,
        "actionLink": _linkController.text.trim(),
        "createdAt": FieldValue.serverTimestamp(),
      });

      setState(() {
        selectedImageBytes = null;
        _linkController.clear();
      });

      Get.snackbar("Success", "Banner added successfully",
          backgroundColor: primary.withOpacity(0.1), colorText: primary);
    } catch (e) {
      Get.snackbar("Error", e.toString(),
          backgroundColor: accentPink.withOpacity(0.1),
          colorText: accentPink);
    } finally {
      setState(() => isUploading = false);
    }
  }

  Future<void> _deleteBanner(String id, String imageUrl) async {
    try {
      await FirebaseStorage.instance.refFromURL(imageUrl).delete();
      await FirebaseFirestore.instance.collection("banners").doc(id).delete();

      Get.snackbar("Deleted", "Banner removed successfully",
          backgroundColor: accentPink.withOpacity(0.08),
          colorText: accentPink);
    } catch (e) {
      Get.snackbar("Error", e.toString(),
          backgroundColor: accentPink.withOpacity(0.1),
          colorText: accentPink);
    }
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
              MyText.titleLarge("🎯 Banner Management",
                  color: darkText, fontWeight: 700),
              MySpacing.height(20),

              // --- Existing Banners ---
              MyContainer(
                color: Colors.white,
                borderRadiusAll: 20,
                paddingAll: 20,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    MyText.titleMedium("Existing Banners",
                        fontWeight: 600, color: darkText),
                    MySpacing.height(16),
                    StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection("banners")
                          .orderBy("createdAt", descending: true)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        } else if (!snapshot.hasData ||
                            snapshot.data!.docs.isEmpty) {
                          return Center(
                              child: MyText.bodyMedium("No banners available"));
                        }

                        final banners = snapshot.data!.docs;
                        final crossAxisCount = _getCrossAxisCount(context);

                        return GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                          SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: crossAxisCount,
                            childAspectRatio: 1.4,
                            crossAxisSpacing: 20,
                            mainAxisSpacing: 20,
                          ),
                          itemCount: banners.length,
                          itemBuilder: (context, index) {
                            final doc = banners[index];
                            final imageUrl = doc['imageUrl'];
                            final actionLink = doc['actionLink'];

                            return Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  )
                                ],
                              ),
                              clipBehavior: Clip.antiAlias,
                              child: Stack(
                                children: [
                                  Positioned.fill(
                                    child: Image.network(
                                      imageUrl,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  Positioned(
                                    top: 10,
                                    right: 10,
                                    child: InkWell(
                                      onTap: () => _deleteBanner(doc.id, imageUrl),
                                      borderRadius: BorderRadius.circular(30),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.redAccent.withOpacity(0.8),
                                          borderRadius:
                                          BorderRadius.circular(30),
                                        ),
                                        padding: const EdgeInsets.all(6),
                                        child: const Icon(
                                          LucideIcons.trash_2,
                                          color: Colors.white,
                                          size: 18,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 0,
                                    left: 0,
                                    right: 0,
                                    child: Container(
                                      padding: const EdgeInsets.all(8),
                                      color: Colors.black.withOpacity(0.45),
                                      child: MyText.bodySmall(
                                        actionLink,
                                        color: Colors.white,
                                        textAlign: TextAlign.center,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
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

              // --- New Banner Upload ---
              MyContainer(
                color: Colors.white,
                borderRadiusAll: 20,
                paddingAll: 24,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    MyText.titleMedium("Add New Banner",
                        fontWeight: 600, color: darkText),
                    MySpacing.height(20),

                    GestureDetector(
                      onTap: _pickImage,
                      child: DottedBorderContainer(
                        child: selectedImageBytes == null
                            ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(LucideIcons.image,
                                size: 40, color: primary),
                            MySpacing.height(8),
                            MyText.bodyMedium(
                              "Tap to upload banner image",
                              color: darkText,
                            ),
                          ],
                        )
                            : ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.memory(
                            selectedImageBytes!,
                            height: 180,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),

                    MySpacing.height(20),
                    MyText.bodyMedium("Action / Deep Link:",
                        color: darkText, fontWeight: 600),
                    MySpacing.height(8),
                    TextField(
                      controller: _linkController,
                      decoration: InputDecoration(
                        hintText: "e.g. /screen/home or /screen/sub/details",
                        filled: true,
                        fillColor: background,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: primary, width: 1),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: primary, width: 2),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 16),
                      ),
                    ),
                    MySpacing.height(24),

                    Align(
                      alignment: Alignment.centerRight,
                      child: MyButton(
                        onPressed: isUploading ? null : _uploadBanner,
                        elevation: 0,
                        padding: MySpacing.xy(32, 16),
                        backgroundColor: primary,
                        borderRadiusAll: 12,
                        child: isUploading
                            ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                            : MyText.bodyMedium(
                          "Add Banner",
                          color: Colors.white,
                          fontWeight: 600,
                        ),
                      ),
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

/// Reusable dotted upload box
class DottedBorderContainer extends StatelessWidget {
  final Widget child;
  const DottedBorderContainer({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF835FFF),
          width: 1.5,
        ),
      ),
      child: Center(child: child),
    );
  }
}
