import 'package:flutter/material.dart';
import 'add_account.dart'; 
import 'edit_customer.dart'; 
import 'add_customer.dart';  

class BankDashboardScreen extends StatelessWidget {
  const BankDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF101D3D),
      body: SafeArea(
        child: Column(
          children: [
            // ================= HEADER =================
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF3B82F6), Color(0xFF2563EB)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(35),
                  bottomRight: Radius.circular(35),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.arrow_back, color: Colors.white),
                      SizedBox(width: 10),
                      Text("Back", style: TextStyle(color: Colors.white, fontSize: 18)),
                    ],
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
                        child: const Icon(Icons.account_balance_rounded, color: Colors.white, size: 35),
                      ),
                      const SizedBox(width: 15),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("National Bank of Egypt", style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                          Text("NBEGEHCX", style: TextStyle(color: Colors.white70, fontSize: 14)),
                        ],
                      )
                    ],
                  ),
                ],
              ),
            ),

            // ================= MAIN CONTENT =================
            Expanded(
              child: Transform.translate(
                offset: const Offset(0, -25),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          _topActionButton(
                            label: "Add\nCustomer",
                            icon: Icons.person_add_alt_1_outlined,
                            color: const Color(0xFF10B981),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const AddCustomerScreen()),
                              );
                            },
                          ),
                          const SizedBox(width: 12),
                          _topActionButton(
                            label: "Add Account",
                            icon: Icons.credit_card,
                            color: const Color(0xFF3B82F6),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const AddAccountScreen()),
                                 );
                                },
                          ),
                        ],
                      ),
                      const SizedBox(height: 25),
                      Row(
                        children: [
                          const Icon(Icons.people_outline, color: Color(0xFF3B82F6)),
                          const SizedBox(width: 8),
                          const Text("Customers", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(color: Color(0xFF1E293B), shape: BoxShape.circle),
                            child: const Text("5", style: TextStyle(color: Color(0xFF3B82F6))),
                          )
                        ],
                      ),
                      const SizedBox(height: 15),
                      const CustomerCard(name: "Ahmed Mohamed", phone: "+20 100 123 4567", accounts: 2, balance: "125,000"),
                      const CustomerCard(name: "Sara Ali", phone: "+20 101 234 5678", accounts: 1, balance: "450,000"),
                      const CustomerCard(name: "Mohamed Hassan", phone: "+20 102 345 6789", accounts: 3, balance: "89,000"),
                      const CustomerCard(name: "Fatma Ibrahim", phone: "+20 111 456 7890", accounts: 1, balance: "320,000"),
                      const CustomerCard(name: "Youssef Ali", phone: "+20 122 789 1234", accounts: 2, balance: "210,000"),
                      const SizedBox(height: 25),
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

  Widget _topActionButton({required String label, required IconData icon, required Color color, required VoidCallback onTap}) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
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
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: Colors.white),
          ),
          const SizedBox(width: 15),
          Text(title, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class CustomerCard extends StatelessWidget {
  final String name;
  final String phone;
  final int accounts;
  final String balance;

  const CustomerCard({super.key, required this.name, required this.phone, required this.accounts, required this.balance});

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
                  Text(name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Text(phone, style: TextStyle(color: Colors.grey[600])),
                ],
              ),
               Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditCustomerScreen(
                            initialName:name ,   // هنا بنمرر متغير الـ name بتاع الكارت
                            initialPhone:phone, // هنا بنمرر متغير الـ phone بتاع الكارت
                          ),
                        ),
                      );
                    },
                    child: Icon(Icons.edit_note, color: Colors.blue[700]),
                  ),
                  const SizedBox(width: 10),
                  const Icon(Icons.delete_outline, color: Colors.red),
                ],
              )
            ],
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              _infoBox("Accounts", accounts.toString(), const Color(0xFFEFF6FF), const Color(0xFF2563EB)),
              const SizedBox(width: 10),
              _infoBox("Balance", balance, const Color(0xFFF0FDF4), const Color(0xFF16A34A)),
            ],
          )
        ],
      ),
    );
  }

  Widget _infoBox(String label, String value, Color bg, Color textCol) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
        child: Column(
          children: [
            Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
            const SizedBox(height: 4),
            Text(value, style: TextStyle(color: textCol, fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}