import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'order_model.dart';
import 'user_model.dart';
import 'database_helper.dart';
import 'order_detail_page.dart';
import 'order_add_page.dart';

class OrderListPage extends StatefulWidget {
  const OrderListPage({super.key});

  @override
  OrderListPageState createState() => OrderListPageState();
}

class OrderListPageState extends State<OrderListPage> {
  List<Order> _orders = [];
  List<Order> _filteredOrders = [];
  bool _isAdmin = false;
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadOrders();
    _checkAdminStatus();
    _searchController.addListener(_onSearchChanged);
  }

  Future<void> _loadOrders() async {
    setState(() {
      _isLoading = true;
    });

    try {
      List<Order> orders;
      if (_isAdmin) {
        orders = await DatabaseHelper.instance.getAllOrders();
      } else {
        final prefs = await SharedPreferences.getInstance();
        final userId = prefs.getInt('userId');
        User? users = await DatabaseHelper.instance.getUserById(userId!);
        orders = await DatabaseHelper.instance.getOrdersByEmail(users!.email);
      }

      if (orders.isEmpty) {}
      setState(() {
        _orders = orders;
        _filteredOrders = orders;
      });
    } catch (e) {
      print('Error loading orders: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _checkAdminStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId');

    if (userId != null) {
      final user = await DatabaseHelper.instance.getUserById(userId);
      setState(() {
        _isAdmin = user?.role == 'admin';
      });
    } else {
      setState(() {
        _isAdmin = false;
      });
    }
  }

  void _onSearchChanged() {
    _searchOrders(_searchController.text);
  }

  void _searchOrders(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredOrders = _orders;
      } else {
        _filteredOrders = _orders.where((order) {
          return order.customerName
                  .toLowerCase()
                  .contains(query.toLowerCase()) ||
              order.status!.toLowerCase().contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  void _showAddOrderPage() async {
    final newOrder = await Navigator.push<Order>(
      context,
      MaterialPageRoute(
        builder: (context) => const OrderAddPage(),
      ),
    );

    if (newOrder != null) {
      await DatabaseHelper.instance.insertOrder(newOrder);
      _loadOrders();
    }
  }

  void _showEditOrderPage(Order order) async {
    final editedOrder = await Navigator.push<Order>(
      context,
      MaterialPageRoute(
        builder: (context) => OrderAddPage(order: order),
      ),
    );

    if (editedOrder != null) {
      await DatabaseHelper.instance.updateOrder(editedOrder);
      _loadOrders();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Order'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadOrders,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      labelText: 'Cari Order',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      prefixIcon: const Icon(Icons.search),
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 16.0),
                    ),
                    style: const TextStyle(fontSize: 16.0),
                  ),
                ),
                const SizedBox(height: 16.0),
                Expanded(
                  child: _filteredOrders.isEmpty
                      ? const Center(child: Text('No data found'))
                      : ListView.builder(
                          itemCount: _filteredOrders.length,
                          itemBuilder: (context, index) {
                            final order = _filteredOrders[index];
                            return Card(
                              margin: const EdgeInsets.all(8.0),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            order.customerName,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18.0,
                                            ),
                                          ),
                                          const SizedBox(height: 8.0),
                                          Text('Total: ${order.totalPrice}'),
                                          Text(
                                              'Status: ${order.status ?? 'N/A'}'),
                                        ],
                                      ),
                                    ),
                                    if (_isAdmin)
                                      Row(
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.edit,
                                                color: Colors.blue),
                                            onPressed: () {
                                              _showEditOrderPage(order);
                                            },
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.delete,
                                                color: Colors.red),
                                            onPressed: () async {
                                              bool confirmDelete =
                                                  await showDialog(
                                                context: context,
                                                builder:
                                                    (BuildContext context) {
                                                  return AlertDialog(
                                                    title: const Text(
                                                        'Konfirmasi Hapus'),
                                                    content: const Text(
                                                        'Apakah Anda yakin ingin menghapus order ini?'),
                                                    actions: <Widget>[
                                                      TextButton(
                                                        child:
                                                            const Text('Batal'),
                                                        onPressed: () =>
                                                            Navigator.of(
                                                                    context)
                                                                .pop(false),
                                                      ),
                                                      TextButton(
                                                        child:
                                                            const Text('Hapus'),
                                                        onPressed: () =>
                                                            Navigator.of(
                                                                    context)
                                                                .pop(true),
                                                      ),
                                                    ],
                                                  );
                                                },
                                              );

                                              if (confirmDelete == true) {
                                                int result =
                                                    await DatabaseHelper
                                                        .instance
                                                        .deleteOrder(order.id);
                                                if (result > 0) {
                                                  _loadOrders();
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                    const SnackBar(
                                                        content: Text(
                                                            'Order berhasil dihapus')),
                                                  );
                                                } else {
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                    const SnackBar(
                                                        content: Text(
                                                            'Gagal menghapus order')),
                                                  );
                                                }
                                              }
                                            },
                                          ),
                                        ],
                                      )
                                    else
                                      ElevatedButton(
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  OrderDetailPage(order: order),
                                            ),
                                          );
                                        },
                                        child: const Text('Detail Order'),
                                      ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
      floatingActionButton: _isAdmin
          ? FloatingActionButton(
              onPressed: _showAddOrderPage,
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
