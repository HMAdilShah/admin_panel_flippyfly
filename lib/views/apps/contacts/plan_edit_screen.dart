// plan_edit_screen.dart
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:image/image.dart' as img;
import 'package:webkit/helpers/theme/app_style.dart';
import 'package:webkit/helpers/utils/ui_mixins.dart';
import 'package:webkit/helpers/widgets/my_button.dart';
import 'package:webkit/helpers/widgets/my_container.dart';
import 'package:webkit/helpers/widgets/my_spacing.dart';
import 'package:webkit/helpers/widgets/my_text.dart';

class PlanEditScreen extends StatefulWidget {
  final String planId;
  const PlanEditScreen({super.key, required this.planId});

  @override
  State<PlanEditScreen> createState() => _PlanEditScreenState();
}

class _PlanEditScreenState extends State<PlanEditScreen> with UIMixin {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final ImagePicker _picker = ImagePicker();

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _coinsController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  DateTime? _fromDate;
  DateTime? _toDate;
  DateTime? _expiryDate;
  bool _isSpecialOffer = false;
  String _isFor = 'premium';
  bool _isSaving = false;

  // images handling
  List<String> _existingImages = []; // URLs currently stored in Firestore
  List<String> _existingExperienceImages = [];
  final Set<String> _removedExistingImages = {}; // URLs marked to delete
  final Set<String> _removedExistingExperienceImages = {};
  List<Uint8List> _newImages = []; // picked new images to upload
  List<Uint8List> _newExperienceImages = [];

  // amenities
  List<Map<String, dynamic>> _amenities = [];
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

 /* // predefined amenities (example)
  final List<String> predefinedAmenities = [
    'Gym', 'Pool', 'Wifi', 'Parking', 'Spa', 'Restaurant', 'Bar'
  ];*/
  final Map<String, IconData> predefinedAmenitiesWithIcons = {
    // Fitness & Wellness
    'Gym': LucideIcons.dumbbell,
    'Yoga Studio': LucideIcons.activity,
    'Personal Trainer': LucideIcons.user,
    'Spa': LucideIcons.sparkles,
    'Sauna': LucideIcons.thermometer,
    'Steam Room': LucideIcons.cloud,
    'Massage': LucideIcons.hand,
    'Meditation Room': LucideIcons.brain,

    // Sports
    'Swimming Pool': LucideIcons.waves,
    'Indoor Pool': LucideIcons.droplets,
    'Outdoor Pool': LucideIcons.sun,
    'Tennis Court': LucideIcons.circle_dot,
    'Basketball Court': LucideIcons.circle,

    // Facilities
    'Locker Room': LucideIcons.lock,
    'Parking': LucideIcons.car,
    'Wheelchair Access': LucideIcons.accessibility,

    // Connectivity
    'Free Wifi': LucideIcons.wifi,
    'Air Conditioning': LucideIcons.wind,

    // Food
    'Cafe': LucideIcons.coffee,
    'Restaurant': LucideIcons.utensils,
  };

  @override
  void initState() {
    super.initState();
    _loadPlan();
  }

  // ---------- load ----------
  Future<void> _loadPlan() async {
    final doc = await _db.collection('plans').doc(widget.planId).get();
    if (!doc.exists) return;
    final data = doc.data()!;
    setState(() {
      _titleController.text = data['title'] ?? '';
      _coinsController.text = (data['coins'] ?? '').toString();
      _descriptionController.text = data['description'] ?? '';
      _fromDate = _parseDate(data['fromDate']);
      _toDate = _parseDate(data['toDate']);
      _expiryDate = _parseDate(data['expiryDate']);
      _isSpecialOffer = data['isSpecialOffer'] ?? false;
      _isFor = data['isFor'] ?? 'premium';

      // images
      final imgs = (data['images'] as List<dynamic>?)?.cast<String>() ?? [];
      _existingImages = List<String>.from(imgs);

      final exImgs = (data['experiencesImages'] as List<dynamic>?)?.cast<String>() ?? [];
      _existingExperienceImages = List<String>.from(exImgs);

      // amenities: normalize
      _amenities = (data['amenities'] as List<dynamic>?)
          ?.map((e) {
        if (e is Map) {
          return {
            'title': e['title'] ?? '',
            'icon': predefinedAmenitiesWithIcons.containsKey(e['title'])
                ? e['title']
                : 'Gym', // fallback

          };
        }
        return {'title': e.toString(), 'icon': 'star'};
      })
          .cast<Map<String, dynamic>>()
          .toList() ??
          [];
    });
  }

  DateTime? _parseDate(dynamic d) {
    if (d == null) return null;
    if (d is Timestamp) return d.toDate();
    if (d is DateTime) return d;
    if (d is String) {
      try {
        return DateTime.tryParse(d);
      } catch (_) {
        // try naive parse like yyyy-M-d
        final parts = d.split('-');
        if (parts.length >= 3) {
          final y = int.tryParse(parts[0]) ?? 0;
          final m = int.tryParse(parts[1]) ?? 1;
          final day = int.tryParse(parts[2]) ?? 1;
          return DateTime(y, m, day);
        }
      }
    }
    return null;
  }

  String _formatDateShort(DateTime? dt) {
    if (dt == null) return '-';
    return "${dt.day.toString().padLeft(2,'0')}/${dt.month.toString().padLeft(2,'0')}/${dt.year}";
  }

  // ---------- image helpers ----------
  Future<Uint8List> _compressImage(Uint8List bytes, {int maxWidth = 1080, int quality = 80}) async {
    try {
      final image = img.decodeImage(bytes);
      if (image == null) return bytes;
      final resized = img.copyResize(image, width: image.width > maxWidth ? maxWidth : image.width);
      final jpg = img.encodeJpg(resized, quality: quality);
      return Uint8List.fromList(jpg);
    } catch (e) {
      debugPrint("Image compress failed: $e");
      return bytes;
    }
  }

  Future<void> _pickNewImages({required bool experiences}) async {
    final picked = await _picker.pickMultiImage();
    if (picked == null || picked.isEmpty) return;
    for (final f in picked) {
      final bytes = await f.readAsBytes();
      final compressed = await _compressImage(bytes);
      setState(() {
        if (experiences) {
          _newExperienceImages.add(compressed);
        } else {
          _newImages.add(compressed);
        }
      });
    }
  }

  void _removeExistingImage(String url, {required bool experiences}) {
    setState(() {
      if (experiences) {
        _existingExperienceImages.remove(url);
        _removedExistingExperienceImages.add(url);
      } else {
        _existingImages.remove(url);
        _removedExistingImages.add(url);
      }
    });
  }

  void _removeNewImageAt(int idx, {required bool experiences}) {
    setState(() {
      if (experiences) {
        _newExperienceImages.removeAt(idx);
      } else {
        _newImages.removeAt(idx);
      }
    });
  }

  // ---------- upload / delete ----------
  Future<List<String>> _uploadBytesList(List<Uint8List> bytes, String folder) async {
    final res = <String>[];
    for (final b in bytes) {
      final compressed = await _compressImage(b, maxWidth: 1080, quality: 85);
      final fileName = "plan_${DateTime.now().millisecondsSinceEpoch}_${res.length}.jpg";
      final ref = FirebaseStorage.instance.ref().child("plans/${widget.planId}/$folder/$fileName");
      final uploadTask = await ref.putData(compressed, SettableMetadata(contentType: 'image/jpeg'));
      final url = await uploadTask.ref.getDownloadURL();
      res.add(url);
    }
    return res;
  }

  Future<void> _deleteRemoteUrls(Set<String> urls) async {
    for (final u in urls) {
      try {
        await FirebaseStorage.instance.refFromURL(u).delete();
      } catch (e) {
        debugPrint("Failed to delete storage url $u: $e");
        // continue - do not block save if deletion fails
      }
    }
  }

  // ---------- amenity dialog ----------
  Future<void> _addAmenityDialog() async {
    final titleCtrl = TextEditingController();
    String selectedIcon = amenityIcons.keys.first;
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
              onChanged: (v) => selectedIcon = v ?? selectedIcon,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey[100],
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
              ),
              dropdownColor: Colors.white,
            )
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              if (titleCtrl.text.trim().isEmpty) return;
              setState(() => _amenities.add({'title': titleCtrl.text.trim(), 'icon': selectedIcon}));
              Get.back();
            },
            child: const Text("Add"),
          ),
        ],
      ),
    );
  }

  // ---------- save ----------
  Future<void> _savePlan() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      // 1) Upload new images (if any)
      final uploadedMain = await _uploadBytesList(_newImages, "images");
      final uploadedExperiences = await _uploadBytesList(_newExperienceImages, "experiences");

      // 2) Delete removed remote images from Storage (best-effort)
      await _deleteRemoteUrls(_removedExistingImages);
      await _deleteRemoteUrls(_removedExistingExperienceImages);

      // 3) Final lists to save
      final finalImages = [..._existingImages, ...uploadedMain];
      final finalExperienceImages = [..._existingExperienceImages, ...uploadedExperiences];

      // 4) Prepare payload
      final payload = {
        'title': _titleController.text.trim(),
        'coins': int.tryParse(_coinsController.text.trim()) ?? 0,
        'description': _descriptionController.text.trim(),
        'fromDate': _fromDate != null ? Timestamp.fromDate(_fromDate!) : null,
        'toDate': _toDate != null ? Timestamp.fromDate(_toDate!) : null,
        'expiryDate': _expiryDate != null ? Timestamp.fromDate(_expiryDate!) : null,
        'isSpecialOffer': _isSpecialOffer,
        'isFor': _isFor,
        'images': finalImages,
        'experiencesImages': finalExperienceImages,
        'amenities': _amenities,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      // 5) Update Firestore
      await _db.collection('plans').doc(widget.planId).update(payload);

      Get.snackbar("Success", "Plan updated successfully", backgroundColor: Colors.green.withOpacity(0.12), colorText: Colors.green);
      // Get.back(result: true);
      Navigator.of(context).pop(true);

    } catch (e, st) {
      debugPrint("Save plan error: $e\n$st");
      Get.snackbar("Error", e.toString(), backgroundColor: Colors.red.withOpacity(0.12), colorText: Colors.red);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  // ---------- date pickers ----------
  Future<void> _pickDate(BuildContext ctx, {required bool isFrom}) async {
    final now = DateTime.now();
    final initial = isFrom ? (_fromDate ?? now) : (_toDate ?? now);
    final picked = await showDatePicker(context: ctx, initialDate: initial, firstDate: DateTime(2000), lastDate: DateTime(2100));
    if (picked != null) {
      setState(() {
        if (isFrom) _fromDate = picked;
        else _toDate = picked;
      });
    }
  }

  Future<void> _pickExpiryDate(BuildContext ctx) async {
    final now = DateTime.now();
    final picked = await showDatePicker(context: ctx, initialDate: _expiryDate ?? now, firstDate: DateTime(2000), lastDate: DateTime(2100));
    if (picked != null) setState(() => _expiryDate = picked);
  }

  // ---------- UI ----------
  Widget _buildImagePreview(String url, {required bool experiences}) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.network(url, height: 90, width: 120, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(color: Colors.grey[200], child: const Icon(Icons.broken_image))),
        ),
        Positioned(
          top: 6,
          right: 6,
          child: GestureDetector(
            onTap: () => _removeExistingImage(url, experiences: experiences),
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(color: Colors.black.withOpacity(0.6), shape: BoxShape.circle),
              child: const Icon(Icons.close, size: 14, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNewImagePreview(Uint8List bytes, int idx, {required bool experiences}) {
    return Stack(
      children: [
        ClipRRect(borderRadius: BorderRadius.circular(10), child: Image.memory(bytes, height: 90, width: 120, fit: BoxFit.cover)),
        Positioned(
          top: 6,
          right: 6,
          child: GestureDetector(
            onTap: () => _removeNewImageAt(idx, experiences: experiences),
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(color: Colors.black.withOpacity(0.6), shape: BoxShape.circle),
              child: const Icon(Icons.close, size: 14, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color primary = const Color(0xFF835FFF);
    final Color background = const Color(0xFFF6F7FE);

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Plan'), backgroundColor: primary),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                MyText.titleLarge("Edit Plan", fontWeight: 700),
                MySpacing.height(16),

                // Title
                TextFormField(
                  controller: _titleController,
                  validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                  decoration: InputDecoration(labelText: "Title", filled: true, fillColor: Colors.grey[100], border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
                ),
                MySpacing.height(12),

                // Dates row
                Row(children: [
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      MyText.titleMedium("From Date"),
                      MySpacing.height(6),
                      InkWell(
                        onTap: () => _pickDate(context, isFrom: true),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          decoration: BoxDecoration(color: Colors.grey[100], border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(10)),
                          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                            Text(_fromDate != null ? _formatDateShort(_fromDate) : 'Select date', style: const TextStyle(color: Colors.black87)),
                            const Icon(Icons.calendar_today, size: 18),
                          ]),
                        ),
                      ),
                    ]),
                  ),
                  MySpacing.width(12),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      MyText.titleMedium("To Date"),
                      MySpacing.height(6),
                      InkWell(
                        onTap: () => _pickDate(context, isFrom: false),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          decoration: BoxDecoration(color: Colors.grey[100], border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(10)),
                          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                            Text(_toDate != null ? _formatDateShort(_toDate) : 'Select date', style: const TextStyle(color: Colors.black87)),
                            const Icon(Icons.calendar_today, size: 18),
                          ]),
                        ),
                      ),
                    ]),
                  ),
                ]),
                MySpacing.height(12),

                // Coins
                TextFormField(
                  controller: _coinsController,
                  keyboardType: TextInputType.number,
                  validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                  decoration: InputDecoration(labelText: "Coins", filled: true, fillColor: Colors.grey[100], border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
                ),
                MySpacing.height(12),

                // Description
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 4,
                  decoration: InputDecoration(labelText: "Description", filled: true, fillColor: Colors.grey[100], border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
                ),
                MySpacing.height(12),

                // Expiry date
                MyText.titleMedium("Expiry Date"),
                MySpacing.height(6),
                InkWell(
                  onTap: () => _pickExpiryDate(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    decoration: BoxDecoration(color: Colors.grey[100], border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(10)),
                    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      Text(_expiryDate != null ? _formatDateShort(_expiryDate) : 'Select expiry date', style: const TextStyle(color: Colors.black87)),
                      const Icon(Icons.calendar_today, size: 18),
                    ]),
                  ),
                ),
                MySpacing.height(12),

                // Membership type + special offer
                Row(children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _isFor,
                      items: const [
                        DropdownMenuItem(value: 'premium', child: Text('Premium')),
                        DropdownMenuItem(value: 'free', child: Text('Free')),
                      ],
                      onChanged: (v) => setState(() => _isFor = v ?? 'premium'),
                      dropdownColor: Colors.white,
                      decoration: InputDecoration(filled: true, fillColor: Colors.grey[100], border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none)),
                    ),
                  ),
                  MySpacing.width(16),
                  Row(children: [
                    Checkbox(value: _isSpecialOffer, onChanged: (v) => setState(() => _isSpecialOffer = v ?? false)),
                    const Text("Special Offer"),
                  ]),
                ]),
                MySpacing.height(16),

                // Images (existing + new)
                MyContainer(
                  color: Colors.white,
                  borderRadiusAll: 12,
                  paddingAll: 14,
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    MyText.titleMedium("Plan Images", fontWeight: 700),
                    MySpacing.height(10),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          // existing images
                          ..._existingImages.map((u) => Padding(padding: const EdgeInsets.only(right: 8), child: _buildImagePreview(u, experiences: false))),
                          // new images
                          ...List.generate(_newImages.length, (i) => Padding(padding: const EdgeInsets.only(right: 8), child: _buildNewImagePreview(_newImages[i], i, experiences: false))),
                          GestureDetector(
                            onTap: () => _pickNewImages(experiences: false),
                            child: Container(
                              height: 90,
                              width: 120,
                              decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(10), border: Border.all(color: const Color(0xFF835FFF))),
                              child: const Center(child: Icon(LucideIcons.plus)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ]),
                ),
                MySpacing.height(12),

                // Experience images (existing + new)
                MyContainer(
                  color: Colors.white,
                  borderRadiusAll: 12,
                  paddingAll: 14,
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    MyText.titleMedium("Experience Images (optional)", fontWeight: 700),
                    MySpacing.height(10),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          ..._existingExperienceImages.map((u) => Padding(padding: const EdgeInsets.only(right: 8), child: _buildImagePreview(u, experiences: true))),
                          ...List.generate(_newExperienceImages.length, (i) => Padding(padding: const EdgeInsets.only(right: 8), child: _buildNewImagePreview(_newExperienceImages[i], i, experiences: true))),
                          GestureDetector(
                            onTap: () => _pickNewImages(experiences: true),
                            child: Container(
                              height: 90,
                              width: 120,
                              decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(10), border: Border.all(color: const Color(0xFF835FFF))),
                              child: const Center(child: Icon(LucideIcons.plus)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ]),
                ),
                MySpacing.height(12),

                // Amenities area (add/select)
                MyContainer(
                  color: Colors.white,
                  borderRadiusAll: 12,
                  paddingAll: 14,
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      MyText.titleMedium("Amenities", fontWeight: 700),
                      const Spacer(),
                      MyButton(onPressed: _addAmenityDialog, backgroundColor: const Color(0xFF835FFF), borderRadiusAll: 10, padding: MySpacing.xy(12, 8), child: Row(children: [const Icon(LucideIcons.plus, size: 14, color: Colors.white), const SizedBox(width: 6), MyText.bodySmall("Add", color: Colors.white)])),
                    ]),
                    MySpacing.height(10),

                    // predefined + icon selection
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            hint: const Text("Select Amenity"),
                            items: predefinedAmenitiesWithIcons.entries.map((entry) {
                              return DropdownMenuItem<String>(
                                value: entry.key,
                                child: Row(
                                  children: [
                                    Icon(entry.value, size: 18, color: const Color(0xFF835FFF)),
                                    const SizedBox(width: 8),
                                    Text(entry.key),
                                  ],
                                ),
                              );
                            }).toList(),
                            onChanged: (value) {
                              if (value == null) return;

                              final exists = _amenities.any((a) => a['title'] == value);
                              if (exists) return;

                              setState(() {
                                _amenities.add({
                                  'title': value,
                                  'icon': value, // key-based icon
                                });
                              });
                            },
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.grey[100],
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            dropdownColor: Colors.white,
                          ),
                        ),
                      ],
                    ),


                    MySpacing.height(12),
                    if (_amenities.isEmpty)
                      MyText.bodySmall("No amenities added", color: Colors.grey[600])
                    else
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _amenities.map((a) {
                          final iconData =
                              predefinedAmenitiesWithIcons[a['icon']] ?? LucideIcons.star;
                          return Chip(
                            avatar: Icon(iconData, size: 16, color: const Color(0xFF835FFF)),
                            label: Text(a['title'] ?? ''),
                            onDeleted: () => setState(() => _amenities.remove(a)),
                            backgroundColor: Colors.grey[100],
                          );
                        }).toList(),
                      ),
                  ]),
                ),
                MySpacing.height(20),

                // Save button
                Align(
                  alignment: Alignment.centerRight,
                  child: MyButton(
                    onPressed: _isSaving ? null : _savePlan,
                    backgroundColor: const Color(0xFF22C55E),
                    borderRadiusAll: 12,
                    padding: MySpacing.xy(24, 12),
                    child: _isSaving ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : MyText.bodyMedium("Save Changes", color: Colors.white),
                  ),
                ),
                MySpacing.height(40),
              ]),
            ),
          ),

          // saving overlay
          if (_isSaving)
            Container(
              color: Colors.black.withOpacity(0.25),
              alignment: Alignment.center,
              child: Column(mainAxisSize: MainAxisSize.min, children: const [
                CircularProgressIndicator(color: Colors.white),
                SizedBox(height: 12),
                Text("Saving your plan...", style: TextStyle(color: Colors.white)),
              ]),
            ),
        ],
      ),
    );
  }
}
