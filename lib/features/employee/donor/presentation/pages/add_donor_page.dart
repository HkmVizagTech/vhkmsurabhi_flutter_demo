// lib/features/employee/donor/presentation/pages/add_donor_page.dart
import 'package:flutter/material.dart';
import 'package:surabhi/core/theme/app_colors.dart';
import 'package:surabhi/core/widgets/app_scaffold.dart';

class AddDonorPage extends StatefulWidget {
  final String title;
  final Color color;

  const AddDonorPage({super.key, this.title = 'Add Donor', this.color = AppColors.employeeColor});

  @override
  State<AddDonorPage> createState() => _AddDonorPageState();
}

class _AddDonorPageState extends State<AddDonorPage> {
  Color get _color => widget.color;
  final _formKey = GlobalKey<FormState>();
  final _firstName = TextEditingController();
  final _lastName = TextEditingController();
  final _mobile = TextEditingController();
  final _email = TextEditingController();
  String _gender = 'Male';
  bool _submitted = false;
  String? _generatedId;

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    _mobile.dispose();
    _email.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _generatedId = 'D${1000 + DateTime.now().millisecond}';
      _submitted = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: widget.title,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: _submitted ? _buildSuccess() : _buildForm(),
      ),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: _firstName,
            decoration: const InputDecoration(labelText: 'First Name *', prefixIcon: Icon(Icons.person)),
            validator: (v) => (v == null || v.trim().isEmpty) ? 'First name is required' : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _lastName,
            decoration: const InputDecoration(labelText: 'Last Name', prefixIcon: Icon(Icons.person_outline)),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _mobile,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(labelText: 'Mobile Number *', prefixIcon: Icon(Icons.phone)),
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Mobile number is required';
              if (!RegExp(r'^\d{10}$').hasMatch(v.trim())) return 'Enter a valid 10-digit mobile number';
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _email,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(labelText: 'Email ID', prefixIcon: Icon(Icons.email)),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            initialValue: _gender,
            decoration: const InputDecoration(labelText: 'Gender *', prefixIcon: Icon(Icons.wc)),
            items: const [
              DropdownMenuItem(value: 'Male', child: Text('Male')),
              DropdownMenuItem(value: 'Female', child: Text('Female')),
            ],
            onChanged: (v) => setState(() => _gender = v ?? 'Male'),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _submit,
            style: ElevatedButton.styleFrom(backgroundColor: _color, minimumSize: const Size.fromHeight(50)),
            icon: const Icon(Icons.person_add, color: Colors.white),
            label: const Text('Add Donor', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccess() {
    return Column(
      children: [
        const SizedBox(height: 24),
        Icon(Icons.check_circle, color: Colors.green.shade600, size: 72),
        const SizedBox(height: 16),
        const Text('Donor Added Successfully', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text('Donor ID: $_generatedId', style: TextStyle(color: _color, fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text('${_firstName.text} ${_lastName.text}'.trim()),
        const SizedBox(height: 32),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Done'),
        ),
      ],
    );
  }
}
