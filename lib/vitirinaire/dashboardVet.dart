import 'package:flutter/material.dart';
import './PendingBatchesPage.dart';

class InspectorDashboard extends StatefulWidget {
  const InspectorDashboard({super.key});

  @override
  State<InspectorDashboard> createState() => _InspectorDashboardState();
}

class _InspectorDashboardState extends State<InspectorDashboard> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F9),
      // Implementing the Header as an AppBar to match your style
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: 80,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            const CircleAvatar(
              radius: 22,
              backgroundColor: Color(0xFFF1F5F9),
              child: Icon(Icons.waves, color: Color(0xFF023E77)), // Logo placeholder
            ),
            const SizedBox(width: 12),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("Welcome back,", style: TextStyle(color: Colors.grey, fontSize: 12)),
                Text(
                  "Dr. Ahmed",
                  style: TextStyle(
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
            // Notification Icon with Red Badge
            Stack(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.notifications, color: Colors.black, size: 22),
                ),
                const Positioned(
                  right: 8,
                  top: 8,
                  child: CircleAvatar(radius: 4, backgroundColor: Colors.red),
                )
              ],
            )
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStartInspectionButton(),
            const Block(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _sectionTitle("Today's Overview"),
                _dateBadge(),
              ],
            ),
            const SizedBox(height: 12),
            _buildStatsGrid(),
            const Block(),
            //_sectionTitle("Inspections Status (Last 7 days)"),
            //_buildDonutChartCard(),
            // const Block(),
            // _sectionTitle("Recent Inspections"),
            // _buildRecentInspectionTile("Lacha (Capt. Omar)", "Rejected", Colors.red, "10:30 AM"),
            // const SizedBox(height: 12),
            // _buildRecentInspectionTile("Sardine (Capt. Khaled)", "Approved", const Color(0xFF01A896), "09:15 AM"),
          ],
        ),
      ),
      //bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildStartInspectionButton() {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => const PendingBatchesPage()));
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF00A896), // Teal color from image_ccbcaf.png
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
            // The square icon container
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.add_box_rounded, // Matches the icon in image_ccbcaf.png
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
            // The chevron arrow
            const Icon(
              Icons.arrow_forward_ios,
              color: Colors.white,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 2.2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      children: [
        _statCard("N/A", "Pending", Icons.access_time, const Color(0xFFFEF3C7), const Color(0xFFD5A439)),
        _statCard("N/A", "Approved", Icons.check_circle_outline, const Color(0xFFD1FAE5), const Color(0xFF01A896)),
        _statCard("N/A", "Rejected", Icons.cancel_outlined, const Color(0xFFFEE2E2), Colors.red),
        _statCard("N/A", "Urgent", Icons.error_outline, const Color(0xFFFFEDEC), Colors.orange),
      ],
    );
  }

  Widget _statCard(String val, String label, IconData icon, Color bg, Color accent) {
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
            decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: accent, size: 20),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(val, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              Text(label, style: const TextStyle(color: Colors.grey, fontSize: 11)),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildDonutChartCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: Row(
        children: [
          // Simplified representation of the Donut Chart
          const Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                height: 100,
                width: 100,
                child: CircularProgressIndicator(value: 0.72, strokeWidth: 12, color: Color(0xFF01A896), backgroundColor: Color(0xFFF1F5F9)),
              ),
              Column(
                children: [
                  Text("157", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  Text("TOTAL", style: TextStyle(color: Colors.grey, fontSize: 8)),
                ],
              )
            ],
          ),
          const SizedBox(width: 30),
          const Expanded(
            child: Column(
              children: [
                //_chartLegend("Approved", "72%", Colors.green),
                //_chartLegend("Expired", "18%", Colors.blueGrey),
                //_chartLegend("Pending", "4%", Colors.yellow),
                //_chartLegend("Urgent", "6%", Colors.red),
              ],
            ),
          )
        ],
      ),
    );
  }

  static Widget _chartLegend(String label, String pct, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(children: [CircleAvatar(radius: 4, backgroundColor: color), const SizedBox(width: 8), Text(label, style: const TextStyle(fontSize: 11))]),
          Text(pct, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
        ],
      ),
    );
  }

  Widget _buildRecentInspectionTile(String title, String status, Color color, String time) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: [
          const Icon(Icons.set_meal, color: Colors.grey),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              Text("$status • $time", style: TextStyle(color: color, fontSize: 11)),
            ],
          ),
          const Spacer(),
          const Icon(Icons.chevron_right, color: Colors.grey),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1E293B)));
  }

  Widget _dateBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: const Color(0xFFD1FAE5), borderRadius: BorderRadius.circular(20)),
      child: const Text("Mar 19, 2026", style: TextStyle(color: Color(0xFF01A896), fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildBottomNavBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      height: 70,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(35),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20)],
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Icon(Icons.home, color: Color(0xFF01A896), size: 28),
          Icon(Icons.history, color: Colors.grey, size: 24),
          Icon(Icons.person_outline, color: Colors.grey, size: 24),
        ],
      ),
    );
  }
}

class Block extends StatelessWidget {
  const Block({super.key});
  @override
  Widget build(BuildContext context) => const SizedBox(height: 20);
}

