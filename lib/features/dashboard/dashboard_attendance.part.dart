part of 'admin_dashboard_screen.dart';

extension AdminDashboardAttendanceUI on _AdminDashboardScreenState {
  Widget _buildAttendanceDetailsCard() {
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
                  color: const Color(0xFFECFDF5),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.bar_chart_rounded,
                  color: Color(0xFF059669),
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Attendance Trends',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Daily attendance for the last 6 days',
                      style: TextStyle(
                        color: Color(0xFF94A3B8),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Refresh attendance',
                onPressed: _isLoadingLastSixDaysAttendance
                    ? null
                    : _loadLastSixDaysAttendance,
                icon: const Icon(
                  Icons.refresh_rounded,
                  color: Color(0xFF64748B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          if (_isLoadingLastSixDaysAttendance)
            const _DashboardLoading()
          else if (_lastSixDaysAttendanceError != null)
            _dashboardErrorView(
              _lastSixDaysAttendanceError!,
              _loadLastSixDaysAttendance,
            )
          else if (_lastSixDaysAttendance.isEmpty)
            const _dashboardEmptyView(
              'No attendance records available for these days.',
            )
          else ...[
            SizedBox(
              height: 220,
              child: BarChart(
                BarChartData(
                  minY: 0,
                  maxY: 100,
                  alignment: BarChartAlignment.spaceAround,
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 25,
                    getDrawingHorizontalLine: (value) => FlLine(
                      color: const Color(0xFFE8EDF5),
                      strokeWidth: 1,
                      dashArray: [5, 4],
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 38,
                        interval: 25,
                        getTitlesWidget: (value, meta) => Text(
                          '${value.toInt()}%',
                          style: const TextStyle(
                            color: Color(0xFF94A3B8),
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 34,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();

                          if (index < 0 ||
                              index >= _lastSixDaysAttendance.length) {
                            return const SizedBox.shrink();
                          }

                          final rawDate = _lastSixDaysAttendance[index]
                              .date
                              .toString();
                          final label = rawDate.length >= 10
                              ? rawDate.substring(5, 10)
                              : rawDate;

                          return Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: Text(
                              label,
                              style: const TextStyle(
                                color: Color(0xFF64748B),
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  barGroups: List.generate(
                    _lastSixDaysAttendance.length,
                    (index) {
                      final item = _lastSixDaysAttendance[index];
                      final percentage = item.attendancePercentage
                          .toDouble()
                          .clamp(0.0, 100.0)
                          .toDouble();

                      return BarChartGroupData(
                        x: index,
                        barRods: [
                          BarChartRodData(
                            toY: percentage,
                            width: 22,
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(7),
                            ),
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFF34D399),
                                Color(0xFF059669),
                              ],
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  barTouchData: BarTouchData(
                    enabled: true,
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        return BarTooltipItem(
                          '${rod.toY.toStringAsFixed(1)}%',
                          const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 12,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 12,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFECFDF5),
                borderRadius: BorderRadius.circular(13),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.insights_rounded,
                    color: Color(0xFF059669),
                    size: 20,
                  ),
                  const SizedBox(width: 9),
                  Expanded(
                    child: Text(
                      'Average attendance: ${_attendanceAverage().toStringAsFixed(1)}%',
                      style: const TextStyle(
                        color: Color(0xFF065F46),
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  double _attendanceAverage() {
    if (_lastSixDaysAttendance.isEmpty) return 0;

    final total = _lastSixDaysAttendance.fold<double>(
      0,
      (sum, item) => sum + item.attendancePercentage.toDouble(),
    );

    return total / _lastSixDaysAttendance.length;
  }
}