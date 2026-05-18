import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import './userMan.dart';
import '../signin/cubit/authcubit.dart';
import '../signin/cubit/authstate.dart';

class HomepageadminPage extends StatefulWidget {
  const HomepageadminPage({super.key});

  @override
  State<HomepageadminPage> createState() => _HomeAdminPageState();
}

class _HomeAdminPageState extends State<HomepageadminPage> {
  @override
  void initState() {
    super.initState();
    context.read<AuthCubit>().fetchadmin();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final adminName = _extractAdminName(state);
        final batchVolume = _extractBatchVolume(state);
        final activities = _extractActivities(state);

        return Scaffold(
          appBar: AppBar(
            elevation: 0,
            backgroundColor: Colors.white,
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircleAvatar(
                backgroundColor: isDark
                    ? Colors.grey[800]
                    : const Color(0xFFE3F2FD),
                child: adminName.isNotEmpty
                    ? Text(
                        adminName[0].toUpperCase(),
                        style: TextStyle(
                          color: isDark
                              ? Colors.white
                              : const Color(0xFF013D73),
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : Icon(
                        Icons.person,
                        color: isDark ? Colors.white : const Color(0xFF013D73),
                        size: 20,
                      ),
              ),
            ),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Welcome back,",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                    fontWeight: FontWeight.normal,
                  ),
                ),
                Text(
                  adminName.isNotEmpty ? adminName : "Admin",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF011A33),
                  ),
                ),
              ],
            ),
          ),
          body: _buildBody(context, state, isDark, batchVolume, activities),
          bottomNavigationBar: _buildBottomNavBar(isDark, 0),
        );
      },
    );
  }

  Widget _buildBody(
    BuildContext context,
    AuthState state,
    bool isDark,
    List<Map<String, dynamic>> batchVolume,
    List<Map<String, dynamic>> activities,
  ) {
    if (state is AuthLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is AuthError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: Colors.red[300], size: 48),
            const SizedBox(height: 12),
            Text(state.message, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.read<AuthCubit>().fetchadmin(),
              child: const Text("Retry"),
            ),
          ],
        ),
      );
    }

    if (state is AdminLoaded) {
      final user = state.user;
      final stat = _dashboardStats(user);

      return RefreshIndicator(
        onRefresh: () async {
          await context.read<AuthCubit>().fetchadmin();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionHeader("Market Overview", subtitle: "Last 7 days"),
              const SizedBox(height: 12),
              _buildStatCard(
                isDark: isDark,
                icon: Icons.people_outline,
                iconBgColor: const Color(0xFFBAEAFF),
                iconColor: const Color(0xFF013D73),
                label: "Total Users",
                value: _safeString(stat['total_users']),
                badge: "+${_safeString(stat['user_growth'])}%",
                badgeBg: const Color(0xFFE8F5E9),
                badgeColor: Colors.green,
              ),
              const SizedBox(height: 12),
              _buildStatCard(
                isDark: isDark,
                icon: Icons.inventory_2_outlined,
                iconBgColor: const Color(0xFFFFF3E0),
                iconColor: const Color(0xFFF59E0B),
                label: "Total Batches",
                value: _safeString(stat['total_batches']),
                badge: "+${_safeString(stat['batch_growth'])}%",
                badgeBg: const Color(0xFFE8F5E9),
                badgeColor: Colors.green,
              ),
              const SizedBox(height: 12),
              _buildRevenueCard(user, isDark),
              const SizedBox(height: 24),
              _buildSectionHeader("Batch Volume", subtitle: "Last 7 days"),
              const SizedBox(height: 12),
              _buildBarChart(batchVolume),
              const SizedBox(height: 24),
              _buildSectionHeader("Batch Status", subtitle: "Last 7 days"),
              const SizedBox(height: 12),
              _buildDonutChart(user),
              const SizedBox(height: 24),
              _buildSectionHeader(
                "Fish Type Distribution",
                subtitle: "Last 7 days",
              ),
              const SizedBox(height: 12),
              _buildFishDistribution(user, isDark),
              const SizedBox(height: 24),
              _buildSectionHeader("Recent System Activity"),
              const SizedBox(height: 12),
              _buildActivityCard(activities, isDark),
              const SizedBox(height: 100),
            ],
          ),
        ),
      );
    }

    if (state is ProfileError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: Colors.red[300], size: 48),
            const SizedBox(height: 12),
            Text(
              state.message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.read<AuthCubit>().fetchadmin(),
              child: const Text("Retry"),
            ),
          ],
        ),
      );
    }

    return const Center(child: Text("No Admin Data Available"));
  }

  String _extractAdminName(AuthState state) {
    if (state is AdminLoaded) {
      final user = state.user;
      if (user['admin'] is Map<String, dynamic>) {
        return _safeString(user['admin']['full_name']);
      }
      return _safeString(user['full_name']);
    }
    return '';
  }

  List<Map<String, dynamic>> _extractBatchVolume(AuthState state) {
    if (state is AdminLoaded) {
      final raw = state.user['batch_volume'];
      if (raw is List) {
        return raw
            .map(
              (item) =>
                  item is Map<String, dynamic> ? item : <String, dynamic>{},
            )
            .toList();
      }
    }
    return [];
  }

  List<Map<String, dynamic>> _extractActivities(AuthState state) {
    if (state is AdminLoaded) {
      final raw = state.user['recent_activity'];
      if (raw is List) {
        return raw
            .map(
              (item) =>
                  item is Map<String, dynamic> ? item : <String, dynamic>{},
            )
            .toList();
      }
    }
    return [];
  }

  Map<String, dynamic> _dashboardStats(Map<String, dynamic> user) {
    return {
      'total_users': user['total_users'],
      'total_batches': user['total_batches'],
      'user_growth': user['deg_incresing'] ?? 0,
      'batch_growth': user['deg_batchs'] ?? 0,
      'total_revenue': user['total_revenue'],
    };
  }

  String _safeString(Object? value) {
    if (value == null) return '';
    return value.toString();
  }

  Widget _buildSectionHeader(String title, {String? subtitle}) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Color(0xFF001E40),
            fontWeight: FontWeight.w700,
            fontSize: 15,
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(width: 6),
          Text(
            "($subtitle)",
            style: TextStyle(color: Colors.grey[500], fontSize: 12),
          ),
        ],
      ],
    );
  }

  Widget _buildStatCard({
    required bool isDark,
    required IconData icon,
    required Color iconBgColor,
    required Color iconColor,
    required String label,
    required String value,
    required String badge,
    required Color badgeBg,
    required Color badgeColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: iconBgColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: badgeBg,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.arrow_upward, color: badgeColor, size: 12),
                    const SizedBox(width: 2),
                    Text(
                      badge,
                      style: TextStyle(
                        color: badgeColor,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(label, style: TextStyle(color: Colors.grey[500], fontSize: 13)),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : const Color(0xFF011A33),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRevenueCard(Map<String, dynamic> user, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF015F6B),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF015F6B).withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.account_balance_wallet_outlined,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: Colors.greenAccent,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 5),
                    const Text(
                      "LIVE",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            "Total Revenue",
            style: TextStyle(color: Colors.white70, fontSize: 13),
          ),
          const SizedBox(height: 4),
          Text(
            _safeString(user['total_revenue']),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBarChart(List<Map<String, dynamic>> batchVolume) {
    final values = batchVolume
        .map(
          (entry) => (entry['count'] is num)
              ? (entry['count'] as num).toDouble()
              : 0.0,
        )
        .toList();
    final labels = batchVolume
        .map((entry) => _shortDate(entry['date']?.toString() ?? ''))
        .toList();

    final defaultValues = [3.0, 1.5, 2.5, 1.0, 1.8, 2.0, 4.5];
    final chartValues = values.isNotEmpty ? values : defaultValues;
    final chartLabels = labels.length == chartValues.length
        ? labels
        : List.generate(chartValues.length, (i) => '');

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: SizedBox(
        height: 160,
        child: BarChart(
          BarChartData(
            gridData: FlGridData(show: false),
            borderData: FlBorderData(show: false),
            titlesData: FlTitlesData(
              leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 28,
                  getTitlesWidget: (value, meta) {
                    final index = value.toInt();
                    if (index < 0 || index >= chartLabels.length)
                      return const SizedBox();
                    return Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        chartLabels[index],
                        style: TextStyle(
                          fontSize: 9,
                          color: index == chartLabels.length - 1
                              ? const Color(0xFF013D73)
                              : Colors.grey,
                          fontWeight: index == chartLabels.length - 1
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            barGroups: List.generate(chartValues.length, (i) {
              return BarChartGroupData(
                x: i,
                barRods: [
                  BarChartRodData(
                    toY: chartValues[i],
                    color: i == chartValues.length - 1
                        ? const Color(0xFF013D73)
                        : const Color(0xFFB3D4F5),
                    width: 30,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ],
              );
            }),
          ),
        ),
      ),
    );
  }

  String _shortDate(String rawDate) {
    final parsed = DateTime.tryParse(rawDate);
    if (parsed != null) {
      return '${parsed.month}/${parsed.day}';
    }
    return rawDate.length >= 5 ? rawDate.substring(0, 5) : rawDate;
  }

  Widget _buildDonutChart(Map<String, dynamic> user) {
    final statusList =
        (user['batch_status'] as List<dynamic>?)
            ?.cast<Map<String, dynamic>>() ??
        [];
    final counts = <String, num>{
      'approved': 0,
      'expired': 0,
      'pending': 0,
      'rejected': 0,
    };
    for (final status in statusList) {
      final key = (status['status'] as String?)?.toLowerCase() ?? '';
      final value = status['count'];
      if (value is num) {
        counts[key] = (counts[key] ?? 0) + value;
      }
    }
    final totalCount = counts.values.fold<num>(0, (sum, item) => sum + item);

    String labelValue(num value) => totalCount > 0
        ? '${((value / totalCount) * 100).toStringAsFixed(0)}%'
        : '0%';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          SizedBox(
            height: 150,
            width: 150,
            child: Stack(
              alignment: Alignment.center,
              children: [
                PieChart(
                  PieChartData(
                    sectionsSpace: 3,
                    centerSpaceRadius: 45,
                    sections: [
                      PieChartSectionData(
                        value: counts['approved']?.toDouble() ?? 0.0,
                        color: const Color(0xFF0F6E56),
                        radius: 28,
                        showTitle: false,
                      ),
                      PieChartSectionData(
                        value: counts['expired']?.toDouble() ?? 0.0,
                        color: const Color(0xFF888780),
                        radius: 28,
                        showTitle: false,
                      ),
                      PieChartSectionData(
                        value: counts['pending']?.toDouble() ?? 0.0,
                        color: const Color(0xFFEF9F27),
                        radius: 28,
                        showTitle: false,
                      ),
                      PieChartSectionData(
                        value: counts['rejected']?.toDouble() ?? 0.0,
                        color: const Color(0xFFE24B4A),
                        radius: 28,
                        showTitle: false,
                      ),
                    ],
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _safeString(totalCount),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "TOTALLEDGER",
                      style: TextStyle(
                        fontSize: 7,
                        color: Colors.grey[500],
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              children: [
                _buildLegendItem(
                  color: const Color(0xFF0F6E56),
                  label: "Approved",
                  percent: labelValue(counts['approved'] ?? 0),
                ),
                _buildLegendItem(
                  color: const Color(0xFF888780),
                  label: "Expired",
                  percent: labelValue(counts['expired'] ?? 0),
                ),
                _buildLegendItem(
                  color: const Color(0xFFEF9F27),
                  label: "Pending",
                  percent: labelValue(counts['pending'] ?? 0),
                ),
                _buildLegendItem(
                  color: const Color(0xFFE24B4A),
                  label: "Rejected",
                  percent: labelValue(counts['rejected'] ?? 0),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem({
    required Color color,
    required String label,
    required String percent,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(label, style: const TextStyle(fontSize: 13))),
          Text(
            percent,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildFishDistribution(Map<String, dynamic> user, bool isDark) {
    final rawList = (user['fish_distribution'] as List<dynamic>?) ?? [];
    final fishData = <Map<String, dynamic>>[];
    num total = 0;

    for (final item in rawList) {
      if (item is Map<String, dynamic>) {
        final count = item['count'];
        if (count is num) {
          total += count;
          fishData.add({
            'name': _safeString(item['fish_name']).toUpperCase(),
            'count': count,
            'color': const Color(0xFF0F6E56),
          });
        }
      }
    }

    if (fishData.isEmpty) {
      fishData.addAll([
        {"name": "SARDINE", "count": 45, "color": const Color(0xFF0F6E56)},
        {"name": "SALMON", "count": 30, "color": const Color(0xFF0F6E56)},
        {"name": "TUNA", "count": 16, "color": const Color(0xFF888780)},
        {"name": "SEA BASS", "count": 10, "color": const Color(0xFFE24B4A)},
        {"name": "OTHER", "count": 5, "color": const Color(0xFF888780)},
      ]);
      total = 106;
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: fishData.map((fish) {
          final pct = total > 0 ? (fish['count'] as num) / total * 100 : 0;
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      fish['name'],
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                        color: Colors.grey[600],
                      ),
                    ),
                    Text(
                      '${pct.toStringAsFixed(1)}%',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: pct / 100,
                    minHeight: 6,
                    backgroundColor: isDark ? Colors.white10 : Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      fish['color'] as Color,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildActivityCard(
    List<Map<String, dynamic>> activities,
    bool isDark,
  ) {
    final firstActivities = activities.take(3).toList();
    if (firstActivities.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Center(child: Text("No recent activity available.")),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: List.generate(firstActivities.length, (index) {
          final activity = firstActivities[index];
          final title = _safeString(activity['title']);
          final subtitle = _safeString(activity['message']);
          final time = _formatActivityTime(activity['created_at']);
          final type = _activityType(title);

          return Column(
            children: [
              _buildActivityItem(
                iconBg: type.iconBg,
                iconBorder: type.iconBorder,
                icon: type.icon,
                iconColor: type.iconColor,
                title: title,
                subtitle: subtitle,
                time: time,
                isLast: index == firstActivities.length - 1,
              ),
              if (index < firstActivities.length - 1) const Divider(height: 1),
            ],
          );
        }),
      ),
    );
  }

  _ActivityIcon _activityType(String title) {
    if (title.toLowerCase().contains('approved')) {
      return _ActivityIcon(
        iconBg: Colors.green.withOpacity(0.1),
        iconBorder: Colors.green.withOpacity(0.3),
        icon: Icons.check_circle_outline,
        iconColor: Colors.green,
      );
    }
    if (title.toLowerCase().contains('rejected')) {
      return _ActivityIcon(
        iconBg: Colors.red.withOpacity(0.1),
        iconBorder: Colors.red.withOpacity(0.3),
        icon: Icons.cancel_outlined,
        iconColor: Colors.red,
      );
    }
    return _ActivityIcon(
      iconBg: Colors.purple.withOpacity(0.1),
      iconBorder: Colors.purple.withOpacity(0.3),
      icon: Icons.person_add_alt_outlined,
      iconColor: Colors.purple,
    );
  }

  String _formatActivityTime(Object? raw) {
    if (raw is String && raw.isNotEmpty) {
      final parsed = DateTime.tryParse(raw);
      if (parsed != null) {
        return '${parsed.hour.toString().padLeft(2, '0')}:${parsed.minute.toString().padLeft(2, '0')}';
      }
      return raw;
    }
    return '';
  }

  Widget _buildActivityItem({
    required Color iconBg,
    required Color iconBorder,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required String time,
    bool isLast = false,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: isLast ? 0 : 4),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: iconBg,
            border: Border.all(color: iconBorder),
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        title: Text(
          title,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: TextStyle(fontSize: 12, color: Colors.grey[500]),
            ),
            const SizedBox(height: 2),
            Text(
              time.toUpperCase(),
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey[400],
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavBar(bool isDark, int activeIndex) {
    return Container(
      margin: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      height: 70,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
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
            onPressed: () {},
            icon: Icon(
              Icons.home,
              color: activeIndex == 0
                  ? (isDark ? const Color(0xFF023E77) : const Color(0xFF013D73))
                  : (isDark ? Colors.white54 : Colors.grey),
              size: 28,
            ),
          ),
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => UserManagementPage()),
              );
            },
            icon: Icon(
              Icons.people_outline,
              color: activeIndex == 1
                  ? (isDark ? const Color(0xFF023E77) : const Color(0xFF013D73))
                  : (isDark ? Colors.white54 : Colors.grey),
              size: 26,
            ),
          ),
          // IconButton(
          //   onPressed: () {},
          //   icon: Icon(
          //     Icons.person_outline,
          //     color: activeIndex == 2
          //         ? (isDark ? const Color(0xFF023E77) : const Color(0xFF013D73))
          //         : (isDark ? Colors.white54 : Colors.grey),
          //     size: 28,
          //   ),
          // ),
        ],
      ),
    );
  }
}

class _ActivityIcon {
  final Color iconBg;
  final Color iconBorder;
  final IconData icon;
  final Color iconColor;

  _ActivityIcon({
    required this.iconBg,
    required this.iconBorder,
    required this.icon,
    required this.iconColor,
  });
}
