// lib/features/shared/donation/presentation/pages/record_donation_page.dart
import 'package:flutter/material.dart';
import 'package:surabhi/core/mock/demo_identity.dart';
import 'package:surabhi/core/mock/donor_insights.dart';
import 'package:surabhi/core/mock/mock_approvals.dart';
import 'package:surabhi/core/mock/mock_donor_data.dart';
import 'package:surabhi/core/mock/mock_festivals.dart';
import 'package:surabhi/core/theme/app_colors.dart';
import 'package:surabhi/core/utils/receipt_number.dart';
import 'package:surabhi/core/widgets/amount_bars.dart';
import 'package:surabhi/core/widgets/app_bottom_nav_item.dart';
import 'package:surabhi/core/widgets/app_scaffold.dart';
import 'package:surabhi/features/shared/approvals/presentation/pages/approval_request_detail_page.dart';
import 'package:surabhi/features/shared/approvals/presentation/widgets/step_chain.dart';
import 'package:surabhi/features/shared/donation/data/receipt_model.dart';
import 'package:surabhi/features/shared/donation/presentation/pages/receipt_page.dart';

/// Shared "record a donation" form. Used as Employee's "Record Donation"
/// and Preacher's "Make Receipt" (same underlying DCC workflow: add a
/// donation for a donor with trust/seva/amount/mode of payment).
class RecordDonationPage extends StatefulWidget {
  final String title;
  final Color color;
  final List<AppBottomNavItem>? bottomNavItems;
  final int bottomNavIndex;
  // Preselects a donor, e.g. when opened from Donor 360
  final MockDonor? initialDonor;
  // When set, the donor picker only offers donors this devotee code
  // enrolled - a preacher can't raise receipts for another preacher's donors.
  final String? enrolledByFilter;

  const RecordDonationPage({
    super.key,
    required this.title,
    required this.color,
    this.bottomNavItems,
    this.bottomNavIndex = 0,
    this.initialDonor,
    this.enrolledByFilter,
  });

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
  bool _taxExemptionRequired = false;

  // Festival receipt: the festival's single code + seva key decide the DCC
  // seva, exactly like DCC's addDonation(festivalCode, sevaKey).
  MockFestival? _festival;
  MockFestivalSeva? _festivalSeva;

  bool _submitted = false;
  Receipt? _receipt;
  // Set instead of _receipt when the HIGH_VALUE_RECEIPT rule held it back
  ApprovalRequest? _approvalRequest;

  List<MockFestival> get _collectingFestivals =>
      mockFestivals.where((f) => f.isCollectingOn(MockData.today)).toList();

  @override
  void initState() {
    super.initState();
    if (_sevaSubCategory.amount != null) {
      _amountController.text = _sevaSubCategory.amount.toString();
    }
    if (widget.initialDonor != null) {
      _selectedDonor = widget.initialDonor;
      _taxExemptionRequired = widget.initialDonor!.pan != null;
    }
  }

  void _onFestivalChanged(MockFestival? festival) {
    setState(() {
      _festival = festival;
      _festivalSeva = festival?.sevas.first;
      if (festival != null) {
        _trust = festival.trust;
        _sevaCategory = 'Festival Donations';
        _sevaSubCategory = MockData.subCategoriesFor(_sevaCategory).firstWhere(
              (s) => s.name == festival.dccSubCategory,
              orElse: () => MockData.subCategoriesFor(_sevaCategory).first,
            );
        _applyFestivalAmount();
      }
    });
  }

  void _onFestivalSevaChanged(MockFestivalSeva? seva) {
    setState(() {
      _festivalSeva = seva;
      _applyFestivalAmount();
    });
  }

  void _applyFestivalAmount() {
    final amount = _festivalSeva?.suggestedAmount;
    if (amount != null) _amountController.text = amount.toString();
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
    final donor = _selectedDonor!;
    final now = DateTime.now();
    // Mirrors DCC's GetDonationReceipt switch on ModeOfPayment: only the
    // fields that mode actually captures are populated, everything else
    // stays blank (this form only captures a reference number for Online).
    final paymentRefNo = _modeOfPayment == 'Online' ? _referenceNumberController.text.trim() : '';
    final paymentDate = _modeOfPayment == 'Online' ? now : null;
    final amount = num.parse(_amountController.text).toInt();
    final isCash = _modeOfPayment == 'Cash';

    // DCC's HIGH_VALUE_RECEIPT rule: at/above the threshold (or the lower
    // cash threshold) the receipt is held until the approval chain clears.
    final store = ApprovalStore.instance;
    if (store.isApprovalRequired(ApprovalActionType.highValueReceipt, amount: amount, isCash: isCash)) {
      final rule = store.rule(ApprovalActionType.highValueReceipt);
      final overAmount = rule.thresholdAmount != null && amount >= rule.thresholdAmount!;
      final seva = _festivalSeva != null ? _festivalSeva!.name : _sevaSubCategory.name;
      final req = store.submitOrApply(
        actionType: ApprovalActionType.highValueReceipt,
        title: 'Receipt ${inr(amount)}${isCash ? ' in Cash' : ' by $_modeOfPayment'}',
        donorId: donor.id,
        donorName: donor.name,
        amount: amount,
        isCash: isCash,
        reason: overAmount ? 'Amount at or above ${inr(rule.thresholdAmount!)}' : 'Cash at or above ${inr(rule.cashThresholdAmount!)}',
        requestedBy: DemoIdentity.of(context).name,
        details: [
          ('Trust', _trust),
          ('Seva', '$_sevaCategory - $seva'),
          ('Mode', _modeOfPayment),
          if (paymentRefNo.isNotEmpty) ('UTR / reference', paymentRefNo),
          if (_festival != null) ('Festival', _festival!.festivalCode),
          ('Tax exemption (80G)', _taxExemptionRequired ? 'Yes' : 'No'),
        ],
        pendingReceipt: MockDonation(
          receiptNumber: buildReceiptNumber(trust: _trust, date: now, sequence: now.millisecondsSinceEpoch % 10000),
          donorId: donor.id,
          donorName: donor.name,
          trust: _trust,
          sevaCategory: _sevaCategory,
          sevaName: seva,
          amount: amount,
          modeOfPayment: _modeOfPayment,
          date: now,
          status: DonationStatus.pending,
          festivalCode: _festival?.festivalCode,
        ),
      );
      // Every step skipped = approved at once; fall through to the receipt
      if (req != null && req.isPending) {
        setState(() {
          _approvalRequest = req;
          _submitted = true;
        });
        return;
      }
    }

    setState(() {
      _receipt = Receipt(
        // DCC's real ReceiptTracker sequence lives server-side; this is a demo stand-in.
        receiptNumber: buildReceiptNumber(trust: _trust, date: now, sequence: now.millisecondsSinceEpoch % 10000),
        receiptDate: now,
        trust: _trust,
        donorName: donor.name,
        address: donor.address,
        // DCC's PatronNumber is just the donor's own DonorNumber, not a
        // separate patron-scheme id.
        patronNumber: donor.id,
        sevakName: '',
        mobile: donor.mobile,
        email: donor.email,
        // DCC only ever pulls the donor's PAN onto the receipt when the
        // tax-exemption flag is set for this donation - not just because
        // the donor happens to have one on file.
        pan: _taxExemptionRequired ? donor.pan : '',
        amount: amount,
        modeOfPayment: _modeOfPayment,
        paymentRefNo: paymentRefNo,
        paymentDate: paymentDate,
        bank: '',
        enrolledBy: donor.enrolledByCode,
        cdc: '',
        // DCC names festival sevas "<category> - <seva code>", e.g.
        // "Festival Donations - Abhishekam" (see DonorNDonationDAL.AddDonation)
        sevaName: _festivalSeva != null
            ? '$_sevaCategory - ${_festivalSeva!.name}'
            : '$_sevaCategory - ${_sevaSubCategory.name}',
        isReceiptAccounted: false,
        isReceiptCancelled: false,
        isTaxExemptionRequired: _taxExemptionRequired,
      );
      _submitted = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: widget.title,
      bottomNavItems: widget.bottomNavItems,
      bottomNavIndex: widget.bottomNavIndex,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: !_submitted
            ? _buildForm()
            : _approvalRequest != null
                ? _buildSentForApproval()
                : _buildSuccess(),
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
          if (_collectingFestivals.isNotEmpty) ...[
            const SizedBox(height: 16),
            DropdownButtonFormField<MockFestival?>(
              key: ValueKey('festival-${_festival?.festivalCode}'),
              initialValue: _festival,
              decoration: const InputDecoration(
                labelText: 'Festival (optional)',
                helperText: 'Tags the receipt with the festival code used by DCC, the website and the app',
                helperMaxLines: 2,
                prefixIcon: Icon(Icons.celebration_outlined),
              ),
              items: [
                const DropdownMenuItem<MockFestival?>(value: null, child: Text('Not a festival seva')),
                ..._collectingFestivals.map((f) => DropdownMenuItem<MockFestival?>(value: f, child: Text(f.name))),
              ],
              onChanged: _onFestivalChanged,
            ),
          ],
          if (_festival != null) ...[
            const SizedBox(height: 16),
            DropdownButtonFormField<MockFestivalSeva>(
              key: ValueKey('seva-${_festival!.festivalCode}'),
              initialValue: _festivalSeva,
              decoration: const InputDecoration(labelText: 'Festival Seva *', prefixIcon: Icon(Icons.volunteer_activism)),
              items: _festival!.sevas
                  .map((s) => DropdownMenuItem(
                        value: s,
                        child: Text(s.suggestedAmount != null ? '${s.name} (₹${s.suggestedAmount})' : s.name),
                      ))
                  .toList(),
              onChanged: _onFestivalSevaChanged,
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: AppColors.cream, borderRadius: BorderRadius.circular(12)),
              child: Row(
                children: [
                  StatusChip(label: _festival!.festivalCode, color: AppColors.gold, icon: Icons.tag),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '$_trust · $_sevaCategory › ${_sevaSubCategory.name} › ${_festivalSeva?.name ?? ''}',
                      style: const TextStyle(fontSize: 12, color: AppColors.ink),
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _trust,
              decoration: const InputDecoration(labelText: 'Trust (Account Type) *', prefixIcon: Icon(Icons.account_balance)),
              items: MockData.trusts.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
              onChanged: (v) => setState(() => _trust = v ?? _trust),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              key: ValueKey('category-$_sevaCategory'),
              initialValue: _sevaCategory,
              decoration: const InputDecoration(labelText: 'Seva Category *', prefixIcon: Icon(Icons.volunteer_activism)),
              items: MockData.sevaCategories.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
              onChanged: (v) => _onCategoryChanged(v ?? _sevaCategory),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<SevaSubCategory>(
              key: ValueKey('sub-$_sevaCategory'),
              initialValue: _sevaSubCategory,
              decoration: const InputDecoration(labelText: 'Seva Sub Category *', prefixIcon: Icon(Icons.category_outlined)),
              items: MockData.subCategoriesFor(_sevaCategory)
                  .map((s) => DropdownMenuItem(value: s, child: Text(s.amount != null ? '${s.name} (₹${s.amount})' : s.name)))
                  .toList(),
              onChanged: (v) => _onSubCategoryChanged(v ?? _sevaSubCategory),
            ),
          ],
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
          const SizedBox(height: 8),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Tax exemption Required'),
            subtitle: const Text('Under section 80G of the Income Tax Act'),
            value: _taxExemptionRequired,
            activeThumbColor: widget.color,
            onChanged: (v) => setState(() => _taxExemptionRequired = v),
          ),
          const SizedBox(height: 16),
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
            return _DonorPickerSheet(scrollController: scrollController, enrolledByFilter: widget.enrolledByFilter);
          },
        );
      },
    );
    if (donor != null) {
      setState(() {
        _selectedDonor = donor;
        _taxExemptionRequired = donor.pan != null;
      });
    }
  }

  // High-value / cash receipt held for approval: request id + live chain
  Widget _buildSentForApproval() {
    return ListenableBuilder(
      listenable: ApprovalStore.instance,
      builder: (context, _) {
        final req = _approvalRequest!;
        final approved = req.status == RequestStatus.approved;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 24),
            Icon(approved ? Icons.check_circle : Icons.hourglass_top, color: approved ? Colors.green.shade600 : AppColors.warningColor, size: 72),
            const SizedBox(height: 16),
            Text(
              approved ? 'Approved - receipt issued' : 'Sent for approval',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('Request ${req.id}', textAlign: TextAlign.center, style: TextStyle(color: widget.color, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text('${inr(req.amount ?? 0)} from ${req.donorName}', textAlign: TextAlign.center),
            const SizedBox(height: 4),
            Text(req.reason, textAlign: TextAlign.center, style: const TextStyle(fontSize: 13, color: Colors.grey)),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: AppColors.cream, borderRadius: BorderRadius.circular(14)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    approved ? (req.outcome ?? 'Receipt issued') : 'The receipt is issued once these approve:',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.ink),
                  ),
                  const SizedBox(height: 8),
                  StepChain(steps: req.steps),
                ],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => ApprovalRequestDetailPage(requestId: req.id, color: widget.color)),
              ),
              style: ElevatedButton.styleFrom(backgroundColor: widget.color, minimumSize: const Size.fromHeight(50)),
              icon: const Icon(Icons.approval, color: Colors.white),
              label: const Text('View request', style: TextStyle(color: Colors.white)),
            ),
            const SizedBox(height: 12),
            ElevatedButton(onPressed: () => Navigator.of(context).maybePop(), child: const Text('Done')),
          ],
        );
      },
    );
  }

  Widget _buildSuccess() {
    final receipt = _receipt!;
    return Column(
      children: [
        const SizedBox(height: 24),
        Icon(Icons.check_circle, color: Colors.green.shade600, size: 72),
        const SizedBox(height: 16),
        const Text('Donation Recorded', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text('Receipt No: ${receipt.receiptNumber}', style: TextStyle(color: widget.color, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text('₹${receipt.amount} from ${receipt.donorName}'),
        const SizedBox(height: 4),
        Text(receipt.sevaName, style: const TextStyle(fontSize: 13, color: Colors.grey)),
        if (_festival != null) ...[
          const SizedBox(height: 8),
          StatusChip(label: 'Tagged ${_festival!.festivalCode}', color: AppColors.gold, icon: Icons.celebration),
        ],
        const SizedBox(height: 24),
        ElevatedButton.icon(
          onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => ReceiptPage(receipt: receipt, color: widget.color))),
          style: ElevatedButton.styleFrom(backgroundColor: widget.color, minimumSize: const Size.fromHeight(50)),
          icon: const Icon(Icons.receipt_long, color: Colors.white),
          label: const Text('View Receipt', style: TextStyle(color: Colors.white)),
        ),
        const SizedBox(height: 12),
        ElevatedButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Done')),
      ],
    );
  }
}

class _DonorPickerSheet extends StatefulWidget {
  final ScrollController scrollController;
  final String? enrolledByFilter;

  const _DonorPickerSheet({required this.scrollController, this.enrolledByFilter});

  @override
  State<_DonorPickerSheet> createState() => _DonorPickerSheetState();
}

class _DonorPickerSheetState extends State<_DonorPickerSheet> {
  final _searchController = TextEditingController();
  late List<MockDonor> _results = _scoped(MockData.donors);

  List<MockDonor> _scoped(List<MockDonor> donors) {
    final code = widget.enrolledByFilter;
    return code == null ? donors : donors.where((d) => d.enrolledByCode == code).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    setState(() => _results = _scoped(MockData.searchDonors(query)));
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
              hintText: 'Name, mobile or Donor ID',
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
                        subtitle: Text('${d.id} · ${d.city}'),
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
