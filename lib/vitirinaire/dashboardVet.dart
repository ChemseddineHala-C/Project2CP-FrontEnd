import './inspectionHistoryPage.dart';
import './notifieVit.dart';
import './profilevit.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fl_chart/fl_chart.dart';
import './PendingBatchesPage.dart';
import '../HOST.dart';

final FlutterSecureStorage storage = const FlutterSecureStorage();

// ==================== API SERVICE ====================
class InspectorApiService {
  static String baseUrl = '$HOST/api'; // Update with your base URL

  static Future<String?> _getToken() async {
    return await storage.read(key: "token");
  }

  static Future<Map<String, dynamic>> getDashboardData() async {
    try {
      String? token = await _getToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }

      final response = await http
          .get(
            Uri.parse('$baseUrl/veterinarians/dashboard'),
            headers: {
              "Content-Type": "application/json",
              "Authorization": "Bearer $token",
            },
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        print(response.body);
        final Map<String, dynamic> data = json.decode(response.body);
        return data;
      } else if (response.statusCode == 401) {
        throw Exception('Session expired. Please login again.');
      } else {
        throw Exception('Failed to load data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception(_getUserFriendlyError(e));
    }
  }

  static String _getUserFriendlyError(dynamic error) {
    if (error.toString().contains('SocketException')) {
      return 'No internet connection. Please check your network.';
    } else if (error.toString().contains('TimeoutException')) {
      return 'Connection timeout. Please try again.';
    } else if (error.toString().contains('token')) {
      return 'Please login again.';
    }
    return error.toString().replaceFirst('Exception: ', '');
  }
}

// ==================== DATA MODELS ====================
class InspectorProfile {
  final String fullName;
  final String? profilePhoto;

  InspectorProfile({required this.fullName, this.profilePhoto});

  factory InspectorProfile.fromJson(Map<String, dynamic> json) {
    return InspectorProfile(
      fullName: json['full_name']?.toString() ?? 'Inspector',
      profilePhoto: json['profile_photo']?.toString(),
    );
  }
}

class TodayOverview {
  final int pending;
  final int approved;
  final int rejected;
  final int urgent;

  TodayOverview({
    required this.pending,
    required this.approved,
    required this.rejected,
    required this.urgent,
  });

  factory TodayOverview.fromJson(Map<String, dynamic> json) {
    return TodayOverview(
      pending: json['pending'] ?? 0,
      approved: json['approved'] ?? 0,
      rejected: json['rejected'] ?? 0,
      urgent: json['urgent'] ?? 0,
    );
  }
}

class StatusItem {
  final int count;
  final double percentage;

  StatusItem({required this.count, required this.percentage});

  factory StatusItem.fromJson(Map<String, dynamic> json) {
    return StatusItem(
      count: json['count'] ?? 0,
      percentage: (json['percentage'] ?? 0.0).toDouble(),
    );
  }
}

class InspectionStatus {
  final int total;
  final StatusItem approved;
  final StatusItem expired;
  final StatusItem pending;
  final StatusItem rejected;

  InspectionStatus({
    required this.total,
    required this.approved,
    required this.expired,
    required this.pending,
    required this.rejected,
  });

  factory InspectionStatus.fromJson(Map<String, dynamic> json) {
    return InspectionStatus(
      total: json['total'] ?? 0,
      approved: StatusItem.fromJson(json['approved'] ?? {}),
      expired: StatusItem.fromJson(json['expired'] ?? {}),
      pending: StatusItem.fromJson(json['pending'] ?? {}),
      rejected: StatusItem.fromJson(json['rejected'] ?? {}),
    );
  }
}

class DashboardData {
  final InspectorProfile profile;
  final TodayOverview todayOverview;
  final InspectionStatus inspectionStatus;

  DashboardData({
    required this.profile,
    required this.todayOverview,
    required this.inspectionStatus,
  });

  factory DashboardData.fromJson(Map<String, dynamic> json) {
    return DashboardData(
      profile: InspectorProfile.fromJson(json['profile'] ?? {}),
      todayOverview: TodayOverview.fromJson(json['today_overview'] ?? {}),
      inspectionStatus: InspectionStatus.fromJson(
        json['inspection_status'] ?? {},
      ),
    );
  }
}

// ==================== MAIN PAGE ====================
class InspectorDashboard extends StatefulWidget {
  const InspectorDashboard({super.key});

  @override
  State<InspectorDashboard> createState() => _InspectorDashboardState();
}

class _InspectorDashboardState extends State<InspectorDashboard> {
  final Color primaryTeal = const Color(0xFF00A896);

  // State variables
  bool _isLoading = true;
  String? _errorMessage;
  DashboardData? _dashboardData;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  // ==================== DATA LOADING ====================
  Future<void> _loadDashboardData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final data = await InspectorApiService.getDashboardData();
      setState(() {
        _dashboardData = DashboardData.fromJson(data);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  void _retryLoad() {
    _loadDashboardData();
  }

  // ==================== HELPER METHODS ====================
  String _getProfilePhotoUrl(String? photoPath) {
    if (photoPath == null || photoPath.isEmpty) return '';
    String cleanPath = photoPath.replaceFirst('src/', '');
    if (!cleanPath.startsWith('http')) {
      cleanPath = '$HOST/$cleanPath';
    }
    return cleanPath;
  }

  String _getFormattedDate() {
    final now = DateTime.now();
    const months = [
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
    return '${months[now.month - 1]} ${now.day}, ${now.year}';
  }

  // ==================== UI BUILDERS ====================
  Widget _buildProfilePhoto() {
    final photoUrl = _dashboardData?.profile.profilePhoto;

    if (photoUrl != null && photoUrl.isNotEmpty) {
      return CircleAvatar(
        radius: 22,
        backgroundColor: const Color(0xFFF1F5F9),
        backgroundImage: NetworkImage(_getProfilePhotoUrl(photoUrl)),
        onBackgroundImageError: (_, __) {},
        child: null,
      );
    }

    return const CircleAvatar(
      radius: 22,
      backgroundColor: Color(0xFFF1F5F9),
      child: Icon(Icons.person, color: Color(0xFF023E77)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: 80,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            _buildProfilePhoto(),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Welcome back,",
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
                Text(
                  _dashboardData?.profile.fullName ?? "Inspector",
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                    fontFamily: "Inter",
                    color: Color(0xFF0F172A),
                    letterSpacing: -0.6,
                  ),
                ),
              ],
            ),
            const Spacer(),
            Stack(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => NotificationVitPage(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.notifications_outlined),
                  ),
                ),
                const Positioned(
                  right: 8,
                  top: 8,
                  child: CircleAvatar(radius: 4, backgroundColor: Colors.red),
                ),
              ],
            ),
          ],
        ),
      ),
      body: _buildBody(),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00A896)),
            ),
            SizedBox(height: 16),
            Text("Loading dashboard...", style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              style: const TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _retryLoad,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00A896),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text("Retry"),
            ),
          ],
        ),
      );
    }

    if (_dashboardData == null) {
      return const Center(child: Text("No data available"));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStartInspectionButton(),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [_sectionTitle("Today's Overview"), _dateBadge()],
          ),
          const SizedBox(height: 12),
          _buildStatsGrid(),
          const SizedBox(height: 20),
          _sectionTitle("Inspection Status"),
          const SizedBox(height: 12),
          _buildDonutChartCard(),
        ],
      ),
    );
  }

  Widget _buildStartInspectionButton() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const PendingBatchesPage()),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF00A896),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF01A896).withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.add_box_rounded,
                color: Colors.white,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            const Text(
              "Start New Inspection",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 18,
                fontFamily: "Inter",
              ),
            ),
            const Spacer(),
            const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 18),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsGrid() {
    final overview = _dashboardData!.todayOverview;

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 2.2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      children: [
        _statCard(
          overview.pending.toString(),
          "Pending",
          Icons.access_time,
          const Color(0xFFFEF3C7),
          const Color(0xFFD5A439),
        ),
        _statCard(
          overview.approved.toString(),
          "Approved",
          Icons.check_circle_outline,
          const Color(0xFFD1FAE5),
          const Color(0xFF01A896),
        ),
        _statCard(
          overview.rejected.toString(),
          "Rejected",
          Icons.cancel_outlined,
          const Color(0xFFFEE2E2),
          Colors.red,
        ),
        _statCard(
          overview.urgent.toString(),
          "Urgent",
          Icons.error_outline,
          const Color(0xFFFFEDEC),
          Colors.orange,
        ),
      ],
    );
  }

  Widget _statCard(
    String val,
    String label,
    IconData icon,
    Color bg,
    Color accent,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: accent, size: 20),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                val,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              Text(
                label,
                style: const TextStyle(color: Colors.grey, fontSize: 11),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDonutChartCard() {
    final status = _dashboardData!.inspectionStatus;

    // Calculate total for validation
    final total = status.total;
    final approvedPct = status.approved.percentage;
    final expiredPct = status.expired.percentage;
    final pendingPct = status.pending.percentage;
    final rejectedPct = status.rejected.percentage;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          // Donut Chart with fl_chart
          SizedBox(
            height: 130,
            width: 130,
            child: Stack(
              alignment: Alignment.center,
              children: [
                PieChart(
                  PieChartData(
                    sectionsSpace: 2,
                    centerSpaceRadius: 45,
                    startDegreeOffset: -90,
                    sections: [
                      PieChartSectionData(
                        value: approvedPct,
                        title: '',
                        color: const Color(0xFF01A896),
                        radius: 28,
                        showTitle: false,
                      ),
                      PieChartSectionData(
                        value: expiredPct,
                        title: '',
                        color: const Color(0xFF64748B),
                        radius: 28,
                        showTitle: false,
                      ),
                      PieChartSectionData(
                        value: pendingPct,
                        title: '',
                        color: const Color(0xFFF59E0B),
                        radius: 28,
                        showTitle: false,
                      ),
                      PieChartSectionData(
                        value: rejectedPct,
                        title: '',
                        color: const Color(0xFFEF4444),
                        radius: 28,
                        showTitle: false,
                      ),
                    ],
                    borderData: FlBorderData(show: false),
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      total.toString(),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    const Text(
                      "TOTAL",
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 8,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          // Legend
          Expanded(
            child: Column(
              children: [
                _chartLegend(
                  "Approved",
                  "${approvedPct.toStringAsFixed(0)}%",
                  const Color(0xFF01A896),
                ),
                const SizedBox(height: 8),
                _chartLegend(
                  "Expired",
                  "${expiredPct.toStringAsFixed(0)}%",
                  const Color(0xFF64748B),
                ),
                const SizedBox(height: 8),
                _chartLegend(
                  "Pending",
                  "${pendingPct.toStringAsFixed(0)}%",
                  const Color(0xFFF59E0B),
                ),
                const SizedBox(height: 8),
                _chartLegend(
                  "Rejected",
                  "${rejectedPct.toStringAsFixed(0)}%",
                  const Color(0xFFEF4444),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _chartLegend(String label, String pct, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            ),
          ],
        ),
        Text(
          pct,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        ),
      ],
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 16,
        color: Color(0xFF1E293B),
      ),
    );
  }

  Widget _dateBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFD1FAE5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        _getFormattedDate(),
        style: const TextStyle(
          color: Color(0xFF01A896),
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildBottomNavBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      height: 70,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(35),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          IconButton(
            onPressed: () {
              _loadDashboardData();
            },
            icon: _navIcon(Icons.home_outlined, true),
          ),
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const InspectionHistoryPage(),
                ),
              );
            },
            icon: _navIcon(Icons.access_time, false),
          ),
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfilevitPage()),
              );
            },
            icon: _navIcon(Icons.person, false),
          ),
        ],
      ),
    );
  }

  Widget _navIcon(IconData icon, bool isActive) {
    return Icon(
      icon,
      color: isActive ? const Color(0xFF00A896) : Colors.grey.shade400,
      size: 28,
    );
  }
}
