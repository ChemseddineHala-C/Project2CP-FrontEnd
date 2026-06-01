//import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../login.dart';
import '../../HOST.dart';

class ResetPasswordPage extends StatefulWidget {
  final String email;
  final String code;
  const ResetPasswordPage({required this.email, required this.code});

  @override
  _ResetPasswordPageState createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final _newController     = TextEditingController();
  final _confirmController = TextEditingController();
  bool _loading  = false;
  bool _obscure1 = true;
  bool _obscure2 = true;

  Future<void> _reset() async {
    setState(() => _loading = true);
    try {
      final response = await http.post(
        Uri.parse('$HOST/api/auth/reset-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email':            widget.email,
          'code':             widget.code,
          'new_password':     _newController.text,
          'confirm_password': _confirmController.text,
        }),
      );

      if (response.statusCode == 200) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => LoginPage()),
          (route) => false,
        );
      } else {
        final data = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message']), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        title: Text('New Password'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('New Password'),
            SizedBox(height: 8),
            TextField(
              controller:  _newController,
              obscureText: _obscure1,
              decoration:  InputDecoration(
                hintText: '••••••••',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                suffixIcon: IconButton(
                  icon: Icon(_obscure1 ? Icons.visibility_off : Icons.visibility),
                  onPressed: () => setState(() => _obscure1 = !_obscure1),
                ),
              ),
            ),
            SizedBox(height: 16),
            Text('Confirm Password'),
            SizedBox(height: 8),
            TextField(
              controller:  _confirmController,
              obscureText: _obscure2,
              decoration:  InputDecoration(
                hintText: '••••••••',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                suffixIcon: IconButton(
                  icon: Icon(_obscure2 ? Icons.visibility_off : Icons.visibility),
                  onPressed: () => setState(() => _obscure2 = !_obscure2),
                ),
              ),
            ),
            SizedBox(height: 24),
            SizedBox(
              width:  double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _loading ? null : _reset,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF1A3A5C),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                ),
                child: _loading
                  ? SizedBox(width: 20, height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : Text('Update Password',
                      style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
