import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';  // ✅ changed from image_picker

import '../signin/cubit/authcubit.dart';
import '../signin/cubit/authstate.dart';

class EditProfilevitPage extends StatefulWidget {
  const EditProfilevitPage({super.key});

  @override
  State<EditProfilevitPage> createState() => _EditProfilevitPageState();
}

class _EditProfilevitPageState extends State<EditProfilevitPage> {
  final TextEditingController _namevitController = TextEditingController();
  final TextEditingController _phonevitController = TextEditingController();
  final TextEditingController _emailvitController = TextEditingController();
  final TextEditingController _homePortvitController = TextEditingController();
  final TextEditingController _boatNamevitController = TextEditingController();

  File? _imageFile;
  bool _isInitialized = false;  // ✅ removed ImagePicker

  @override
  void initState() {
    super.initState();
    context.read<AuthCubit>().fetchvitProfile();
  }

  @override
  void dispose() {
    _namevitController.dispose();
    _phonevitController.dispose();
    _emailvitController.dispose();
    _homePortvitController.dispose();
    _boatNamevitController.dispose();
    super.dispose();
  }

  // Future<void> _pickImage() async {
  //   try {
  //     final XFile? pickedFile = await _pickervit.pickImage(
  //       source: ImageSource.gallery,
  //       maxWidth: 1000,
  //       maxHeight: 1000,
  //       imageQuality: 85,
  //     );
  //     if (pickedFile != null) {
  //       setState(() {
  //         _imageFile = File(pickedFile.path);
  //       });
  //     }
  //   } catch (e) {
  //     debugPrint("Error picking image: $e");
  //   }
  // }
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
            case "profile_photo":
              _imageFile = selectedFile;
              break;
          }
        });
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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: const Text(
          "Edit Profile",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is ProfileLoaded) {
            _namevitController.text = state.user["full_name"] ?? "";
            _phonevitController.text = state.user["phone_number"] ?? "";
            _emailvitController.text = state.user["email"] ?? "";
            _homePortvitController.text = state.user["home_port"] ?? "";
            _boatNamevitController.text = state.user["boat_name"] ?? "";
            _isInitialized = true;
          }
          if (state is ProfileUpdatedSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Profile updated successfully")),
            );
            Navigator.pop(context);
          }
          if (state is ProfileError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          if (state is AuthLoading && !_isInitialized) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _buildProfileImage(state, isDark),
                const SizedBox(height: 24),
                _buildPersonalInfoCard(isDark),
                const SizedBox(height: 20),
                _buildVesselCard(isDark),
                const SizedBox(height: 24),
                _buildDeactivateButton(),
                const SizedBox(height: 16),
                _buildSaveButton(isDark),
                const SizedBox(height: 12),
                _buildCancelButton(),
              ],
            ),
          );
        },
      ),
    );
  }

  // Widget _buildProfileImage(AuthState state,bool isDark) {
  //   String? networkImage;
  //   if (state is ProfileLoaded) networkImage = state.user["profile_photo"];
  //   return Column(
  //     children: [
  //       Stack(
  //         children: [
  //           GestureDetector(
  //             onTap: _pickImage,
  //             child: Container(
  //               padding: const EdgeInsets.all(4),
  //               decoration: BoxDecoration(
  //                   color: Theme.of(context).cardColor,
  //                   shape: BoxShape.circle
  //               ),
  //               child: CircleAvatar(
  //                 radius: 65,
  //                 backgroundColor: isDark ? Colors.white12 : const Color(0xFFE3F2FD),
  //                 backgroundImage:
  //                 _imageFile != null
  //                     ? FileImage(_imageFile!)
  //                     : (networkImage != null
  //                     ? NetworkImage(networkImage)
  //                     : const NetworkImage('https://localhost:3000/uploads/fishermen/me/photo')) as ImageProvider,
  //                 // _imageFile != null
  //                 //     ? FileImage(_imageFile!)
  //                 //     : const NetworkImage('https://localhost:3000/uploads/fishermen/me/photo') as ImageProvider,
  //               ),
  //             ),
  //           ),
  //           Positioned(
  //             bottom: 5,
  //             right: 5,
  //             child: GestureDetector(
  //               onTap: _pickImage,
  //               child: Container(
  //                 padding: const EdgeInsets.all(4),
  //                 decoration: const BoxDecoration(
  //                   color: Color(0xFF00A896),
  //                   shape: BoxShape.circle,
  //                 ),
  //                 child: const Icon(Icons.camera_alt, color: Colors.white, size: 18),
  //               ),
  //             ),
  //           )
  //         ],
  //       ),
  //       const SizedBox(height: 12),
  //       GestureDetector(
  //         onTap: _pickImage,
  //         child: const Text(
  //           "Change Profile Photo",
  //           style: TextStyle(color: Color(0xFF00A896), fontWeight: FontWeight.bold, fontSize: 14),
  //         ),
  //       )
  //     ],
  //   );
  // }
  Widget _buildProfileImage(AuthState state, bool isDark) {
    String? networkImage;
    if (state is ProfileLoaded) networkImage = state.user["profile_photo"];

    return Column(
      children: [
        Stack(
          children: [
            GestureDetector(
              onTap: () => _pickFile("profile_photo"), // ✅ corrigé
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(color: Theme.of(context).cardColor, shape: BoxShape.circle),
                child: CircleAvatar(
                  radius: 65,
                  backgroundColor: isDark ? Colors.white12 : const Color(0xFFE3F2FD),
                  backgroundImage: _imageFile != null
                      ? FileImage(_imageFile!)
                      : (networkImage != null
                      ? NetworkImage(networkImage)
                      : const NetworkImage('https://localhost:3000/uploads/veterinarians/me/photo'))
                  as ImageProvider,
                ),
              ),
            ),
            Positioned(
              bottom: 5,
              right: 5,
              child: GestureDetector(
                onTap: () => _pickFile("profile_photo"),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Color(0xFF013D73),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.camera_alt, color: Colors.white, size: 18),
                ),
              ),
            )
          ],
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: () => _pickFile("profile_photo"),
          child: const Text(
            "Change Profile Photo",
            style: TextStyle(color: Color(0xFF013D73), fontWeight: FontWeight.bold, fontSize: 14),
          ),
        )
      ],
    );
  }

  Widget _buildPersonalInfoCard(bool isDark) {
    return _cardContainer(
      isDark: isDark,
      title: "PERSONAL INFORMATION",
      children: [
        _buildTextField("Full Name", _namevitController, isDark),
        const SizedBox(height: 16),
        _buildTextField("Phone Number", _phonevitController, isDark),
        const SizedBox(height: 16),
        _buildTextField(
          "Email Address (just for contact)",
          _emailvitController,
          isDark,
          enabled: false,
          suffixIcon: Icons.lock_outline,
        ),
        const SizedBox(height: 8),
        const Text(
          "Email address is verified and cannot be changed.",
          style: TextStyle(color: Color(0xFFAAB8C2), fontSize: 11),
        ),
      ],
    );
  }

  Widget _buildVesselCard(bool isDark) {
    return _cardContainer(
      isDark: isDark,
      title: "ADDITIONAL INFORMATION",
      children: [
        _buildTextField("Assigned Port", _homePortvitController, isDark, prefixIcon: Icons.location_on_outlined),
        const SizedBox(height: 16),
        _buildTextField("Boat Name", _boatNamevitController, isDark, prefixIcon: Icons.directions_boat_outlined),
      ],
    );
  }

  Widget _buildDeactivateButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.delete_outline, color: Color(0xFFFF5252), size: 20),
        TextButton(
          onPressed: () {},
          child: const Text(
            "Deactivate Account",
            style: TextStyle(color: Color(0xFFFF5252), fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton(bool isDark) {
    return ElevatedButton(
      onPressed: () {
        context.read<AuthCubit>().updateProfilevit(
          name: _namevitController.text,
          phone: _phonevitController.text,
          homePort: _homePortvitController.text,
          boatName: _boatNamevitController.text,
          profileImage: _imageFile,  // ✅ added profileImage
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF00A896),
        minimumSize: const Size(double.infinity, 56),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 2,
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check_circle_outline, color: Colors.white),
          SizedBox(width: 8),
          Text(
            "Save Changes",
            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildCancelButton() {
    return TextButton(
      onPressed: () => Navigator.pop(context),
      child: const Text(
        "Cancel",
        style: TextStyle(color: Color(0xFF7B8D9E), fontWeight: FontWeight.bold, fontSize: 16),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, bool isDark, {bool enabled = true, IconData? prefixIcon, IconData? suffixIcon}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white70 : const Color(0xFF4A5568), fontSize: 13)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          enabled: enabled,
          style: TextStyle(color: isDark ? Colors.white : (enabled ? Colors.black : const Color(0xFF7B8D9E))),
          decoration: InputDecoration(
            prefixIcon: prefixIcon != null ? Icon(prefixIcon, color: const Color(0xFF00A896)) : null,
            suffixIcon: suffixIcon != null ? Icon(suffixIcon, color: const Color(0xFFBDC8D1), size: 18) : null,
            filled: true,
            fillColor: isDark ? Colors.white12 : (enabled ? Colors.white : const Color(0xFFF8FAFB)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: isDark ? BorderSide.none : const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: isDark ? BorderSide.none : const BorderSide(color: Color(0xFFE2E8F0)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _cardContainer({required String title, required List<Widget> children, required bool isDark}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white54 : const Color(0xFF718096), fontSize: 14, letterSpacing: 0.5),
          ),
          const SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }
}