import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'config.dart';

class AddCardScreen extends StatefulWidget {
  final int accountId;

  const AddCardScreen({super.key, required this.accountId});

  @override
  State<AddCardScreen> createState() => _AddCardScreenState();
}

class _AddCardScreenState extends State<AddCardScreen> {
  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _dailyLimitController = TextEditingController();
  
  String? _selectedCardType;
  String? _selectedStatus;
  DateTime? _selectedExpiryDate;
  bool _isLoading = false;

  final List<String> _cardTypes = ['debit', 'credit', 'prepaid'];
  final List<String> _statuses = ['active', 'blocked', 'expired'];

  String _formatDate(DateTime date) {
    return "${date.year}-${_twoDigits(date.month)}-${_twoDigits(date.day)}";
  }

  String _twoDigits(int n) {
    if (n >= 10) return "$n";
    return "0$n";
  }

  Future<void> _selectExpiryDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 365)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: const Color(0xFF2D7CFF),
            colorScheme: const ColorScheme.light(primary: Color(0xFF2D7CFF)),
            buttonTheme: const ButtonThemeData(textTheme: ButtonTextTheme.primary),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null) {
      setState(() {
        _selectedExpiryDate = picked;
      });
    }
  }

  Future<void> _createCard() async {
    if (_selectedCardType == null) {
      _showSnackBar("Please select card type!", Colors.orange);
      return;
    }
    
    if (_cardNumberController.text.isEmpty || _cardNumberController.text.replaceAll(' ', '').length != 16) {
      _showSnackBar("Please enter a valid 16-digit card number!", Colors.orange);
      return;
    }
    
    if (_selectedExpiryDate == null) {
      _showSnackBar("Please select expiry date!", Colors.orange);
      return;
    }
    
    if (_dailyLimitController.text.isEmpty) {
      _showSnackBar("Please enter daily limit!", Colors.orange);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final String cleanCardNumber = _cardNumberController.text.replaceAll(' ', '');
      final String maskedNumber = "**** **** **** ${cleanCardNumber.substring(cleanCardNumber.length - 4)}";
      final String expiryDate = _formatDate(_selectedExpiryDate!);
      final String cvvHash = _generateCvvHash(cleanCardNumber);
      
      // ✅ استخدام "cardtype" بدلاً من "cardType"
      final Map<String, dynamic> payload = {
        "cardtype": _selectedCardType,
        "maskedNumber": maskedNumber,
        "expiryDate": expiryDate,
        "cvvHash": cvvHash,
        "status": _selectedStatus ?? "active",
        "dailyLimit": double.tryParse(_dailyLimitController.text) ?? 1000.0,
        "accountID": {
          "accountID": widget.accountId
        }
      };

      print("📤 Sending payload to: ${AppConfig.baseUrl}/api/card");
      print("📤 Payload: ${jsonEncode(payload)}");

      final response = await http.post(
        Uri.parse("${AppConfig.baseUrl}/api/card"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(payload),
      );

      if (!mounted) return;

      print("📥 Response status: ${response.statusCode}");
      print("📥 Response body: ${response.body}");

      if (response.statusCode == 201 || response.statusCode == 200) {
        _showSnackBar("✅ Card issued successfully!", Colors.green);
        Navigator.pop(context, true);
      } else {
        _showSnackBar("❌ Error: ${response.body}", Colors.red);
      }
    } catch (e) {
      if (!mounted) return;
      print("❌ Error: $e");
      _showSnackBar("❌ Connection Error: $e", Colors.red);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _generateCvvHash(String cardNumber) {
    String combined = cardNumber + DateTime.now().millisecondsSinceEpoch.toString();
    String hash = combined.hashCode.abs().toString();
    return hash.length > 30 ? hash.substring(0, 30) : hash.padRight(30, '0');
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
                        label: "Card Category",
                        icon: Icons.credit_card_outlined,
                        child: DropdownButtonFormField<String>(
                          value: _selectedCardType,
                          hint: const Text("Select card type"),
                          items: _cardTypes
                              .map((s) => DropdownMenuItem(value: s, child: Text(s.toUpperCase())))
                              .toList(),
                          onChanged: (v) => setState(() => _selectedCardType = v),
                          decoration: _inputDecoration(),
                        ),
                      ),
                      const SizedBox(height: 20),

                      _buildCard(
                        label: "Card Number (16 digits)",
                        icon: Icons.numbers,
                        child: TextField(
                          controller: _cardNumberController,
                          maxLength: 19,
                          keyboardType: TextInputType.number,
                          decoration: _inputDecoration(hint: "1234 5678 9012 3456"),
                          onChanged: (value) {
                            String cleanValue = value.replaceAll(' ', '');
                            if (cleanValue.length > 16) {
                              cleanValue = cleanValue.substring(0, 16);
                            }
                            
                            String formatted = '';
                            for (int i = 0; i < cleanValue.length; i++) {
                              if (i > 0 && i % 4 == 0) {
                                formatted += ' ';
                              }
                              formatted += cleanValue[i];
                            }
                            
                            if (formatted != value) {
                              _cardNumberController.value = TextEditingValue(
                                text: formatted,
                                selection: TextSelection.fromPosition(
                                  TextPosition(offset: formatted.length),
                                ),
                              );
                            }
                          },
                        ),
                      ),
                      const SizedBox(height: 20),

                      _buildCard(
                        label: "Expiry Date",
                        icon: Icons.calendar_today,
                        child: InkWell(
                          onTap: () => _selectExpiryDate(context),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                            decoration: BoxDecoration(
                              color: Colors.grey[50],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey[200]!),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  _selectedExpiryDate != null
                                      ? "${_selectedExpiryDate!.year}-${_twoDigits(_selectedExpiryDate!.month)}"
                                      : "Select expiry date",
                                  style: TextStyle(
                                    color: _selectedExpiryDate != null ? Colors.black : Colors.grey,
                                  ),
                                ),
                                Icon(Icons.calendar_today, color: Colors.grey[600], size: 20),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      _buildCard(
                        label: "Daily Spend Limit (EGP)",
                        icon: Icons.speed_outlined,
                        child: TextField(
                          controller: _dailyLimitController,
                          keyboardType: TextInputType.number,
                          decoration: _inputDecoration(hint: "3000.00"),
                        ),
                      ),
                      const SizedBox(height: 20),

                      _buildCard(
                        label: "Card Status",
                        icon: Icons.toggle_on,
                        child: DropdownButtonFormField<String>(
                          value: _selectedStatus,
                          hint: const Text("Select status (default: active)"),
                          items: _statuses
                              .map((s) => DropdownMenuItem(value: s, child: Text(s.toUpperCase())))
                              .toList(),
                          onChanged: (v) => setState(() => _selectedStatus = v),
                          decoration: _inputDecoration(),
                        ),
                      ),

                      const SizedBox(height: 30),
                      
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.blue[200]!),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.info_outline, color: Colors.blue[700], size: 20),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                "The card will be linked to Account #${widget.accountId}\nCreated date will be set automatically by the server.",
                                style: TextStyle(color: Colors.blue[700], fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 30),
                      
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
          const Text("Issue New Card",
              style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold)),
          Text("Linking card to Account ID: #${widget.accountId}",
              style: const TextStyle(color: Colors.white70, fontSize: 14)),
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
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFF2563EB), size: 20),
              const SizedBox(width: 8),
              Text(label,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1E293B))),
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
      counterText: "",
      contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[200]!)),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[100]!)),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12), 
          borderSide: const BorderSide(color: Color(0xFF2D7CFF), width: 2)),
    );
  }

  Widget _buildSubmitButton() {
    return ElevatedButton(
      onPressed: _createCard,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF2D7CFF),
        minimumSize: const Size(double.infinity, 60),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        elevation: 5,
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.credit_card, color: Colors.white),
          SizedBox(width: 12),
          Text("Issue Card",
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}