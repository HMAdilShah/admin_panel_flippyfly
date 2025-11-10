import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:webkit/helpers/widgets/my_button.dart';
import 'package:webkit/helpers/widgets/my_spacing.dart';
import 'package:webkit/helpers/widgets/my_text.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

final Map<String, IconData> amenityIcons = {
  'star': LucideIcons.star,
  'heart': LucideIcons.heart,
  'wifi': LucideIcons.wifi,
  'coffee': LucideIcons.coffee,
  'music': LucideIcons.music,
};

class PlanEditScreen extends StatefulWidget {
  final String planId;
  const PlanEditScreen({super.key, required this.planId});

  @override
  State<PlanEditScreen> createState() => _PlanEditScreenState();
}

class _PlanEditScreenState extends State<PlanEditScreen> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _coinsController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  DateTime? _fromDate;
  DateTime? _toDate;
  bool _isSpecialOffer = false;
  String _isFor = 'premium'; // default
  // List<Map<String, String>> _amenities = [];
  List<Map<String, dynamic>> _amenities = [];

  final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadPlan();
  }

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
      _isSpecialOffer = data['isSpecialOffer'] ?? false;
      _isFor = data['isFor'] ?? 'premium';
      _amenities = (data['amenities'] as List<dynamic>?)
          ?.cast<Map<String, dynamic>>()
          .map((e) => {
        'title': e['title'] ?? '',
        'icon': e['icon'] ?? 'star',
      })
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
        return DateTime.parse(d);
      } catch (_) {}
    }
    return null;
  }

  Future<void> _pickDate(BuildContext context, bool isFrom) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isFrom ? (_fromDate ?? DateTime.now()) : (_toDate ?? DateTime.now()),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        if (isFrom) {
          _fromDate = picked;
        } else {
          _toDate = picked;
        }
      });
    }
  }

  Future<void> _addAmenityDialog() async {
    final titleCtrl = TextEditingController();
    String selectedIcon = 'star';

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Add Amenity"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleCtrl,
              decoration: InputDecoration(
                labelText: "Title",
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
              ),
            ),
            MySpacing.height(12),
            DropdownButtonFormField<String>(
              value: selectedIcon,
              items: amenityIcons.entries
                  .map(
                    (e) => DropdownMenuItem(
                  value: e.key,
                  child: Row(
                    children: [
                      Icon(e.value, size: 18),
                      MySpacing.width(8),
                      Text(e.key),
                    ],
                  ),
                ),
              )
                  .toList(),
              onChanged: (v) => selectedIcon = v ?? 'star',
              dropdownColor: Colors.white,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey[100],
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              if (titleCtrl.text.isNotEmpty) {
                setState(() => _amenities.add({
                  "title": titleCtrl.text,
                  "icon": selectedIcon,
                }));
                Get.back();
              }
            },
            child: const Text("Add"),
          ),
        ],
      ),
    );
  }

  Future<void> _savePlan() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    try {
      await _db.collection('plans').doc(widget.planId).update({
        'title': _titleController.text.trim(),
        'coins': int.tryParse(_coinsController.text.trim()) ?? 0,
        'description': _descriptionController.text.trim(),
        'fromDate': _fromDate != null ? Timestamp.fromDate(_fromDate!) : null,
        'toDate': _toDate != null ? Timestamp.fromDate(_toDate!) : null,
        'isSpecialOffer': _isSpecialOffer,
        'isFor': _isFor,
        'amenities': _amenities,
      });

      Get.snackbar("Success", "Plan updated successfully", backgroundColor: Colors.green.withOpacity(0.1), colorText: Colors.green);
      Get.back(result: true);
    } catch (e) {
      Get.snackbar("Error", e.toString(), backgroundColor: Colors.red.withOpacity(0.1), colorText: Colors.red);
    } finally {
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Plan')),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MyText.titleLarge("Edit Plan", fontWeight: 700),
                  MySpacing.height(16),

                  // Title
                  TextFormField(
                    controller: _titleController,
                    validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                    decoration: InputDecoration(
                      labelText: "Title",
                      filled: true,
                      fillColor: Colors.grey[100],
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  MySpacing.height(16),

                  // Dates
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            MyText.titleMedium("From Date"),
                            MySpacing.height(6),
                            InkWell(
                              onTap: () => _pickDate(context, true),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  border: Border.all(color: Colors.grey.shade400),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      _fromDate != null ? _dateFormat.format(_fromDate!) : 'Select date',
                                      style: TextStyle(color: Colors.grey[800]),
                                    ),
                                    const Icon(Icons.calendar_today, size: 18),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      MySpacing.width(12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            MyText.titleMedium("To Date"),
                            MySpacing.height(6),
                            InkWell(
                              onTap: () => _pickDate(context, false),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  border: Border.all(color: Colors.grey.shade400),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      _toDate != null ? _dateFormat.format(_toDate!) : 'Select date',
                                      style: TextStyle(color: Colors.grey[800]),
                                    ),
                                    const Icon(Icons.calendar_today, size: 18),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  MySpacing.height(16),

                  // Coins
                  TextFormField(
                    controller: _coinsController,
                    keyboardType: TextInputType.number,
                    validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                    decoration: InputDecoration(
                      labelText: "Coins",
                      filled: true,
                      fillColor: Colors.grey[100],
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  MySpacing.height(16),

                  // Description
                  TextFormField(
                    controller: _descriptionController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      labelText: "Description",
                      filled: true,
                      fillColor: Colors.grey[100],
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  MySpacing.height(16),

                  // Membership type + Special Offer
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _isFor,
                          items: const [
                            DropdownMenuItem(value: 'premium', child: Text('Premium')),
                            DropdownMenuItem(value: 'free', child: Text('Free')),
                          ],
                          onChanged: (v) => setState(() => _isFor = v!),
                          dropdownColor: Colors.white,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.grey[100],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                      MySpacing.width(24),
                      Row(
                        children: [
                          Checkbox(
                            value: _isSpecialOffer,
                            onChanged: (v) => setState(() => _isSpecialOffer = v ?? false),
                          ),
                          const Text("Special Offer"),
                        ],
                      ),
                    ],
                  ),
                  MySpacing.height(16),

                  // Amenities
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      MyText.titleMedium("Amenities"),
                      ElevatedButton.icon(
                        onPressed: _addAmenityDialog,
                        icon: const Icon(LucideIcons.plus, size: 16),
                        label: const Text("Add"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ],
                  ),
                  MySpacing.height(8),
                  if (_amenities.isEmpty)
                    Text("No amenities added", style: TextStyle(color: Colors.grey[600]))
                  else
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _amenities.map((a) {
                        final iconData = amenityIcons[a['icon']] ?? LucideIcons.star;
                        return Chip(
                          label: Text(a['title'] ?? ''),
                          avatar: Icon(iconData, size: 16, color: Colors.amber),
                          onDeleted: () {
                            setState(() => _amenities.remove(a));
                          },
                        );
                      }).toList(),
                    ),

                  MySpacing.height(32),
                  MyButton(
                    onPressed: _isSaving ? null : _savePlan,
                    backgroundColor: Colors.green,
                    borderRadiusAll: 12,
                    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
                    child: _isSaving
                        ? const SizedBox(
                        width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : MyText.bodyMedium("Save Changes", color: Colors.white),
                  ),
                  MySpacing.height(40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
