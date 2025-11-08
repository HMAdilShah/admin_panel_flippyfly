import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:webkit/helpers/widgets/my_button.dart';
import 'package:webkit/helpers/widgets/my_spacing.dart';
import 'package:webkit/helpers/widgets/my_text.dart';

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

  final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');

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
    });
  }

  DateTime? _parseDate(dynamic d) {
    if (d == null) return null;
    if (d is Timestamp) return d.toDate();
    if (d is DateTime) return d;
    if (d is String) {
      try {
        return DateTime.parse(d);
      } catch (_) {
        final parts = d.split('-');
        if (parts.length == 3) {
          final y = int.tryParse(parts[0]) ?? 0;
          final m = int.tryParse(parts[1]) ?? 0;
          final day = int.tryParse(parts[2]) ?? 0;
          return DateTime(y, m, day);
        }
      }
    }
    return null;
  }

  Future<void> _savePlan() async {
    if (!_formKey.currentState!.validate()) return;

    await _db.collection('plans').doc(widget.planId).update({
      'title': _titleController.text.trim(),
      'coins': int.tryParse(_coinsController.text.trim()) ?? 0,
      'description': _descriptionController.text.trim(),
      'fromDate': _fromDate != null ? Timestamp.fromDate(_fromDate!) : null,
      'toDate': _toDate != null ? Timestamp.fromDate(_toDate!) : null,
      'isSpecialOffer': _isSpecialOffer,
      'isFor': _isFor,
    });

    Get.back(result: true); // go back and refresh
  }

  @override
  void initState() {
    super.initState();
    _loadPlan();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Plan')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              MyText.titleMedium("Title"),
              MySpacing.height(6),
              TextFormField(
                controller: _titleController,
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                decoration: const InputDecoration(border: OutlineInputBorder()),
              ),
              MySpacing.height(16),

              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        MyText.titleMedium("From Date"),
                        MySpacing.height(6),
                        InkWell(
                          onTap: () async {
                            final date = await showDatePicker(
                              context: context,
                              initialDate: _fromDate ?? DateTime.now(),
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2100),
                            );
                            if (date != null) setState(() => _fromDate = date);
                          },
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(_fromDate != null ? _dateFormat.format(_fromDate!) : 'Select date'),
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
                          onTap: () async {
                            final date = await showDatePicker(
                              context: context,
                              initialDate: _toDate ?? DateTime.now(),
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2100),
                            );
                            if (date != null) setState(() => _toDate = date);
                          },
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(_toDate != null ? _dateFormat.format(_toDate!) : 'Select date'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              MySpacing.height(16),

              MyText.titleMedium("Coins"),
              MySpacing.height(6),
              TextFormField(
                controller: _coinsController,
                keyboardType: TextInputType.number,
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                decoration: const InputDecoration(border: OutlineInputBorder()),
              ),
              MySpacing.height(16),

              MyText.titleMedium("Description"),
              MySpacing.height(6),
              TextFormField(
                controller: _descriptionController,
                maxLines: 4,
                decoration: const InputDecoration(border: OutlineInputBorder()),
              ),
              MySpacing.height(16),

              Row(
                children: [
                  MyText.bodyMedium("Type: "),
                  MySpacing.width(12),
                  DropdownButton<String>(
                    value: _isFor,
                    items: const [
                      DropdownMenuItem(value: 'premium', child: Text('Premium')),
                      DropdownMenuItem(value: 'free', child: Text('Free')),
                    ],
                    onChanged: (val) => setState(() => _isFor = val!),
                  ),
                  MySpacing.width(24),
                  MyText.bodyMedium("Special Offer: "),
                  Checkbox(
                    value: _isSpecialOffer,
                    onChanged: (val) => setState(() => _isSpecialOffer = val ?? false),
                  ),
                ],
              ),

              MySpacing.height(24),
              MyButton(
                onPressed: _savePlan,
                backgroundColor: Colors.green,
                borderRadiusAll: 12,
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
                child: MyText.bodyMedium("Save Changes", color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
