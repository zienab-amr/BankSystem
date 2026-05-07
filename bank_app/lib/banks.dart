import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'add_bank.dart';
import 'add_account.dart';
import 'edit_customer.dart';
import 'add_customer.dart';
import 'customer.dart';
import 'config.dart';

// ─────────────────────────────────────────
// MODEL (BankModel)
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
  static const int _pageSize = 10;

  Future<List<BankModel>> fetchBanks({required int page}) async {
    try {
      final response = await http.get(
        Uri.parse('${AppConfig.baseUrl}/api/banks?page=$page&pageSize=$_pageSize'),
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

Future<void> deleteBank(String id) async {
  print('🗑️ Attempting to delete bank with ID: $id');
  

  
  // أو جرب DELETE مع headers إضافية
  final response = await http.delete(
    Uri.parse('${AppConfig.baseUrl}/api/banks/$id'),
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'X-HTTP-Method-Override': 'DELETE', // 🔥 مهم ده أحياناً
    },
  );
}
  Future<void> updateBank(String id, String name, String swiftCode, String status) async {
    final response = await http.put(
      Uri.parse('${AppConfig.baseUrl}/api/banks/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'bankname': name,
        'swiftCode': swiftCode,
        'country': 'Egypt',
        'status': status,
      }),
    );
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to update bank: ${response.statusCode}');
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
  String _filter = 'All';

  int get _activeBanks => _banks.where((b) => b.isActive).length;
  int get _inactiveBanks => _banks.where((b) => !b.isActive).length;

  List<BankModel> get _filteredBanks {
    if (_filter == 'Active') return _banks.where((b) => b.isActive).toList();
    if (_filter == 'Inactive') return _banks.where((b) => !b.isActive).toList();
    return _banks;
  }

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

 Future<void> _deleteBank(BankModel bank) async {
  final confirm = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Delete Bank'),
      content: Text('Are you sure you want to delete "${bank.name}"?'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
        TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete', style: TextStyle(color: Colors.red))),
      ],
    ),
  );
  if (confirm != true) return;

  try {
    final response = await http.delete(
      Uri.parse('${AppConfig.baseUrl}/api/banks/${bank.id}'),
      headers: {'Content-Type': 'application/json'}, // ✅ زيه زي Customer
    );
    
    if (response.statusCode == 200 || response.statusCode == 204) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Bank deleted successfully'), backgroundColor: Colors.green),
        );
        _refresh();
      }
    } else {
      throw Exception('Failed to delete');
    }
  } catch (e) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }
}

void _editBank(BankModel bank) {
  final nameController = TextEditingController(text: bank.name);
  final swiftController = TextEditingController(text: bank.swiftCode);
  bool isActive = bank.isActive;
  bool isSaving = false;

  showDialog(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setStateDialog) => AlertDialog(
        title: const Text('Edit Bank'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Bank Name'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: swiftController,
              decoration: const InputDecoration(labelText: 'SWIFT Code'),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Status:'),
                Switch(
                  value: isActive,
                  onChanged: (val) => setStateDialog(() => isActive = val),
                  activeColor: Colors.green,
                ),
                Text(
                  isActive ? 'Active' : 'Inactive',
                  style: TextStyle(
                    color: isActive ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: isSaving
                ? null
                : () async {
                    setStateDialog(() => isSaving = true);
                    
                    print("🔥 PUT URL: ${AppConfig.baseUrl}/api/banks/${bank.id}");
                    
                    try {
                      final response = await http.put(
                        Uri.parse('${AppConfig.baseUrl}/api/banks/${bank.id}'),
                        headers: {'Content-Type': 'application/json'},
                        body: jsonEncode({
                          'bankname': nameController.text.trim(),
                          'swiftCode': swiftController.text.trim(),
                          'country': 'Egypt',
                          'status': isActive ? 'active' : 'suspended',
                        }),
                      );

                      print("🔥 Response status: ${response.statusCode}");
                      print("🔥 Response body: ${response.body}");

                      if (!mounted) return;
if (ctx.mounted) Navigator.pop(ctx);
                      if (response.statusCode == 200 || response.statusCode == 204) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('✅ Bank updated successfully'),
                            backgroundColor: Colors.green,
                          ),
                        );
                        _refresh();
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('❌ Failed: ${response.statusCode} - ${response.body}'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    } catch (e) {
                      print("🔥 ERROR: $e");
                      if (!mounted) return;
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('❌ Error: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
            child: isSaving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Save'),
          ),
        ],
      ),
    ),
  );
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
                      if (index < _filteredBanks.length) {
                        return _BankCard(
                          bank: _filteredBanks[index],
                          onDelete: () => _deleteBank(_filteredBanks[index]),
                          onEdit: () => _editBank(_filteredBanks[index]),
                        );
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
                    childCount: _filteredBanks.length + 1,
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
                  child: const Icon(Icons.account_balance, color: Colors.white, size: 22),
                ),
                const SizedBox(width: 12),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Central Bank', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
                    Text('Dashboard', style: TextStyle(color: Colors.white70, fontSize: 12)),
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
        Expanded(child: _buildStatCard('Total', '${_banks.length}', const Color(0xFF111827))),
        const SizedBox(width: 8),
        Expanded(child: _buildStatCard('Active', '$_activeBanks', const Color(0xFF2563EB))),
        const SizedBox(width: 8),
        Expanded(child: _buildStatCard('Inactive', '$_inactiveBanks', const Color(0xFFEF4444))),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280))),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: color)),
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
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _filter,
                  icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF9CA3AF)),
                  style: const TextStyle(fontSize: 13, color: Color(0xFF374151)),
                  onChanged: (value) {
                    if (value != null) setState(() => _filter = value);
                  },
                  items: const [
                    DropdownMenuItem(value: 'All', child: Row(children: [Icon(Icons.list_alt, size: 18, color: Color(0xFF374151)), SizedBox(width: 8), Text('All Banks')])),
                    DropdownMenuItem(value: 'Active', child: Row(children: [Icon(Icons.check_circle_outline, size: 18, color: Color(0xFF10B981)), SizedBox(width: 8), Text('Active')])),
                    DropdownMenuItem(value: 'Inactive', child: Row(children: [Icon(Icons.cancel_outlined, size: 18, color: Color(0xFFEF4444)), SizedBox(width: 8), Text('Inactive')])),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () async {
              final result = await Navigator.push(context, MaterialPageRoute(builder: (_) => const AddBankScreen()));
              if (result == true) _refresh();
            },
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(color: const Color(0xFF7C3AED), borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.add, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────
// BANK CARD WIDGET
// ─────────────────────────────────────────

class _BankCard extends StatelessWidget {
  final BankModel bank;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const _BankCard({
    required this.bank,
    required this.onDelete,
    required this.onEdit,
  });

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
              padding: const EdgeInsets.fromLTRB(14, 14, 4, 10),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(color: const Color(0xFF2563EB), borderRadius: BorderRadius.circular(10)),
                    child: const Icon(Icons.account_balance, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(bank.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF111827)), maxLines: 1, overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 2),
                        Text(bank.swiftCode, style: const TextStyle(fontSize: 11, color: Color(0xFF9CA3AF))),
                      ],
                    ),
                  ),
                  IconButton(icon: const Icon(Icons.edit_note, color: Color(0xFF2563EB), size: 22), onPressed: onEdit, tooltip: 'Edit'),
                  IconButton(icon: const Icon(Icons.delete_outline, color: Colors.red, size: 22), onPressed: onDelete, tooltip: 'Delete'),
                ],
              ),
            ),
            const Divider(height: 0.5, thickness: 0.5, color: Color(0xFFF3F4F6)),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 8, 14, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(children: [
                    Container(width: 7, height: 7, decoration: BoxDecoration(shape: BoxShape.circle, color: bank.isActive ? const Color(0xFF10B981) : const Color(0xFFEF4444))),
                    const SizedBox(width: 5),
                    Text(bank.country, style: const TextStyle(fontSize: 12, color: Color(0xFF374151))),
                  ]),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(color: bank.isActive ? const Color(0xFFD1FAE5) : const Color(0xFFFEE2E2), borderRadius: BorderRadius.circular(20)),
                    child: Text(bank.isActive ? 'Active' : 'Inactive', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: bank.isActive ? const Color(0xFF065F46) : const Color(0xFF991B1B))),
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
// BANK DETAILS SCREEN (WITH REPORTS)
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
  List<Customer> _customers = [];
  bool _isLoadingCustomers = true;

  @override
  void initState() {
    super.initState();
    _loadCustomersForBank();
  }

Future<List<Map<String, dynamic>>> fetchHighRisk() async {
  final response = await http.get(
    Uri.parse("${AppConfig.baseUrl}/api/reports/high-risk"),
  );
  if (response.statusCode == 200) {
    final List<dynamic> data = jsonDecode(response.body);
    return data.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  } else {
    throw Exception("Failed: ${response.statusCode}");
  }
}
Future<List<Map<String, dynamic>>> fetchCustomersByRiskLevel() async {
  final response = await http.get(
    Uri.parse("${AppConfig.baseUrl}/api/reports/risk-level"),
  );
  if (response.statusCode == 200) {
    final List<dynamic> data = jsonDecode(response.body);
    return data.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  } else {
    throw Exception("Failed: ${response.statusCode}");
  }
}

  Future<List<Map<String, dynamic>>> fetchTotalBalance() async {
    final response = await http.get(Uri.parse("${AppConfig.baseUrl}/api/reports/total-balance"));
    if (response.statusCode == 200) {
      List data = jsonDecode(response.body);
      return data.cast<Map<String, dynamic>>();
    } else {
      throw Exception("Failed to load report");
    }
  }

  Future<List<Map<String, dynamic>>> fetchVIP(double minBalance) async {
    final response = await http.get(Uri.parse("${AppConfig.baseUrl}/api/reports/vip?minBalance=$minBalance"));
    if (response.statusCode == 200) {
      List data = jsonDecode(response.body);
      return data.cast<Map<String, dynamic>>();
    } else {
      throw Exception("Failed VIP");
    }
  }

  Future<List<Map<String, dynamic>>> fetchBankRanking() async {
    final response = await http.get(Uri.parse("${AppConfig.baseUrl}/api/reports/bank-ranking"));
    if (response.statusCode == 200) {
      List data = jsonDecode(response.body);
      return data.cast<Map<String, dynamic>>();
    } else {
      throw Exception("Failed to load bank ranking");
    }
  }

  Future<List<Map<String, dynamic>>> fetchRecentCards() async {
    final response = await http.get(Uri.parse("${AppConfig.baseUrl}/api/reports/recent-cards"));
    if (response.statusCode == 200) {
      List data = jsonDecode(response.body);
      return data.cast<Map<String, dynamic>>();
    } else {
      throw Exception("Failed to load recent cards");
    }
  }

  Future<void> _loadCustomersForBank() async {
    setState(() => _isLoadingCustomers = true);

    try {
      final response = await http.get(
        Uri.parse('${AppConfig.baseUrl}/api/customers?bankId=${widget.bankId}'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          _customers = data.map((json) => Customer.fromJson(json)).toList();
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

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Failed to load customers: $e'),
              backgroundColor: Colors.red),
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
                          Text(widget.bankName, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                          Text(widget.swiftCode, style: const TextStyle(color: Colors.white70, fontSize: 14)),
                        ],
                      )
                    ],
                  ),
                ],
              ),
            ),
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
                            onTap: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => AddAccountScreen(bankId: int.parse(widget.bankId))),
                              );
                              _loadCustomersForBank();
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
                        ..._customers
                            .map((customer) => CustomerCard(
                                  customer: customer,
                                  onRefresh: _loadCustomersForBank,
                                ))
                            .toList(),
                      const SizedBox(height: 25),
                      const Row(
                        children: [
                          Icon(Icons.analytics_outlined, color: Color(0xFF3B82F6)),
                          SizedBox(width: 8),
                          Text("Analytics & Reports", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 15),
                      _analyticsButton(
                        "Show VIP Customers",
                        const Color(0xFFF59E0B),
                        const Color(0xFFEA580C),
                        Icons.trending_up,
                        onTap: () async {
                          try {
                            final data = await fetchVIP(5000);
                            showDialog(
                              context: context,
                              builder: (_) => AlertDialog(
                                title: const Row(children: [Icon(Icons.emoji_events, color: Colors.amber), SizedBox(width: 8), Text("VIP Customers", style: TextStyle(fontWeight: FontWeight.bold))]),
                                content: SizedBox(
                                  height: 400,
                                  width: 350,
                                  child: data.isEmpty
                                      ? const Center(child: Text("No VIP customers found"))
                                      : ListView.builder(
                                          itemCount: data.length,
                                          itemBuilder: (context, i) => Card(
                                            margin: const EdgeInsets.symmetric(vertical: 4),
                                            child: ListTile(
                                              leading: CircleAvatar(backgroundColor: Colors.amber.shade100, child: const Icon(Icons.person, color: Colors.amber)),
                                              title: Text("${data[i]["firstName"]} ${data[i]["lastName"]}", style: const TextStyle(fontWeight: FontWeight.bold)),
                                              subtitle: Text(data[i]["type"] ?? "VIP Customer"),
                                              trailing: Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                decoration: BoxDecoration(color: Colors.green.shade100, borderRadius: BorderRadius.circular(12)),
                                                child: Text("\$${data[i]["balance"]}", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                                              ),
                                            ),
                                          ),
                                        ),
                                ),
                                actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text("Close"))],
                              ),
                            );
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red));
                          }
                        },
                      ),
                      const SizedBox(height: 12),
                      _analyticsButton(
                        "Total Balance",
                        const Color(0xFF10B981),
                        const Color(0xFF059669),
                        Icons.attach_money,
                        onTap: () async {
                          try {
                            final data = await fetchTotalBalance();
                            showModalBottomSheet(
                              context: context,
                              backgroundColor: Colors.transparent,
                              builder: (_) => Container(
                                decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.only(topLeft: Radius.circular(25), topRight: Radius.circular(25))),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      margin: const EdgeInsets.all(16),
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(12)),
                                      child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.account_balance, color: Colors.green), SizedBox(width: 8), Text("Total Balance by Bank", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))]),
                                    ),
                                    Flexible(
                                      child: ListView.builder(
                                        shrinkWrap: true,
                                        itemCount: data.length,
                                        itemBuilder: (context, index) => ListTile(
                                          leading: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.blue.shade100, borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.business, color: Colors.blue)),
                                          title: Text(data[index]["bankName"], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                          trailing: Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: Colors.green.shade100, borderRadius: BorderRadius.circular(20)), child: Text("\$${data[index]["totalBalance"]}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.green))),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                  ],
                                ),
                              ),
                            );
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red));
                          }
                        },
                      ),
                      const SizedBox(height: 12),
                      _analyticsButton(
                        "Bank Ranking",
                        const Color(0xFF8B5CF6),
                        const Color(0xFF7C3AED),
                        Icons.emoji_events,
                        onTap: () async {
                          try {
                            final data = await fetchBankRanking();
                            showDialog(
                              context: context,
                              builder: (_) => AlertDialog(
                                title: const Row(children: [Icon(Icons.emoji_events, color: Color(0xFF8B5CF6)), SizedBox(width: 8), Text("Bank Performance Ranking", style: TextStyle(fontWeight: FontWeight.bold))]),
                                content: SizedBox(
                                  height: 400,
                                  width: 350,
                                  child: data.isEmpty
                                      ? const Center(child: Text("No bank ranking data available"))
                                      : ListView.builder(
                                          itemCount: data.length,
                                          itemBuilder: (context, i) {
                                            Color rankColor;
                                            if (i == 0) {
                                              rankColor = Colors.amber;
                                            } else if (i == 1) {
                                              rankColor = Colors.grey.shade400;
                                            } else if (i == 2) {
                                              rankColor = Colors.brown.shade300;
                                            } else {
                                              rankColor = const Color(0xFF8B5CF6).withOpacity(0.1);
                                            }
                                            return Card(
                                              margin: const EdgeInsets.symmetric(vertical: 4),
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  gradient: i == 0 ? const LinearGradient(colors: [Color(0xFFFFF3E0), Color(0xFFFFE0B2)], begin: Alignment.topLeft, end: Alignment.bottomRight) : null,
                                                  borderRadius: BorderRadius.circular(8),
                                                ),
                                                child: ListTile(
                                                  leading: Container(width: 40, height: 40, decoration: BoxDecoration(color: rankColor, borderRadius: BorderRadius.circular(20)), child: Center(child: Text("${data[i]["rank"]}", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: i <= 2 ? Colors.white : const Color(0xFF8B5CF6))))),
                                                  title: Text(data[i]["bankName"], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                                  subtitle: Text("Accounts: ${data[i]["accounts"]}"),
                                                  trailing: Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: Colors.green.shade100, borderRadius: BorderRadius.circular(20)), child: Text("\$${data[i]["totalBalance"]}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.green))),
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                ),
                                actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text("Close"))],
                              ),
                            );
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red));
                          }
                        },
                      ),
const SizedBox(height: 12),
                      _analyticsButton(
                        "Recent Cards Activity",
                        const Color(0xFF3B82F6),
                        const Color(0xFF2563EB),
                        Icons.credit_card,
                        onTap: () async {
                          try {
                            final data = await fetchRecentCards();
                            showDialog(
                              context: context,
                              builder: (_) => AlertDialog(
                                title: const Row(children: [Icon(Icons.credit_card, color: Color(0xFF3B82F6)), SizedBox(width: 8), Text("Recent Cards (Last 30 Days)", style: TextStyle(fontWeight: FontWeight.bold))]),
                                content: SizedBox(
                                  height: 400,
                                  width: 350,
                                  child: data.isEmpty
                                      ? const Center(child: Text("No recent card activity"))
                                      : ListView.builder(
                                          itemCount: data.length,
                                          itemBuilder: (context, i) => Card(
                                            margin: const EdgeInsets.symmetric(vertical: 4),
                                            child: ListTile(
                                              leading: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: const Color(0xFF3B82F6).withOpacity(0.1), borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.credit_card, color: Color(0xFF3B82F6))),
                                              title: Text("${data[i]["firstName"]} ${data[i]["lastName"]}", style: const TextStyle(fontWeight: FontWeight.bold)),
                                              subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text("Card Type: ${data[i]["cardType"]}"), Text("Status: ${data[i]["status"]}"), Text("Issued: ${data[i]["createdAt"]}")]),
                                            ),
                                          ),
                                        ),
                                ),
                                actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text("Close"))],
                              ),
                            );
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red));
                          }
                        },
                      ),
                      const SizedBox(height: 30),
                      _analyticsButton(
                        "High Risk Customers",
                        const Color(0xFFEF4444),
                        const Color(0xFFDC2626),
                        Icons.warning_amber_rounded,
                        onTap: () async {
                          try {
                            final data = await fetchHighRisk();
                            showDialog(
                              context: context,
                              builder: (_) => AlertDialog(
                                title: const Row(children: [
                                  Icon(Icons.warning_amber_rounded, color: Colors.red),
                                  SizedBox(width: 8),
                                  Text("High Risk Customers", style: TextStyle(fontWeight: FontWeight.bold))
                                ]),
                                content: SizedBox(
                                  height: 400,
                                  width: 350,
                                  child: data.isEmpty
                                      ? const Center(child: Text("No high risk customers found"))
                                      : ListView.builder(
                                          itemCount: data.length,
                                          itemBuilder: (context, i) => Card(
                                            margin: const EdgeInsets.symmetric(vertical: 4),
                                            child: ListTile(
                                              leading: Container(
                                                padding: const EdgeInsets.all(8),
                                                decoration: BoxDecoration(
                                                  color: Colors.red.withOpacity(0.1),
                                                  borderRadius: BorderRadius.circular(10),
                                                ),
                                                child: const Icon(Icons.person, color: Colors.red),
                                              ),
                                              title: Text(
                                                "${data[i]["firstName"]} ${data[i]["lastName"]}",
                                                style: const TextStyle(fontWeight: FontWeight.bold),
                                              ),
                                              subtitle: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text("Accounts: ${data[i]["accounts"]}"),
                                                  Text("Cards: ${data[i]["cards"]}"),
                                                ],
                                              ),
                                              trailing: Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                decoration: BoxDecoration(
                                                  color: Colors.red.shade100,
                                                  borderRadius: BorderRadius.circular(12),
                                                ),
                                                child: Text(
                                                  "\$${data[i]["totalBalance"]}",
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.red,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                ),
                                actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text("Close"))],
                              ),
                            );
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
                            );
                          }
                        },

                      ),
                      const SizedBox(height: 12),
_analyticsButton(
  "Risk Level Customers",
  const Color(0xFF0EA5E9),
  const Color(0xFF0284C7),
  Icons.monitor_heart,
  onTap: () async {
    try {
      final data = await fetchCustomersByRiskLevel();
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Row(children: [
            Icon(Icons.monitor_heart, color: Color(0xFF0EA5E9)),
            SizedBox(width: 8),
            Text("Risk Level Customers", style: TextStyle(fontWeight: FontWeight.bold))
          ]),
          content: SizedBox(
            height: 400,
            width: 350,
            child: data.isEmpty
                ? const Center(child: Text("No data found"))
                : ListView.builder(
                    itemCount: data.length,
                    itemBuilder: (context, i) => Card(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      child: ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0EA5E9).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.person, color: Color(0xFF0EA5E9)),
                        ),
                        title: Text(
                          "${data[i]["firstName"]} ${data[i]["lastName"]}",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Bank: ${data[i]["bankName"]}"),
                            Text("Monitoring: ${data[i]["monitoringLevel"]}"),
                            Text("Accounts: ${data[i]["accounts"]}"),
                          ],
                        ),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0EA5E9).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            "\$${data[i]["totalBalance"]}",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0284C7),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
          ),
          actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text("Close"))],
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
      );
    }
  },
),
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

  Widget _topActionButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
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

  Widget _analyticsButton(String title, Color c1, Color c2, IconData icon, {required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(gradient: LinearGradient(colors: [c1, c2]), borderRadius: BorderRadius.circular(15)),
        child: Row(
          children: [
            Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(10)), child: Icon(icon, color: Colors.white)),
            const SizedBox(width: 15),
            Text(title, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────
// CUSTOMER CARD WIDGET
// ─────────────────────────────────────────

class CustomerCard extends StatelessWidget {
  final Customer customer;
  final VoidCallback onRefresh;

  const CustomerCard({
    super.key,
    required this.customer,
    required this.onRefresh,
  });

  void _showDeleteConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Delete Customer'),
          content: Text('Are you sure you want to delete ${customer.firstName} ${customer.lastName}?'),
          actions: <Widget>[
            TextButton(child: const Text('Cancel'), onPressed: () => Navigator.of(dialogContext).pop()),
            TextButton(
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                try {
                  final response = await http.delete(
                    Uri.parse('${AppConfig.baseUrl}/api/customers/${customer.id}'),
                  );
                  if (response.statusCode == 200 || response.statusCode == 204) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Customer deleted successfully'), backgroundColor: Colors.green),
                      );
                      onRefresh();
                    }
                  } else {
                    throw Exception('Failed to delete');
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error deleting customer: $e'), backgroundColor: Colors.red),
                    );
                  }
                }
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
                  Text("${customer.firstName} ${customer.lastName}", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Text(customer.phone, style: TextStyle(color: Colors.grey[600])),
                ],
              ),
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => EditCustomerScreen(customer: customer)),
                      );
                    },
                    child: Icon(Icons.edit_note, color: Colors.blue[700]),
                  ),
                  const SizedBox(width: 10),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: () => _showDeleteConfirmationDialog(context),
                  ),
                ],
              )
            ],
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              _infoBox("Email", customer.email, const Color(0xFFEFF6FF), const Color(0xFF2563EB)),
              const SizedBox(width: 10),
              _infoBox("Phone", customer.phone, const Color(0xFFF0FDF4), const Color(0xFF16A34A)),
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
            Text(value, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: textCol, fontSize: 14, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}