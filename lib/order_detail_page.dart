import 'dart:io';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'order_model.dart';
import 'database_helper.dart';
import 'package:photo_view/photo_view.dart';

class OrderDetailPage extends StatefulWidget {
  final Order order;

  const OrderDetailPage({super.key, required this.order});

  @override
  State<OrderDetailPage> createState() => _OrderDetailPageState();
}

class FullScreenImage extends StatelessWidget {
  final String fotoURL;
  const FullScreenImage({super.key, required this.fotoURL});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Foto Progress'),
        backgroundColor: Colors.black,
      ),
      body: PhotoView(
        imageProvider: FileImage(File(fotoURL)),
      ),
    );
  }
}

class _OrderDetailPageState extends State<OrderDetailPage> {
  List<OrderItem> _orderItems = [];
  List<Map<String, dynamic>> _fotoProgressHistory = [];

  @override
  void initState() {
    super.initState();
    _loadOrderItems();
    _loadFotoProgressHistory();
  }

  Future<void> _loadOrderItems() async {
    final items =
        await DatabaseHelper.instance.getOrderItemsByOrderId(widget.order.id);
    setState(() {
      _orderItems = items;
    });
  }

  Future<void> _loadFotoProgressHistory() async {
    final history =
        await DatabaseHelper.instance.getFotoProgressHistory(widget.order.id);
    setState(() {
      _fotoProgressHistory = history;
    });
    if (_fotoProgressHistory.isEmpty) {
      debugPrint('Tidak ada data riwayat foto progress.');
    } else {
      debugPrint(
          'Ada ${_fotoProgressHistory.length} entri riwayat foto progress.');
    }
  }

  String intlDate(DateTime date) {
    final format = DateFormat('dd MMMM yyyy, hh:mm a');
    return format.format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Order'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Email Pelanggan: ${widget.order.customerName}',
                  style: const TextStyle(fontSize: 18)),
              Text('Total Harga: ${widget.order.totalPrice}',
                  style: const TextStyle(fontSize: 18)),
              Text('Tanggal Order: ${intlDate(widget.order.orderDate)}',
                  style: const TextStyle(fontSize: 18)),
              Text('Status: ${widget.order.status}',
                  style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 10),
              const Text('Item Order:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _orderItems.length,
                itemBuilder: (context, index) {
                  final item = _orderItems[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    child: ListTile(
                      title: Text(item.productName),
                      subtitle: Text(
                        'Jumlah: ${item.quantity} - Harga: ${item.price}',
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              const Text('Riwayat Foto Progress:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _fotoProgressHistory.length,
                separatorBuilder: (context, index) => const Divider(height: 16),
                itemBuilder: (context, index) {
                  final fotoURL =
                      _fotoProgressHistory[index]['newFotoProgressURL'];
                  final isSuccess = fotoURL != null;
                  String updateDate = _fotoProgressHistory[index]['updateDate'];
                  return ListTile(
                    leading: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.circle,
                            color: isSuccess ? Colors.green : Colors.red,
                            size: 16),
                        if (index < _fotoProgressHistory.length - 1)
                          Container(
                            width: 2,
                            height: 20,
                            color: Colors.grey,
                          ),
                      ],
                    ),
                    title: Text(
                        '${intlDate(DateTime.parse(updateDate))} - ${_fotoProgressHistory[index]['status']} '),
                    subtitle: isSuccess
                        ? GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      FullScreenImage(fotoURL: fotoURL),
                                ),
                              );
                            },
                            child: SizedBox(
                              width: 80,
                              height: 80,
                              child: Image.file(File(fotoURL)),
                            ),
                          )
                        : null,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
