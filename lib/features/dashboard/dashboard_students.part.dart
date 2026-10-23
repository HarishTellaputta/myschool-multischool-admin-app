part of 'admin_dashboard_screen.dart';

extension AdminDashboardStudentsUI on _AdminDashboardScreenState {
  Widget _buildStatsGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 1200
            ? 4
            : constraints.maxWidth >= 620
                ? 2
                : 1;

        final cardWidth =
            (constraints.maxWidth - (columns - 1) * 16) / columns;

        return Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            SizedBox(
              width: cardWidth,
              child: _buildStatCard(
                title: 'Total Students',
                value: _isLoadingDashboard ? '—' : '$_studentCount',
                subtitle: 'Enrolled students',
                icon: Icons.school_rounded,
                color: const Color(0xFF2563EB),
                background: const Color(0xFFEFF6FF),
                loading: _isLoadingDashboard,
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: _buildStatCard(
                title: 'Total Teachers',
                value: _isLoadingDashboard ? '—' : '$_teacherCount',
                subtitle: 'Teaching staff',
                icon: Icons.groups_rounded,
                color: const Color(0xFF059669),
                background: const Color(0xFFECFDF5),
                loading: _isLoadingDashboard,
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: _buildStatCard(
                title: 'Attendance',
                value: _isLoadingAttendanceDashboard
                    ? '—'
                    : _attendanceDashboardSummary == null
                        ? 'No data'
                        : '${_attendanceDashboardSummary!.attendancePercentage.toStringAsFixed(1)}%',
                subtitle: 'Attendance overview',
                icon: Icons.fact_check_rounded,
                color: const Color(0xFFD97706),
                background: const Color(0xFFFFFBEB),
                loading: _isLoadingAttendanceDashboard,
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: _buildStatCard(
                title: 'Fee Collection',
                value: _isLoadingFeeDashboard
                    ? '—'
                    : _feeDashboardSummary == null
                        ? 'No data'
                        : '${_feeDashboardSummary!.collectionPercentage.toStringAsFixed(1)}%',
                subtitle: 'Collection progress',
                icon: Icons.account_balance_wallet_rounded,
                color: const Color(0xFF7C3AED),
                background: const Color(0xFFF5F3FF),
                loading: _isLoadingFeeDashboard,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
    required Color background,
    required bool loading,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE8EDF5)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.035),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: background,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: color, size: 27),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF0F172A),
                    fontSize: 23,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  loading ? 'Loading...' : subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF94A3B8),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}