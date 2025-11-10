import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
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
import 'package:image/image.dart' as img;


class CreatePlanScreen extends StatefulWidget {
  const CreatePlanScreen({super.key});

  @override
  State<CreatePlanScreen> createState() => _CreatePlanScreenState();
}

class _CreatePlanScreenState extends State<CreatePlanScreen> with UIMixin {
  final Color primary = const Color(0xFF835FFF);
  final Color background = const Color(0xFFF6F7FE);
  final Color accentPink = const Color(0xFFF71E64);
  final Color darkText = const Color(0xFF222222);

  final _formKey = GlobalKey<FormState>();
  final _picker = ImagePicker();

  // Controllers
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _coinsController = TextEditingController();
  final _fromDateController = TextEditingController();
  final _toDateController = TextEditingController();
  final _expiryDateController = TextEditingController();

  // Lists
  List<Uint8List> planImages = [];
  List<Uint8List> experienceImages = [];
  List<Map<String, dynamic>> amenities = [];

  String selectedMemberType = 'premium';
  bool isSpecialOffer = false;
  bool isSaving = false;



  // Predefined amenities
  final List<String> predefinedAmenities = [
    'Gym', 'Pool', 'Wifi', 'Parking', 'Spa', 'Restaurant', 'Bar'
  ];

// Map of available icons
  final Map<String, IconData> amenityIcons = {
    'star': LucideIcons.star,
    'heart': LucideIcons.heart,
    'wifi': LucideIcons.wifi,
    'coffee': LucideIcons.coffee,
    'music': LucideIcons.music,
    'car': LucideIcons.car,
    'dumbbell': LucideIcons.dumbbell,
    'sun': LucideIcons.sun,
  };



  // Date Picker helper
  Future<void> _pickDate(TextEditingController controller) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      controller.text = "${picked.year}-${picked.month}-${picked.day}";
    }
  }

  Future<void> _pickImages(List<Uint8List> targetList) async {
    final pickedFiles = await _picker.pickMultiImage();
    if (pickedFiles.isNotEmpty) {
      for (var f in pickedFiles) {
        final bytes = await f.readAsBytes();
        final compressed = await _compressImage(bytes);
        targetList.add(compressed);
      }
      setState(() {});
    }
  }

  Future<Uint8List> _compressImage(Uint8List bytes, {int maxWidth = 1080, int quality = 80}) async {
    try {
      final image = img.decodeImage(bytes);
      if (image == null) return bytes;

      final resized = img.copyResize(
        image,
        width: image.width > maxWidth ? maxWidth : image.width,
      );

      final jpg = img.encodeJpg(resized, quality: quality);
      return Uint8List.fromList(jpg);
    } catch (e) {
      debugPrint("⚠️ Image compression failed: $e");
      return bytes;
    }
  }

  // Add amenity dialog
  Future<void> _addAmenityDialog() async {
    final titleCtrl = TextEditingController();
    String selectedIcon = 'star';

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text("Add Amenity"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleCtrl,
              decoration: const InputDecoration(labelText: "Title"),
            ),
            MySpacing.height(12),
            DropdownButtonFormField<String>(
              value: selectedIcon,
              items: amenityIcons.keys
                  .map((k) => DropdownMenuItem(
                value: k,
                child: Row(
                  children: [
                    Icon(amenityIcons[k], size: 18, color: Colors.black87),
                    MySpacing.width(8),
                    Text(k),
                  ],
                ),
              ))
                  .toList(),
              onChanged: (v) => selectedIcon = v ?? 'star',
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey[100],
                contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
              dropdownColor: Colors.white, // ✅ fixes transparency
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              if (titleCtrl.text.isNotEmpty) {
                amenities.add({
                  "title": titleCtrl.text,
                  "icon": selectedIcon,
                });
                setState(() {});
                Get.back();
              }
            },
            child: const Text("Add"),
          ),
        ],
      ),
    );
  }


  /*Future<void> _addAmenityDialog() async {
    final titleCtrl = TextEditingController();
    final iconCtrl = TextEditingController();
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Add Amenity"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleCtrl,
              decoration: const InputDecoration(labelText: "Title"),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: iconCtrl,
              decoration: const InputDecoration(labelText: "Icon (e.g. star, heart)"),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              if (titleCtrl.text.isNotEmpty) {
                amenities.add({
                  "title": titleCtrl.text,
                  "icon": iconCtrl.text.isEmpty ? "star" : iconCtrl.text,
                });
                setState(() {});
                Get.back();
              }
            },
            child: const Text("Add"),
          ),
        ],
      ),
    );
  }*/

  Future<List<String>> _uploadImages(List<Uint8List> images, String folder) async {
    final urls = <String>[];
    for (var bytes in images) {
      final compressed = await _compressImage(bytes, maxWidth: 1080, quality: 80);
      final fileName = "${DateTime.now().millisecondsSinceEpoch}.jpg";
      final ref = FirebaseStorage.instance.ref().child("plans/$folder/$fileName");
      final uploadTask = await ref.putData(compressed, SettableMetadata(contentType: 'image/jpeg'));
      final url = await uploadTask.ref.getDownloadURL();
      urls.add(url);
    }
    return urls;
  }


  Future<void> _savePlan() async {
    if (!_formKey.currentState!.validate()) return;

    if (planImages.isEmpty) {
      Get.snackbar("Images Required", "Please upload at least one plan image.",
          backgroundColor: accentPink.withOpacity(0.08), colorText: accentPink);
      return;
    }

    setState(() => isSaving = true);

    try {
      final planImageUrls = await _uploadImages(planImages, "main");
      final expImageUrls = experienceImages.isNotEmpty
          ? await _uploadImages(experienceImages, "experiences")
          : [];

      await FirebaseFirestore.instance.collection("plans").add({
        "title": _titleController.text.trim(),
        "description": _descriptionController.text.trim(),
        "coins": int.tryParse(_coinsController.text.trim()) ?? 0,
        "fromDate": _fromDateController.text.trim(),
        "toDate": _toDateController.text.trim(),
        "expiryDate": _expiryDateController.text.trim(),
        "isFor": selectedMemberType,
        "isSpecialOffer": isSpecialOffer,
        "images": planImageUrls,
        "amenities": amenities,
        "experiencesImages": expImageUrls,
        "createdAt": FieldValue.serverTimestamp(),
      });

      Get.snackbar(
        "✅ Success",
        "Plan created successfully",
        backgroundColor: primary.withOpacity(0.1),
        colorText: primary,
        snackPosition: SnackPosition.TOP,
      );

      // small delay for visual feedback
      await Future.delayed(const Duration(milliseconds: 600));

      if (mounted) {
        // ✅ Pop back to PlansOverview (refreshes automatically)
        Get.back(result: true);
      }
    } catch (e, st) {
      debugPrint("🔥 Save plan error: $e\n$st");
      Get.snackbar("Error", e.toString(),
          backgroundColor: accentPink.withOpacity(0.08), colorText: accentPink);
    } finally {
      if (mounted) setState(() => isSaving = false);
    }
  }


  @override
  Widget build(BuildContext context) {
    return Stack(
       children: [
         Layout(
           child: SingleChildScrollView(
             padding: MySpacing.xy(flexSpacing, flexSpacing),
             child: Form(
               key: _formKey,
               child: Column(
                 crossAxisAlignment: CrossAxisAlignment.start,
                 children: [
                   MyText.titleLarge("Create Plan", fontWeight: 800, color: darkText),
                   MySpacing.height(16),

                   MyContainer(
                     color: Colors.white,
                     borderRadiusAll: 20,
                     paddingAll: 24,
                     child: Column(
                       crossAxisAlignment: CrossAxisAlignment.start,
                       children: [
                         MyText.titleMedium("Basic Details", fontWeight: 700),
                         MySpacing.height(12),
                         TextFormField(
                           controller: _titleController,
                           decoration: const InputDecoration(labelText: "Title"),
                           validator: (v) => v!.isEmpty ? "Required" : null,
                         ),
                         MySpacing.height(12),
                         TextFormField(
                           controller: _descriptionController,
                           decoration: const InputDecoration(labelText: "Description"),
                           maxLines: 3,
                           validator: (v) => v!.isEmpty ? "Required" : null,
                         ),
                         MySpacing.height(12),
                         TextFormField(
                           controller: _coinsController,
                           keyboardType: TextInputType.number,
                           decoration: const InputDecoration(labelText: "No. of Coins"),
                         ),
                         MySpacing.height(16),
                         Row(
                           children: [
                             Expanded(
                               child: TextFormField(
                                 controller: _fromDateController,
                                 readOnly: true,
                                 decoration: InputDecoration(
                                   labelText: "From Date",
                                   suffixIcon: IconButton(
                                     icon: const Icon(LucideIcons.calendar),
                                     onPressed: () => _pickDate(_fromDateController),
                                   ),
                                 ),
                               ),
                             ),
                             MySpacing.width(16),
                             Expanded(
                               child: TextFormField(
                                 controller: _toDateController,
                                 readOnly: true,
                                 decoration: InputDecoration(
                                   labelText: "To Date",
                                   suffixIcon: IconButton(
                                     icon: const Icon(LucideIcons.calendar),
                                     onPressed: () => _pickDate(_toDateController),
                                   ),
                                 ),
                               ),
                             ),
                           ],
                         ),
                       ],
                     ),
                   ),

                   MySpacing.height(24),

                   // Images
                   MyContainer(
                     color: Colors.white,
                     borderRadiusAll: 20,
                     paddingAll: 24,
                     child: Column(
                       crossAxisAlignment: CrossAxisAlignment.start,
                       children: [
                         MyText.titleMedium("Plan Images", fontWeight: 700),
                         MySpacing.height(12),
                         Wrap(
                           spacing: 12,
                           runSpacing: 12,
                           children: [
                             ...planImages.map((img) => ClipRRect(
                               borderRadius: BorderRadius.circular(10),
                               child: Image.memory(img, height: 90, width: 120, fit: BoxFit.cover),
                             )),
                             GestureDetector(
                               onTap: () => _pickImages(planImages),
                               child: Container(
                                 height: 90,
                                 width: 120,
                                 decoration: BoxDecoration(
                                   color: background,
                                   borderRadius: BorderRadius.circular(10),
                                   border: Border.all(color: primary, style: BorderStyle.solid),
                                 ),
                                 child: const Icon(LucideIcons.plus, color: Colors.grey),
                               ),
                             ),
                           ],
                         ),
                       ],
                     ),
                   ),

                   MySpacing.height(24),

                   // Amenities
                  /* MyContainer(
                     color: Colors.white,
                     borderRadiusAll: 20,
                     paddingAll: 24,
                     child: Column(
                       crossAxisAlignment: CrossAxisAlignment.start,
                       children: [
                         Row(
                           children: [
                             MyText.titleMedium("Amenities", fontWeight: 700),
                             const Spacer(),
                             MyButton(
                               onPressed: _addAmenityDialog,
                               backgroundColor: primary,
                               borderRadiusAll: 10,
                               padding: MySpacing.xy(12, 8),
                               child: Row(children: [
                                 const Icon(LucideIcons.plus, size: 14, color: Colors.white),
                                 MySpacing.width(6),
                                 MyText.bodySmall("Add", color: Colors.white),
                               ]),
                             ),
                           ],
                         ),
                         MySpacing.height(12),
                         if (amenities.isEmpty)
                           MyText.bodySmall("No amenities added yet", color: Colors.grey[600])
                         else
                           Wrap(
                             spacing: 8,
                             runSpacing: 8,
                             children: amenities
                                 .map((a) => Chip(
                               label: Text(a['title']),
                               deleteIcon: const Icon(Icons.close, size: 16),
                               onDeleted: () {
                                 setState(() => amenities.remove(a));
                               },
                             ))
                                 .toList(),
                           ),
                       ],
                     ),
                   ),*/
                   MyContainer(
                     color: Colors.white,
                     borderRadiusAll: 20,
                     paddingAll: 24,
                     child: Column(
                       crossAxisAlignment: CrossAxisAlignment.start,
                       children: [
                         Row(
                           children: [
                             MyText.titleMedium("Amenities", fontWeight: 700),
                             const Spacer(),
                             MyButton(
                               onPressed: _addAmenityDialog,
                               backgroundColor: primary,
                               borderRadiusAll: 10,
                               padding: MySpacing.xy(12, 8),
                               child: Row(children: [
                                 const Icon(LucideIcons.plus, size: 14, color: Colors.white),
                                 MySpacing.width(6),
                                 MyText.bodySmall("Add", color: Colors.white),
                               ]),
                             ),
                           ],
                         ),
                         MySpacing.height(12),

                         // Dropdown to select predefined amenity
                         Row(
                           children: [
                             // Amenity selection
                             Expanded(
                               child: DropdownButtonFormField<String>(
                                 hint: const Text("Select Amenity"),
                                 items: predefinedAmenities
                                     .map((e) => DropdownMenuItem(
                                   value: e,
                                   child: Text(e),
                                 ))
                                     .toList(),
                                 onChanged: (value) {
                                   if (value != null) {
                                     amenities.add({
                                       'title': value,
                                       'icon': 'star', // default icon
                                     });
                                     setState(() {});
                                   }
                                 },
                                 decoration: InputDecoration(
                                   filled: true,
                                   fillColor: Colors.grey[100],
                                   contentPadding:
                                   const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                   border: OutlineInputBorder(
                                     borderRadius: BorderRadius.circular(10),
                                     borderSide: BorderSide.none,
                                   ),
                                 ),
                                 dropdownColor: Colors.white, // <-- makes the list visible
                               ),
                             ),
                             MySpacing.width(12),

                             // Icon selection
                             Expanded(
                               child: DropdownButtonFormField<String>(
                                 hint: const Text("Select Icon"),
                                 items: amenityIcons.keys
                                     .map((k) => DropdownMenuItem(
                                   value: k,
                                   child: Row(
                                     children: [
                                       Icon(amenityIcons[k], size: 18, color: primary),
                                       MySpacing.width(8),
                                       Text(k),
                                     ],
                                   ),
                                 ))
                                     .toList(),
                                 onChanged: (iconKey) {
                                   if (iconKey != null && amenities.isNotEmpty) {
                                     amenities.last['icon'] = iconKey;
                                     setState(() {});
                                   }
                                 },
                                 decoration: InputDecoration(
                                   filled: true,
                                   fillColor: Colors.grey[100],
                                   contentPadding:
                                   const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                   border: OutlineInputBorder(
                                     borderRadius: BorderRadius.circular(10),
                                     borderSide: BorderSide.none,
                                   ),
                                 ),
                                 dropdownColor: Colors.white, // <-- fixes transparency
                               ),
                             ),
                           ],
                         ),


                         MySpacing.height(12),

                         // Display added amenities
                         if (amenities.isEmpty)
                           MyText.bodySmall("No amenities added yet", color: Colors.grey[600])
                         else
                           Wrap(
                             spacing: 8,
                             runSpacing: 8,
                             children: amenities
                                 .map((a) => Chip(
                               avatar: Icon(
                                 amenityIcons[a['icon']] ?? LucideIcons.star,
                                 size: 16,
                                 color: primary,
                               ),
                               label: Text(a['title']),
                               deleteIcon: const Icon(Icons.close, size: 16),
                               onDeleted: () {
                                 setState(() => amenities.remove(a));
                               },
                               backgroundColor: Colors.grey[100],
                             ))
                                 .toList(),
                           ),
                       ],
                     ),
                   ),

                   MySpacing.height(24),

                   // Membership Type + Special Offer
                   MyContainer(
                     color: Colors.white,
                     borderRadiusAll: 20,
                     paddingAll: 24,
                     child: Column(
                       crossAxisAlignment: CrossAxisAlignment.start,
                       children: [
                         MyText.titleMedium("Plan Settings", fontWeight: 700),
                         MySpacing.height(16),
                         MyText.bodyMedium("Membership Type", fontWeight: 600),
                         Row(
                           children: [
                             Radio<String>(
                               value: 'free',
                               groupValue: selectedMemberType,
                               onChanged: (v) => setState(() => selectedMemberType = v!),
                             ),
                             const Text("Free"),
                             Radio<String>(
                               value: 'premium',
                               groupValue: selectedMemberType,
                               onChanged: (v) => setState(() => selectedMemberType = v!),
                             ),
                             const Text("Premium"),
                           ],
                         ),
                         MySpacing.height(12),
                         Row(
                           children: [
                             Checkbox(
                               value: isSpecialOffer,
                               onChanged: (v) => setState(() => isSpecialOffer = v!),
                             ),
                             const Text("Special Offer"),
                           ],
                         ),
                         MySpacing.height(12),
                         TextFormField(
                           controller: _expiryDateController,
                           readOnly: true,
                           decoration: InputDecoration(
                             labelText: "Expiry Date",
                             suffixIcon: IconButton(
                               icon: const Icon(LucideIcons.calendar),
                               onPressed: () => _pickDate(_expiryDateController),
                             ),
                           ),
                         ),
                       ],
                     ),
                   ),

                   MySpacing.height(24),

                   // Experience Images
                   MyContainer(
                     color: Colors.white,
                     borderRadiusAll: 20,
                     paddingAll: 24,
                     child: Column(
                       crossAxisAlignment: CrossAxisAlignment.start,
                       children: [
                         MyText.titleMedium("Experiences (optional)", fontWeight: 700),
                         MySpacing.height(12),
                         Wrap(
                           spacing: 12,
                           runSpacing: 12,
                           children: [
                             ...experienceImages.map((img) => ClipRRect(
                               borderRadius: BorderRadius.circular(10),
                               child: Image.memory(img, height: 90, width: 120, fit: BoxFit.cover),
                             )),
                             GestureDetector(
                               onTap: () => _pickImages(experienceImages),
                               child: Container(
                                 height: 90,
                                 width: 120,
                                 decoration: BoxDecoration(
                                   color: background,
                                   borderRadius: BorderRadius.circular(10),
                                   border: Border.all(color: primary),
                                 ),
                                 child: const Icon(LucideIcons.plus, color: Colors.grey),
                               ),
                             ),
                           ],
                         ),
                       ],
                     ),
                   ),

                   MySpacing.height(32),

                   Align(
                     alignment: Alignment.centerRight,
                     child: MyButton(
                       onPressed: isSaving ? null : _savePlan,
                       backgroundColor: primary,
                       borderRadiusAll: 12,
                       padding: MySpacing.xy(32, 14),
                       child: isSaving
                           ? const SizedBox(
                           width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                           : MyText.bodyMedium("Save Plan", color: Colors.white, fontWeight: 700),
                     ),
                   ),
                   MySpacing.height(40),
                 ],
               ),
             ),
           ),
         ),
         if (isSaving)
           Container(
             color: Colors.black.withOpacity(0.25),
             alignment: Alignment.center,
             child: Column(
               mainAxisSize: MainAxisSize.min,
               children: const [
                 CircularProgressIndicator(color: Colors.white),
                 SizedBox(height: 12),
                 Text("Saving your plan...", style: TextStyle(color: Colors.white)),
               ],
             ),
           ),
       ],
    );
  }
}
