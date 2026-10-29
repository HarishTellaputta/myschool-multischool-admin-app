import 'package:flutter/material.dart';

import '../fees/models/fee_model.dart';
import 'payment_history_screen.dart';
import '../fees/services/fee_service.dart';
import 'package:flutter/material.dart';

import 'package:flutter/material.dart';

import '../fees/models/fee_model.dart';
import '../fees/services/fee_service.dart';
import 'payment_history_screen.dart';

class FeeDetailsScreen extends StatefulWidget {
  final StudentFeeModel record;
  final List<StudentFeeModel>? studentRecords;

  const FeeDetailsScreen({
    super.key,
    required this.record,
    this.studentRecords,
  });

  @override
  State<FeeDetailsScreen> createState() => _FeeDetailsScreenState();
}

class _FeeDetailsScreenState extends State<FeeDetailsScreen> {
  final FeeService _feeService = FeeService();

  late StudentFeeModel record;

  bool isPaymentSaving = false;

  // Student ki sambandhinchina anni fee records
  List<StudentFeeModel> get allStudentFees => widget.studentRecords ?? [record];

  // Tuition Fee
  double get tuitionFee => allStudentFees
      .where((fee) => fee.feeName.toLowerCase().contains('tuition'))
      .fold(0.0, (sum, fee) => sum + fee.totalAmount);

  // Transport Fee
  double get transportFee => allStudentFees
      .where((fee) => fee.feeName.toLowerCase().contains('transport'))
      .fold(0.0, (sum, fee) => sum + fee.totalAmount);

  // Other Fees
  double get otherFees => allStudentFees
      .where((fee) {
        final name = fee.feeName.toLowerCase();
        return !name.contains('tuition') && !name.contains('transport');
      })
      .fold(0.0, (sum, fee) => sum + fee.totalAmount);

  // Total Fee
  double get totalStudentFee =>
      allStudentFees.fold(0.0, (sum, fee) => sum + fee.totalAmount);

  // Total Paid
  double get totalStudentPaid =>
      allStudentFees.fold(0.0, (sum, fee) => sum + fee.paidAmount);

  // Total Pending
  double get totalStudentPending =>
      allStudentFees.fold(0.0, (sum, fee) => sum + fee.pendingAmount);

       // Total Pending
  double get discount =>
      allStudentFees.fold(0.0, (sum, fee) => sum + fee.discountAmount);


  // Student-level payment progress
  double get studentProgress {
    if (totalStudentFee <= 0) return 0;

    return (totalStudentPaid / totalStudentFee).clamp(0.0, 1.0);
  }

  String get studentDisplayStatus {
    if (totalStudentPending <= 0) return 'PAID';
    if (totalStudentPaid > 0) return 'PARTIAL';
    return 'PENDING';
  }

  @override
  void initState() {
    super.initState();
    record = widget.record;
  }

  String _formatCurrency(double value) {
    return '₹${value.toStringAsFixed(2)}';
  }

  String _formatDate(String date) {
    if (date.isEmpty) return '-';

    try {
      final d = DateTime.parse(date);

      const months = [
        '',
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];

      return '${d.day.toString().padLeft(2, '0')} '
          '${months[d.month]} ${d.year}';
    } catch (_) {
      return date;
    }
  }

  double get progress {
    if (record.totalAmount <= 0) {
      return 0;
    }

    return (record.paidAmount / record.totalAmount).clamp(0.0, 1.0);
  }

  String get displayStatus {
    if (record.pendingAmount <= 0) {
      return 'PAID';
    }

    if (record.paidAmount > 0) {
      return 'PARTIAL';
    }

    return 'PENDING';
  }

  Future<void> _openPaymentHistory() async {
    if (record.studentId == null) {
      return;
    }

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PaymentHistoryScreen(
          studentId: record.studentId!,
          studentName: record.studentName,
        ),
      ),
    );
  }

  Future<void> _collectPayment() async {
    final totalPending = allStudentFees.fold<double>(
      0.0,
      (sum, fee) => sum + fee.pendingAmount,
    );

    if (totalPending <= 0) {
      _showMessage('No pending fee available.', isError: true);
      return;
    }

    final amountController = TextEditingController();
    final remarksController = TextEditingController();

    String paymentMethod = 'CASH';
    bool saving = false;

    final shouldRefresh = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Collect Student Fee'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Total Pending Amount',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatCurrency(totalPending),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                    const SizedBox(height: 16),

                    TextField(
                      controller: amountController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Payment Amount',
                        prefixText: '₹ ',
                        border: OutlineInputBorder(),
                      ),
                    ),

                    const SizedBox(height: 12),

                    DropdownButtonFormField<String>(
                      value: paymentMethod,
                      decoration: const InputDecoration(
                        labelText: 'Payment Method',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'CASH', child: Text('Cash')),
                        DropdownMenuItem(value: 'UPI', child: Text('UPI')),
                        DropdownMenuItem(
                          value: 'ONLINE',
                          child: Text('Online'),
                        ),
                        DropdownMenuItem(
                          value: 'BANK_TRANSFER',
                          child: Text('Bank Transfer'),
                        ),
                        DropdownMenuItem(
                          value: 'CHEQUE',
                          child: Text('Cheque'),
                        ),
                      ],
                      onChanged: saving
                          ? null
                          : (value) {
                              if (value != null) {
                                setDialogState(() {
                                  paymentMethod = value;
                                });
                              }
                            },
                    ),

                    const SizedBox(height: 12),

                    TextField(
                      controller: remarksController,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        labelText: 'Remarks (Optional)',
                        border: OutlineInputBorder(),
                      ),
                    ),

                    const SizedBox(height: 12),

                    const Text(
                      'Payment will be allocated to pending fee records '
                      'in order.',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: saving
                      ? null
                      : () => Navigator.pop(dialogContext, false),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: saving
                      ? null
                      : () async {
                          final amount = double.tryParse(
                            amountController.text.trim(),
                          );

                          if (amount == null || amount <= 0) {
                            _showMessage(
                              'Please enter a valid payment amount.',
                              isError: true,
                            );
                            return;
                          }

                          if (amount > totalPending) {
                            _showMessage(
                              'Amount cannot exceed ${_formatCurrency(totalPending)}.',
                              isError: true,
                            );
                            return;
                          }

                          setDialogState(() {
                            saving = true;
                          });

                          try {
                            double remainingAmount = amount;

                            // Allocate payment across all pending fee records.
                            for (final fee in allStudentFees) {
                              if (remainingAmount <= 0) break;

                              if (fee.id == null || fee.pendingAmount <= 0) {
                                continue;
                              }

                              final paymentForThisFee =
                                  remainingAmount < fee.pendingAmount
                                  ? remainingAmount
                                  : fee.pendingAmount;

                              await _feeService.recordPayment(
                                studentFeeId: fee.id!,
                                amount: paymentForThisFee,
                                paymentMethod: paymentMethod,
                                remarks: remarksController.text.trim(),
                              );

                              remainingAmount -= paymentForThisFee;
                            }

                            if (remainingAmount > 0.001) {
                              throw Exception(
                                'Some payment amount could not be allocated.',
                              );
                            }

                            if (dialogContext.mounted) {
                              Navigator.pop(dialogContext, true);
                            }
                          } catch (e) {
                            setDialogState(() {
                              saving = false;
                            });

                            _showMessage(
                              e.toString().replaceFirst('Exception: ', ''),
                              isError: true,
                            );
                          }
                        },
                  child: saving
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Collect Payment'),
                ),
              ],
            );
          },
        );
      },
    );

    amountController.dispose();
    remarksController.dispose();

    if (shouldRefresh == true && mounted) {
      Navigator.pop(context, true);
    }
  }

  void _showMessage(String message, {bool isError = false}) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? const Color(0xFFDC2626) : null,
      ),
    );
  }

  Future<void> _showFixedDiscountDialog() async {
    if (record.id == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Fee record ID not found.')));
      return;
    }

    final amountController = TextEditingController();
    final reasonController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    bool saving = false;

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Apply Fixed Discount'),
              content: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Original Fee: ₹${record.totalAmount.toStringAsFixed(2)}',
                      ),
                    ),
                    const SizedBox(height: 6),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Already Paid: ₹${record.paidAmount.toStringAsFixed(2)}',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: amountController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Discount Amount (₹)',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        final discount = double.tryParse((value ?? '').trim());

                        if (discount == null || discount < 0) {
                          return 'Enter a valid discount amount';
                        }

                        if (discount > record.totalAmount) {
                          return 'Discount cannot exceed original fee';
                        }

                        final newPayable = record.totalAmount - discount;

                        if (newPayable < record.paidAmount) {
                          return 'Payable cannot be less than amount paid';
                        }

                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: reasonController,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        labelText: 'Discount Reason',
                        hintText: 'Enter reason for discount',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Discount reason is required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 8),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'This discount amount replaces the current discount.',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: saving
                      ? null
                      : () => Navigator.of(dialogContext).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: saving
                      ? null
                      : () async {
                          if (!formKey.currentState!.validate()) return;

                          final discount = double.parse(
                            amountController.text.trim(),
                          );

                          setDialogState(() => saving = true);

                          try {
                            await FeeService().applyFixedDiscount(
                              studentFeeId: record.id!,
                              discountAmount: discount,
                              discountReason: reasonController.text.trim(),
                            );

                            if (!dialogContext.mounted) return;
                            Navigator.of(dialogContext).pop();

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Fixed discount applied.'),
                              ),
                            );

                            // Reload the fee record here using the existing
                            // screen refresh mechanism.
                          } catch (e) {
                            setDialogState(() => saving = false);

                            ScaffoldMessenger.of(dialogContext).showSnackBar(
                              SnackBar(
                                content: Text(
                                  e.toString().replaceFirst('Exception: ', ''),
                                ),
                              ),
                            );
                          }
                        },
                  child: saving
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Apply Discount'),
                ),
              ],
            );
          },
        );
      },
    );

    amountController.dispose();
    reasonController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final percentage = studentProgress * 100;
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF0F172A),
        title: const Text(
          'Fee Details',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1050),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _studentHeader(),
                const SizedBox(height: 20),
                _paymentProgress(percentage),
                const SizedBox(height: 20),
                _feeInformation(),
                const SizedBox(height: 20),
                _actionButtons(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _studentHeader() {
    final name = record.studentName.isEmpty
        ? 'Student #${record.studentId}'
        : record.studentName;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(23),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          Container(
            height: 68,
            width: 68,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF2563EB), Color(0xFF4F46E5)],
              ),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Center(
              child: Text(
                name.isEmpty ? '?' : name[0].toUpperCase(),
                style: const TextStyle(
                  fontSize: 26,
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          const SizedBox(width: 17),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'Student ID: ${record.studentId ?? '-'}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  record.feeName,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
          _statusChip(),
        ],
      ),
    );
  }

  Widget _statusChip() {
    Color color;
    Color background;

    switch (displayStatus) {
      case 'PAID':
        color = const Color(0xFF15803D);
        background = const Color(0xFFDCFCE7);
        break;
      case 'PARTIAL':
        color = const Color(0xFFD97706);
        background = const Color(0xFFFEF3C7);
        break;
      default:
        color = const Color(0xFFDC2626);
        background = const Color(0xFFFEE2E2);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        displayStatus,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _paymentProgress(double percentage) {
    return Container(
      padding: const EdgeInsets.all(23),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final mobile = constraints.maxWidth < 650;

          final progressWidget = SizedBox(
            height: 108,
            width: 108,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  height: 108,
                  width: 108,
                  child: CircularProgressIndicator(
                    value: studentProgress,
                    strokeWidth: 10,
                    backgroundColor: const Color(0xFFE2E8F0),
                    valueColor: const AlwaysStoppedAnimation(Color(0xFF2563EB)),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${percentage.toStringAsFixed(0)}%',
                      style: const TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const Text(
                      'Paid',
                      style: TextStyle(fontSize: 10, color: Color(0xFF64748B)),
                    ),
                  ],
                ),
              ],
            ),
          );

          final amounts = Wrap(
            spacing: 28,
            runSpacing: 18,
            children: [
              _amountBlock(
                'Total Fee',
                totalStudentFee,
                const Color(0xFF2563EB),
              ),
              _amountBlock('Paid', totalStudentPaid, const Color(0xFF059669)),
              _amountBlock(
                'Remaining',
                totalStudentPending,
                const Color(0xFFDC2626),
              ),
            ],
          );
          if (mobile) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(child: progressWidget),
                const SizedBox(height: 22),
                const Text(
                  'Payment Progress',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 17),
                amounts,
              ],
            );
          }

          return Row(
            children: [
              progressWidget,
              const SizedBox(width: 25),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Payment Progress',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 17),
                    amounts,
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _amountBlock(String title, double amount, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
        ),
        const SizedBox(height: 4),
        Text(
          _formatCurrency(amount),
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _feeInformation() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(23),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Complete Fee Details',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 15),

          _infoRow(
            'Tuition Fee',
            _formatCurrency(tuitionFee),
            Icons.school_outlined,
          ),
          _infoRow(
            'Transport Fee',
            _formatCurrency(transportFee),
            Icons.directions_bus_outlined,
          ),
          _infoRow(
            'Other Fees',
            _formatCurrency(otherFees),
            Icons.receipt_long_outlined,
          ),

          _infoRow(
            'Discount',
            _formatCurrency(discount),
            Icons.school_outlined,
          ),

          const Divider(height: 25),

          _infoRow(
            'Total Fee',
            _formatCurrency(totalStudentFee),
            Icons.account_balance_wallet_outlined,
          ),
          _infoRow(
            'Paid Amount',
            _formatCurrency(totalStudentPaid),
            Icons.payments_outlined,
          ),
          _infoRow(
            'Pending Amount',
            _formatCurrency(totalStudentPending),
            Icons.pending_actions_outlined,
          ),

          const Divider(height: 25),

          _infoRow('Current Fee Name', record.feeName, Icons.receipt_outlined),
          _infoRow(
            'Due Date',
            _formatDate(record.dueDate),
            Icons.calendar_today_outlined,
          ),
          _infoRow(
            'Overall Status',
            studentDisplayStatus,
            Icons.verified_outlined,
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 13),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9))),
      ),
      child: Row(
        children: [
          Container(
            height: 36,
            width: 36,
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 17, color: const Color(0xFF64748B)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0F172A),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionButtons() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final mobile = constraints.maxWidth < 600;

        final history = OutlinedButton.icon(
          onPressed: _openPaymentHistory,
          icon: const Icon(Icons.history_rounded),
          label: const Text('Payment History'),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(52),
            foregroundColor: const Color(0xFF334155),
            side: const BorderSide(color: Color(0xFFCBD5E1)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(13),
            ),
          ),
        );

        final discount = OutlinedButton.icon(
          onPressed: record.id != null ? _showFixedDiscountDialog : null,
          icon: const Icon(Icons.discount_outlined),
          label: const Text('Fixed Discount'),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(52),
            foregroundColor: const Color(0xFF7C3AED),
            side: const BorderSide(color: Color(0xFFDDD6FE)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(13),
            ),
          ),
        );

        final collect = ElevatedButton.icon(
          onPressed: record.pendingAmount > 0 ? _collectPayment : null,
          icon: const Icon(Icons.add_card_rounded),
          label: const Text('Collect Payment'),
          style: ElevatedButton.styleFrom(
            minimumSize: const Size.fromHeight(52),
            backgroundColor: const Color(0xFF2563EB),
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(13),
            ),
          ),
        );

        if (mobile) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(width: double.infinity, child: history),
              const SizedBox(height: 12),
              SizedBox(width: double.infinity, child: discount),
              const SizedBox(height: 12),
              SizedBox(width: double.infinity, child: collect),
            ],
          );
        }

        return Row(
          children: [
            Expanded(child: history),
            const SizedBox(width: 12),
            Expanded(child: discount),
            const SizedBox(width: 12),
            Expanded(child: collect),
          ],
        );
      },
    );
  }
}
