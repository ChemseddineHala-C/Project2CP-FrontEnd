import 'package:fishapp/consumer/interfaceconsumer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'homePage.dart';
import '../signin/cubit/authcubit.dart';
import '../signin/cubit/authstate.dart';

class SetupConspage extends StatefulWidget {
  const SetupConspage({super.key});

  @override
  State<SetupConspage> createState() => _SetupConpageState();
}

class _SetupConpageState extends State<SetupConspage> {
  final _fullNameConsController = TextEditingController();
  final _nationalIdConsController = TextEditingController();
  final _phoneConsController = TextEditingController();
  final _deleveryaddressConsController = TextEditingController();
  final _nearbyPortConsController = TextEditingController();

  // ✅ متغيرات نسبة الإكمال
  double _completionPercent = 0.0;
  int _filledFields = 0;
  final int _totalFields = 5;
  late List<TextEditingController> _allControllers;

  @override
  void initState() {
    super.initState();
    // ✅ تهيئة قائمة الحقول
    _allControllers = [
      _fullNameConsController,
      _nationalIdConsController,
      _phoneConsController,
      _deleveryaddressConsController,
      _nearbyPortConsController,
    ];
    
    // ✅ إضافة مستمعين لكل حقل
    for (var controller in _allControllers) {
      controller.addListener(_updateCompletionPercent);
    }
  }

  // ✅ دالة لحساب نسبة الإكمال
  void _updateCompletionPercent() {
    setState(() {
      _filledFields = _allControllers.where((c) => c.text.trim().isNotEmpty).length;
      _completionPercent = _filledFields / _totalFields;
    });
  }

  @override
  void dispose() {
    // ✅ إزالة المستمعين عند الخروج
    for (var controller in _allControllers) {
      controller.removeListener(_updateCompletionPercent);
    }
    _fullNameConsController.dispose();
    _nationalIdConsController.dispose();
    _phoneConsController.dispose();
    _deleveryaddressConsController.dispose();
    _nearbyPortConsController.dispose();
    super.dispose();
  }

  void _submit() {
    // ✅ التحقق من الحقول المطلوبة
    if (_fullNameConsController.text.isEmpty || _deleveryaddressConsController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all required fields")),
      );
      return;
    }

    // ✅ فقط إرسال البيانات إلى الخادم (بدون تنقل)
    context.read<AuthCubit>().submitSetupCons(
      fullNameCons: _fullNameConsController.text.trim(),
      nationalIdCons: _nationalIdConsController.text.trim(),
      phoneCons: _phoneConsController.text.trim(),
      delevryAddress: _deleveryaddressConsController.text.trim(),
      nearbyPortCons: _nearbyPortConsController.text.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryGold = const Color(0xFFD5A439);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFE5E7EB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text("Setup", style: TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.bold)),
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: Colors.black),
        ),
      ),
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is SetupSuccess) {
            // ✅ التنقل يحدث هنا بعد نجاح العملية
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomePage()));
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        builder: (context, state) {
          if (state is SetupLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile Completion Card مع نسبة إكمال ديناميكية
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Profile Completion", style: TextStyle(color: primaryGold, fontWeight: FontWeight.w600, fontSize: 14)),
                          Text(
                            "${(_completionPercent * 100).toInt()}%",
                            style: const TextStyle(color: Color(0xFF1E293B), fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      LinearPercentIndicator(
                        lineHeight: 8.0,
                        percent: _completionPercent,
                        padding: EdgeInsets.zero,
                        backgroundColor: const Color(0xFFE5EDFF),
                        progressColor: primaryGold,
                        barRadius: const Radius.circular(10),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "$_filledFields of $_totalFields fields completed",
                        style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Main Form Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _label("Full Name"),
                      _buildTextField("e.g. Ahmed ..", _fullNameConsController, isDark),
                      const SizedBox(height: 16),
                      _label("National ID / Passport"),
                      _buildTextField("ID Number", _nationalIdConsController, isDark),
                      const SizedBox(height: 16),
                      _label("Phone Number"),
                      _buildTextField("+213 674854088", _phoneConsController, isDark),
                      const SizedBox(height: 16),
                      _label("Delivery Address"),
                      _buildTextField("eg.. Rue El Wiam Sidi Bel Abbes", _deleveryaddressConsController, isDark),
                      const SizedBox(height: 16),
                      _label("Nearby Port"),
                      _buildTextField("eg .. Oran Port", _nearbyPortConsController, isDark),
                    ],
                  ),
                ),

                const SizedBox(height: 32),
                _buildCompleteButton(primaryGold),
                const SizedBox(height: 20),
                _buildFooterText(isDark),
                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _label(String text) => Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text, style: const TextStyle(color: Color(0xFF1E293B), fontSize: 14, fontWeight: FontWeight.bold))
  );

  Widget _buildTextField(String hint, TextEditingController controller, bool isDark) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.black),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
        filled: true,
        fillColor: const Color(0xFFF8FAFB),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
      ),
    );
  }

  Widget _buildCompleteButton(Color color) {
    // ✅ الزر غير نشط حتى يتم ملء جميع الحقول
    bool isFormComplete = _completionPercent == 1.0;
    
    return ElevatedButton(
      onPressed: isFormComplete ? _submit : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        minimumSize: const Size(double.infinity, 56),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        elevation: 0,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            isFormComplete ? "Complete Setup" : "Complete ${(_completionPercent * 100).toInt()}%",
            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 8),
          Icon(isFormComplete ? Icons.check_circle_outline : Icons.lock_outline, color: Colors.white),
        ],
      ),
    );
  }

  Widget _buildFooterText(bool isDark) {
    return Center(
      child: Column(
        children: [
          Text(
            "By completing setup, you agree to \"Let's Fishing\"",
            style: TextStyle(color: isDark ? Colors.white54 : Colors.grey, fontSize: 12),
            textAlign: TextAlign.center,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Terms of Service",
                style: TextStyle(color: const Color(0xFFD5A439), fontSize: 12, decoration: TextDecoration.underline),
              ),
              Text(
                " and Safety Guidelines.",
                style: TextStyle(color: isDark ? Colors.white54 : Colors.grey, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
