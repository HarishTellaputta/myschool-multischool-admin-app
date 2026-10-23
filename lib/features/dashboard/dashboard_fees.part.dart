part of 'admin_dashboard_screen.dart';

extension AdminDashboardFeesUI on _AdminDashboardScreenState {
  Widget _buildFeesDetailsCard() {
    final summary = _feeDashboardSummary;

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE8EDF5)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.035),
            blurRadius: 20,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F3FF),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.payments_rounded,
                  color: Color(0xFF7C3AED),
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Fee Collection Details',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Collection and outstanding fees',
                      style: TextStyle(
                        color: Color(0xFF94A3B8),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (_isLoadingFeeDashboard)
            const _DashboardLoading()
          else if (_feeDashboardError != null)
            _dashboardErrorView(
              _feeDashboardError!,
              _loadFeeDashboardSummary,
            )
          else if (summary == null)
            const _dashboardEmptyView('No fee summary available.')
          else ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFFF5F3FF),
                    Color(0xFFEDE9FE),
                  ],
                ),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Total fees collected',
                    style: TextStyle(
                      color: Color(0xFF6D28D9),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _formatIndianCurrency(summary.collected),
                    style: const TextStyle(
                      color: Color(0xFF4C1D95),
                      fontSize: 27,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: LinearProgressIndicator(
                      value: (summary.collectionPercentage
                                  .toDouble()
                                  .clamp(0.0, 100.0)) /
                              100,
                      minHeight: 8,
                      backgroundColor: Colors.white,
                      valueColor:
                          const AlwaysStoppedAnimation(
                        Color(0xFF7C3AED),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${summary.collectionPercentage.toStringAsFixed(1)}% collected',
                    style: const TextStyle(
                      color: Color(0xFF6D28D9),
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            _feeDetailRow(
              'Pending amount',
              _formatIndianCurrency(summary.pending),
              Icons.hourglass_bottom_rounded,
              const Color(0xFFDC2626),
              const Color(0xFFFEF2F2),
            ),
            const SizedBox(height: 12),
            _feeDetailRow(
              'Total fee amount',
              _formatIndianCurrency(summary.totalFee),
              Icons.account_balance_wallet_outlined,
              const Color(0xFF2563EB),
              const Color(0xFFEFF6FF),
            ),
          ],
        ],
      ),
    );
  }

  Widget _feeDetailRow(
    String label,
    String value,
    IconData icon,
    Color color,
    Color background,
  ) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: background,
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: Color(0xFF64748B),
                fontSize: 12,
              ),
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(
                color: Color(0xFF0F172A),
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatIndianCurrency(num amount) {
    final rounded = amount.round();
    final negative = rounded < 0;
    final digits = rounded.abs().toString();

    if (digits.length <= 3) {
      return '${negative ? '-₹' : '₹'}$digits';
    }

    final lastThree = digits.substring(digits.length - 3);
    final prefix = digits.substring(0, digits.length - 3);
    final groups = <String>[];

    for (int i = prefix.length; i > 0; i -= 2) {
      final start = i - 2 < 0 ? 0 : i - 2;
      groups.insert(0, prefix.substring(start, i));
    }

    return '${negative ? '-₹' : '₹'}${groups.join(',')},$lastThree';
  }
}