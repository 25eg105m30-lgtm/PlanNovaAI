import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../main.dart';
import '../models/subject.dart';

class AddSubjectProvider extends ChangeNotifier {
  String name = '';
  int difficulty = 1;
  DateTime? examDate;
  double requiredHours = 0.0;
  bool isSaving = false;

  void setName(String v) {
    name = v;
    notifyListeners();
  }

  void setDifficulty(double v) {
    difficulty = v.toInt();
    notifyListeners();
  }

  void setExamDate(DateTime? v) {
    examDate = v;
    notifyListeners();
  }

  void setRequiredHours(String v) {
    requiredHours = double.tryParse(v) ?? 0.0;
    notifyListeners();
  }

  Future<void> save(String userId) async {
    if (name.isEmpty || examDate == null || requiredHours <= 0) {
      throw Exception('Please fill all fields correctly');
    }
    isSaving = true;
    notifyListeners();
    final subj = Subject(
      id: '',
      name: name,
      difficulty: difficulty,
      examDate: examDate!,
      requiredHours: requiredHours,
      completedHours: 0,
    );
    final data = subj.toMap()
      ..remove('id')
      ..['userId'] = userId;
    await FirebaseFirestore.instance.collection('subjects').add(data);
    isSaving = false;
    notifyListeners();
  }
}

class AddSubjectScreen extends StatefulWidget {
  const AddSubjectScreen({Key? key}) : super(key: key);

  @override
  State<AddSubjectScreen> createState() => _AddSubjectScreenState();
}

class _AddSubjectScreenState extends State<AddSubjectScreen> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context, listen: false);

    return ChangeNotifierProvider(
      create: (_) => AddSubjectProvider(),
      child: Scaffold(
        appBar: AppBar(title: const Text('Add Subject')),
        body: Consumer<AddSubjectProvider>(
          builder: (context, provider, _) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      decoration: const InputDecoration(labelText: 'Name'),
                      onChanged: provider.setName,
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),
                    Text('Difficulty: ${provider.difficulty}'),
                    Slider(
                      min: 1,
                      max: 5,
                      divisions: 4,
                      value: provider.difficulty.toDouble(),
                      onChanged: provider.setDifficulty,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: Text(provider.examDate == null
                              ? 'No date chosen'
                              : 'Exam: ${provider.examDate!.toLocal().toIso8601String().split('T').first}'),
                        ),
                        TextButton(
                          onPressed: () async {
                            final now = DateTime.now();
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: now,
                              firstDate: now,
                              lastDate: DateTime(now.year + 5),
                            );
                            if (picked != null) {
                              provider.setExamDate(picked);
                            }
                          },
                          child: const Text('Select Date'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      decoration:
                          const InputDecoration(labelText: 'Required hours'),
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      onChanged: provider.setRequiredHours,
                      validator: (v) {
                        final num? val = num.tryParse(v ?? '');
                        if (val == null || val <= 0) return 'Must be > 0';
                        return null;
                      },
                    ),
                    const Spacer(),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: provider.isSaving
                            ? null
                            : () async {
                              if (_formKey.currentState!.validate()) {
                                try {
                                  await provider
                                      .save(auth.user?.uid ?? '');
                                  if (mounted) Navigator.of(context).pop();
                                } catch (e) {
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(
                                    SnackBar(content: Text(e.toString())),
                                  );
                                }
                              }
                            },
                        child: provider.isSaving
                            ? const CircularProgressIndicator()
                            : const Text('Save'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
