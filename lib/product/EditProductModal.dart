import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../service/config.dart';

class EditProductModal extends StatefulWidget {
  final Map<String, dynamic> produk;
  final Function onSuccess;

  const EditProductModal({
    Key? key,
    required this.produk,
    required this.onSuccess,
  }) : super(key: key);

  @override
  _EditProductModalState createState() => _EditProductModalState();
}

class _EditProductModalState extends State<EditProductModal> {
  late TextEditingController namaProdukController;
  late TextEditingController hargaController;
  late TextEditingController deskripsiController;
  late String kategori;
  late int stok;
  File? foto;

  // Daftar kategori
  final List<String> kategoriList = [
    'Kain Sarung',
    'Kain Songket',
    'Kain Ikat',
    'Selendang',
    'Busana Adat',
    'Gaun Tenun',
    'Taplak Meja Tenun',
    'Hiasan Dinding',
    'Lainnya',
  ];

  @override
  void initState() {
    super.initState();
    namaProdukController = TextEditingController(
      text: widget.produk['nama_produk'] ?? '',
    );
    hargaController = TextEditingController(
      text: widget.produk['harga_jual'].toString(),
    );
    deskripsiController = TextEditingController(
      text: widget.produk['deskripsi'] ?? '',
    );
    kategori = widget.produk['kategori'] ?? '';
    stok = int.tryParse(widget.produk['stok'].toString()) ?? 0;
  }

  @override
  void dispose() {
    namaProdukController.dispose();
    hargaController.dispose();
    deskripsiController.dispose();
    super.dispose();
  }

  void _showSnackBar(String message, {Color backgroundColor = Colors.green}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Future<void> _saveChanges() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      if (token == null) {
        _showSnackBar('Token tidak ditemukan!');
        return;
      }

      var request = http.MultipartRequest(
        'POST',
        Uri.parse(
          '${Config.apiUrl}/api/produk/${widget.produk['id']}?_method=PUT',
        ),
      );
      request.headers['Authorization'] = 'Bearer $token';
      request.fields['nama_produk'] = namaProdukController.text;
      request.fields['kategori'] = kategori;
      request.fields['harga_jual'] = hargaController.text;
      request.fields['stok'] = stok.toString();
      request.fields['deskripsi'] = deskripsiController.text;

      if (foto != null) {
        request.files.add(
          await http.MultipartFile.fromPath('gambar', foto!.path),
        );
      }

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        Navigator.pop(context);
        _showSnackBar('Pembaruan berhasil disimpan!');

      } else {
        // Parse error response
        String errorMessage = 'Gagal update produk.';
        try {
          final Map<String, dynamic> errorData = json.decode(responseBody);
          if (errorData.containsKey('message')) {
            errorMessage = 'Error: ${errorData['message']}';
          } else if (errorData.containsKey('error')) {
            errorMessage = 'Error: ${errorData['error']}';
          } else if (errorData.containsKey('errors')) {
            // Handle validation errors
            Map<String, dynamic> errors = errorData['errors'];
            List<String> errorList = [];
            errors.forEach((key, value) {
              if (value is List) {
                errorList.addAll(value.map((e) => e.toString()));
              } else {
                errorList.add(value.toString());
              }
            });
            errorMessage = 'Validation Error:\n${errorList.join('\n')}';
          }
        } catch (e) {
          errorMessage = 'Error ${response.statusCode}: $responseBody';
        }

        _showSnackBar(errorMessage);
      }
    } catch (e) {
      _showSnackBar('Gagal menyimpan pembaruan.', backgroundColor: Colors.red);

    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: EdgeInsets.zero,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Edit Produk',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),

          backgroundColor: const Color(0xFFD7B44C),
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: Container(
          decoration: const BoxDecoration(color: Color(0xFFD7B44C)),
          child: Container(
            margin: const EdgeInsets.only(top: 20),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Image Picker Area
                    Center(
                      child: GestureDetector(
                        onTap: () async {
                          final picker = ImagePicker();
                          final picked = await picker.pickImage(
                            source: ImageSource.gallery,
                          );
                          if (picked != null) {
                            setState(() => foto = File(picked.path));
                          }
                        },
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child:
                              foto != null
                                  ? Stack(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(15),
                                        child: Image.file(
                                          foto!,
                                          width: 120,
                                          height: 120,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      Positioned(
                                        top: 8,
                                        right: 8,
                                        child: Container(
                                          padding: const EdgeInsets.all(4),
                                          decoration: const BoxDecoration(
                                            color: Colors.black54,
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            Icons.edit,
                                            color: Colors.white,
                                            size: 16,
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                  : widget.produk['gambar'] != null
                                  ? Stack(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(15),
                                        child: Image.network(
                                          '${Config.apiUrl}/storage/${widget.produk['gambar']}',
                                          width: 120,
                                          height: 120,
                                          fit: BoxFit.cover,
                                          errorBuilder: (
                                            context,
                                            error,
                                            stackTrace,
                                          ) {
                                            return const Icon(
                                              Icons.edit,
                                              size: 30,
                                              color: Colors.grey,
                                            );
                                          },
                                        ),
                                      ),
                                      Positioned(
                                        top: 8,
                                        right: 8,
                                        child: Container(
                                          padding: const EdgeInsets.all(4),
                                          decoration: const BoxDecoration(
                                            color: Colors.black54,
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            Icons.edit,
                                            color: Colors.white,
                                            size: 16,
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                  : const Icon(
                                    Icons.edit,
                                    size: 30,
                                    color: Colors.grey,
                                  ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Nama Produk
                    Text(
                      'Nama Produk',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F5E8),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: TextField(
                        controller: namaProdukController,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 15,
                          ),
                          hintText: 'Masukkan nama produk',
                          hintStyle: TextStyle(color: Colors.grey),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Kategori
                    Text(
                      'Kategori',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F5E8),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 15,
                          ),
                          hintText: 'Pilih Kategori',
                          hintStyle: TextStyle(color: Colors.grey),
                        ),
                        value: kategori.isEmpty ? null : kategori,
                        icon: const Icon(Icons.keyboard_arrow_down),
                        items:
                            kategoriList.map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            kategori = newValue ?? '';
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Stok
                    Text(
                      'Stok',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            if (stok > 0) {
                              setState(() => stok--);
                            }
                          },
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8F5E8),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.remove, color: Colors.grey),
                          ),
                        ),
                        const SizedBox(width: 15),
                        Container(
                          width: 60,
                          height: 40,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F5E8),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Center(
                            child: Text(
                              stok.toString(),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 15),
                        GestureDetector(
                          onTap: () {
                            setState(() => stok++);
                          },
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8F5E8),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.add, color: Colors.grey),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Harga Jual
                    Text(
                      'Harga Jual',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F5E8),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: TextField(
                        controller: hargaController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 15,
                          ),
                          hintText: '0',
                          hintStyle: TextStyle(color: Colors.grey),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Deskripsi
                    Text(
                      'Deskripsi',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F5E8),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: TextField(
                        controller: deskripsiController,
                        maxLines: 4,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 15,
                          ),
                          hintText: 'Deskripsi Produk',
                          hintStyle: TextStyle(color: Colors.grey),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Simpan Button
                    Container(
                      width: double.infinity,
                      height: 50,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFD7B44C), Color(0xFFE8C55A)],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          foregroundColor: Colors.white,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                        onPressed: _saveChanges,
                        child: Text(
                          'Simpan Perubahan',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: const Color.fromARGB(221, 255, 255, 255),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
