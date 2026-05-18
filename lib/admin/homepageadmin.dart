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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundColor: isDark
                ? Colors.grey[800]
                : const Color(0xFFE3F2FD),
            child: Icon(Icons.person,
                color: isDark ? Colors.white : const Color(0xFF013D73),
                size: 20),
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
              "Mr. Ahmed",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF011A33),
              ),
            ),
          ],
        ),
      ),
      body: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, state) {

          // ─── Chargement ─────────────────────────────
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
                  Text(
                    state.message,  // ← affiche "No token found"
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

          // ─── Données chargées ────────────────────────
          if (state is AdminLoaded) {
            final user = state.user;

            return RefreshIndicator(
              onRefresh: () async {
                await context.read<AuthCubit>().fetchadmin();
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    // ─── Section Market Overview ───────
                    _buildSectionHeader(
                      "Market Overview",
                      subtitle: "Last 7 days",
                    ),
                    const SizedBox(height: 12),

                    // Carte Total Users
                    _buildStatCard(
                      isDark: isDark,
                      icon: Icons.people_outline,
                      iconBgColor: const Color(0xFFBAEAFF),
                      iconColor: const Color(0xFF013D73),
                      label: "Total Users",
                      value: user["infousers"],
                      badge: "+${user["deg_incresing"]}%",
                      badgeBg: const Color(0xFFE8F5E9),
                      badgeColor: Colors.green,
                    ),
                    const SizedBox(height: 12),

                    // Carte Total Batches
                    _buildStatCard(
                      isDark: isDark,
                      icon: Icons.inventory_2_outlined,
                      iconBgColor: const Color(0xFFFFF3E0),
                      iconColor: const Color(0xFFF59E0B),
                      label: "Total Batches",
                      value: user["total_batchs"],
                      badge: "+${user["deg_batchs"]}%",
                      badgeBg: const Color(0xFFE8F5E9),
                      badgeColor: Colors.green,
                    ),
                    const SizedBox(height: 12),

                    // Carte Total Revenue (fond teal)
                    _buildRevenueCard(user),
                    const SizedBox(height: 24),

                    // ─── Section Batch Volume ───────────
                    _buildSectionHeader(
                      "Batch Volume",
                      subtitle: "Last 7 days",
                    ),
                    const SizedBox(height: 12),
                    _buildBarChart(),
                    const SizedBox(height: 24),

                    // ─── Section Batch Status ───────────
                    _buildSectionHeader(
                      "Batch Status",
                      subtitle: "Last 7 days",
                    ),
                    const SizedBox(height: 12),
                    _buildDonutChart(user),
                    const SizedBox(height: 24),

                    // ─── Section Fish Distribution ──────
                    _buildSectionHeader(
                      "Fish Type Distribution",
                      subtitle: "Last 7 days",
                    ),
                    const SizedBox(height: 12),
                    _buildFishDistribution(user, isDark),
                    const SizedBox(height: 24),

                    // ─── Section Recent Activity ────────
                    _buildSectionHeader("Recent System Activity"),
                    const SizedBox(height: 12),
                    _buildActivityCard(user, isDark),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            );
          }

          // ─── Erreur ──────────────────────────────────
          if (state is ProfileError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline,
                      color: Colors.red[300], size: 48),
                  const SizedBox(height: 12),
                  Text(state.message,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.grey)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () =>
                        context.read<AuthCubit>().fetchadmin(),
                    child: const Text("Retry"),
                  ),
                ],
              ),
            );
          }

          return const Center(child: Text("No Admin Data Available"));
        },
      ),
      bottomNavigationBar: _buildBottomNavBar(isDark),
    );
  }

  // ─── En-tête de section ──────────────────────────────────
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
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 12,
            ),
          ),
        ],
      ],
    );
  }

  // ─── Carte statistique réutilisable ─────────────────────
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
              // Icône
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: iconBgColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              // Badge pourcentage
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: badgeBg,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.arrow_upward,
                        color: badgeColor, size: 12),
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
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 13,
            ),
          ),
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

  // ─── Carte Revenue (fond teal) ───────────────────────────
  Widget _buildRevenueCard(Map<String, dynamic> user) {
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
              // Icône monnaie
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
              // Badge LIVE
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6, height: 6,
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
            style: TextStyle(
              color: Colors.white70,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            user["total_revenu"],
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

  // ─── Graphique barres ────────────────────────────────────
  Widget _buildBarChart() {
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
              leftTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false)),
              topTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false)),
              rightTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false)),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 28,
                  getTitlesWidget: (value, meta) {
                    const days = [
                      'MON','TUE','WED','THU','FRI','SAT','TODAY'
                    ];
                    final isToday = value.toInt() == 6;
                    return Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        days[value.toInt()],
                        style: TextStyle(
                          fontSize: 9,
                          color: isToday
                              ? const Color(0xFF013D73)
                              : Colors.grey,
                          fontWeight: isToday
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            barGroups: List.generate(7, (i) {
              // données simulées
              final values = [3.0, 1.5, 2.5, 1.0, 1.8, 2.0, 4.5];
              return BarChartGroupData(
                x: i,
                barRods: [
                  BarChartRodData(
                    toY: values[i],
                    color: i == 6
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

  // ─── Graphique Donut ─────────────────────────────────────
  Widget _buildDonutChart(Map<String, dynamic> user) {
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
          // ─── Cercle donut ───────────────────────────
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
                        value: (user["batch_approved"] as num).toDouble(),
                        color: const Color(0xFF0F6E56),
                        radius: 28,
                        showTitle: false,
                      ),
                      PieChartSectionData(
                        value: (user["batch_expired"] as num).toDouble(),
                        color: const Color(0xFF888780),
                        radius: 28,
                        showTitle: false,
                      ),
                      PieChartSectionData(
                        value: (user["batch_pending"] as num).toDouble(),
                        color: const Color(0xFFEF9F27),
                        radius: 28,
                        showTitle: false,
                      ),
                      PieChartSectionData(
                        value: (user["batch_rejected"] as num).toDouble(),
                        color: const Color(0xFFE24B4A),
                        radius: 28,
                        showTitle: false,
                      ),
                    ],
                  ),
                ),
                // Texte au centre
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      user["batch"],
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
          // ─── Légende ────────────────────────────────
          Expanded(
            child: Column(
              children: [
                _buildLegendItem(
                  color: const Color(0xFF0F6E56),
                  label: "Approved",
                  percent: user["approved_label"],
                ),
                _buildLegendItem(
                  color: const Color(0xFF888780),
                  label: "Expired",
                  percent: user["expired_label"],
                ),
                _buildLegendItem(
                  color: const Color(0xFFEF9F27),
                  label: "Pending",
                  percent: user["pending_label"],
                ),
                _buildLegendItem(
                  color: const Color(0xFFE24B4A),
                  label: "Rejected",
                  percent: user["rejected_label"],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Item de légende ────────────────────────────────────
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
            width: 10, height: 10,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 13),
            ),
          ),
          Text(
            percent,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Distribution par type de poisson ───────────────────
  Widget _buildFishDistribution(
      Map<String, dynamic> user, bool isDark) {
    final List<Map<String, dynamic>> fishData = [
      {
        "name": "SARDINE",
        "pct": (user["sardine_pct"] as num).toDouble(),
        "label": user["sardine_label"],
        "color": const Color(0xFF0F6E56),
      },
      {
        "name": "SALMON",
        "pct": (user["salmon_pct"] as num).toDouble(),
        "label": user["salmon_label"],
        "color": const Color(0xFF0F6E56),
      },
      {
        "name": "TUNA",
        "pct": (user["tuna_pct"] as num).toDouble(),
        "label": user["tuna_label"],
        "color": const Color(0xFF888780),
      },
      {
        "name": "SEA BASS",
        "pct": (user["seabass_pct"] as num).toDouble(),
        "label": user["seabass_label"],
        "color": const Color(0xFFE24B4A),
      },
      {
        "name": "OTHER",
        "pct": (user["other_pct"] as num).toDouble(),
        "label": user["other_label"],
        "color": const Color(0xFF888780),
      },
    ];

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
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      fish["name"],
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                        color: Colors.grey[600],
                      ),
                    ),
                    Text(
                      fish["label"],
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: fish["pct"] / 100,
                    minHeight: 6,
                    backgroundColor: isDark
                        ? Colors.white10
                        : Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      fish["color"],
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

  // ─── Activité récente ────────────────────────────────────
  Widget _buildActivityCard(
      Map<String, dynamic> user, bool isDark) {
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
        children: [
          // ─── Batch Approved ───────────────────────
          _buildActivityItem(
            iconBg: Colors.green.withOpacity(0.1),
            iconBorder: Colors.green.withOpacity(0.3),
            icon: Icons.check_circle_outline,
            iconColor: Colors.green,
            title: "Batch #7819 Approved",
            subtitle: "Vet ID: ${user["vet_id"]}  •  Dr. ${user["fulnamevet"]}",
            time: "${user["time"]} ago",
          ),

          const Divider(height: 1),

          // ─── Batch Rejected ───────────────────────
          _buildActivityItem(
            iconBg: Colors.red.withOpacity(0.1),
            iconBorder: Colors.red.withOpacity(0.3),
            icon: Icons.cancel_outlined,
            iconColor: Colors.red,
            title: "Batch #7819 Rejected",
            subtitle: "Vet ID: ${user["vet_id"]}  •  Dr. ${user["fulnamevet"]}",
            time: "${user["time"]} ago",
          ),

          const Divider(height: 1),

          // ─── New Buyer ────────────────────────────
          _buildActivityItem(
            iconBg: Colors.purple.withOpacity(0.1),
            iconBorder: Colors.purple.withOpacity(0.3),
            icon: Icons.person_add_alt_outlined,
            iconColor: Colors.purple,
            title: "New Buyer Registered",
            subtitle: "Atlantic Logistics Ltd  •  Cape Town Hub",
            time: "${user["time_reg"]} ago",
            isLast: true,
          ),
        ],
      ),
    );
  }

  // ─── Item d'activité réutilisable ────────────────────────
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
      padding: EdgeInsets.symmetric(
          vertical: isLast ? 0 : 4),
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
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[500],
              ),
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

  // ─── Barre de navigation ─────────────────────────────────
  Widget _buildBottomNavBar(bool isDark) {
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
              color: isDark
                  ? const Color(0xFF023E77)
                  : const Color(0xFF013D73),
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
              color: isDark ? Colors.white54 : Colors.grey,
              size: 26,
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: Icon(
              Icons.person_outline,
              color: isDark ? Colors.white54 : Colors.grey,
              size: 28,
            ),
          ),
        ],
      ),
    );
  }
}