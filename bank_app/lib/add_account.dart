import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'config.dart'; // ✅ ADDED

class AddAccountScreen extends StatefulWidget {
  final int bankId;

  const AddAccountScreen({super.key, required this.bankId});

  @override
  State<AddAccountScreen> createState() => _AddAccountScreenState();
}

class _AddAccountScreenState extends State<AddAccountScreen> {
  final TextEditingController _balanceController = TextEditingController();
  String? _selectedAccountType;
  bool _isLoading = false;

  List<dynamic> _customers = [];
  int? _selectedCustomerId;

  final List<String> _accountTypes = ['savings', 'current', 'business'];

  @override
  void initState() {
    super.initState();
    _loadAllCustomers();
  }

  Future<void> _loadAllCustomers() async {
    try {
      final response = await http.get(
        Uri.parse("${AppConfig.baseUrl}/api/customers/all"), // ✅ FIXED
      );

      if (response.statusCode == 200) {
        if (mounted) {
          setState(() {
            _customers = jsonDecode(response.body);
          });
        }
      } else {
        debugPrint("Error: Failed to load customers");
      }
    } catch (e) {
      debugPrint("Connection Error: $e");
    }
  }

  Future<void> _createAccount() async {
    if (_selectedCustomerId == null || _selectedAccountType == null || _balanceController.text.isEmpty) {
      _showSnackBar("Please fill all fields!", Colors.orange);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final Map<String, dynamic> payload = {
        "accountType": _selectedAccountType,
        "balance": double.tryParse(_balanceController.text) ?? 0.0,
        "currency": "EGP",
        "status": "Active",
        "openedat": DateTime.now().toIso8601String(),
        "customerID": _selectedCustomerId,
        "bankID": widget.bankId,
      };

      final response = await http.post(
        Uri.parse("${AppConfig.baseUrl}/api/account"), // ✅ FIXED
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(payload),
      );

      if (!mounted) return;

      if (response.statusCode == 201 || response.statusCode == 200) {
        _onSuccess();
      } else {
        _showSnackBar("❌ Server Error: ${response.statusCode}", Colors.red);
      }
    } catch (e) {
      if (!mounted) return;
      _showSnackBar("❌ Connection Error: $e", Colors.red);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _onSuccess() {
    _showSnackBar("✅ Account added successfully!", Colors.green);
    if (mounted) Navigator.pop(context, true);
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
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: Transform.translate(
                offset: const Offset(0, -25),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      _buildCard(
                        label: "Select Customer",
                        icon: Icons.person_search_outlined,
                        child: DropdownButtonFormField<int>(
                          value: _selectedCustomerId,
                          isExpanded: true,
                          hint: const Text("Choose a customer"),
                          items: _customers.map<DropdownMenuItem<int>>((c) {
                            return DropdownMenuItem<int>(
                              value: c["customerID"],
                              child: Text("${c["fname"]} ${c["lname"]}"),
                            );
                          }).toList(),
                          onChanged: (v) => setState(() => _selectedCustomerId = v),
                          decoration: _inputDecoration(),
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildCard(
                        label: "Account Type",
                        icon: Icons.account_balance_wallet_outlined,
                        child: DropdownButtonFormField<String>(
                          value: _selectedAccountType,
                          hint: const Text("Select type"),
                          items: _accountTypes
                              .map((s) => DropdownMenuItem(value: s, child: Text(s.toUpperCase())))
                              .toList(),
                          onChanged: (v) => setState(() => _selectedAccountType = v),
                          decoration: _inputDecoration(),
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildCard(
                        label: "Initial Balance (EGP)",
                        icon: Icons.monetization_on_outlined,
                        child: TextField(
                          controller: _balanceController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: _inputDecoration(hint: "0.00"),
                        ),
                      ),
                      const SizedBox(height: 40),
                      _isLoading
                          ? const CircularProgressIndicator(color: Color(0xFF2D7CFF))
                          : _buildSubmitButton(),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 45),
      decoration: const BoxDecoration(
        color: Color(0xFF2D7CFF),
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
          const Text("Account Registration",
              style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold)),
          const Text("Link a customer to this bank office",
              style: TextStyle(color: Colors.white70, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildCard({required String label, required IconData icon, required Widget child}) {
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
              Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1E293B))),
            ],
          ),
          const SizedBox(height: 15),
          child,
        ],
      ),
    );
  }

  InputDecoration _inputDecoration({String? hint}) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.grey[50],
      contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[200]!)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[100]!)),
    );
  }

  Widget _buildSubmitButton() {
    return ElevatedButton(
      onPressed: _createAccount,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF2D7CFF),
        minimumSize: const Size(double.infinity, 60),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        elevation: 5,
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.add_task, color: Colors.white),
          SizedBox(width: 12),
          Text("Create Account", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}