import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'config.dart';

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
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
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
    // Validate all fields before making the request
    if (!_formKey.currentState!.validate()) {
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
        "status": "verified",
      };

      print("Sending data: ${jsonEncode(customerData)}");

      final response = await http
          .post(
            Uri.parse("${AppConfig.baseUrl}/api/customer"),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode(customerData),
          )
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 201 || response.statusCode == 200) {
        _showSnackBar("✅ Customer added successfully!", Colors.green);
        if (mounted) Navigator.pop(context, true);
      } else {
        _showSnackBar("❌ Failed to add customer: ${response.statusCode}", Colors.red);
      }
    } catch (e) {
      print("Actual Error: $e");
      _showSnackBar("❌ Connection error: $e", Colors.red);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message), backgroundColor: color));
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
                          Text(
                            "Back",
                            style: TextStyle(color: Colors.white, fontSize: 18),
                          ),
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
                          child: const Icon(
                            Icons.person_outline_rounded,
                            color: Colors.white,
                            size: 35,
                          ),
                        ),
                        const SizedBox(width: 15),
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Add New Customer",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              "Enter customer details",
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
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
                  child: Form(
                    key: _formKey,
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
                          hint: "01123456789",
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
                                ),
                              ],
                            ),
                            child: Center(
                              child: _isLoading
                                  ? const CircularProgressIndicator(
                                      color: Colors.white,
                                    )
                                  : const Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.save_outlined,
                                          color: Colors.white,
                                        ),
                                        SizedBox(width: 10),
                                        Text(
                                          "Save Customer",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                            ),
                          ),
                        ),
                      ],
                    ),
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
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFF2563EB), size: 20),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: Color(0xFF1E293B),
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return "$label is required";
              }

              // Email validation - Strong regex
              if (label == "Email Address") {
                final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                if (!emailRegex.hasMatch(value.trim())) {
                  return "Enter valid email (e.g., name@example.com)";
                }
              }

              // Phone validation - Must be exactly 11 digits
              if (label == "Phone Number") {
                final phoneRegex = RegExp(r'^[0-9]{11}$');
                if (!phoneRegex.hasMatch(value.trim())) {
                  return "Phone must be exactly 11 digits (numbers only)";
                }
              }

              // National ID validation - Must be exactly 14 digits
              if (label == "National ID") {
                final nationalRegex = RegExp(r'^[0-9]{14}$');
                if (!nationalRegex.hasMatch(value.trim())) {
                  return "National ID must be exactly 14 digits (numbers only)";
                }
              }

              // Name validation - Only letters and spaces
              if (label == "First Name" || label == "Last Name") {
                final nameRegex = RegExp(r'^[a-zA-Z\s]+$');
                if (!nameRegex.hasMatch(value.trim())) {
                  return "Only letters and spaces allowed";
                }
              }

              return null;
            },
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: Colors.grey),
              filled: true,
              fillColor: Colors.grey[50],
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 15,
                vertical: 15,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[200]!),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.red),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.red, width: 2),
              ),
            ),
          ),
        ],
      ),
    );
  }
}