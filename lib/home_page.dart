import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomePage extends StatefulWidget {
  final User? user;

  const HomePage({Key? key, required this.user}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _sizeController = TextEditingController();
  final TextEditingController _businessController = TextEditingController();

  final CollectionReference _collection =
  FirebaseFirestore.instance.collection('Store Data');

  @override
  void dispose() {
    _heightController.dispose();
    _sizeController.dispose();
    _businessController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState?.validate() ?? false) {
      try {
        await _storeData(
          height: _heightController.text,
          size: _sizeController.text,
          business: _businessController.text,
        );
        _showSuccessDialog(context);
        _clearFormFields();
      } catch (e) {
        _showErrorSnackBar(context, 'Failed to store data: $e');
      }
    }
  }

  Future<void> _storeData({
    required String height,
    required String size,
    required String business,
  }) async {
    await _collection.add({
      'height': height,
      'size': size,
      'business': business,
      'userId': widget.user?.uid,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  void _clearFormFields() {
    _heightController.clear();
    _sizeController.clear();
    _businessController.clear();
  }

  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Success'),
          content: const Text('Data successfully stored!'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Page'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildTextFormField(
                controller: _heightController,
                label: 'Height',
                keyboardType: TextInputType.number,
                validator: (value) =>
                value?.isEmpty ?? true ? 'Please enter height' : null,
              ),
              _buildTextFormField(
                controller: _sizeController,
                label: 'Size',
                keyboardType: TextInputType.number,
                validator: (value) =>
                value?.isEmpty ?? true ? 'Please enter size' : null,
              ),
              _buildTextFormField(
                controller: _businessController,
                label: 'Business',
                validator: (value) =>
                value?.isEmpty ?? true ? 'Please enter business' : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitForm,
                child: const Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    TextInputType keyboardType = TextInputType.text,
    required String? Function(String?) validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(labelText: label),
      keyboardType: keyboardType,
      validator: validator,
    );
  }
}
