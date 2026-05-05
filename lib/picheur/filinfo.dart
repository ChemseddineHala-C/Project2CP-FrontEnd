import 'dart:io' hide Platform;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import '../signin/cubit/authcubit.dart';
import '../signin/cubit/authstate.dart';
import 'homepage.dart';

class Infopage extends StatefulWidget {
  const Infopage({super.key});

  @override
  State<Infopage> createState() => _InfopageState();
}

class _InfopageState extends State<Infopage> {
  final _fullNameController = TextEditingController();
  final _nationalIdController = TextEditingController();
  final _phoneController = TextEditingController();
  final _boatNameController = TextEditingController();
  final _registrationController = TextEditingController();
  final _homePortController = TextEditingController();
  final _licenseController = TextEditingController();
  final _expiryController = TextEditingController();

  File? _fishingLicenseFile;
  File? _boatRegistrationFile;
  File? _IdcardFile;

  // ✅ متغيرات نسبة الإكمال
  double _completionPercent = 0.0;
  int _filledFields = 0;
  final int _totalFields = 8;  // 5 حقول نصية + 3 ملفات
  late List<TextEditingController> _textControllers;

  @override
  void initState() {
    super.initState();
    // ✅ تهيئة قائمة الحقول النصية
    _textControllers = [
      _fullNameController,
      _nationalIdController,
      _phoneController,
      _boatNameController,
      _registrationController,
      _homePortController,
      _licenseController,
      _expiryController,
    ];
    
    // ✅ إضافة مستمعين لكل حقل نصي
    for (var controller in _textControllers) {
      controller.addListener(_updateCompletionPercent);
    }
  }

  // ✅ دالة لحساب نسبة الإكمال تشمل الحقول النصية + الملفات
  void _updateCompletionPercent() {
    setState(() {
      // حساب الحقول النصية المملوءة
      int filledTextFields = _textControllers.where((c) => c.text.trim().isNotEmpty).length;
      
      // حساب الملفات المرفوعة
      int filledFiles = 0;
      if (_fishingLicenseFile != null) filledFiles++;
      if (_boatRegistrationFile != null) filledFiles++;
      if (_IdcardFile != null) filledFiles++;
      
      // المجموع: 8 حقول نصية + 3 ملفات = 11 عنصر كامل
      _filledFields = filledTextFields + filledFiles;
      _completionPercent = _filledFields / 11;  // 11 = total items (8 text + 3 files)
    });
  }

  @override
  void dispose() {
    // ✅ إزالة المستمعين عند الخروج
    for (var controller in _textControllers) {
      controller.removeListener(_updateCompletionPercent);
    }
    _fullNameController.dispose();
    _nationalIdController.dispose();
    _phoneController.dispose();
    _boatNameController.dispose();
    _registrationController.dispose();
    _homePortController.dispose();
    _licenseController.dispose();
    _expiryController.dispose();
    super.dispose();
  }

  Future<void> _pickFile(String type) async {
    try {
      FilePickerResult? result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
      );

      if (result != null && result.files.single.path != null) {
        File selectedFile = File(result.files.single.path!);

        setState(() {
          switch (type) {
            case "license":
              _fishingLicenseFile = selectedFile;
              break;
            case "boat":
              _boatRegistrationFile = selectedFile;
              break;
            case "idcard":
              _IdcardFile = selectedFile;
              break;
          }
          _updateCompletionPercent();  // ✅ تحديث النسبة بعد رفع الملف
        });

        String fileName = result.files.single.name;
        String fileType = fileName.toLowerCase().contains('.pdf') ? 'PDF' : 'Image';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('OK $fileType: $fileName'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      } else {
        print('No file');
      }
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  void _submit() {
    // ✅ التحقق من جميع الحقول والملفات
    if (_fullNameController.text.isEmpty ||
        _nationalIdController.text.isEmpty ||
        _phoneController.text.isEmpty ||
        _homePortController.text.isEmpty ||
        _licenseController.text.isEmpty ||
        _expiryController.text.isEmpty ||
        _boatNameController.text.isEmpty ||
        _registrationController.text.isEmpty ||
        _fishingLicenseFile == null ||
        _boatRegistrationFile == null ||
        _IdcardFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please fill all required fields and upload documents"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // ✅ فقط إرسال البيانات إلى الخادم (بدون تنقل)
    context.read<AuthCubit>().submitSetup(
      fullName: _fullNameController.text.trim(),
      nationalId: _nationalIdController.text.trim(),
      phone: _phoneController.text.trim(),
      homePort: _homePortController.text.trim(),
      licenseNumber: _licenseController.text.trim(),
      expiryDate: _expiryController.text.trim(),
      boatName: _boatNameController.text.trim(),
      registrationNumber: _registrationController.text.trim(),
      fishingLicense: _fishingLicenseFile,
      boatRegistration: _boatRegistrationFile,
      Idcard: _IdcardFile,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? const Color(0xFF01A896) : const Color(0xFF033F78);

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text(
          "Setup",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : Colors.black),
        ),
      ),
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is SetupSuccess) {
            // ✅ التنقل يحدث هنا بعد نجاح العملية
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => HomePage()),
            );
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is SetupLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ✅ Profile Completion Card مع نسبة إكمال ديناميكية
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: isDark ? Colors.black26 : Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Profile Completion",
                            style: TextStyle(color: primaryColor, fontWeight: FontWeight.w600, fontSize: 14),
                          ),
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
                        backgroundColor: isDark ? Colors.white24 : const Color(0xFFE5EDFF),
                        progressColor: primaryColor,
                        barRadius: const Radius.circular(10),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "$_filledFields of 11 fields completed",
                        style: TextStyle(color: isDark ? Colors.white54 : const Color(0xFF94A3B8), fontSize: 12),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // ── Section 1 : Personal Info ──
                _buildSection(
                  isDark: isDark,
                  number: "1",
                  title: "Personal Information",
                  children: [
                    _label("Full Name *"),
                    customTextField("Enter your full name", _fullNameController, isDark),
                    const SizedBox(height: 16),
                    _label("National ID/Passport *"),
                    customTextField("Enter National Id", _nationalIdController, isDark),
                    const SizedBox(height: 16),
                    _label("Phone Number *"),
                    customTextField("Enter your phone number", _phoneController, isDark),
                  ],
                ),
                const SizedBox(height: 20),

                // ── Section 2 : Boat Details ──
                _buildSection(
                  isDark: isDark,
                  number: "2",
                  title: "Boat details",
                  children: [
                    _label("Boat Name *"),
                    customTextField("Enter your Boat name", _boatNameController, isDark),
                    const SizedBox(height: 16),
                    _label("Registration Number *"),
                    customTextField("Enter your Registration Number", _registrationController, isDark),
                    const SizedBox(height: 16),
                    _label("Home Port *"),
                    portTextField("City, Port Name", _homePortController, isDark),
                  ],
                ),
                const SizedBox(height: 20),

                // ── Section 3 : Licenses ──
                _buildSection(
                  isDark: isDark,
                  number: "3",
                  title: "Licenses & Documents",
                  children: [
                    _label("Fishing License Number *"),
                    customTextField("LIC-00-1122", _licenseController, isDark),
                    const SizedBox(height: 16),
                    _label("License Expiry Date *"),
                    customTextField("YYYY-MM-DD", _expiryController, isDark),
                    const SizedBox(height: 24),
                    Text(
                      "Required Uploads (PDF or JPG) *",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.cyanAccent : const Color(0xFF033F78),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildUploadTile(
                      Icons.description,
                      "Fishing License *",
                      _fishingLicenseFile,
                      () => _pickFile("license"),
                      isDark,
                    ),
                    const SizedBox(height: 12),
                    _buildUploadTile(
                      Icons.directions_boat,
                      "Boat Registration *",
                      _boatRegistrationFile,
                      () => _pickFile("boat"),
                      isDark,
                    ),
                    const SizedBox(height: 12),
                    _buildUploadTile(
                      Icons.add_card_outlined,
                      "ID Card *",
                      _IdcardFile,
                      () => _pickFile("idcard"),
                      isDark,
                    ),
                  ],
                ),
                const SizedBox(height: 30),

                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: state is SetupLoading ? null : (_filledFields == 11 ? _submit : null),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: state is SetupLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _filledFields == 11 ? "Complete Setup" : "Complete ${(_completionPercent * 100).toInt()}%",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Icon(
                                _filledFields == 11 ? Icons.check_circle_outline : Icons.lock_outline,
                                color: Colors.white,
                                size: 20,
                              ),
                            ],
                          ),
                  ),
                ),
                const SizedBox(height: 24),
                _buildFooterText(isDark),
                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSection({
    required bool isDark,
    required String number,
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black26 : Colors.black.withOpacity(0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 15,
                backgroundColor: isDark ? const Color(0xFF01A896) : const Color(0xFF033F78),
                child: Text(
                  number,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }

  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(
      text,
      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
    ),
  );

  Widget _buildUploadTile(
    IconData icon,
    String title,
    File? file,
    VoidCallback onTap,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.white12 : const Color(0xFFE2E8F0),
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: isDark ? Colors.cyanAccent : const Color(0xFF033F78),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  file != null ? file.path.split('/').last : "Not uploaded",
                  style: TextStyle(
                    color: file != null ? Colors.green : Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: onTap,
            style: ElevatedButton.styleFrom(
              backgroundColor: isDark ? Colors.white12 : const Color(0xFFE3F2FD),
              foregroundColor: isDark ? Colors.cyanAccent : const Color(0xFF033F78),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(file != null ? "Change" : "Upload"),
          ),
        ],
      ),
    );
  }

  Widget _buildFooterText(bool isDark) {
    return Center(
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          style: TextStyle(
            fontSize: 11,
            color: isDark ? Colors.white54 : Colors.grey,
          ),
          children: [
            const TextSpan(text: "By completing setup, you agree to Finder's "),
            TextSpan(
              text: "Terms of Maritime Service",
              style: TextStyle(
                color: isDark ? Colors.cyanAccent : const Color(0xFF0D2B55),
                decoration: TextDecoration.underline,
              ),
            ),
            const TextSpan(text: " and Safety Guidelines."),
          ],
        ),
      ),
    );
  }
}

Widget customTextField(
  String hint,
  TextEditingController controller,
  bool isDark,
) {
  return TextField(
    controller: controller,
    decoration: InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: isDark ? Colors.white.withOpacity(0.05) : const Color(0xFFF8FAFB),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    ),
  );
}

Widget portTextField(
  String hint,
  TextEditingController controller,
  bool isDark,
) {
  return TextField(
    controller: controller,
    decoration: InputDecoration(
      prefixIcon: const Icon(Icons.location_on, color: Colors.lightBlueAccent),
      hintText: hint,
      filled: true,
      fillColor: isDark ? Colors.white.withOpacity(0.05) : const Color(0xFFF8FAFB),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    ),
  );
}
