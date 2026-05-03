import 'package:fishapp/picheur/profil.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';
import '../signin/cubit/authcubit.dart';
import 'homepage.dart';
import 'myBatches.dart';

class WeatherSafetypage extends StatefulWidget {
  const WeatherSafetypage({super.key});

  @override
  State<WeatherSafetypage> createState() => _WeatherSafetyState();
}

class _WeatherSafetyState extends State<WeatherSafetypage> {
  double? _temp;
  double? _wind;
  double? _visibility;
  double? _waveHeight;
  String? _highTide, _lowTide, _sunrise, _sunset, _lastUpdated = "";
  // ignore: unused_field
  bool _weatherLoaded = false;

  Future<void> _getWeather() async {
    try {
      // Vérifier les permissions avant de demander la position
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      Position position = await Geolocator.getCurrentPosition();

      final response = await http.get(
        Uri.parse(
          "https://api.openweathermap.org/data/2.5/weather?lat=${position.latitude}&lon=${position.longitude}&appid=00267594af2060e6f2b24e9db3d63478&units=metric",
        ),
      );

      final response1 = await http.get(
        Uri.parse(
          "https://marine-api.open-meteo.com/v1/marine?latitude=${position.latitude}&longitude=${position.longitude}&current=wave_height",
        ),
      );

      final response2 = await http.get(
        Uri.parse(
          "https://api.open-meteo.com/v1/forecast?latitude=${position.latitude}&longitude=${position.longitude}&daily=sunrise,sunset&timezone=auto",
        ),
      );

      final response3 = await http.get(
        Uri.parse(
          "https://api.stormglass.io/v2/tide/extremes/point?lat=${position.latitude}&&lng=${position.longitude}&type=high,low",
        ),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _temp = data["main"]["temp"];
          _wind = data["wind"]["speed"];
          _visibility = (data["visibility"] as int) / 1000;
          _lastUpdated = DateTime.now().toString();
          _weatherLoaded = true;
        });
      }

      if (response1.statusCode == 200) {
        final data1 = jsonDecode(response1.body);

        setState(() {
          _waveHeight = data1["current"]["wave_height"];
          _lastUpdated = DateTime.now().toString();
          _weatherLoaded = true;
        });
      }

      if (response2.statusCode == 200) {
        final data2 = jsonDecode(response2.body);

        setState(() {
          _sunrise = data2["daily"]["sunrise"][0];
          _sunset = data2["daily"]["sunset"][0];
          _lastUpdated = DateTime.now().toString();
          _weatherLoaded = true;
        });
      }

      if (response3.statusCode == 200) {
        final data3 = jsonDecode(response3.body);

        setState(() {
          _highTide = data3["data"]?[0]?["high"]?.toString();
          _lowTide = data3["data"]?[0]?["low"]?.toString();
          _lastUpdated = DateTime.now().toString();
          _weatherLoaded = true;
        });
      }
    } catch (e) {
      debugPrint("Error fetching weather: $e");
    }
  }

  String _getUpdatedTime() {
    if (_lastUpdated == null || _lastUpdated!.isEmpty) return "Updating...";

    final lastTime = DateTime.parse(_lastUpdated!);
    final difference = DateTime.now().difference(lastTime);

    if (difference.inMinutes < 1) return "Updated just now";
    if (difference.inMinutes < 60)
      return "Updated ${difference.inMinutes}m ago";
    return "Updated ${difference.inHours}h ago";
  }

  Future<void> _makeCall() async {
    final url = Uri.parse("tel:1548");
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  @override
  void initState() {
    super.initState();
    _getWeather();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F9),
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back),
          color: const Color(0xFF0F172A),
        ),
        title: const Text(
          "Weather & Safety",
          style: TextStyle(
            color: Color(0xFF0F172A),
            fontWeight: FontWeight.w700,
            fontSize: 24,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        shadowColor: Colors.black,
        elevation: 3,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "CURRENT WEATHER",
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                ),
                Text(
                  _getUpdatedTime(),
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: WeatherInfo(
                    title: "temp",
                    value: "${_temp ?? "--"}°C",
                    icon1: Icons.thermostat,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: WeatherInfo(
                    title: "wind",
                    value: "${_wind ?? "--"}m/s",
                    icon1: Icons.air_outlined,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: WeatherInfo(
                    title: "waves",
                    value: "${_waveHeight ?? "--"}m",
                    icon1: Icons.waves,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: WeatherInfo(
                    title: "visibility",
                    value: "${_visibility ?? "--"}km",
                    icon1: Icons.visibility,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text(
              "Navigation Map",
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 22),
            ),
            const SizedBox(height: 336),
            const SizedBox(height: 20),
            _buildSOSButtons(),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: cardInfo(
                    const Color(0xFF033F78),
                    Icons.waves_outlined,
                    "TIDE TIME",
                    "High",
                    _formatTime(_highTide),
                    "Low",
                    _formatTime(_lowTide),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: cardInfo(
                    const Color(0xFFF97316),
                    Icons.wb_sunny_outlined,
                    "DAILY LIGHT",
                    "RISE",
                    _formatTime(_sunrise),
                    "SET",
                    _formatTime(_sunset),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  String _formatTime(String? time) {
    if (time == null || time.length < 16) return "--:--";
    return time.substring(11, 16);
  }

  Widget _buildSOSButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: _makeCall,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(13),
              ),
            ),
            child: const Column(
              children: [
                Text(
                  "SOS",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text("EMERGENCY SOS", style: TextStyle(fontSize: 10)),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),
        _actionBtn(
          Icons.navigation_outlined,
          "Navigate to\nPort",
          const Color(0xFF0F172A),
          Colors.white,
        ),


      ],
    );
  }

  Widget _buildBottomNavBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      height: 70,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(35),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => HomePage(),
                ),
              );
            },
            child: _navIcon(Icons.home, false),
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MyBatchesPage(),
                ),
              );
            },
            child: _navIcon(Icons.anchor, false),
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => WeatherSafetypage(),
                ),
              );
            },
            child: _navIcon(Icons.remove_red_eye_outlined, true),
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProfilePage(),
                ),
              );
            },
            child: _navIcon(Icons.person_outline, false),
          ),
        ],
      ),
    );
  }

  Widget _navIcon(IconData icon, bool isActive) {
    return Icon(
      icon,
      color: isActive ? const Color(0xFF013D73) : Colors.grey.shade400,
      size: 28,
    );
  }
}

Widget _actionBtn(IconData icon, String label, Color bg, Color text) {
  return SizedBox(
    width: 200,
    height: 56,
    child: ElevatedButton(
      onPressed: () {},
      style: ElevatedButton.styleFrom(
        backgroundColor: bg,
        foregroundColor: text,
        padding: const EdgeInsets.all(10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: const Color(0xFF033F78)),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ),
  );
}

class WeatherInfo extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon1;
  const WeatherInfo({
    super.key,
    required this.title,
    required this.value,
    required this.icon1,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon1, color: const Color(0xFF033F78), size: 20),
              const SizedBox(width: 6),
              Text(
                title,
                style: const TextStyle(color: Color(0xFF64748B), fontSize: 13),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios_outlined,
                color: Color(0xFFA8A8A8),
                size: 14,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

Widget cardInfo(
    Color color,
    IconData icon,
    String title,
    String i1,
    String v1,
    String i2,
    String v2,
    ) {
  return Container(
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(
      color: const Color(0xFFF8FAFC),
      borderRadius: BorderRadius.circular(13),
      border: Border.all(color: const Color(0xFFE2E8F0), width: 0.5),
    ),
    child: Column(
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 15),
            const SizedBox(width: 6),
            Text(
              title,
              style: const TextStyle(
                color: Color(0xFF64748B),
                fontWeight: FontWeight.bold,
                fontSize: 10,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        _rowInfo(i1, v1),
        const SizedBox(height: 4),
        _rowInfo(i2, v2),
      ],
    ),
  );
}

Widget _rowInfo(String label, String value) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(
        label,
        style: const TextStyle(color: Color(0xFF64748B), fontSize: 12),
      ),
      Text(
        value,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
      ),
    ],
  );
}

class Block extends StatelessWidget {
  const Block({super.key});
  @override
  Widget build(BuildContext context) {
    return const SizedBox(height: 20);
  }
}
