import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'customer.dart';
import 'config.dart';

class EditCustomerScreen extends StatefulWidget {
  final Customer customer;

  const EditCustomerScreen({super.key, required this.customer});

  @override
  State<EditCustomerScreen> createState() => _EditCustomerScreenState();
}

class _EditCustomerScreenState extends State<EditCustomerScreen> {
  late TextEditingController _fnameController;
  late TextEditingController _lnameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _nationalIDController;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _fnameController = TextEditingController(text: widget.customer.firstName);
    _lnameController = TextEditingController(text: widget.customer.lastName);
    _emailController = TextEditingController(text: widget.customer.email);
    _phoneController = TextEditingController(text: widget.customer.phone);
    _nationalIDController = TextEditingController(text: widget.customer.nationalID);
  }

  @override
  void dispose() {
    _fnameController.dispose();
    _lnameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _nationalIDController.dispose();
    super.dispose();
  }

  Future<void> _updateCustomer() async {
    // Validate all fields before making the request
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSaving = true);

    try {
      Map<String, dynamic> updatedData = {
        "customerID": widget.customer.id,
        "fname": _fnameController.text.trim(),
        "lname": _lnameController.text.trim(),
        "email": _emailController.text.trim(),
        "phone": _phoneController.text.trim(),
        "nationalID": _nationalIDController.text.trim(),
        "status": widget.customer.status ?? "ACTIVE",
      };

      final String url = "${AppConfig.baseUrl}/api/customers/${widget.customer.id}";

      print("📤 Sending PUT to: $url");

      final response = await http.put(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(updatedData),
      ).timeout(const Duration(seconds: 15));

      print("📥 Status Code: ${response.statusCode}");

      if (response.statusCode == 200 || response.statusCode == 204) {
        _showSnackBar("✅ Success!", Colors.green);
        if (mounted) Navigator.pop(context, true);
      } else {
        _showSnackBar("Failed: ${response.statusCode}", Colors.red);
      }
    } catch (e) {
      _showSnackBar("Connection Error: $e", Colors.red);
    } finally {
      if (mounted) setState(() => _isSaving = false);
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
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
                decoration: const BoxDecoration(
                  color: Color(0xFFFF6B00),
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
                          child: const Icon(Icons.edit_note_rounded, color: Colors.white, size: 35),
                        ),
                        const SizedBox(width: 15),
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Edit Customer", style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                            Text("Update information carefully", style: TextStyle(color: Colors.white70, fontSize: 14)),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
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
                          icon: Icons.person_outline,
                          controller: _fnameController,
                        ),
                        const SizedBox(height: 15),
                        _buildInputField(
                          label: "Last Name",
                          icon: Icons.person_outline,
                          controller: _lnameController,
                        ),
                        const SizedBox(height: 15),
                        _buildInputField(
                          label: "Email Address",
                          icon: Icons.email_outlined,
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 15),
                        _buildInputField(
                          label: "Phone Number",
                          icon: Icons.phone_outlined,
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                        ),
                        const SizedBox(height: 15),
                        _buildInputField(
                          label: "National ID",
                          icon: Icons.badge_outlined,
                          controller: _nationalIDController,
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: 30),
                        GestureDetector(
                          onTap: _isSaving ? null : _updateCustomer,
                          child: Container(
                            width: double.infinity,
                            height: 60,
                            decoration: BoxDecoration(
                              color: const Color(0xFFFF6B00),
                              borderRadius: BorderRadius.circular(15),
                              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 5))],
                            ),
                            child: Center(
                              child: _isSaving
                                  ? const CircularProgressIndicator(color: Colors.white)
                                  : const Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.check_circle_outline, color: Colors.white),
                                        SizedBox(width: 10),
                                        Text("Save Changes", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                                      ],
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required String label,
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
              Icon(icon, color: const Color(0xFFFF6B00), size: 20),
              const SizedBox(width: 8),
              Text(label, style: const TextStyle(color: Color(0xFF1E293B), fontWeight: FontWeight.bold, fontSize: 16)),
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

              // Email validation
              if (label == "Email Address") {
                final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                if (!emailRegex.hasMatch(value.trim())) {
                  return "Enter valid email";
                }
              }

              // Phone validation
              if (label == "Phone Number") {
                final phoneRegex = RegExp(r'^[0-9]{11}$');
                if (!phoneRegex.hasMatch(value.trim())) {
                  return "Phone must be 11 digits";
                }
              }

              // National ID validation
              if (label == "National ID") {
                final nationalRegex = RegExp(r'^[0-9]{14}$');
                if (!nationalRegex.hasMatch(value.trim())) {
                  return "National ID must be 14 digits";
                }
              }

              // Name validation
              if (label == "First Name" || label == "Last Name") {
                final nameRegex = RegExp(r'^[a-zA-Z\s]+$');
                if (!nameRegex.hasMatch(value.trim())) {
                  return "Only letters allowed";
                }
              }

              return null;
            },
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.grey[50],
              contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
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