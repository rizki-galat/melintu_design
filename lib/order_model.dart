class Order {
  final int id;
  final String customerName;
  final List<OrderItem> items;
  final DateTime orderDate;
  final double totalPrice;
  final String? productName;
  final int? quantity;
  final double? price;
  final String?
      nomorFaktur; // Opsional, jika nomor faktur tidak selalu tersedia
  final String? status;
  final String?
      fotoProdukURL; // Opsional, jika foto produk tidak selalu tersedia
  final String?
      fotoProgressURL; // Opsional, jika foto progress tidak selalu tersedia
  final String? videoProgressURL;

  Order(
      {required this.id,
      required this.customerName,
      required this.items,
      required this.orderDate,
      required this.totalPrice,
      this.nomorFaktur,
      this.status,
      this.fotoProdukURL,
      this.fotoProgressURL,
      this.videoProgressURL,
      this.productName,
      this.quantity,
      this.price});

  // Konversi Map ke objek Order
  factory Order.fromMap(Map<String, dynamic> map) {
    return Order(
      id: map['id'],
      customerName: map['customerName'],
      totalPrice: map['totalPrice'],
      orderDate: DateTime.parse(map['orderDate']),
      status: map['status'],
      nomorFaktur: map['nomorFaktur'],
      fotoProdukURL: map['fotoProdukURL'],
      fotoProgressURL: map['fotoProgressURL'],
      videoProgressURL: map['videoProgressURL'],
      items: [], // Items perlu diambil dari tabel terpisahi
      productName: map['productName'],
      quantity: map['quantity'],
      price: map['price'],
    );
  }

  // Konversi objek Order ke Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'customerName': customerName,
      'totalPrice': totalPrice,
      'orderDate': orderDate.toIso8601String(),
      'status': status,
      'nomorFaktur': nomorFaktur,
      'fotoProdukURL': fotoProdukURL,
      'fotoProgressURL': fotoProgressURL,
      'videoProgressURL': videoProgressURL,
      'productName': productName,
      'quantity': quantity,
      'price': price,
    };
  }
}

class OrderItem {
  final String productName;
  final int quantity;
  final double price;
  final String? fotoProduk; // Opsional, jika foto produk tidak selalu tersedia
  final String?
      fotoProgress; // Opsional, jika foto progress tidak selalu tersedia
  OrderItem({
    required this.productName,
    required this.quantity,
    required this.price,
    this.fotoProduk,
    this.fotoProgress,
  });

  // Konversi Map ke objek OrderItem
  factory OrderItem.fromMap(Map<String, dynamic> map) {
    return OrderItem(
      productName: map['productName'],
      quantity: map['quantity'],
      price: map['price'],
      fotoProduk: map['fotoProduk'],
      fotoProgress: map['fotoProgress'],
    );
  }

  // Konversi objek OrderItem ke Map
  Map<String, dynamic> toMap() {
    return {
      'productName': productName,
      'quantity': quantity,
      'price': price,
      'fotoProduk': fotoProduk,
      'fotoProgress': fotoProgress,
    };
  }
}
