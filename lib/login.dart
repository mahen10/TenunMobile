import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import 'register_screen.dart';
import 'service/config.dart';
import 'home_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Manajemen Tenun',
      theme: ThemeData(
        primarySwatch: Colors.green,
        textTheme: GoogleFonts.poppinsTextTheme(),
      ),
      home: LoginScreen(),
      initialRoute: '/login',
      routes: {
        '/login': (context) => LoginScreen(),
        '/home': (context) => HomeScreen(),
        '/register': (context) => RegisterScreen(),
      },
    );
  }
}

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String _errorMessage = '';
  bool _isLoading = false;

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });

      try {
        final response = await http.post(
          Uri.parse('${Config.apiUrl}/api/auth/login'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'email': _emailController.text,
            'password': _passwordController.text,
          }),
        );
        print('Response status: ${response.statusCode}');
        print('Response body: ${response.body}');

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          String? token = data['token'] as String?;
          if (token != null) {
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString('auth_token', token);
            Navigator.pushReplacementNamed(context, '/main');
          } else {
            setState(() {
              _errorMessage = 'Token tidak ditemukan dalam respons';
              _isLoading = false;
            });
          }
        } else {
          final data = jsonDecode(response.body);
          setState(() {
            _errorMessage =
                data['message'] ?? 'Login gagal, cek kredensial Anda';
            _isLoading = false;
          });
        }
      } catch (e) {
        print('Error: $e');
        setState(() {
          _errorMessage = 'Terjadi kesalahan: $e';
          _isLoading = false;
        });
      }
    }
  }
  

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
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
            colors: [
              Color(0xFFF8F5E8), // Krem lembut
              Color(0xFFFFFFFF), // Putih bersih
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 32.0, vertical: 20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Logo App
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
                  SizedBox(height: 32),

                  // Judul "Selamat Datang"
                  Text(
                    'Selamat Datang',
                    style: GoogleFonts.poppins(
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF2C3E50),
                      letterSpacing: 0.5,
                    ),
                  ),
                  SizedBox(height: 8),

                  // Subtitle
                  Text(
                    'Kelola bisnis tenun Anda dengan mudah',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF7F8C8D),
                    ),
                  ),
                  SizedBox(height: 48),

                  // Container untuk form dengan desain modern
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
                          // Input Username atau Email
                          Container(
                            decoration: BoxDecoration(
                              color: Color(0xFFF8F9FA),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: Color(0xFFE9ECEF),
                                width: 1,
                              ),
                            ),
                            child: TextFormField(
                              controller: _emailController,
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                color: Color(0xFF2C3E50),
                              ),
                              decoration: InputDecoration(
                                labelText: 'Email',
                                labelStyle: GoogleFonts.poppins(
                                  color: Color(0xFF7F8C8D),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                                prefixIcon: Icon(
                                  Icons.person_outline,
                                  color: Color(0xFFD7B44C),
                                  size: 22,
                                ),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 18,
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Email tidak boleh kosong';
                                }
                                return null;
                              },
                            ),
                          ),
                          SizedBox(height: 20),

                          // Input Password
                          Container(
                            decoration: BoxDecoration(
                              color: Color(0xFFF8F9FA),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: Color(0xFFE9ECEF),
                                width: 1,
                              ),
                            ),
                            child: TextFormField(
                              controller: _passwordController,
                              obscureText: true,
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                color: Color(0xFF2C3E50),
                              ),
                              decoration: InputDecoration(
                                labelText: 'Kata Sandi',
                                labelStyle: GoogleFonts.poppins(
                                  color: Color(0xFF7F8C8D),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                                prefixIcon: Icon(
                                  Icons.lock_outline,
                                  color: Color(0xFFD7B44C),
                                  size: 22,
                                ),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 18,
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Password tidak boleh kosong';
                                }
                                return null;
                              },
                            ),
                          ),

                          // Error message
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

                          // Tombol Masuk
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
                              onPressed: _isLoading ? null : _login,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                foregroundColor: Colors.white,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child:
                                  _isLoading
                                      ? SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      )
                                      : Text(
                                        'Masuk',
                                        style: GoogleFonts.poppins(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                            ),
                          ),
                          SizedBox(height: 16),

                          // Tombol Daftar
                          Container(
                            width: double.infinity,
                            height: 52,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: Color(0xFFD7B44C),
                                width: 1.5,
                              ),
                            ),
                            child: OutlinedButton(
                              onPressed:
                                  _isLoading
                                      ? null
                                      : () {
                                        Navigator.pushNamed(
                                          context,
                                          '/register',
                                        );
                                      },
                              style: OutlinedButton.styleFrom(
                                side: BorderSide.none,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                backgroundColor: Colors.transparent,
                              ),
                              child: Text(
                                'Daftar',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFFD7B44C),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 32),

                  // Divider dengan teks
                  Row(
                    children: [
                      Expanded(
                        child: Divider(color: Color(0xFFE9ECEF), thickness: 1),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'Atau masuk dengan',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Color(0xFF7F8C8D),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Divider(color: Color(0xFFE9ECEF), thickness: 1),
                      ),
                    ],
                  ),
                  SizedBox(height: 24),

                  // Social Login Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Color(0xFFE9ECEF),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.1),
                              spreadRadius: 0,
                              blurRadius: 10,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.facebook,
                          color: Color(0xFF1877F2),
                          size: 28,
                        ),
                      ),
                      SizedBox(width: 16),
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Color(0xFFE9ECEF),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.1),
                              spreadRadius: 0,
                              blurRadius: 10,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.g_mobiledata,
                          color: Color(0xFFDB4437),
                          size: 32,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 32),

                  // Link ke Register
                  TextButton(
                    onPressed:
                        _isLoading
                            ? null
                            : () {
                              Navigator.pushNamed(context, '/register');
                            },
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                    child: RichText(
                      text: TextSpan(
                        text: 'Belum punya akun? ',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Color(0xFF7F8C8D),
                          fontWeight: FontWeight.w400,
                        ),
                        children: [
                          TextSpan(
                            text: 'Daftar sekarang',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Color(0xFFD7B44C),
                              fontWeight: FontWeight.w600,
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
}
