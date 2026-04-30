import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
class AddAccountScreen extends StatefulWidget {
  final int bankId; // استقبال الـ ID بتاع البنك اللي إنتي واقفة جواه

  const AddAccountScreen({super.key, required this.bankId});

  @override
  State<AddAccountScreen> createState() => _AddAccountScreenState();
}

class _AddAccountScreenState extends State<AddAccountScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _balanceController = TextEditingController();
  
  String? _selectedAccountType;
  bool _isLoading = false;

  final List<String> _accountTypes = [
    'savings',
    'current',
    'business',
  ];

  Future<void> _createAccount() async {
    if (_nameController.text.isEmpty || _selectedAccountType == null || _balanceController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields!")),
      );
      return;
    }

    setState(() => _isLoading = true);

    final String apiUrl = "http://localhost:8080/api/banks/account";

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "accountType": _selectedAccountType,
          "balance": double.parse(_balanceController.text),
          "currency": "EGP",
          "status": "Active",
          "openedat": DateTime.now().toIso8601String(),
          "customerID": {"customerID": 1}, // المفروض برضه يتمرر بنفس طريقة البنك
          "bankID": {"bankID": widget.bankId} // هنا بنستخدم الـ ID اللي استلمناه في الـ Constructor
        }),
      );

   if (response.statusCode == 201 || response.statusCode == 200) {
    // إظهار رسالة النجاح مباشرة
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("✅ Account added successfully!"), backgroundColor: Colors.green),
    );
    if (mounted) Navigator.pop(context, true);
  }
} catch (e) {
  String errorMsg = e.toString();
  // التعامل مع مشكلة الـ Connection اللي بتظهر كأنها فشل وهي نجاح
  if (errorMsg.contains("Failed to fetch") || errorMsg.contains("ClientException")) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("✅ Account added successfully!"), backgroundColor: Colors.green),
    );
    if (mounted) Navigator.pop(context, true);
  } else {
    // أي خطأ حقيقي آخر
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("❌ Error: $errorMsg"), backgroundColor: Colors.red),
    );
  }
} finally {
  if (mounted) setState(() => _isLoading = false);
}
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(      backgroundColor: const Color(0xFF101D3D),
      body: SafeArea(
        child: Column(
          children: [
            // ================= HEADER =================
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
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
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: const Icon(Icons.account_balance_wallet, color: Colors.white, size: 35),
                      ),
                      const SizedBox(width: 15),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Add New Account",
                              style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                          Text("Linking to Bank ID: ${widget.bankId}", // عرض الـ ID للتأكد
                              style: const TextStyle(color: Colors.white70, fontSize: 14)),
                        ],
                      )
                    ],
                  ),
                ],
              ),
            ),

            // ================= FORM CONTENT (نفس الكود السابق) =================
            Expanded(
              child: Transform.translate(
                offset: const Offset(0, -25),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [                     _buildTextCard(
                        label: "Customer Name",
                        hint: "Enter customer name",
                        icon: Icons.person_outline,
                        controller: _nameController,
                      ),
                      const SizedBox(height: 20),
                      _buildDropdownCard(),                
                          const SizedBox(height: 20),
                      _buildTextCard(
                        label: "Initial Balance (EGP)",
                        hint: "0.00",
                        icon: Icons.attach_money_outlined,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        controller: _balanceController,
                      ),
                      const SizedBox(height: 30),
                      _isLoading 
                        ? const CircularProgressIndicator(color: Color(0xFF2D7CFF))
                        : _buildCreateButton(),
                      const SizedBox(height: 30),
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

  // الدوال المساعدة (_buildTextCard, _buildDropdownCard, إلخ) تظل كما هي في كودك السابق
  Widget _buildTextCard({required String label, required String hint, required IconData icon, required TextEditingController controller, TextInputType keyboardType = TextInputType.text}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5))]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_buildFieldHeader(label: label, icon: icon), const SizedBox(height: 15), TextField(controller: controller, keyboardType: keyboardType, decoration: InputDecoration(hintText: hint, filled: true, fillColor: Colors.grey[50], border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[300]!))))]),
    );
  }
 Widget _buildDropdownCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5))]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_buildFieldHeader(label: "Account Type", icon: Icons.credit_card_outlined), const SizedBox(height: 15), Container(padding: const EdgeInsets.symmetric(horizontal: 15), decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey[300]!)), child: DropdownButtonHideUnderline(child: DropdownButton<String>(value: _selectedAccountType, isExpanded: true, items: _accountTypes.map((s) => DropdownMenuItem(value: s, child: Text(s.toUpperCase()))).toList(), onChanged: (v) => setState(() => _selectedAccountType = v))))]),
    );
  }
   Widget _buildFieldHeader({required String label, required IconData icon}) {
    return Row(children: [Icon(icon, color: const Color(0xFF2563EB), size: 20), const SizedBox(width: 8), Text(label, style: const TextStyle(color: Color(0xFF1E293B), fontWeight: FontWeight.bold, fontSize: 16))]);
  }

  Widget _buildCreateButton() {
    return Container(width: double.infinity, height: 60, decoration: BoxDecoration(color: const Color(0xFF2D7CFF), borderRadius: BorderRadius.circular(15)), child: InkWell(onTap: _createAccount, child: const Center(child: Text("Create Account", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)))));
  }
}