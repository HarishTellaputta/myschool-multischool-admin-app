part of 'admin_dashboard_screen.dart';

extension AdminDashboardActivityUI on _AdminDashboardScreenState {
  Widget _buildBottomSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth >= 900) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _buildAttendanceDetailsCard()),
                  const SizedBox(width: 20),
                  Expanded(child: _buildFeesDetailsCard()),
                ],
              );
            }

            return Column(
              children: [
                _buildAttendanceDetailsCard(),
                const SizedBox(height: 20),
                _buildFeesDetailsCard(),
              ],
            );
          },
        ),
        const SizedBox(height: 28),
        const Text(
          'Quick Actions',
          style: TextStyle(
            color: Color(0xFF0F172A),
            fontSize: 21,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 5),
        const Text(
          'Jump directly to frequently used school tools.',
          style: TextStyle(color: Color(0xFF64748B), fontSize: 13),
        ),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            final columns = constraints.maxWidth >= 1000
                ? 4
                : constraints.maxWidth >= 560
                ? 2
                : 1;

            final width = (constraints.maxWidth - (columns - 1) * 14) / columns;

            return Wrap(
              spacing: 14,
              runSpacing: 14,
              children: [
                SizedBox(
                  width: width,
                  child: _quickActionCard(
                    title: 'Add Student',
                    subtitle: 'Manage student records',
                    icon: Icons.person_add_alt_1_rounded,
                    color: const Color(0xFF2563EB),
                    background: const Color(0xFFEFF6FF),
                    onTap: () => _onMenuSelected(1),
                  ),
                ),
                SizedBox(
                  width: width,
                  child: _quickActionCard(
                    title: 'Add Teacher',
                    subtitle: 'Manage teaching staff',
                    icon: Icons.group_add_rounded,
                    color: const Color(0xFF059669),
                    background: const Color(0xFFECFDF5),
                    onTap: () => _onMenuSelected(2),
                  ),
                ),
                // SizedBox(
                //   width: width,
                //   child: _quickActionCard(
                //     title: 'MCQ Tests',
                //     subtitle: 'Manage online tests',
                //     icon: Icons.quiz_rounded,
                //     color: const Color(0xFF7C3AED),
                //     background: const Color(0xFFF5F3FF),
                //     onTap: () => _onMenuSelected(11),
                //   ),
                // ),
                SizedBox(
                  width: width,
                  child: _quickActionCard(
                    title: 'Notices',
                    subtitle: 'Manage school notices',
                    icon: Icons.campaign_rounded,
                    color: const Color(0xFFD97706),
                    background: const Color(0xFFFFFBEB),
                    onTap: () => _onMenuSelected(13),
                  ),
                ),

                SizedBox(
                  width: width,
                  child: _quickActionCard(
                    title: 'Teacher Leaves',
                    subtitle: 'View teacher leave applications',
                    icon: Icons.event_note_rounded,
                    color: const Color(0xFF7C3AED),
                    background: const Color(0xFFF5F3FF),
                    onTap: () => _onMenuSelected(21),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _quickActionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required Color background,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(17),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFE8EDF5)),
          ),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: background,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: color, size: 23),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF0F172A),
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 10,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 4),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: Color(0xFF94A3B8),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
