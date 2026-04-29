import 'package:flutter/material.dart';
import 'banks.dart';

class AddBankScreen extends StatefulWidget {
  const AddBankScreen({super.key});

  @override
  State<AddBankScreen> createState() => _AddBankScreenState();
}

class _AddBankScreenState extends State<AddBankScreen> {
  bool isActive = true; // للتحكم في اختيار الحالة
  String? selectedCountry;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // الخلفية الزرقاء العميقة
      backgroundColor: const Color(0xff1a237e),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // الجزء العلوي البنفسجي المنحني
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(top: 60, left: 20, right: 20, bottom: 30),
              decoration: const BoxDecoration(
                color: Color(0xffa020f0),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    label: const Text("Back", style: TextStyle(color: Colors.white)),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: const Icon(Icons.account_balance, color: Colors.white, size: 30),
                      ),
                      const SizedBox(width: 15),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Add New Bank",
                            style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            "Register a new bank",
                            style: TextStyle(color: Colors.white70, fontSize: 14),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // حقل اسم البنك
                  _buildInputCard(
                    title: "Bank Name",
                    icon: Icons.account_balance_outlined,
                    child: _buildTextField("Enter bank name"),
                  ),
                  const SizedBox(height: 15),

                  // حقل SWIFT Code
                  _buildInputCard(
                    title: "SWIFT Code",
                    icon: Icons.code,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildTextField("XXXXXXXX"),
                        const Padding(
                          padding: EdgeInsets.only(top: 8, left: 5),
                          child: Text("8 or 11 characters (e.g., NBEGEHCX)", 
                            style: TextStyle(color: Colors.grey, fontSize: 12)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 15),

                  // حقل الدولة
                  _buildInputCard(
                    title: "Country",
                    icon: Icons.public,
                    child: _buildDropdown(),
                  ),
                  const SizedBox(height: 15),

                  // حقل الحالة (Status)
                  _buildInputCard(
                    title: "Status",
                    icon: Icons.check_circle_outline,
                    child: Row(
                      children: [
                        Expanded(child: _buildStatusButton("Active", true)),
                        const SizedBox(width: 10),
                        Expanded(child: _buildStatusButton("Inactive", false)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),

                  // زر الإضافة النهائي
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xffa020f0),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      ),
                      onPressed: () {},
                      icon: const Icon(Icons.save_outlined, color: Colors.white),
                      label: const Text("Add Bank", 
                        style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ويجيت لبناء الكروت البيضاء
  Widget _buildInputCard({required String title, required IconData icon, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xffa020f0), size: 20),
              const SizedBox(width: 10),
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
          const SizedBox(height: 15),
          child,
        ],
      ),
    );
  }

  Widget _buildTextField(String hint) {
    return TextField(
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.grey.shade50,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: Colors.grey.shade300)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: Colors.grey.shade300)),
      ),
    );
  }

  Widget _buildDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          hint: const Text("Select country"),
          value: selectedCountry,
          items: ['Egypt', 'United States', 'United Kingdom', 'Canada', 'Germany',
                'France', 'Italy', 'Spain', 'UAE', 'Saudi Arabia', 'Kuwait', 'Qatar'].map((String value) {
            return DropdownMenuItem<String>(value: value, child: Text(value));
          }).toList(),
          onChanged: (val) => setState(() => selectedCountry = val),
        ),
      ),
    );
  }

  Widget _buildStatusButton(String label, bool activeBtn) {
    bool isSelected = (activeBtn == isActive);
    return GestureDetector(
      onTap: () => setState(() => isActive = activeBtn),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? (activeBtn ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1)) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? (activeBtn ? Colors.green : Colors.red) : Colors.grey.shade300),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(activeBtn ? Icons.check_box : Icons.cancel, 
                 color: activeBtn ? Colors.green : Colors.red, size: 18),
            const SizedBox(width: 5),
            Text(label, style: TextStyle(color: activeBtn ? Colors.green : Colors.red, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}