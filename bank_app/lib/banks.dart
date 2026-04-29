import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'add_bank.dart';

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
// SCREEN
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
    _refresh(); // تحديث القائمة بعد الإضافة
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
// BANK CARD WIDGET
// ─────────────────────────────────────────

class _BankCard extends StatelessWidget {
  final BankModel bank;

  const _BankCard({required this.bank});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Navigator.push(context, MaterialPageRoute(
        //   builder: (_) => BankDetailsScreen(bank: bank),
        // ));
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