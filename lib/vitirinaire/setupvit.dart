import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'profilevit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

import '../signin/cubit/authcubit.dart';
import '../signin/cubit/authstate.dart';

class SetupVitpage extends StatefulWidget {
  const SetupVitpage({super.key});

  @override
  State<SetupVitpage> createState() => _SetupVitpageState();
}

class _SetupVitpageState extends State<SetupVitpage> {
  final _fullNameVitController = TextEditingController();
  final _nationalIdVitController = TextEditingController();
  final _phoneVitController = TextEditingController();
  final _emailVitController = TextEditingController();
  final _specializationController = TextEditingController();
  final _registrationVitController = TextEditingController();
  final _licenseVitController = TextEditingController();
  final _expiryVitController = TextEditingController();
  File? _fishingLicenseFileVit;
  File? _idcardFileVit;

  // ✅ متغيرات نسبة الإكمال
  double _completionPercent = 0.0;
  int _filledFields = 0;
  final int _totalFields = 5;  // عدد الحقول النصية (بدون الملفات)
  late List<TextEditingController> _textControllers;

  @override
  void initState() {
    super.initState();
    // ✅ تهيئة قائمة الحقول النصية
    _textControllers = [
      _fullNameVitController,
      _nationalIdVitController,
      _phoneVitController,
      _specializationController,
      _licenseVitController,
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
      if (_fishingLicenseFileVit != null) filledFiles++;
      if (_idcardFileVit != null) filledFiles++;
      
      // المجموع: 5 حقول نصية + 2 ملفات = 7 عناصر كاملة
      _filledFields = filledTextFields + filledFiles;
      _completionPercent = _filledFields / 7;  // 7 = total items (5 text + 2 files)
    });
  }

  @override
  void dispose() {
    // ✅ إزالة المستمعين عند الخروج
    for (var controller in _textControllers) {
      controller.removeListener(_updateCompletionPercent);
    }
    _fullNameVitController.dispose();
    _nationalIdVitController.dispose();
    _phoneVitController.dispose();
    _emailVitController.dispose();
    _specializationController.dispose();
    _registrationVitController.dispose();
    _licenseVitController.dispose();
    _expiryVitController.dispose();
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
              _fishingLicenseFileVit = selectedFile;
              break;
            case "idcard":
              _idcardFileVit = selectedFile;
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
    // ✅ التحقق من الحقول المطلوبة والملفات
    if (_fullNameVitController.text.isEmpty || 
        _specializationController.text.isEmpty || 
        _licenseVitController.text.isEmpty ||
        _fishingLicenseFileVit == null ||
        _idcardFileVit == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all required fields and upload documents")),
      );
      return;
    }

    // ✅ فقط إرسال البيانات إلى الخادم (بدون تنقل)
    context.read<AuthCubit>().submitSetupVit(
      fullNameVit: _fullNameVitController.text.trim(),
      nationalIdVit: _nationalIdVitController.text.trim(),
      phoneVit: _phoneVitController.text.trim(),
      specialization: _specializationController.text.trim(),
      registrationNumberVit: _registrationVitController.text.trim(),
      licenseNumberVit: _licenseVitController.text.trim(),
      expiryDateVit: _expiryVitController.text.trim(),
      fishingLicenseVit: _fishingLicenseFileVit,
      Idcard: _idcardFileVit,
    );
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = const Color(0xFF01A896);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text("Setup", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF011A33))),
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
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => ProfilevitPage()));
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          if (state is SetupLoading) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF01A896)));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ✅ Profile Completion Card مع نسبة إكمال ديناميكية
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
                          Text("Profile Completion", style: TextStyle(color: primaryColor, fontWeight: FontWeight.w600, fontSize: 14)),
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
                        progressColor: primaryColor,
                        barRadius: const Radius.circular(10),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "$_filledFields of 7 fields completed",
                        style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Section 1: Personal Information
                _buildSection(
                  number: "1",
                  title: "Personal Information",
                  children: [
                    _label("Full Name *"),
                    customTextField("e.g. Dr Ahmed ..", _fullNameVitController),
                    const SizedBox(height: 16),
                    _label("National ID / Passport"),
                    customTextField("ID Number", _nationalIdVitController),
                    const SizedBox(height: 16),
                    _label("Phone Number"),
                    customTextField("+213 674854088", _phoneVitController),
                  ],
                ),

                const SizedBox(height: 20),

                // Section 2: Licenses & Documents
                _buildSection(
                  number: "2",
                  title: "Licenses & Documents",
                  children: [
                    _label("Specialization *"),
                    customTextField("eg. Aquatic Pathology", _specializationController),
                    const SizedBox(height: 16),
                    _label("Primary License Number *"),
                    customTextField("LIC-00-1122", _licenseVitController),
                    const SizedBox(height: 16),
                    _label("Expiry Date"),
                    customTextField("YYYY-MM-DD", _expiryVitController),
                    const SizedBox(height: 24),
                    const Text(
                      "Required Uploads (PDF or JPG) *",
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF011A33)),
                    ),
                    const SizedBox(height: 16),
                    _buildUploadTile(
                      Icons.description, 
                      "Fishing License *", 
                      _fishingLicenseFileVit, 
                      () => _pickFile("license"),
                      primaryColor,
                    ),
                    const SizedBox(height: 12),
                    _buildUploadTile(
                      Icons.directions_boat, 
                      "ID Card *", 
                      _idcardFileVit, 
                      () => _pickFile("idcard"),
                      primaryColor,
                    ),
                  ],
                ),

                const SizedBox(height: 32),
                _buildCompleteButton(primaryColor),
                const SizedBox(height: 24),
                _buildFooterText(),
                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSection({required String number, required String title, required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 15, 
                backgroundColor: const Color(0xFF01A896), 
                child: Text(number, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold))
              ),
              const SizedBox(width: 12),
              Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF011A33))),
            ],
          ),
          const SizedBox(height: 24),
          ...children,
        ],
      ),
    );
  }

  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 8), 
    child: Text(text, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF4A5568)))
  );

  Widget _buildUploadTile(IconData icon, String title, File? file, VoidCallback onTap, Color primaryColor) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Icon(icon, color: primaryColor),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF011A33))),
                Text(
                  file != null ? file.path.split('/').last : "Not uploaded",
                  style: TextStyle(color: file != null ? Colors.green : Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: onTap,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE0F2F1),
              foregroundColor: primaryColor,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text(file != null ? "Change" : "Upload", style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildCompleteButton(Color color) {
    // ✅ الزر غير نشط حتى يتم ملء جميع الحقول والملفات
    bool isFormComplete = _filledFields == 7;  // 7 = total items (5 text + 2 files)
    
    return ElevatedButton(
      onPressed: isFormComplete ? _submit : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        minimumSize: const Size(double.infinity, 56),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 2,
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

  Widget _buildFooterText() {
    return Center(
      child: Column(
        children: [
          const Text("By completing setup, you agree to \"Let's Fishing\"", style: TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () {},
                child: const Text("Terms of Maritime Service", style: TextStyle(color: Color(0xFF01A896), decoration: TextDecoration.underline, fontSize: 12, fontWeight: FontWeight.bold)),
              ),
              const Text(" and Safety Guidelines.", style: TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
        ],
      ),
    );
  }
}

// ✅ دوال مساعدة خارج الكلاس
Widget customTextField(String hint, TextEditingController controller) {
  return TextField(
    controller: controller,
    decoration: InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
      filled: true,
      fillColor: const Color(0xFFF8FAFB),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
    ),
  );
}

Widget portTextField(String hint, TextEditingController controller) {
  return TextField(
    controller: controller,
    decoration: InputDecoration(
      prefixIcon: const Icon(Icons.location_on_outlined, color: Color(0xFF01A896)),
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
      filled: true,
      fillColor: const Color(0xFFF8FAFB),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
    ),
  );
}
