part of 'admin_dashboard_screen.dart';

extension AdminDashboardHeaderUI on _AdminDashboardScreenState {
  Widget _buildDashboardContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildWelcomeSection(),
        const SizedBox(height: 28),
        _buildStatsGrid(),
        const SizedBox(height: 28),
        _buildOverviewSection(),
        const SizedBox(height: 28),
        _buildBottomSection(),
      ],
    );
  }

  Widget _buildWelcomeSection() {
    final isLoading = _isLoadingDashboard ||
        _isLoadingAttendanceDashboard ||
        _isLoadingFeeDashboard ||
        _isLoadingLastSixDaysAttendance;

    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 650;

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF172554), Color(0xFF2563EB)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF2563EB).withValues(alpha: 0.18),
                blurRadius: 24,
                offset: const Offset(0, 10),
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
                      color: Colors.white.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.dashboard_customize_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'SMARTKIDS • ADMIN',
                      style: TextStyle(
                        color: Color(0xFFBFDBFE),
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Refresh dashboard',
                    onPressed: isLoading
                        ? null
                        : () {
                            _loadDashboardData();
                            _loadFeeDashboardSummary();
                            _loadAttendanceDashboardSummary();
                            _loadLastSixDaysAttendance();
                          },
                    icon: Icon(
                      isLoading
                          ? Icons.sync_rounded
                          : Icons.refresh_rounded,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                _isLoadingSchoolId
                    ? 'Preparing your dashboard...'
                    : _schoolId == null
                        ? 'Dashboard needs attention'
                        : 'Welcome back, Admin 👋',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: compact ? 24 : 30,
                  fontWeight: FontWeight.w800,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _schoolId == null
                    ? 'Please sign in again to load your school dashboard.'
                    : 'Your school overview, attendance and fee insights — all in one place.',
                style: const TextStyle(
                  color: Color(0xFFDBEAFE),
                  fontSize: 14,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 22),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _headerPill(
                    Icons.calendar_month_rounded,
                    _formattedToday(),
                  ),
                  _headerPill(
                    isLoading
                        ? Icons.sync_rounded
                        : Icons.verified_rounded,
                    isLoading ? 'Updating data' : 'Dashboard overview',
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _headerPill(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 9,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.16),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.white),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  String _formattedToday() {
    final now = DateTime.now();
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];

    return '${now.day} ${months[now.month - 1]} ${now.year}';
  }
}