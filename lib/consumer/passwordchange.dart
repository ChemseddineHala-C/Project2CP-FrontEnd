import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../signin/cubit/authcubit.dart';
import '../signin/cubit/authstate.dart';

class ChangepasswordConsPage extends StatefulWidget {

  const ChangepasswordConsPage({super.key});

  @override
  State<ChangepasswordConsPage> createState() => _ChangepasswordConsPageState();
}

class _ChangepasswordConsPageState extends State<ChangepasswordConsPage> {
  final TextEditingController _currentPasswordConsController = TextEditingController();
  final TextEditingController _newPasswordConsController = TextEditingController();
  final TextEditingController _confirmPasswordConsController = TextEditingController();

  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;


  String _newPass = "";

  @override
  void initState() {
    super.initState();
    _newPasswordConsController.addListener(() {
      setState(() {
        _newPass = _newPasswordConsController.text;
      });
    });
  }

  @override
  void dispose() {
    _currentPasswordConsController.dispose();
    _newPasswordConsController.dispose();
    _confirmPasswordConsController.dispose();
    super.dispose();
  }

  bool _hasMinLength() => _newPass.length >= 8;

  bool _hasNumber() => _newPass.contains(RegExp(r'[0-9]'));

  bool _hasSpecialChar() =>
      _newPass.contains(RegExp(r'[@%!#*&?]'));

  void _submitUpdate() {
    final currentPasscons = _currentPasswordConsController.text.trim();
    final newPasscons = _newPasswordConsController.text.trim();
    final confirmPasscons = _confirmPasswordConsController.text.trim();

    if (currentPasscons.isEmpty || newPasscons.isEmpty || confirmPasscons.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields")),
      );
      return;
    }

    if (newPasscons != confirmPasscons) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Passwords do not match")),
      );
      return;
    }

    if (!_hasMinLength()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Password must be at least 8 characters")),
      );
      return;
    }

    if (!_hasNumber()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Password must have a number (0-9)")),
      );
      return;
    }

    if (!_hasSpecialChar()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Password must have a special character (@,#,%,&,*,!,?)")),
      );
      return;
    }

    context.read<AuthCubit>().updatePasswordCons(
      currentpasswordCons: currentPasscons,
      passwordCons: newPasscons,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
      isDark ? const Color(0xFF121212) : const Color(0xFFF5F7F9),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back,
              color: isDark ? Colors.white : const Color(0xFFD5A439)),
        ),
        title: Text(
          "Change Password",
          style: TextStyle(
            color: isDark ? Colors.white : const Color(0xFFD5A439),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is PasswordUpdatedSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text("Password updated successfully!"),
                  backgroundColor: Colors.green),
            );
            Navigator.pop(context);
          } else if (state is ProfileError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is AuthLoading;
          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const SizedBox(height: 20),
                _buildIconHeader(),
                const SizedBox(height: 24),
                const Text(
                  "Change Password",
                  style: TextStyle(
                      fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                const Text(
                  "Enter your current password and choose a strong new one to keep your account secure.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
                const SizedBox(height: 32),
                _buildInputCard(isDark, isLoading),
                const SizedBox(height: 24),
                _buildSecurityStandards(isDark),
                const SizedBox(height: 32),
                _buildUpdateButton(isLoading),
                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildIconHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE3F2FD),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Icon(Icons.lock_reset,
          size: 40, color: Color(0xFFD5A439)),
    );
  }

  Widget _buildInputCard(bool isDark, bool isLoading) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFieldLabel("Current Password"),
          _buildPasswordField(
            _currentPasswordConsController,
            _obscureCurrent,
                () => setState(() => _obscureCurrent = !_obscureCurrent),
            isDark,
            enabled: !isLoading,
          ),
          const SizedBox(height: 20),
          _buildFieldLabel("New Password"),
          _buildPasswordField(
            _newPasswordConsController,
            _obscureNew,
                () => setState(() => _obscureNew = !_obscureNew),
            isDark,
            enabled: !isLoading,
          ),
          const SizedBox(height: 12),
          _buildFieldLabel("Confirm New Password"),
          _buildPasswordField(
            _confirmPasswordConsController,
            _obscureConfirm,
                () => setState(() => _obscureConfirm = !_obscureConfirm),
            isDark,
            hint: "Confirm your password",
            enabled: !isLoading,
          ),
        ],
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        label,
        style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: Colors.grey),
      ),
    );
  }

  Widget _buildPasswordField(
      TextEditingController controller,
      bool obscure,
      VoidCallback onToggle,
      bool isDark, {
        String hint = "........",
        bool enabled = true,
      }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      enabled: enabled,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: isDark
            ? Colors.white54
            : const Color(0xFFF8FAFB),
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        suffixIcon: IconButton(
          icon: Icon(
            obscure
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
            color: Colors.grey,
            size: 20,
          ),
          onPressed: onToggle,
        ),
      ),
    );
  }

  Widget _buildSecurityStandards(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 8, bottom: 12),
          child: Text(
            "SECURITY STANDARDS",
            style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
                fontSize: 12),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Column(
            children: [
              _buildStandardRow(
                "At least 8 characters",
                _hasMinLength(),
              ),
              const SizedBox(height: 12),
              _buildStandardRow(
                "Include a number (0-9)",
                _hasNumber(),
              ),
              const SizedBox(height: 12),
              _buildStandardRow(
                "Include a special character (@,#,%,&,*,!,?)",
                _hasSpecialChar(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStandardRow(String text, bool isValid) {
    return Row(
      children: [
        Icon(
          isValid ? Icons.check_circle : Icons.circle_outlined,
          color: isValid ? Colors.green : Colors.grey,
          size: 20,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(text, style: const TextStyle(fontSize: 14)),
        ),
      ],
    );
  }

  Widget _buildUpdateButton(bool isLoading) {
    return ElevatedButton(
      onPressed: isLoading ? null : _submitUpdate,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFD5A439),
        minimumSize: const Size(double.infinity, 56),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12)),
      ),
      child: isLoading
          ? const CircularProgressIndicator(color: Colors.white)
          : const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.save_outlined, color: Colors.white, size: 20),
          SizedBox(width: 10),
          Text(
            "Update Password",
            style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
