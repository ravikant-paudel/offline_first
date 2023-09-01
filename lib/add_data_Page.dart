import 'package:flutter/material.dart';
import 'package:offline_first/database/database.dart';
import 'package:offline_first/model/offline_model.dart';

class AddDataPage extends StatefulWidget {
  const AddDataPage({super.key});

  @override
  State<AddDataPage> createState() => _AddDataPageState();
}

class _AddDataPageState extends State<AddDataPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  String _name = '';
  int _age = 0;
  bool _isValid = true;

  void _submitForm() async {
    setState(() {
      _name = _nameController.text;
      _age = int.tryParse(_ageController.text) ?? 0;
      _isValid = _name.isNotEmpty && _age > 0;
    });

    if (_isValid) {
      final offlineModel = OfflineModel(name: _name, age: _age);

      final OfflineDatabase offDb = OfflineDatabase();
      await offDb.init();
      final offlineDb = offDb.openStore<OfflineModel>();

      //now insert data
      offlineDb.insert([offlineModel]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Input Page'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: _ageController,
              decoration: const InputDecoration(labelText: 'Age'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _submitForm,
              child: const Text('Submit'),
            ),
            const SizedBox(height: 16),
            _isValid ? const Text('data Submitted') : const Text('Please enter valid data.'),
          ],
        ),
      ),
    );
  }
}
