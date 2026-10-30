import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fl_chart/fl_chart.dart';

import 'package:smartkids_admin/features/attendance/models/attendance_dashboard_summary_model.dart';
import 'package:smartkids_admin/features/attendance/models/attendance_last_six_days_model.dart';
import 'package:smartkids_admin/features/attendance/services/attendance_service.dart';
import 'package:smartkids_admin/features/fees/models/fee_dashboard_summary_model.dart';
import 'package:smartkids_admin/features/fees/services/fee_service.dart';
import 'package:smartkids_admin/models/student_gender_summary.dart';

import '../../core/network/api_client.dart';
import '../../services/auth_service.dart';
import '../../services/admin_dashboard_service.dart';
import '../../widgets/admin_sidebar.dart';
import '../../widgets/admin_topbar.dart';

import '../attendance/attendance_dashboard_screen.dart';
import '../students/students_screen.dart';
import '../classes/classes_screen.dart';
import '../teachers/teachers_screen.dart';
import '../subjects/subjects_screen.dart';
import '../parents/parents_screen.dart';
import '../attendance/attendance_screen.dart';
import '../homework/homework_screen.dart';
import '../timetable/timetable_screen.dart';
import '../fees/fees_screen.dart';
import '../exams/exams_screen.dart';
import '../mcq/mcq_screen.dart';
import '../results/results_screen.dart';
import '../notices/notices_screen.dart';
import '../events/events_screen.dart';
import '../settings/settings_screen.dart';
import '../auth/login_screen.dart';
import '../../report_cards/screens/report_cards_screen.dart';
import '../reports/screens/reports_screen.dart';
import '../birthdays/birthdays_screen.dart';
import 'package:smartkids_admin/excel_reports/excel_reports_screen.dart';

import '../teachers/teacher_leaves_screen.dart';

// Dashboard UI is split into separate files.
part 'admin_dashboard_header.dart';
part 'dashboard_layout.part.dart';
part 'dashboard_students.part.dart';
part 'dashboard_attendance.part.dart';
part 'dashboard_fees.part.dart';
part 'dashboard_activity.part.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int? _schoolId;
  bool _isLoadingSchoolId = true;
  final ApiClient _apiClient = ApiClient();

  late final AdminDashboardService _dashboardService;

  final FeeService _feeService = FeeService();

  FeeDashboardSummaryModel? _feeDashboardSummary;

  AttendanceDashboardSummaryModel? _attendanceDashboardSummary;

  bool _isLoadingAttendanceDashboard = true;
  String? _attendanceDashboardError;

  bool _isLoadingFeeDashboard = true;
  String? _feeDashboardError;

  List<AttendanceLastSixDaysModel> _lastSixDaysAttendance = [];

  bool _isLoadingLastSixDaysAttendance = true;
  String? _lastSixDaysAttendanceError;

  bool _isLoadingDashboard = true;
  String? _dashboardError;

  int _studentCount = 0;
  StudentGenderSummary? _studentGenderSummary;
  int _teacherCount = 0;

  int selectedIndex = 0;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();

    _dashboardService = AdminDashboardService(_apiClient);
    _initializeDashboard();
  }

  Future<void> _initializeDashboard() async {
    final prefs = await SharedPreferences.getInstance();
    final schoolId = prefs.getInt('school_id');

    if (!mounted) return;

    if (schoolId == null || schoolId <= 0) {
      setState(() {
        _schoolId = null;
        _isLoadingSchoolId = false;
        _dashboardError = 'School ID not found. Please login again.';
      });
      return;
    }

    setState(() {
      _schoolId = schoolId;
      _isLoadingSchoolId = false;
    });

    await Future.wait([
      _loadDashboardData(),
      _loadFeeDashboardSummary(),
      _loadAttendanceDashboardSummary(),
      _loadLastSixDaysAttendance(),
    ]);
  }

  // --------------------------------------------------
  // SIDEBAR MENU
  // --------------------------------------------------

  void _onMenuSelected(int index) {
    setState(() {
      selectedIndex = index;
    });

    // Close drawer on mobile after selecting an item.
    if (MediaQuery.of(context).size.width < 900) {
      Navigator.of(context).pop();
    }
  }

  String _menuName(int index) {
    const names = [
      'Dashboard',
      'Students',
      'Teachers',
      'Classes',
      'Subjects',
      'Parents',
      'Attendance',
      'Homework',
      'Timetable',
      'Fees',
      'Exams',
      'MCQ Tests',
      'Results',
      'Notices',
      'Events',
      'Reports',
      'Settings',
      'Logout',
      'Report Cards',
      'Birthdays',
      'Excel Reports',
    ];

    if (index >= 0 && index < names.length) {
      return names[index];
    }

    return 'Selected';
  }

  // --------------------------------------------------
  // DASHBOARD API CALLS
  // --------------------------------------------------

  Future<void> _loadDashboardData() async {
    setState(() {
      _isLoadingDashboard = true;
      _dashboardError = null;
    });

    try {
      final data = await _dashboardService.getDashboardCounts();

      final genderSummary = await _dashboardService.getStudentGenderSummary();

      if (!mounted) return;

      setState(() {
        _studentCount = data['students'] ?? 0;
        _teacherCount = data['teachers'] ?? 0;

        _studentGenderSummary = genderSummary;
        _isLoadingDashboard = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoadingDashboard = false;
        _dashboardError = e.toString();
      });
    }
  }

  Future<void> _loadFeeDashboardSummary() async {
    setState(() {
      _isLoadingFeeDashboard = true;
      _feeDashboardError = null;
    });

    try {
      final data = await _feeService.getDashboardSummary();

      if (!mounted) return;

      setState(() {
        _feeDashboardSummary = data;
        _isLoadingFeeDashboard = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoadingFeeDashboard = false;
        _feeDashboardError = e.toString();
      });
    }
  }

  Future<void> _loadAttendanceDashboardSummary() async {
    setState(() {
      _isLoadingAttendanceDashboard = true;
      _attendanceDashboardError = null;
    });

    try {
      final prefs = await SharedPreferences.getInstance();

      final token = prefs.getString('jwt_token') ?? '';

      if (token.trim().isEmpty) {
        throw Exception('JWT token not found. Please login again.');
      }

      final attendanceService = AttendanceService(token.trim());

      final data = await attendanceService.getDashboardSummary();

      if (!mounted) return;

      setState(() {
        _attendanceDashboardSummary = data;
        _isLoadingAttendanceDashboard = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoadingAttendanceDashboard = false;
        _attendanceDashboardError = e.toString();
      });
    }
  }

  Future<void> _loadLastSixDaysAttendance() async {
    setState(() {
      _isLoadingLastSixDaysAttendance = true;
      _lastSixDaysAttendanceError = null;
    });

    try {
      final prefs = await SharedPreferences.getInstance();

      final token = prefs.getString('jwt_token');

      if (token == null || token.trim().isEmpty) {
        throw Exception('Authentication token not found');
      }

      final attendanceService = AttendanceService(token.trim());

      final data = await attendanceService.getLastSixDaysAttendance();

      if (!mounted) return;

      setState(() {
        _lastSixDaysAttendance = data;
        _isLoadingLastSixDaysAttendance = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _lastSixDaysAttendanceError = e.toString();
        _isLoadingLastSixDaysAttendance = false;
      });
    }
  }

  // --------------------------------------------------
  // LOGOUT
  // --------------------------------------------------

  Future<void> _logout() async {
    try {
      final apiClient = ApiClient();

      final authService = AuthService(apiClient);

      await authService.logout();

      final prefs = await SharedPreferences.getInstance();

      await prefs.remove('jwt_token');

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    }
  }

  // --------------------------------------------------
  // MAIN LAYOUT
  // --------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 900;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFFF5F7FB),

      // Mobile drawer.
      drawer: isMobile
          ? Drawer(
              width: 270,
              child: AdminSidebar(
                selectedIndex: selectedIndex,
                onItemSelected: _onMenuSelected,
              ),
            )
          : null,

      body: Row(
        children: [
          // Desktop sidebar.
          if (!isMobile)
            AdminSidebar(
              selectedIndex: selectedIndex,
              onItemSelected: _onMenuSelected,
            ),

          // Main content.
          Expanded(
            child: Column(
              children: [
                AdminTopbar(
                  onMenuPressed: isMobile
                      ? () {
                          _scaffoldKey.currentState?.openDrawer();
                        }
                      : null,
                ),

                Expanded(child: _buildSelectedScreen()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --------------------------------------------------
  // SCREEN NAVIGATION
  // --------------------------------------------------

  Widget _buildSelectedScreen() {
    switch (selectedIndex) {
      case 0:
        return SingleChildScrollView(
          padding: const EdgeInsets.all(28),
          child: _buildDashboardContent(),
        );

      case 1:
        return const StudentsScreen();

      case 2:
        return const TeachersScreen();

      case 3:
        return const ClassesScreen();

      case 4:
        return _schoolId == null
            ? const Center(child: CircularProgressIndicator())
            : SubjectsScreen(schoolId: _schoolId!);

      case 5:
        return const ParentsScreen();

      case 6:
        return const AttendanceDashboardScreen();

      case 7:
        return const HomeworkScreen();

      case 8:
        return const TimetableScreen();

      case 9:
        return const FeesScreen();

      case 10:
        return const ExamsScreen();

      case 11:
        return const McqScreen();

      case 12:
        return const ResultsScreen();

      case 13:
        return const NoticesScreen();

      case 14:
        return const EventsScreen();

      case 15:
        return const ReportsScreen();

      case 16:
        return const SettingsScreen();

      case 17:
        return _buildLogoutScreen();

      case 18:
        return const ReportCardsScreen();

      case 19:
        return const BirthdaysScreen();

      case 20:
        return const ExcelReportsScreen();

      case 21:
        return const TeacherLeavesScreen();

      default:
        return SingleChildScrollView(
          padding: const EdgeInsets.all(28),
          child: _buildDashboardContent(),
        );
    }
  }

  // --------------------------------------------------
  // LOGOUT CONFIRMATION SCREEN
  // --------------------------------------------------

  Widget _buildLogoutScreen() {
    return Center(
      child: Container(
        width: 420,
        padding: const EdgeInsets.all(30),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE5E7EB)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x08000000),
              blurRadius: 15,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 64,
              width: 64,
              decoration: BoxDecoration(
                color: const Color(0xFFFEF2F2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.logout_outlined,
                size: 32,
                color: Color(0xFFDC2626),
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              'Logout',
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.bold,
                color: Color(0xFF111827),
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'Are you sure you want to logout?',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
            ),

            const SizedBox(height: 28),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton(
                  onPressed: () {
                    setState(() {
                      selectedIndex = 0;
                    });
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 13,
                    ),
                    side: const BorderSide(color: Color(0xFFD1D5DB)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(
                      color: Color(0xFF374151),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                ElevatedButton(
                  onPressed: _logout,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFDC2626),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 13,
                    ),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Logout',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
