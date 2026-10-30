import 'package:flutter/material.dart';
import 'package:smartkids_admin/core/network/api_client.dart';

import 'models/teacher_leave_model.dart';
import 'services/teacher_leave_service.dart';

class TeacherLeavesScreen extends StatefulWidget {
  const TeacherLeavesScreen({super.key});

  @override
  State<TeacherLeavesScreen> createState() => _TeacherLeavesScreenState();
}

class _TeacherLeavesScreenState extends State<TeacherLeavesScreen> {
  static const Color primaryColor = Color(0xFF2563EB);
  static const Color backgroundColor = Color(0xFFF5F7FB);
  static const Color darkColor = Color(0xFF172033);

  late final TeacherLeaveService _leaveService;

  final TextEditingController _searchController = TextEditingController();

  List<TeacherLeave> _leaves = [];
  bool _isLoading = true;
  String? _errorMessage;
  String _selectedFilter = 'ALL';

  @override
  void initState() {
    super.initState();
    _leaveService = TeacherLeaveService(ApiClient());
    _loadLeaves();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadLeaves() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      final result = await _leaveService.getAllSchoolLeaves();

      if (!mounted) return;

      setState(() {
        _leaves = result;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  List<TeacherLeave> get _filteredLeaves {
    final query = _searchController.text.trim().toLowerCase();

    return _leaves.where((leave) {
      final matchesSearch =
          leave.teacherName.toLowerCase().contains(query) ||
          leave.leaveType.toLowerCase().contains(query) ||
          leave.reason.toLowerCase().contains(query);

      final matchesFilter = _selectedFilter == 'ALL' ||
          leave.status.toUpperCase() == _selectedFilter;

      return matchesSearch && matchesFilter;
    }).toList();
  }

  int get _todayLeaves {
    final today = DateTime.now();

    return _leaves.where((leave) {
      final start = DateTime.tryParse(leave.startDate);
      final end = DateTime.tryParse(leave.endDate);

      if (start == null || end == null) return false;

      final currentDate = DateTime(today.year, today.month, today.day);

      return !currentDate.isBefore(
            DateTime(start.year, start.month, start.day),
          ) &&
          !currentDate.isAfter(
            DateTime(end.year, end.month, end.day),
          );
    }).length;
  }

  int get _upcomingLeaves {
    final today = DateTime.now();
    final currentDate = DateTime(today.year, today.month, today.day);

    return _leaves.where((leave) {
      final start = DateTime.tryParse(leave.startDate);
      if (start == null) return false;

      return DateTime(start.year, start.month, start.day)
          .isAfter(currentDate);
    }).length;
  }

  String _formatDate(String value) {
    final date = DateTime.tryParse(value);
    if (date == null) return value.isEmpty ? 'N/A' : value;

    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');

    return '$day/$month/${date.year}';
  }

  void _showLeaveDetails(TeacherLeave leave) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          title: const Text(
            'Leave Application Details',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: darkColor,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _detailRow('Teacher', leave.teacherName),
                _detailRow('Leave Type', leave.leaveType),
                _detailRow('Start Date', _formatDate(leave.startDate)),
                _detailRow('End Date', _formatDate(leave.endDate)),
                _detailRow('Reason', leave.reason),
                _detailRow('Status', leave.status),
                _detailRow(
                  'Applied At',
                  leave.appliedAt == null
                      ? 'N/A'
                      : _formatDate(leave.appliedAt!),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text(
                'Close',
                style: TextStyle(
                  color: primaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value.isEmpty ? 'N/A' : value,
            style: const TextStyle(
              color: darkColor,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryCard({
    required String title,
    required int count,
    required IconData icon,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE8ECF3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 12),
            Text(
              count.toString(),
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: darkColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCards() {
    return Row(
      children: [
        _summaryCard(
          title: 'Total Applications',
          count: _leaves.length,
          icon: Icons.description_outlined,
          color: primaryColor,
        ),
        const SizedBox(width: 10),
        _summaryCard(
          title: 'On Leave Today',
          count: _todayLeaves,
          icon: Icons.event_available_outlined,
          color: Colors.orange,
        ),
        const SizedBox(width: 10),
        _summaryCard(
          title: 'Upcoming',
          count: _upcomingLeaves,
          icon: Icons.calendar_month_outlined,
          color: Colors.green,
        ),
      ],
    );
  }

  Widget _buildSearchAndFilter() {
    return Column(
      children: [
        TextField(
          controller: _searchController,
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            hintText: 'Search teacher, leave type or reason...',
            prefixIcon: const Icon(Icons.search),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE8ECF3)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE8ECF3)),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Align(
          alignment: Alignment.centerLeft,
          child: Wrap(
            spacing: 8,
            children: [
              _filterChip('ALL', 'All'),
              _filterChip('APPLIED', 'Applied'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _filterChip(String value, String label) {
    final selected = _selectedFilter == value;

    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) {
        setState(() {
          _selectedFilter = value;
        });
      },
      selectedColor: primaryColor.withValues(alpha: 0.12),
      labelStyle: TextStyle(
        color: selected ? primaryColor : darkColor,
        fontWeight: FontWeight.w600,
      ),
      side: BorderSide(
        color: selected ? primaryColor : const Color(0xFFE8ECF3),
      ),
      backgroundColor: Colors.white,
    );
  }

  Widget _buildLeaveCard(TeacherLeave leave) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE8ECF3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: primaryColor.withValues(alpha: 0.10),
                child: Text(
                  leave.teacherName.isEmpty
                      ? '?'
                      : leave.teacherName[0].toUpperCase(),
                  style: const TextStyle(
                    color: primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      leave.teacherName,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: darkColor,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      leave.leaveType,
                      style: const TextStyle(
                        color: Colors.black54,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  leave.status,
                  style: const TextStyle(
                    color: Colors.deepOrange,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(
                Icons.calendar_today_outlined,
                size: 16,
                color: Colors.black54,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${_formatDate(leave.startDate)} - ${_formatDate(leave.endDate)}',
                  style: const TextStyle(
                    color: darkColor,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
          if (leave.reason.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              leave.reason,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.black54,
                fontSize: 13,
              ),
            ),
          ],
          const SizedBox(height: 12),
          const Divider(height: 1),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: () => _showLeaveDetails(leave),
              icon: const Icon(Icons.visibility_outlined, size: 18),
              label: const Text('View Details'),
              style: TextButton.styleFrom(
                foregroundColor: primaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: primaryColor),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 42,
              ),
              const SizedBox(height: 12),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _loadLeaves,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    final leaves = _filteredLeaves;

    if (leaves.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.event_busy_outlined,
              size: 54,
              color: Colors.black26,
            ),
            const SizedBox(height: 12),
            Text(
              _leaves.isEmpty
                  ? 'No teacher leave applications yet'
                  : 'No matching applications found',
              style: const TextStyle(
                color: Colors.black54,
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadLeaves,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(top: 4, bottom: 24),
        itemCount: leaves.length,
        itemBuilder: (context, index) {
          return _buildLeaveCard(leaves[index]);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Teacher Leave Applications',
          style: TextStyle(
            color: darkColor,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: darkColor),
        actions: [
          IconButton(
            onPressed: _loadLeaves,
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildSummaryCards(),
              const SizedBox(height: 20),
              _buildSearchAndFilter(),
              const SizedBox(height: 16),
              Expanded(child: _buildBody()),
            ],
          ),
        ),
      ),
    );
  }
}