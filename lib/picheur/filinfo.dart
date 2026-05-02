import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

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
  final _emailController = TextEditingController();
  final _boatNameController = TextEditingController();
  final _registrationController = TextEditingController();
  final _homePortController = TextEditingController();
  final _licenseController = TextEditingController();
  final _expiryController = TextEditingController();

  String _selectedvesselType = "Trawler";
  File? _fishingLicenseFile;
  File? _boatRegistrationFile;
  File? _IdcardFile;
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _fullNameController.dispose();
    _nationalIdController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _boatNameController.dispose();
    _registrationController.dispose();
    _homePortController.dispose();
    _licenseController.dispose();
    _expiryController.dispose();
    super.dispose();
  }

  // Future<void> _pickFile(bool isLicense) async {
  //   final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
  //   if (pickedFile != null) {
  //     setState(() {
  //       // if (isLicense) {
  //       //   _fishingLicenseFile = File(pickedFile.path);
  //       // } else {
  //       //   _boatRegistrationFile = File(pickedFile.path);
  //       // }
  //       if (type == "license") {
  //         _fishingLicenseFile = File(pickedFile.path);
  //       } else if (type == "boat") {
  //         _boatRegistrationFile = File(pickedFile.path);
  //       } else if (type == "idcard") {
  //         _IdcardFile = File(pickedFile.path);
  //       }
  //     });
  //   }
  // }
  Future<void> _pickFile(String type) async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        if (type == "license") {
          _fishingLicenseFile = File(pickedFile.path);
        } else if (type == "boat") {
          _boatRegistrationFile = File(pickedFile.path);
        } else if (type == "idcard") {
          _IdcardFile = File(pickedFile.path);
        }
      });
    }
  }

  // void _submit() {
  //   if (_fullNameController.text.isEmpty || _boatNameController.text.isEmpty || _licenseController.text.isEmpty || _expiryController.text.isEmpty || _fishingLicenseFile == null || _boatRegistrationFile == null || _homePortController.text.isEmpty || _registrationController.text.isEmpty || _phoneController.text.isEmpty || _emailController.text.isEmpty || _nationalIdController.text.isEmpty) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text("Please fill all required fields"), backgroundColor: Colors.red),
  //     );
  //     return;
  //   }
  //   else{
  //     Navigator.push(context, MaterialPageRoute(builder: (context) => HomePage()));
  //   }
  //
  //   context.read<AuthCubit>().submitSetup(
  //     fullName: _fullNameController.text.trim(),
  //     nationalId: _nationalIdController.text.trim(),
  //     phone: _phoneController.text.trim(),
  //     email: _emailController.text.trim(),
  //     boatName: _boatNameController.text.trim(),
  //     registrationNumber: _registrationController.text.trim(),
  //     vesselType: _selectedvesselType,
  //     homePort: _homePortController.text.trim(),
  //     licenseNumber: _licenseController.text.trim(),
  //     expiryDate: _expiryController.text.trim(),
  //     fishingLicense: _fishingLicenseFile,
  //     boatRegistration: _boatRegistrationFile,
  //     Idcard: _IdcardFile,
  //   );
  // }
  void _submit() {
    if (_fullNameController.text.isEmpty ||
        _boatNameController.text.isEmpty ||
        _licenseController.text.isEmpty ||
        _expiryController.text.isEmpty ||
        _fishingLicenseFile == null ||
        _boatRegistrationFile == null ||
        _IdcardFile == null ||         // ← ajouter
        _homePortController.text.isEmpty ||
        _registrationController.text.isEmpty ||
        _phoneController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _nationalIdController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all required fields"), backgroundColor: Colors.red),
      );
      return;
    }

    // ✅ Envoie au backend directement — le listener gère la navigation
    context.read<AuthCubit>().submitSetup(
      fullName: _fullNameController.text.trim(),
      nationalId: _nationalIdController.text.trim(),
      phone: _phoneController.text.trim(),
      email: _emailController.text.trim(),
      boatName: _boatNameController.text.trim(),
      registrationNumber: _registrationController.text.trim(),
      vesselType: _selectedvesselType,
      homePort: _homePortController.text.trim(),
      licenseNumber: _licenseController.text.trim(),
      expiryDate: _expiryController.text.trim(),
      fishingLicense: _fishingLicenseFile,
      boatRegistration: _boatRegistrationFile,
      Idcard: _IdcardFile,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text("Setup", style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black)),
        centerTitle: true,
      ),
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is SetupSuccess) {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HomePage()));
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.red),
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
                _buildSection(
                  isDark: isDark,
                  number: "1",
                  title: "Personal Information",
                  children: [
                    _label("Full Name"),
                    customTextField("Enter your full name", _fullNameController, isDark),
                    const SizedBox(height: 16),
                    _label("National ID/Passport"),
                    customTextField("Enter National Id", _nationalIdController, isDark),
                    const SizedBox(height: 16),
                    _label("Phone Number"),
                    customTextField("Enter your phone number", _phoneController, isDark),
                    const SizedBox(height: 16),
                    _label("Email Address"),
                    customTextField("Enter your Email address", _emailController, isDark),
                  ],
                ),
                const SizedBox(height: 20),
                _buildSection(
                  isDark: isDark,
                  number: "2",
                  title: "Boat details",
                  children: [
                    _label("Boat Name"),
                    customTextField("Enter your Boat name", _boatNameController, isDark),
                    const SizedBox(height: 16),
                    _label("Registration Number"),
                    customTextField("Enter your Registration Number", _registrationController, isDark),
                    const SizedBox(height: 16),
                    _label("Home Port"),
                    portTextField("City, Port Name", _homePortController, isDark),
                  ],
                ),
                const SizedBox(height: 20),
                _buildSection(
                  isDark: isDark,
                  number: "3",
                  title: "Licenses & Documents",
                  children: [
                    _label("Primary License"),
                    customTextField("LIC-00-1122", _licenseController, isDark),
                    const SizedBox(height: 16),
                    _label("Expiry Date"),
                    customTextField("mm/dd/yyyy", _expiryController, isDark),
                    const SizedBox(height: 24),
                    Text("Required Uploads (PDF or JPG)",
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: isDark ? Colors.cyanAccent : const Color(0xFF033F78))),
                    const SizedBox(height: 16),
                    _buildUploadTile(Icons.description, "Fishing License", _fishingLicenseFile, () => _pickFile("license"), isDark),
                    const SizedBox(height: 12),
                    _buildUploadTile(Icons.directions_boat, "Boat Registration", _boatRegistrationFile, () => _pickFile("boat"), isDark),
                    const SizedBox(height: 12),
                    _buildUploadTile(Icons.add_card_outlined, "ID_CARD", _IdcardFile, () => _pickFile("idcard"), isDark),
                  ],
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _submit, // Appel correct de la fonction d'envoi
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDark ? const Color(0xFF01A896) : const Color(0xFF033F78),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text("Complete Setup", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
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

  Widget _buildSection({required bool isDark, required String number, required String title, required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: isDark ? Colors.black26 : Colors.black.withOpacity(0.05),
              blurRadius: 10
          )
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
                  child: Text(number, style: const TextStyle(color: Colors.white))
              ),
              const SizedBox(width: 12),
              Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
      child: Text(text, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500))
  );

  Widget _buildUploadTile(IconData icon, String title, File? file, VoidCallback onTap, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? Colors.white12 : const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Icon(icon, color: isDark ? Colors.cyanAccent : const Color(0xFF033F78)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                Text(file != null ? file.path.split('/').last : "Not uploaded",
                    style: TextStyle(color: file != null ? Colors.green : Colors.grey, fontSize: 12)),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: onTap,
            style: ElevatedButton.styleFrom(
              backgroundColor: isDark ? Colors.white12 : const Color(0xFFE3F2FD),
              foregroundColor: isDark ? Colors.cyanAccent : const Color(0xFF033F78),
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
          style: TextStyle(fontSize: 11, color: isDark ? Colors.white54 : Colors.grey),
          children: [
            const TextSpan(text: "By completing setup, you agree to Finder's "),
            TextSpan(
                text: "Terms of Maritime Service",
                style: TextStyle(color: isDark ? Colors.cyanAccent : const Color(0xFF0D2B55), decoration: TextDecoration.underline)
            ),
            const TextSpan(text: " and Safety Guidelines."),
          ],
        ),
      ),
    );
  }
}

Widget customTextField(String hint, TextEditingController controller, bool isDark) {
  return TextField(
    controller: controller,
    decoration: InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: isDark ? Colors.white.withOpacity(0.05) : const Color(0xFFF8FAFB),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
    ),
  );
}

Widget portTextField(String hint, TextEditingController controller, bool isDark) {
  return TextField(
    controller: controller,
    decoration: InputDecoration(
      prefixIcon: const Icon(Icons.location_on, color: Colors.lightBlueAccent),
      hintText: hint,
      filled: true,
      fillColor: isDark ? Colors.white.withOpacity(0.05) : const Color(0xFFF8FAFB),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
    ),
  );
}
