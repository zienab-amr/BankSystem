import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'add_bank.dart';
import 'add_account.dart';
import 'edit_customer.dart';
import 'add_customer.dart';

// ─────────────────────────────────────────
// MODEL
// ─────────────────────────────────────────

class BankModel {
  final String id;
  final String name;
  final String swiftCode;
  final String country;
  final bool isActive;

  const BankModel({
    required this.id,
    required this.name,
    required this.swiftCode,
    required this.country,
    required this.isActive,
  });

  factory BankModel.fromJson(Map<String, dynamic> json) {
    return BankModel(
      id: json['bankID'].toString(),
      name: json['bankname'],
      swiftCode: json['swiftCode'],
      country: json['country'],
      isActive: json['status'] == 'active',
    );
  }
}

// ─────────────────────────────────────────
// REPOSITORY
// ─────────────────────────────────────────

class BankRepository {
  static const String _baseUrl = 'http://localhost:8080/api';
  static const int _pageSize = 10;

  Future<List<BankModel>> fetchBanks({required int page}) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/banks?page=$page&pageSize=$_pageSize'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => BankModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load banks: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
}

// ─────────────────────────────────────────
// SCREEN (قائمة البنوك الرئيسية)
// ─────────────────────────────────────────

class BankDashboardScreen extends StatefulWidget {
  const BankDashboardScreen({super.key});

  @override
  State<BankDashboardScreen> createState() => _BankDashboardScreenState();
}

class _BankDashboardScreenState extends State<BankDashboardScreen> {
  final _repo = BankRepository();
  final _scrollController = ScrollController();

  final List<BankModel> _banks = [];
  int _currentPage = 0;
  bool _isLoading = false;
  bool _hasMore = true;

  int get _activeBanks => _banks.where((b) => b.isActive).length;
  int get _inactiveBanks => _banks.where((b) => !b.isActive).length;

  @override
  void initState() {
    super.initState();
    _loadMore();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 200 &&
          !_isLoading &&
          _hasMore) {
        _loadMore();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadMore() async {
    if (_isLoading || !_hasMore) return;
    setState(() => _isLoading = true);
    
    try {
      final newBanks = await _repo.fetchBanks(page: _currentPage);
      setState(() {
        _banks.addAll(newBanks);
        _currentPage++;
        _isLoading = false;
        if (newBanks.isEmpty) _hasMore = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      print('Error: $e');
    }
  }

  Future<void> _refresh() async {
    setState(() {
      _banks.clear();
      _currentPage = 0;
      _hasMore = true;
    });
    await _loadMore();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refresh,
          child: CustomScrollView(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverAppBar(
                expandedHeight: 180,
                pinned: true,
                backgroundColor: const Color(0xFF1D4ED8),
                flexibleSpace: FlexibleSpaceBar(
                  background: _buildHeader(),
                ),
                title: const Text(
                  'Central Bank',
                  style: TextStyle(color: Colors.white, fontSize: 17),
                ),
              ),

              SliverToBoxAdapter(child: _buildFilterRow()),

              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      if (index < _banks.length) {
                        return _BankCard(bank: _banks[index]);
                      }
                      return _hasMore
                          ? const Padding(
                              padding: EdgeInsets.symmetric(vertical: 20),
                              child: Center(child: CircularProgressIndicator()),
                            )
                          : const Padding(
                              padding: EdgeInsets.all(24),
                              child: Center(
                                child: Text(
                                  'All banks loaded',
                                  style: TextStyle(color: Color(0xFF9CA3AF)),
                                ),
                              ),
                            );
                    },
                    childCount: _banks.length + 1,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return SafeArea(
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.account_balance,
                      color: Colors.white, size: 22),
                ),
                const SizedBox(width: 12),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Central Bank',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600)),
                    Text('Dashboard',
                        style: TextStyle(color: Colors.white70, fontSize: 12)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildStatsRow(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard('Total', '${_banks.length}', const Color(0xFF111827)),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildStatCard('Active', '$_activeBanks', const Color(0xFF2563EB)),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildStatCard('Inactive', '$_inactiveBanks', const Color(0xFFEF4444)),
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280))),
          const SizedBox(height: 4),
          Text(value,
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: color)),
        ],
      ),
    );
  }

  Widget _buildFilterRow() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.list_alt, size: 20, color: Color(0xFF374151)),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text('All Banks',
                        style: TextStyle(
                            fontSize: 13, color: Color(0xFF374151))),
                  ),
                  Icon(Icons.keyboard_arrow_down, color: Color(0xFF9CA3AF)),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddBankScreen()),
              );
              if (result == true) {
                _refresh();
              }
            },
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFF7C3AED),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.add, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────
// BANK CARD WIDGET (بقابل للضغط)
// ─────────────────────────────────────────

class _BankCard extends StatelessWidget {
  final BankModel bank;

  const _BankCard({required this.bank});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => BankDetailsScreen(
              bankId: bank.id,
              bankName: bank.name,
              swiftCode: bank.swiftCode,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE5E7EB), width: 0.5),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2563EB),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.account_balance,
                        color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(bank.name,
                            style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF111827)),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 2),
                        Text(bank.swiftCode,
                            style: const TextStyle(
                                fontSize: 11, color: Color(0xFF9CA3AF))),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right,
                      color: Color(0xFF9CA3AF), size: 18),
                ],
              ),
            ),
            const Divider(height: 0.5, thickness: 0.5, color: Color(0xFFF3F4F6)),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 8, 14, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 7,
                        height: 7,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: bank.isActive
                              ? const Color(0xFF10B981)
                              : const Color(0xFFEF4444),
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(bank.country,
                          style: const TextStyle(
                              fontSize: 12, color: Color(0xFF374151))),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: bank.isActive
                          ? const Color(0xFFD1FAE5)
                          : const Color(0xFFFEE2E2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      bank.isActive ? 'Active' : 'Inactive',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: bank.isActive
                            ? const Color(0xFF065F46)
                            : const Color(0xFF991B1B),
                      ),
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
}

// ─────────────────────────────────────────
// BANK DETAILS SCREEN (صفحة تفاصيل البنك مع جلب العملاء من API)
// ─────────────────────────────────────────

class BankDetailsScreen extends StatefulWidget {
  final String bankId;
  final String bankName;
  final String swiftCode;

  const BankDetailsScreen({
    super.key,
    required this.bankId,
    required this.bankName,
    required this.swiftCode,
  });

  @override
  State<BankDetailsScreen> createState() => _BankDetailsScreenState();
}

class _BankDetailsScreenState extends State<BankDetailsScreen> {
  List<Map<String, dynamic>> _customers = [];
  bool _isLoadingCustomers = true;

  @override
  void initState() {
    super.initState();
    _loadCustomersForBank();
  }

  Future<void> _loadCustomersForBank() async {
    setState(() => _isLoadingCustomers = true);
    
    try {
      // ✅ جلب العملاء من API حسب bankId
      final response = await http.get(
        Uri.parse('http://localhost:8080/api/customers?bankId=${widget.bankId}'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          _customers = data.map((json) => {
            'id': json['customerID'].toString(),
            'name': '${json['fname'] ?? ''} ${json['lname'] ?? ''}'.trim(),
            'phone': json['phone'] ?? '',
            'accounts': json['accountsCount'] ?? 0,
            'balance': json['totalBalance']?.toString() ?? '0',
          }).toList();
          _isLoadingCustomers = false;
        });
      } else {
        throw Exception('Failed to load customers');
      }
    } catch (e) {
      setState(() {
        _isLoadingCustomers = false;
        _customers = [];
      });
      print('Error loading customers: $e');
      
      // عرض رسالة خطأ للمستخدم
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load customers: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

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
                        child: const Icon(Icons.account_balance_rounded, color: Colors.white, size: 35),
                      ),
                      const SizedBox(width: 15),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(widget.bankName,
                              style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                          Text(widget.swiftCode,
                              style: const TextStyle(color: Colors.white70, fontSize: 14)),
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
                            onTap: () async {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const AddCustomerScreen()),
                              );
                              if (result == true) {
                                _loadCustomersForBank();
                              }
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
                            child: Text("${_customers.length}", style: const TextStyle(color: Color(0xFF3B82F6))),
                          )
                        ],
                      ),
                      const SizedBox(height: 15),
                      
                      // ✅ عرض العملاء أو مؤشر تحميل
                      if (_isLoadingCustomers)
                        const Center(child: CircularProgressIndicator())
                      else if (_customers.isEmpty)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(32),
                            child: Text("No customers found for this bank", style: TextStyle(color: Colors.white70)),
                          ),
                        )
                      else
                        ..._customers.map((customer) => CustomerCard(
                          name: customer['name'],
                          phone: customer['phone'],
                          accounts: customer['accounts'],
                          balance: customer['balance'],
                        )).toList(),
                        
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

// ─────────────────────────────────────────
// CUSTOMER CARD WIDGET
// ─────────────────────────────────────────

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
                            initialName: name,
                            initialPhone: phone,
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