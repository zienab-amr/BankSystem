import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class AddCustomerScreen extends StatefulWidget {
  const AddCustomerScreen({super.key});

  @override
  State<AddCustomerScreen> createState() => _AddCustomerScreenState();
}

class _AddCustomerScreenState extends State<AddCustomerScreen> {
  final TextEditingController _fnameController = TextEditingController();
  final TextEditingController _lnameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _nationalIDController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _fnameController.dispose();
    _lnameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _nationalIDController.dispose();
    super.dispose();
  }

  Future<void> _saveCustomer() async {
    // التحقق من جميع الحقول
    if (_fnameController.text.trim().isEmpty) {
      _showSnackBar("Please enter first name", Colors.orange);
      return;
    }
    if (_lnameController.text.trim().isEmpty) {
      _showSnackBar("Please enter last name", Colors.orange);
      return;
    }
    if (_emailController.text.trim().isEmpty) {
      _showSnackBar("Please enter email", Colors.orange);
      return;
    }
    if (!_emailController.text.contains('@')) {
      _showSnackBar("Please enter valid email", Colors.orange);
      return;
    }
    if (_phoneController.text.trim().isEmpty) {
      _showSnackBar("Please enter phone number", Colors.orange);
      return;
    }
    if (_nationalIDController.text.trim().isEmpty) {
      _showSnackBar("Please enter national ID", Colors.orange);
      return;
    }
    if (_nationalIDController.text.length != 14) {
      _showSnackBar("National ID must be 14 digits", Colors.orange);
      return;
    }

    setState(() => _isLoading = true);

    try {
      Map<String, dynamic> customerData = {
        "fname": _fnameController.text.trim(),
        "lname": _lnameController.text.trim(),
        "email": _emailController.text.trim(),
        "phone": _phoneController.text.trim(),
        "nationalID": _nationalIDController.text.trim(),
        "createdat": DateTime.now().toIso8601String(),
        "status": "verified"
      };
      
      print("Sending data: ${jsonEncode(customerData)}");

      // استبدلي الجزء ده في كود الـ _saveCustomer
final response = await http.post(
      Uri.parse('http://127.0.0.1:8080/api/customer'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode(customerData),
    ).timeout(const Duration(seconds: 5)); // قللنا الـ timeout شوية

    if (response.statusCode == 201 || response.statusCode == 200) {
      _showSnackBar("✅ Customer added successfully!", Colors.green);
      if (mounted) Navigator.pop(context, true);
    }
  } catch (e) {
  print("Actual Error: $e");
  _showSnackBar("❌ Failed to add customer", Colors.red);
}
}
  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF101D3D),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // HEADER
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
                decoration: const BoxDecoration(
                  color: Color(0xFF00C853),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(35),
                    bottomRight: Radius.circular(35),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Row(
                        children: [
                          Icon(Icons.arrow_back, color: Colors.white),
                          SizedBox(width: 10),
                          Text("Back", style: TextStyle(color: Colors.white, fontSize: 18)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 25),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: const Icon(Icons.person_outline_rounded, color: Colors.white, size: 35),
                        ),
                        const SizedBox(width: 15),
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Add New Customer", style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                            Text("Enter customer details", style: TextStyle(color: Colors.white70, fontSize: 14)),
                          ],
                        )
                      ],
                    ),
                  ],
                ),
              ),

              // FORM
              Transform.translate(
                offset: const Offset(0, -25),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      _buildInputField(
                        label: "First Name",
                        hint: "Enter first name",
                        icon: Icons.person_outline,
                        controller: _fnameController,
                      ),
                      const SizedBox(height: 15),
                      _buildInputField(
                        label: "Last Name",
                        hint: "Enter last name",
                        icon: Icons.person_outline,
                        controller: _lnameController,
                      ),
                      const SizedBox(height: 15),
                      _buildInputField(
                        label: "Email Address",
                        hint: "customer@example.com",
                        icon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        controller: _emailController,
                      ),
                      const SizedBox(height: 15),
                      _buildInputField(
                        label: "Phone Number",
                        hint: "+20 XXX XXX XXXX",
                        icon: Icons.phone_outlined,
                        keyboardType: TextInputType.phone,
                        controller: _phoneController,
                      ),
                      const SizedBox(height: 15),
                      _buildInputField(
                        label: "National ID",
                        hint: "14 digits national ID",
                        icon: Icons.badge_outlined,
                        keyboardType: TextInputType.number,
                        controller: _nationalIDController,
                      ),
                      const SizedBox(height: 30),

                      GestureDetector(
                        onTap: _isLoading ? null : _saveCustomer,
                        child: Container(
                          width: double.infinity,
                          height: 60,
                          decoration: BoxDecoration(
                            color: const Color(0xFF00C853),
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              )
                            ],
                          ),
                          child: Center(
                            child: _isLoading 
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.save_outlined, color: Colors.white),
                                    SizedBox(width: 10),
                                    Text("Save Customer", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                                  ],
                                ),
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
    );
  }

  Widget _buildInputField({
    required String label,
    required String hint,
    required IconData icon,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFF2563EB), size: 20),
              const SizedBox(width: 8),
              Text(label, style: const TextStyle(color: Color(0xFF1E293B), fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
          const SizedBox(height: 15),
          TextField(
            controller: controller,
            keyboardType: keyboardType,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: Colors.grey),
              filled: true,
              fillColor: Colors.grey[50],
              contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[300]!)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[200]!)),
            ),
          ),
        ],
      ),
    );
  }
}