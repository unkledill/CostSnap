class Item {
  final String id;
  final String name;
  final String photoPath;
  final List<PriceEntry> priceHistory;
  final String tag;

  Item({
    required this.id,
    required this.name,
    required this.photoPath,
    required this.priceHistory,
    required this.tag,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'photoPath': photoPath,
      'priceHistory': priceHistory.map((e) => e.toMap()).toList(),
      'tag': tag,
    };
  }

  factory Item.fromMap(Map<String, dynamic> map) {
    return Item(
      id: map['id'],
      name: map['name'],
      photoPath: map['photoPath'],
      priceHistory: (map['priceHistory'] as List)
          .map((e) => PriceEntry.fromMap(e))
          .toList(),
      tag: map['tag'],
    );
  }
}

class PriceEntry {
  final double price;
  final String location;
  final DateTime date;

  PriceEntry({required this.price, required this.location, required this.date});

  Map<String, dynamic> toMap() {
    return {
      'price': price,
      'location': location,
      'date': date.toIso8601String()
    };
  }

  factory PriceEntry.fromMap(Map<String, dynamic> map) {
    return PriceEntry(
      price: map['price'],
      location: map['location'],
      date: DateTime.parse(map['date']),
    );
  }
}
