// transaction_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class TransactionScreen extends StatefulWidget {
  @override
  _TransactionScreenState createState() => _TransactionScreenState();
}

class _TransactionScreenState extends State<TransactionScreen> {
  bool isPembelian = true;

  // Placeholder untuk data pembelian/penjualan dari database
  final List<Map<String, String>> _pembelian = [];
  final List<Map<String, String>> _penjualan = [];

  void _navigateToAddTransaction() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => isPembelian
            ? TambahPembelianScreen()
            : TambahPenjualanScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.yellow[700],
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.only(top: 50, left: 16, right: 16, bottom: 20),
            decoration: BoxDecoration(
              color: Colors.yellow[700],
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(50),
                bottomRight: Radius.circular(50),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.arrow_back, color: Colors.black),
                SizedBox(width: 16),
                Text(
                  'Transaksi',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Row(
                            children: [
                              GestureDetector(
                                onTap: () => setState(() => isPembelian = true),
                                child: Container(
                                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: isPembelian ? Colors.black : Colors.transparent,
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  child: Text("Pembelian", style: TextStyle(color: isPembelian ? Colors.white : Colors.black)),
                                ),
                              ),
                              GestureDetector(
                                onTap: () => setState(() => isPembelian = false),
                                child: Container(
                                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: !isPembelian ? Colors.black : Colors.transparent,
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  child: Text("Penjualan", style: TextStyle(color: !isPembelian ? Colors.white : Colors.black)),
                                ),
                              ),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: _navigateToAddTransaction,
                          child: Row(
                            children: [
                              Icon(Icons.add_circle, color: Colors.cyan),
                              SizedBox(width: 5),
                              Text(isPembelian ? 'Pembelian' : 'Penjualan', style: GoogleFonts.poppins(fontWeight: FontWeight.bold))
                            ],
                          ),
                        )
                      ],
                    ),
                    SizedBox(height: 16),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.green[50],
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              decoration: InputDecoration(
                                hintText: isPembelian ? 'Cari Bahan' : 'Cari Produk',
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () {},
                            child: Text('Cari'),
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: Colors.black,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    SizedBox(height: 20),
                    Text(isPembelian ? 'Pembelian Bahan' : 'Penjualan', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold)),
                    SizedBox(height: 10),
                    Expanded(
                      child: ListView.builder(
                        itemCount: isPembelian ? _pembelian.length : _penjualan.length,
                        itemBuilder: (context, index) {
                          final transaction = isPembelian ? _pembelian[index] : _penjualan[index];
                          return _buildItem(
                            transaction['name'] ?? '-',
                            transaction['jumlah'] ?? '0',
                            transaction['total'] ?? '0',
                            transaction['date'] ?? '-',
                            transaction['image'] ?? 'assets/default.png',
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItem(String name, String jumlah, String total, String date, String imageAsset) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.asset(imageAsset, width: 50, height: 50, fit: BoxFit.cover),
      ),
      title: Text(name, style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Jumlah: $jumlah', style: GoogleFonts.poppins()),
          Text('Total: Rp $total', style: GoogleFonts.poppins(color: Colors.blue)),
        ],
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(date, style: GoogleFonts.poppins(fontSize: 12)),
          Text('Detail', style: GoogleFonts.poppins(color: Colors.teal)),
        ],
      ),
    );
  }
}

class TambahPembelianScreen extends StatefulWidget {
  @override
  State<TambahPembelianScreen> createState() => _TambahPembelianScreenState();
}

class _TambahPembelianScreenState extends State<TambahPembelianScreen> {
  TextEditingController dateController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.yellow[700],
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.only(top: 50, left: 16, right: 16, bottom: 20),
            child: Row(
              children: [
                IconButton(onPressed: () => Navigator.pop(context), icon: Icon(Icons.arrow_back)),
                SizedBox(width: 16),
                Text('Tambah Pembelian', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold))
              ],
            ),
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
              ),
              padding: EdgeInsets.all(24),
              child: Column(
                children: [
                  _buildField('Nama Bahan'),
                  _buildField('Jumlah Dibeli', isNumber: true),
                  _buildField('Total Harga', isNumber: true),
                  _buildDateField(dateController),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.yellow[700],
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      minimumSize: Size(150, 50),
                    ),
                    child: Text('Simpan', style: GoogleFonts.poppins(color: Colors.black)),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildField(String hint, {bool isNumber = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          hintText: hint,
          filled: true,
          fillColor: Colors.green[50],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildDateField(TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        readOnly: true,
        onTap: () async {
          DateTime? picked = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime(2000),
            lastDate: DateTime(2100),
          );
          if (picked != null) {
            controller.text = DateFormat('dd/MM/yyyy').format(picked);
          }
        },
        decoration: InputDecoration(
          hintText: 'Tanggal Pembelian',
          filled: true,
          fillColor: Colors.green[50],
          suffixIcon: Icon(Icons.calendar_today, size: 20),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}

class TambahPenjualanScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.yellow[700],
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.only(top: 50, left: 16, right: 16, bottom: 20),
            child: Row(
              children: [
                IconButton(onPressed: () => Navigator.pop(context), icon: Icon(Icons.arrow_back)),
                SizedBox(width: 16),
                Text('Tambah Penjualan', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold))
              ],
            ),
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
              ),
              padding: EdgeInsets.all(24),
              child: Column(
                children: [
                  _buildDropdown('Pilih Produk'),
                  _buildField('Jumlah Terjual', isNumber: true),
                  _buildField('Total Harga', isNumber: true),
                  _buildDateField(context),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.yellow[700],
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      minimumSize: Size(150, 50),
                    ),
                    child: Text('Simpan', style: GoogleFonts.poppins(color: Colors.black)),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildDropdown(String hint) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.green[50],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide.none,
          ),
        ),
        hint: Text(hint),
        items: ['Produk 1', 'Produk 2']
            .map((item) => DropdownMenuItem<String>(
                  value: item,
                  child: Text(item),
                ))
            .toList(),
        onChanged: (value) {},
      ),
    );
  }

  Widget _buildField(String hint, {bool isNumber = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          hintText: hint,
          filled: true,
          fillColor: Colors.green[50],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildDateField(BuildContext context) {
    TextEditingController controller = TextEditingController();
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        readOnly: true,
        onTap: () async {
          DateTime? picked = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime(2000),
            lastDate: DateTime(2100),
          );
          if (picked != null) {
            controller.text = DateFormat('dd/MM/yyyy').format(picked);
          }
        },
        decoration: InputDecoration(
          hintText: 'Tanggal Penjualan',
          filled: true,
          fillColor: Colors.green[50],
          suffixIcon: Icon(Icons.calendar_today, size: 20),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}
