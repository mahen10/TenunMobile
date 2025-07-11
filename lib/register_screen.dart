import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import 'service/config.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _businessNameController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  String _errorMessage = '';

  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      try {
        final response = await http.post(
          Uri.parse('${Config.apiUrl}/api/auth/register'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'name': _nameController.text,
            'email': _emailController.text,
            'password': _passwordController.text,
            'nama_usaha': _businessNameController.text,
            'alamat': _addressController.text,
            'no_telepon': _phoneController.text,
          }),
        );
        print('Response status: ${response.statusCode}');
        print('Response body: ${response.body}');

        if (response.statusCode == 201) {
          final data = jsonDecode(response.body);
          String token = data['access_token'];
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('auth_token', token);
          Navigator.pushReplacementNamed(context, '/main');
        } else {
          final data = jsonDecode(response.body);
          setState(() {
            _errorMessage = data['message'] ?? 'Registrasi gagal';
          });
        }
      } catch (e) {
        print('Error: $e');
        setState(() {
          _errorMessage = 'Terjadi kesalahan: $e';
        });
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _businessNameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF8F5E8), Color(0xFFFFFFFF)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 32.0, vertical: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Logo atau Icon
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(60),
                      boxShadow: [
                        BoxShadow(
                          color: Color(0xFFD7B44C).withOpacity(0.3),
                          spreadRadius: 3,
                          blurRadius: 15,
                          offset: Offset(0, 8),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(60),
                      child: Image.asset(
                        'assets/images/app_icon.jpg',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  SizedBox(height: 24),

                  Text(
                    'Buat Akun Baru',
                    style: GoogleFonts.poppins(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF2C3E50),
                    ),
                  ),
                  SizedBox(height: 32),

                  Container(
                    padding: EdgeInsets.all(28.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Color(0xFFD7B44C).withOpacity(0.1),
                          spreadRadius: 0,
                          blurRadius: 20,
                          offset: Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          _buildInputField('Nama', _nameController),
                          SizedBox(height: 20),
                          _buildInputField('Email', _emailController),
                          SizedBox(height: 20),
                          _buildInputField(
                            'Password',
                            _passwordController,
                            obscureText: true,
                          ),
                          SizedBox(height: 20),
                          _buildInputField(
                            'Nama Usaha',
                            _businessNameController,
                          ),
                          SizedBox(height: 20),
                          _buildInputField('Alamat', _addressController),
                          SizedBox(height: 20),
                          _buildInputField('No Telepon', _phoneController),
                          SizedBox(height: 16),

                          if (_errorMessage.isNotEmpty)
                            Container(
                              width: double.infinity,
                              margin: EdgeInsets.only(top: 16),
                              padding: EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.red.shade50,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.red.shade200,
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                _errorMessage,
                                style: GoogleFonts.poppins(
                                  color: Colors.red.shade700,
                                  fontSize: 14,
                                ),
                              ),
                            ),

                          SizedBox(height: 32),

                          Container(
                            width: double.infinity,
                            height: 52,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Color(0xFFD7B44C), Color(0xFFE8C55A)],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Color(0xFFD7B44C).withOpacity(0.3),
                                  spreadRadius: 0,
                                  blurRadius: 12,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ElevatedButton(
                              onPressed: _register,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                foregroundColor: Colors.white,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: Text(
                                'Daftar',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 16),

                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text(
                              'Kembali ke Login',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: Color(0xFFD7B44C),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField(
    String label,
    TextEditingController controller, {
    bool obscureText = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Color(0xFFE9ECEF), width: 1),
      ),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        style: GoogleFonts.poppins(fontSize: 16, color: Color(0xFF2C3E50)),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.poppins(
            color: Color(0xFF7F8C8D),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return '$label tidak boleh kosong';
          }
          if (label == 'Password' && value.length < 8) {
            return 'Password minimal 8 karakter';
          }
          return null;
        },
      ),
    );
  }
}
