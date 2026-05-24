import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../signin/cubit/authcubit.dart';
import '../signin/cubit/authstate.dart';


class Addvet extends StatefulWidget {
  const Addvet({super.key});

  @override
  State<Addvet> createState() => _AddvetState();
}

class _AddvetState extends State<Addvet> {
  final _emailvetController = TextEditingController();
  final _passwordvetController = TextEditingController();
  final _homePortvetController = TextEditingController();
  final _full_nameController=TextEditingController();
  final _national_idController=TextEditingController();
  final _phone_numberController=TextEditingController();
  final _specializationController=TextEditingController();
  final _license_numberController=TextEditingController();
  final _license_expiry_dateController=TextEditingController();
  bool _obscurePassword = true;
  bool _sendCredentials = true;

  @override
  void dispose() {
    _emailvetController.dispose();
    _passwordvetController.dispose();
    _homePortvetController.dispose();
    _full_nameController.dispose();
    _national_idController.dispose();
    _phone_numberController.dispose();
    _specializationController.dispose();
    _license_numberController.dispose();
    _license_expiry_dateController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_emailvetController.text.isEmpty ||
        _passwordvetController.text.isEmpty ||
        _homePortvetController.text.isEmpty || _full_nameController.text.isEmpty || _national_idController.text.isEmpty || _phone_numberController.text.isEmpty || _specializationController.text.isEmpty || _license_numberController.text.isEmpty || _license_expiry_dateController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please fill all required fields"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // On lance l'appel API. La navigation se fera dans le listener ci-dessous.
    context.read<AuthCubit>().submitAdmin(
      emailvet: _emailvetController.text.trim(),
      passwordvet: _passwordvetController.text.trim(),
      homePortvet: _homePortvetController.text.trim(),
      full_name: _full_nameController.text.trim(),
      national_id: _national_idController.text.trim(),
      phone_number: _phone_numberController.text.trim(),
      specialization: _specializationController.text.trim(),
      license_number: _license_numberController.text.trim(),
      license_expiry_date: _license_expiry_dateController.text.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF5F7F9),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : const Color(0xFF011A33)),
        ),
        title: Text(
          "Add Veterinarian",
          style: TextStyle(
            color: isDark ? Colors.white : const Color(0xFF011A33),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is VetCreatedSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Account created successfully!"), backgroundColor: Colors.green),
            );
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.red),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is AuthLoading || state is SetupLoading;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildMsm(isDark: isDark),
                const SizedBox(height: 20),
                _buildSection(
                  isDark: isDark,
                  children: [
                    _label("EMAIL ADDRESS"),
                    customTextField("vet@gmail.com", _emailvetController, isDark),
                    const SizedBox(height: 16),
                    _label("TEMPORARY PASSWORD"),
                    _buildPasswordField(isDark, isLoading),
                    const SizedBox(height: 16),
                    _label("Home Port"),
                    customTextField("Enter Home port", _homePortvetController, isDark),
                    const SizedBox(height: 30),
                    _label("Full Name"),
                    customTextField("Enter Full Name", _full_nameController, isDark),
                    const SizedBox(height: 16),
                    _label("National ID"),
                    customTextField("Enter National ID", _national_idController, isDark),
                    const SizedBox(height: 16),
                    _label("Phone Number"),
                    customTextField("Enter Phone Number", _phone_numberController, isDark),
                    const SizedBox(height: 16),
                    _label("Specialization"),
                    customTextField("Enter Specialization", _specializationController, isDark),
                    const SizedBox(height: 16),
                    _label("License Number"),
                    customTextField("LIC-00-1122", _license_numberController, isDark),
                    const SizedBox(height: 16),
                    _label("License Expiry Date"),
                    customTextField("YYYY-MM-DD", _license_expiry_dateController, isDark),
                    const SizedBox(height: 16),
                    _buildCheckbox(isLoading),
                    const SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isDark ? const Color(0xFF01A896) : const Color(0xFF033F78),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.person_add_alt_outlined, color: Colors.white),
                            SizedBox(width: 10),
                            Text("Create Account",
                                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMsm({required bool isDark}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: isDark ? Colors.black26 : Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: const Text(
        "Create a basic account for a new inspector. They will complete their professional profile upon their first login.",
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: Color(0xFF3F484C)),
      ),
    );
  }

  Widget _buildSection({required bool isDark, required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: isDark ? Colors.black26 : Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _buildPasswordField(bool isDark, bool isLoading) {
    return TextField(
      controller: _passwordvetController,
      enabled: !isLoading,
      obscureText: _obscurePassword,
      decoration: InputDecoration(
        hintText: "Enter password here",
        prefixIcon: const Icon(Icons.lock_outline, color: Colors.grey, size: 20),
        suffixIcon: IconButton(
          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
          icon: Icon(_obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: Colors.grey, size: 20),
        ),
        filled: true,
        fillColor: isDark ? Colors.white10 : const Color(0xFFF5F5F5),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      ),
    );
  }

  Widget _buildCheckbox(bool isLoading) {
    return Row(
      children: [
        Checkbox(
          value: _sendCredentials,
          onChanged: isLoading ? null : (value) => setState(() => _sendCredentials = value ?? true),
          activeColor: const Color(0xFF015F6B),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        ),
        const Text("Send login credentials via email", style: TextStyle(fontSize: 14)),
      ],
    );
  }

  Widget _label(String text) => Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 8),
      child: Text(text, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)));
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
