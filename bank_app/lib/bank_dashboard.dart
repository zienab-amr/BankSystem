import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'add_account.dart';
import 'edit_customer.dart';
import 'add_customer.dart';
import 'customer.dart';
import 'config.dart';

class Bank2DashboardScreen extends StatefulWidget {
  const Bank2DashboardScreen({super.key});

  @override
  State<Bank2DashboardScreen> createState() => _Bank2DashboardScreenState();
}

class _Bank2DashboardScreenState extends State<Bank2DashboardScreen> {
  final int currentBankId = 1;
  List<Customer> _customers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchCustomers();
  }

  Future<void> _deleteCustomer(int id) async {
    try {
      final url = Uri.parse("${AppConfig.baseUrl}/api/customers/$id");

      print("DELETE URL: $url");

      final response = await http.delete(url);

      print("Status: ${response.statusCode}");
      print("Body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 204) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Deleted successfully")),
        );
        _fetchCustomers();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Delete failed: ${response.statusCode}"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print("DELETE ERROR: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _fetchCustomers() async {
    setState(() => _isLoading = true);
    try {
      final response = await http.get(
        Uri.parse("${AppConfig.baseUrl}/api/customers/all"), // ✅ FIXED
      );

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        setState(() {
          _customers = data.map((c) => Customer.fromJson(c)).toList();
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      debugPrint("Connection Error: $e");
      setState(() => _isLoading = false);
    }
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
              child: RefreshIndicator(
                onRefresh: _fetchCustomers,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildActionButtons(),
                      const SizedBox(height: 25),
                      _buildSectionHeader(),
                      const SizedBox(height: 15),
                      _isLoading
                          ? const Center(child: CircularProgressIndicator(color: Colors.white))
                          : _customers.isEmpty
                              ? const Center(child: Text("No customers found", style: TextStyle(color: Colors.white)))
                              : Column(
                                  children: _customers
                                      .map((c) => CustomerCard(
                                            customer: c,
                                            onRefresh: _fetchCustomers,
                                            onDelete: _deleteCustomer,
                                          ))
                                      .toList(),
                                ),
                      const SizedBox(height: 25),
                      _buildAnalyticsSection(),
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
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
      decoration: const BoxDecoration(
        gradient: LinearGradient(colors: [Color(0xFF3B82F6), Color(0xFF2563EB)]),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(35),
          bottomRight: Radius.circular(35),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(height: 10),
          const Row(
            children: [
              Icon(Icons.account_balance_rounded, color: Colors.white, size: 35),
              SizedBox(width: 15),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("National Bank of Egypt", style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                  Text("NBEGEHCX", style: TextStyle(color: Colors.white70, fontSize: 14)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        _topActionButton(
          label: "Add\nCustomer",
          icon: Icons.person_add_alt_1_outlined,
          color: const Color(0xFF10B981),
          onTap: () async {
            await Navigator.push(context, MaterialPageRoute(builder: (context) => const AddCustomerScreen()));
            _fetchCustomers();
          },
        ),
        const SizedBox(width: 12),
        _topActionButton(
          label: "Add Account",
          icon: Icons.credit_card,
          color: const Color(0xFF3B82F6),
          onTap: () async {
            await Navigator.push(context, MaterialPageRoute(builder: (context) => AddAccountScreen(bankId: currentBankId)));
            _fetchCustomers();
          },
        ),
      ],
    );
  }

  Widget _buildSectionHeader() {
    return Row(
      children: [
        const Icon(Icons.people_outline, color: Color(0xFF3B82F6)),
        const SizedBox(width: 8),
        const Text("Customers", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
        const Spacer(),
        Container(
          padding: const EdgeInsets.all(8),
          decoration: const BoxDecoration(color: Color(0xFF1E293B), shape: BoxShape.circle),
          child: Text("${_customers.length}", style: const TextStyle(color: Color(0xFF3B82F6))),
        ),
      ],
    );
  }

  Widget _buildAnalyticsSection() {
    return Column(
      children: [
        const Row(
          children: [
            Icon(Icons.analytics_outlined, color: Color(0xFF3B82F6)),
            SizedBox(width: 8),
            Text("Analytics & Reports", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 15),
        _analyticsButton("Show VIP Customers", const Color(0xFFF59E0B), const Color(0xFFEA580C), Icons.trending_up),
        const SizedBox(height: 12),
        _analyticsButton("Total Balance", const Color(0xFF10B981), const Color(0xFF059669), Icons.attach_money),
      ],
    );
  }

  Widget _topActionButton({required String label, required IconData icon, required Color color, required VoidCallback onTap}) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Container(
          height: 100,
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(20)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 30),
              const SizedBox(height: 8),
              Text(label, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _analyticsButton(String title, Color c1, Color c2, IconData icon) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(gradient: LinearGradient(colors: [c1, c2]), borderRadius: BorderRadius.circular(15)),
      child: Row(
        children: [
          Icon(icon, color: Colors.white),
          const SizedBox(width: 15),
          Text(title, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class CustomerCard extends StatelessWidget {
  final Customer customer;
  final VoidCallback onRefresh;
  final Future<void> Function(int id) onDelete;

  const CustomerCard({
    super.key,
    required this.customer,
    required this.onRefresh,
    required this.onDelete,
  });

  void _showDeleteConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Delete Customer'),
          content: Text('Are you sure you want to delete ${customer.firstName} ${customer.lastName}?'),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
            TextButton(
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                await onDelete(customer.id);
                onRefresh();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("${customer.firstName} ${customer.lastName}",
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Text(customer.phone, style: TextStyle(color: Colors.grey[600])),
                ],
              ),
              Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.edit_note, color: Colors.blue[700], size: 28),
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => EditCustomerScreen(customer: customer)),
                      );
                      onRefresh();
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: () => _showDeleteConfirmationDialog(context),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              _infoBox("Email", customer.email, const Color(0xFFEFF6FF), const Color(0xFF2563EB)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoBox(String label, String value, Color bg, Color textCol) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
        child: Column(
          children: [
            Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
            const SizedBox(height: 4),
            Text(value,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: textCol, fontSize: 14, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}