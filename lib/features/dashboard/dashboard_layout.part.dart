part of 'admin_dashboard_screen.dart';

extension AdminDashboardLayoutUI on _AdminDashboardScreenState {
  Widget _buildOverviewSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'School Performance',
          style: TextStyle(
            fontSize: 21,
            fontWeight: FontWeight.w800,
            color: Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 5),
        const Text(
          'A quick look at attendance and fee collection.',
          style: TextStyle(
            color: Color(0xFF64748B),
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 18),
        LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth >= 850) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _buildAttendanceOverviewCard()),
                  const SizedBox(width: 18),
                  Expanded(child: _buildFeesOverviewCard()),
                ],
              );
            }

            return Column(
              children: [
                _buildAttendanceOverviewCard(),
                const SizedBox(height: 18),
                _buildFeesOverviewCard(),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildAttendanceOverviewCard() {
    final summary = _attendanceDashboardSummary;

    final percentage = summary == null
        ? 0.0
        : summary.attendancePercentage
            .toDouble()
            .clamp(0.0, 100.0)
            .toDouble();

    return _overviewCardShell(
      icon: Icons.fact_check_rounded,
      iconColor: const Color(0xFF2563EB),
      title: 'Attendance Overview',
      subtitle: 'Student attendance summary',
      trailing: const Text(
        'ATTENDANCE',
        style: TextStyle(
          color: Color(0xFF64748B),
          fontSize: 10,
          fontWeight: FontWeight.w800,
          letterSpacing: 1,
        ),
      ),
      child: _isLoadingAttendanceDashboard
          ? const _DashboardLoading()
          : _attendanceDashboardError != null
              ? _dashboardErrorView(
                  _attendanceDashboardError!,
                  _loadAttendanceDashboardSummary,
                )
              : summary == null
                  ? const _dashboardEmptyView('No attendance data available.')
                  : Column(
                      children: [
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            SizedBox(
                              width: 108,
                              height: 108,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  SizedBox.expand(
                                    child: CircularProgressIndicator(
                                      value: percentage / 100,
                                      strokeWidth: 10,
                                      strokeCap: StrokeCap.round,
                                      backgroundColor:
                                          const Color(0xFFEFF6FF),
                                      valueColor:
                                          const AlwaysStoppedAnimation(
                                        Color(0xFF2563EB),
                                      ),
                                    ),
                                  ),
                                  Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        '${percentage.toStringAsFixed(1)}%',
                                        style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w800,
                                          color: Color(0xFF0F172A),
                                        ),
                                      ),
                                      const Text(
                                        'Present rate',
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: Color(0xFF64748B),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 22),
                            Expanded(
                              child: Column(
                                children: [
                                  _overviewMetric(
                                    'Total students',
                                    '${summary.totalStudents}',
                                    Icons.groups_outlined,
                                    const Color(0xFF2563EB),
                                  ),
                                  const SizedBox(height: 14),
                                  _overviewMetric(
                                    'Attendance marked',
                                    '${summary.marked}',
                                    Icons.check_circle_outline_rounded,
                                    const Color(0xFF059669),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 22),
                        const Divider(color: Color(0xFFEEF2F7)),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _smallSummary(
                                'Present',
                                '${summary.present}',
                                const Color(0xFF059669),
                              ),
                            ),
                            Expanded(
                              child: _smallSummary(
                                'Absent',
                                '${summary.absent}',
                                const Color(0xFFDC2626),
                              ),
                            ),
                            Expanded(
                              child: _smallSummary(
                                'Leave',
                                '${summary.leave}',
                                const Color(0xFFD97706),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
    );
  }

  Widget _buildFeesOverviewCard() {
    final summary = _feeDashboardSummary;

    final percentage = summary == null
        ? 0.0
        : summary.collectionPercentage
            .toDouble()
            .clamp(0.0, 100.0)
            .toDouble();

    return _overviewCardShell(
      icon: Icons.account_balance_wallet_rounded,
      iconColor: const Color(0xFF7C3AED),
      title: 'Fees Overview',
      subtitle: 'Collection and pending balance',
      trailing: const Icon(
        Icons.trending_up_rounded,
        color: Color(0xFF7C3AED),
      ),
      child: _isLoadingFeeDashboard
          ? const _DashboardLoading()
          : _feeDashboardError != null
              ? _dashboardErrorView(
                  _feeDashboardError!,
                  _loadFeeDashboardSummary,
                )
              : summary == null
                  ? const _dashboardEmptyView('No fee data available.')
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 22),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Collection progress',
                                    style: TextStyle(
                                      color: Color(0xFF64748B),
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    '${percentage.toStringAsFixed(1)}%',
                                    style: const TextStyle(
                                      color: Color(0xFF0F172A),
                                      fontSize: 31,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  const Text(
                                    'Of total fees collected',
                                    style: TextStyle(
                                      color: Color(0xFF94A3B8),
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              width: 78,
                              height: 78,
                              child: CircularProgressIndicator(
                                value: percentage / 100,
                                strokeWidth: 8,
                                strokeCap: StrokeCap.round,
                                backgroundColor: const Color(0xFFF3E8FF),
                                valueColor:
                                    const AlwaysStoppedAnimation(
                                  Color(0xFF7C3AED),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 22),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: LinearProgressIndicator(
                            value: percentage / 100,
                            minHeight: 8,
                            backgroundColor: const Color(0xFFF3E8FF),
                            valueColor:
                                const AlwaysStoppedAnimation(
                              Color(0xFF7C3AED),
                            ),
                          ),
                        ),
                        const SizedBox(height: 22),
                        _moneySummaryRow(
                          'Collected',
                          _formatIndianCurrency(summary.collected),
                          const Color(0xFF059669),
                        ),
                        const SizedBox(height: 14),
                        _moneySummaryRow(
                          'Pending',
                          _formatIndianCurrency(summary.pending),
                          const Color(0xFFDC2626),
                        ),
                        const SizedBox(height: 14),
                        _moneySummaryRow(
                          'Total fees',
                          _formatIndianCurrency(summary.totalFee),
                          const Color(0xFF475569),
                        ),
                      ],
                    ),
    );
  }

  Widget _overviewCardShell({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required Widget trailing,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
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
                  color: iconColor.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: iconColor, size: 23),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Color(0xFF94A3B8),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              trailing,
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _overviewMetric(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Row(
      children: [
        Icon(icon, size: 17, color: color),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: Color(0xFF64748B),
              fontSize: 11,
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Color(0xFF0F172A),
            fontWeight: FontWeight.w800,
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  Widget _smallSummary(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF64748B),
            fontSize: 11,
          ),
        ),
        const SizedBox(height: 7),
        Row(
          children: [
            Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                value,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                  color: Color(0xFF0F172A),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _moneySummaryRow(String label, String amount, Color color) {
    return Row(
      children: [
        Container(
          width: 9,
          height: 9,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 10),
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
            amount,
            textAlign: TextAlign.end,
            style: const TextStyle(
              color: Color(0xFF0F172A),
              fontWeight: FontWeight.w800,
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }

  Widget _dashboardErrorView(
    String error,
    Future<void> Function() retry,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.cloud_off_rounded,
            color: Color(0xFFDC2626),
          ),
          const SizedBox(height: 8),
          const Text(
            'Unable to load data',
            style: TextStyle(
              color: Color(0xFF991B1B),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            error,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF991B1B),
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: () => retry(),
            icon: const Icon(Icons.refresh_rounded, size: 17),
            label: const Text('Try again'),
          ),
        ],
      ),
    );
  }
}

class _DashboardLoading extends StatelessWidget {
  const _DashboardLoading();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 36),
      child: Center(
        child: CircularProgressIndicator(strokeWidth: 3),
      ),
    );
  }
}

class _dashboardEmptyView extends StatelessWidget {
  final String message;

  const _dashboardEmptyView(this.message);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 28),
      child: Center(
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Color(0xFF64748B),
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}