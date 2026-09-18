// lib/features/shared/donation/presentation/pages/record_donation_page.dart
import 'package:flutter/material.dart';
import 'package:surabhi/core/mock/mock_donor_data.dart';
import 'package:surabhi/core/widgets/app_scaffold.dart';

/// Shared "record a donation" form. Used as Employee's "Record Donation"
/// and Preacher's "Record Seva" (same underlying DCC workflow: add a
/// donation for a donor with trust/seva/amount/mode of payment).
class RecordDonationPage extends StatefulWidget {
  final String title;
  final Color color;

  const RecordDonationPage({super.key, required this.title, required this.color});

  @override
  State<RecordDonationPage> createState() => _RecordDonationPageState();
}

class _RecordDonationPageState extends State<RecordDonationPage> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _referenceNumberController = TextEditingController();

  MockDonor? _selectedDonor;
  String _trust = MockData.trusts.first;
  String _sevaCategory = MockData.sevaCategories.first;
  late SevaSubCategory _sevaSubCategory = MockData.subCategoriesFor(_sevaCategory).first;
  String _modeOfPayment = MockData.modesOfPayment.first;

  bool _submitted = false;
  String? _receiptNumber;

  @override
  void initState() {
    super.initState();
    if (_sevaSubCategory.amount != null) {
      _amountController.text = _sevaSubCategory.amount.toString();
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _referenceNumberController.dispose();
    super.dispose();
  }

  void _onCategoryChanged(String category) {
    setState(() {
      _sevaCategory = category;
      _sevaSubCategory = MockData.subCategoriesFor(category).first;
      if (_sevaSubCategory.amount != null) {
        _amountController.text = _sevaSubCategory.amount.toString();
      }
    });
  }

  void _onSubCategoryChanged(SevaSubCategory subCategory) {
    setState(() {
      _sevaSubCategory = subCategory;
      if (subCategory.amount != null) {
        _amountController.text = subCategory.amount.toString();
      }
    });
  }

  void _submit() {
    if (_selectedDonor == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a donor first')));
      return;
    }
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _receiptNumber = '$_trust|2026|${DateTime.now().millisecondsSinceEpoch % 10000}';
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
          InkWell(
            onTap: _pickDonorInline,
            child: InputDecorator(
              decoration: const InputDecoration(labelText: 'Donor *', prefixIcon: Icon(Icons.person_search)),
              child: Text(_selectedDonor == null ? 'Tap to select a donor' : '${_selectedDonor!.name} (${_selectedDonor!.id})'),
            ),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            initialValue: _trust,
            decoration: const InputDecoration(labelText: 'Trust (Account Type) *', prefixIcon: Icon(Icons.account_balance)),
            items: MockData.trusts.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
            onChanged: (v) => setState(() => _trust = v ?? _trust),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            initialValue: _sevaCategory,
            decoration: const InputDecoration(labelText: 'Seva Category *', prefixIcon: Icon(Icons.volunteer_activism)),
            items: MockData.sevaCategories.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
            onChanged: (v) => _onCategoryChanged(v ?? _sevaCategory),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<SevaSubCategory>(
            initialValue: _sevaSubCategory,
            decoration: const InputDecoration(labelText: 'Seva Sub Category *', prefixIcon: Icon(Icons.category_outlined)),
            items: MockData.subCategoriesFor(_sevaCategory)
                .map((s) => DropdownMenuItem(value: s, child: Text(s.amount != null ? '${s.name} (₹${s.amount})' : s.name)))
                .toList(),
            onChanged: (v) => _onSubCategoryChanged(v ?? _sevaSubCategory),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Amount (₹) *', prefixIcon: Icon(Icons.currency_rupee)),
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Amount is required';
              final n = num.tryParse(v);
              if (n == null || n <= 0) return 'Enter a valid amount';
              return null;
            },
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            initialValue: _modeOfPayment,
            decoration: const InputDecoration(labelText: 'Mode of Payment *', prefixIcon: Icon(Icons.payment)),
            items: MockData.modesOfPayment.map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
            onChanged: (v) => setState(() => _modeOfPayment = v ?? _modeOfPayment),
          ),
          if (_modeOfPayment == 'Online') ...[
            const SizedBox(height: 16),
            TextFormField(
              controller: _referenceNumberController,
              decoration: const InputDecoration(
                labelText: 'UTR / Transaction Reference Number *',
                helperText: 'Used to verify this payment against the bank statement',
                prefixIcon: Icon(Icons.confirmation_number_outlined),
              ),
              validator: (v) {
                if (_modeOfPayment != 'Online') return null;
                if (v == null || v.trim().isEmpty) return 'Reference number is required for online payments';
                return null;
              },
            ),
          ],
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _submit,
            style: ElevatedButton.styleFrom(backgroundColor: widget.color, minimumSize: const Size.fromHeight(50)),
            icon: const Icon(Icons.receipt_long, color: Colors.white),
            label: const Text('Record Donation', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _pickDonorInline() async {
    final donor = await showModalBottomSheet<MockDonor>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.85,
          expand: false,
          builder: (context, scrollController) {
            return _DonorPickerSheet(scrollController: scrollController);
          },
        );
      },
    );
    if (donor != null) setState(() => _selectedDonor = donor);
  }

  Widget _buildSuccess() {
    return Column(
      children: [
        const SizedBox(height: 24),
        Icon(Icons.check_circle, color: Colors.green.shade600, size: 72),
        const SizedBox(height: 16),
        const Text('Donation Recorded', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text('Receipt No: $_receiptNumber', style: TextStyle(color: widget.color, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text('₹${_amountController.text} from ${_selectedDonor?.name ?? ''}'),
        const SizedBox(height: 4),
        Text('$_sevaCategory · ${_sevaSubCategory.name} · $_modeOfPayment', style: const TextStyle(fontSize: 13, color: Colors.grey)),
        if (_modeOfPayment == 'Online' && _referenceNumberController.text.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text('Ref: ${_referenceNumberController.text}', style: const TextStyle(fontSize: 13, color: Colors.grey)),
        ],
        const SizedBox(height: 24),
        OutlinedButton.icon(onPressed: () {}, icon: const Icon(Icons.download), label: const Text('Download Receipt (demo)')),
        const SizedBox(height: 12),
        ElevatedButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Done')),
      ],
    );
  }
}

class _DonorPickerSheet extends StatefulWidget {
  final ScrollController scrollController;

  const _DonorPickerSheet({required this.scrollController});

  @override
  State<_DonorPickerSheet> createState() => _DonorPickerSheetState();
}

class _DonorPickerSheetState extends State<_DonorPickerSheet> {
  final _searchController = TextEditingController();
  List<MockDonor> _results = MockData.donors;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    setState(() => _results = MockData.searchDonors(query));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Select Donor', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          TextField(
            controller: _searchController,
            autofocus: true,
            decoration: const InputDecoration(
              hintText: 'Search by name, mobile or Donor ID',
              prefixIcon: Icon(Icons.search),
            ),
            onChanged: _onSearchChanged,
          ),
          const SizedBox(height: 12),
          Expanded(
            child: _results.isEmpty
                ? const Center(child: Text('No donors found'))
                : ListView.builder(
                    controller: widget.scrollController,
                    itemCount: _results.length,
                    itemBuilder: (context, index) {
                      final d = _results[index];
                      return ListTile(
                        leading: CircleAvatar(child: Text(d.name[0])),
                        title: Text(d.name),
                        subtitle: Text('${d.id} · ${d.mobile} · ${d.city}'),
                        onTap: () => Navigator.of(context).pop(d),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
