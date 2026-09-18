// lib/features/employee/donor/presentation/pages/add_donor_page.dart
//
// Mirrors DCC's real donor creation form (DCC/Views/Donor/_DonorPartial.cshtml,
// DCC/Models/DonorDonationViewModels.cs DonorVM) field for field: Personal
// Details, Additional Details, and both Residence + Office Address tabs.
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:surabhi/core/mock/mock_donor_data.dart';
import 'package:surabhi/core/theme/app_colors.dart';
import 'package:surabhi/core/widgets/app_scaffold.dart';
import 'package:surabhi/features/auth/presentation/bloc/auth_bloc.dart';

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

  // Personal Details
  final _firstName = TextEditingController();
  final _lastName = TextEditingController();
  final _mobile1 = TextEditingController();
  final _mobile2 = TextEditingController();
  final _email = TextEditingController();
  final _pan = TextEditingController();
  String _gender = 'Male';

  // Additional Details
  final _dob = TextEditingController();
  int _norc = 0; // Number of Rounds Chanting
  final _occupation = TextEditingController();
  final _spouseName = TextEditingController();
  String _mailingAddress = 'Residence';
  String _enrolledByCode = kCurrentPreacherCode;

  // Address Details (both collected, matching DCC's Residence/Office tabs)
  int _addressTab = 0;
  final _resLine1 = TextEditingController();
  final _resLine2 = TextEditingController();
  final _resLandline = TextEditingController();
  final _resPincode = TextEditingController();
  final _resCity = TextEditingController();
  final _resState = TextEditingController();
  final _offName = TextEditingController();
  final _offLine1 = TextEditingController();
  final _offLine2 = TextEditingController();
  final _offLandline = TextEditingController();
  final _offPincode = TextEditingController();
  final _offCity = TextEditingController();
  final _offState = TextEditingController();

  bool _submitted = false;
  String? _generatedId;
  final DateTime _enrolledDate = DateTime.now();

  bool get _isPreacher => context.read<AuthBloc>().state is AuthAuthenticated &&
      (context.read<AuthBloc>().state as AuthAuthenticated).user.role.toLowerCase() == 'preacher';

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    _mobile1.dispose();
    _mobile2.dispose();
    _email.dispose();
    _pan.dispose();
    _dob.dispose();
    _occupation.dispose();
    _spouseName.dispose();
    _resLine1.dispose();
    _resLine2.dispose();
    _resLandline.dispose();
    _resPincode.dispose();
    _resCity.dispose();
    _resState.dispose();
    _offName.dispose();
    _offLine1.dispose();
    _offLine2.dispose();
    _offLandline.dispose();
    _offPincode.dispose();
    _offCity.dispose();
    _offState.dispose();
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
          _sectionTitle('Personal Details'),
          const SizedBox(height: 12),
          TextFormField(
            controller: _firstName,
            textCapitalization: TextCapitalization.characters,
            decoration: const InputDecoration(labelText: 'First Name *', prefixIcon: Icon(Icons.person)),
            validator: (v) => (v == null || v.trim().isEmpty) ? 'First name is required' : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _lastName,
            textCapitalization: TextCapitalization.characters,
            decoration: const InputDecoration(labelText: 'Last Name', prefixIcon: Icon(Icons.person_outline)),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _mobile1,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(labelText: 'Mobile Number 1 *', prefixIcon: Icon(Icons.phone)),
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Mobile number is required';
              if (!RegExp(r'^\d{10}$').hasMatch(v.trim())) return 'Enter a valid 10-digit mobile number';
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _mobile2,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(labelText: 'Mobile Number 2', prefixIcon: Icon(Icons.phone_outlined)),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _email,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(labelText: 'Email ID', prefixIcon: Icon(Icons.email)),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _pan,
            textCapitalization: TextCapitalization.characters,
            maxLength: 10,
            decoration: const InputDecoration(labelText: 'PAN', prefixIcon: Icon(Icons.badge_outlined)),
          ),
          const SizedBox(height: 4),
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
          _sectionTitle('Additional Details'),
          const SizedBox(height: 12),
          TextFormField(
            controller: _dob,
            readOnly: true,
            decoration: const InputDecoration(labelText: 'Date of Birth', prefixIcon: Icon(Icons.cake_outlined)),
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: DateTime(1990),
                firstDate: DateTime(1920),
                lastDate: DateTime.now(),
              );
              if (picked != null) _dob.text = _formatDate(picked);
            },
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<int>(
            initialValue: _norc,
            decoration: const InputDecoration(labelText: 'No of Rounds Chanting *', prefixIcon: Icon(Icons.repeat)),
            items: List.generate(17, (i) => i).map((n) => DropdownMenuItem(value: n, child: Text('$n'))).toList(),
            onChanged: (v) => setState(() => _norc = v ?? 0),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _occupation,
            decoration: const InputDecoration(labelText: 'Occupation', prefixIcon: Icon(Icons.work_outline)),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _spouseName,
            textCapitalization: TextCapitalization.characters,
            decoration: const InputDecoration(labelText: 'Spouse Name', prefixIcon: Icon(Icons.favorite_border)),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            initialValue: _mailingAddress,
            decoration: const InputDecoration(labelText: 'Mailing Address *', prefixIcon: Icon(Icons.markunread_mailbox_outlined)),
            items: const [
              DropdownMenuItem(value: 'Residence', child: Text('Residence')),
              DropdownMenuItem(value: 'Office', child: Text('Office')),
            ],
            onChanged: (v) => setState(() => _mailingAddress = v ?? 'Residence'),
          ),
          const SizedBox(height: 16),
          if (_isPreacher)
            InputDecorator(
              decoration: const InputDecoration(labelText: 'Enrolled By *', prefixIcon: Icon(Icons.church_outlined)),
              child: Text(kCurrentPreacherCode),
            )
          else
            DropdownButtonFormField<String>(
              initialValue: _enrolledByCode,
              decoration: const InputDecoration(labelText: 'Enrolled By *', prefixIcon: Icon(Icons.church_outlined)),
              items: const ['ABRD', 'JTMD', 'SRND', 'SYMD']
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (v) => setState(() => _enrolledByCode = v ?? _enrolledByCode),
            ),
          const SizedBox(height: 16),
          InputDecorator(
            decoration: const InputDecoration(labelText: 'Enrolled Date', prefixIcon: Icon(Icons.event_available_outlined)),
            child: Text(_formatDate(_enrolledDate)),
          ),
          const SizedBox(height: 24),
          _sectionTitle('Address Details'),
          const SizedBox(height: 12),
          _addressTabToggle(),
          const SizedBox(height: 12),
          if (_addressTab == 0) _residenceAddressFields() else _officeAddressFields(),
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

  Widget _sectionTitle(String title) {
    return Row(
      children: [
        Container(width: 4, height: 18, color: _color),
        const SizedBox(width: 8),
        Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _addressTabToggle() {
    return Row(
      children: [
        Expanded(
          child: ChoiceChip(
            label: const Text('Residence Address'),
            selected: _addressTab == 0,
            onSelected: (_) => setState(() => _addressTab = 0),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ChoiceChip(
            label: const Text('Office Address'),
            selected: _addressTab == 1,
            onSelected: (_) => setState(() => _addressTab = 1),
          ),
        ),
      ],
    );
  }

  Widget _residenceAddressFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextFormField(controller: _resLine1, decoration: const InputDecoration(labelText: 'Address Line 1')),
        const SizedBox(height: 16),
        TextFormField(controller: _resLine2, decoration: const InputDecoration(labelText: 'Address Line 2')),
        const SizedBox(height: 16),
        TextFormField(
          controller: _resLandline,
          keyboardType: TextInputType.phone,
          decoration: const InputDecoration(labelText: 'Landline Number'),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: TextFormField(controller: _resCity, decoration: const InputDecoration(labelText: 'City'))),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                controller: _resPincode,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Pincode'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        TextFormField(controller: _resState, decoration: const InputDecoration(labelText: 'State')),
      ],
    );
  }

  Widget _officeAddressFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextFormField(controller: _offName, decoration: const InputDecoration(labelText: 'Company Name')),
        const SizedBox(height: 16),
        TextFormField(controller: _offLine1, decoration: const InputDecoration(labelText: 'Address Line 1')),
        const SizedBox(height: 16),
        TextFormField(controller: _offLine2, decoration: const InputDecoration(labelText: 'Address Line 2')),
        const SizedBox(height: 16),
        TextFormField(
          controller: _offLandline,
          keyboardType: TextInputType.phone,
          decoration: const InputDecoration(labelText: 'Landline Number'),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: TextFormField(controller: _offCity, decoration: const InputDecoration(labelText: 'City'))),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                controller: _offPincode,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Pincode'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        TextFormField(controller: _offState, decoration: const InputDecoration(labelText: 'State')),
      ],
    );
  }

  Widget _buildSuccess() {
    final mailingAddress = _mailingAddress == 'Residence'
        ? [_resLine1.text, _resLine2.text, _resCity.text, _resState.text].where((s) => s.isNotEmpty).join(', ')
        : [_offLine1.text, _offLine2.text, _offCity.text, _offState.text].where((s) => s.isNotEmpty).join(', ');
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
        const SizedBox(height: 4),
        Text(_mobile1.text, style: const TextStyle(color: Colors.grey)),
        if (mailingAddress.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text('Mailing ($_mailingAddress): $mailingAddress', style: const TextStyle(color: Colors.grey, fontSize: 12), textAlign: TextAlign.center),
        ],
        const SizedBox(height: 4),
        Text('Enrolled by $_enrolledByCode on ${_formatDate(_enrolledDate)}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
        const SizedBox(height: 32),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Done'),
        ),
      ],
    );
  }

  String _formatDate(DateTime d) => '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
}
