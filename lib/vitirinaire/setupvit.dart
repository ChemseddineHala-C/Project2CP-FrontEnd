import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:fishapp/vitirinaire/profilevit.dart';
import 'package:fishapp/vitirinaire/succesverfc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

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
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
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
      // ✅ الطريقة الصحيحة والمحدثة لاختيار الملفات (بدون .platform)
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
        });

        // رسالة تأكيد اختيار الملف
        String fileName = result.files.single.name;
        String fileType = fileName.toLowerCase().contains('.pdf')
            ? 'PDF'
            : 'Image';
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
  // Future<void> _pickFile(bool isLicense) async {
  //   final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
  //   if (pickedFile != null) {
  //     setState(() {
  //       if (isLicense) {
  //         _fishingLicenseFileVit = File(pickedFile.path);
  //       } else {
  //         _idcardFileVit = File(pickedFile.path);
  //       }
  //     });
  //   }
  // }

  void _submit() {
    if (_fullNameVitController.text.isEmpty || _specializationController.text.isEmpty || _licenseVitController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all required fields")),
      );
      return;
    }
    else{
      Navigator.push(context, MaterialPageRoute(builder: (context) => ProfilevitPage()));
    }

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
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text("Setup", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF011A33))),
        centerTitle: true,
      ),
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is SetupSuccess) {
            // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => VetInspectionPage(token: widget.token, batchId: "NEW-BATCH")));
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
                const SizedBox(height: 24),
                _buildSection(
                  number: "1",
                  title: "Personal Information",
                  children: [
                    _label("Full Name"),
                    customTextField("e.g. Dr Ahmed ..", _fullNameVitController),
                    const SizedBox(height: 16),
                    _label("National ID / Passport"),
                    customTextField("ID Number", _nationalIdVitController),
                    const SizedBox(height: 16),
                    _label("Phone Number"),
                    customTextField("+213 674854088", _phoneVitController),
                    const SizedBox(height: 16),
                    // _label("Email Address"),
                    // customTextField("Projet@esi-sba.dz", _emailVitController),
                  ],
                ),
                // const SizedBox(height: 20),
                // _buildSection(
                //   number: "2",
                //   title: "Boat Details",
                //   children: [
                //     _label("Boat Name"),
                //     customTextField("Sea's King", _boatNameVitController),
                //     const SizedBox(height: 16),
                //     _label("Registration Number"),
                //     customTextField("REG-8829-X", _registrationVitController),
                //     const SizedBox(height: 16),
                //   ],
                // ),
                const SizedBox(height: 20),
                _buildSection(
                  number: "3",
                  title: "Licenses & Documents",
                  children: [
                    _label("Specialization #"),
                    customTextField("LIC-00-1122", _specializationController),
                    const SizedBox(height: 16),
                    _label("Primary License #"),
                    customTextField("LIC-00-1122", _licenseVitController),
                    const SizedBox(height: 16),
                    _label("Expiry Date"),
                    customTextField("mm/dd/yyyy", _expiryVitController),
                    const SizedBox(height: 24),
                    const Text("Required Uploads (PDF or JPG)", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF011A33))),
                    const SizedBox(height: 16),
                    _buildUploadTile(Icons.description, "Fishing License", _fishingLicenseFileVit, () => _pickFile("license")),
                    const SizedBox(height: 12),
                    _buildUploadTile(Icons.directions_boat, "ID Card", _idcardFileVit, () => _pickFile("idcard")),
                  ],
                ),
                const SizedBox(height: 32),
                _buildCompleteButton(),
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
              CircleAvatar(radius: 15, backgroundColor: const Color(0xFF01A896), child: Text(number, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold))),
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

  Widget _label(String text) => Padding(padding: const EdgeInsets.only(bottom: 8), child: Text(text, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF4A5568))));

  Widget _buildUploadTile(IconData icon, String title, File? file, VoidCallback onTap) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF01A896)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF011A33))),
                Text(file != null ? file.path.split('/').last : "Not uploaded",
                    style: TextStyle(color: file != null ? Colors.green : Colors.grey, fontSize: 12)),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: onTap,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE0F2F1),
              foregroundColor: const Color(0xFF01A896),
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

  Widget _buildCompleteButton() {
    return ElevatedButton(
      onPressed: _submit,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF01A896),
        minimumSize: const Size(double.infinity, 56),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 2,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Text("Complete Setup", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(width: 8),
          Icon(Icons.check_circle_outline, color: Colors.white),
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
