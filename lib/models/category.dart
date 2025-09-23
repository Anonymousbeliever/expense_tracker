import 'package:flutter/material.dart';

class Category {
  final String id;
  final String name;
  final IconData icon;
  final Color color;
  final String description;
  final bool isDefault;
  final String? userId; // null for default categories, userId for custom ones
  final DateTime? createdAt;

  Category({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    this.description = '',
    this.isDefault = false,
    this.userId,
    this.createdAt,
  });

  // Map icon data to string for Firebase storage
  String get iconName {
    // Map common icons to string names
    final iconMap = {
      Icons.restaurant: 'restaurant',
      Icons.directions_car: 'directions_car',
      Icons.movie: 'movie',
      Icons.shopping_cart: 'shopping_cart',
      Icons.receipt: 'receipt',
      Icons.local_hospital: 'local_hospital',
      Icons.home: 'home',
      Icons.flight: 'flight',
      Icons.category: 'category',
      Icons.attach_money: 'attach_money',
      Icons.work: 'work',
      Icons.school: 'school',
    };
    return iconMap[icon] ?? 'category';
  }

  // Convert color to hex string
  String get colorHex {
    return '#${color.value.toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}';
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'iconName': iconName,
      'colorHex': colorHex,
      'description': description,
      'isDefault': isDefault,
      'userId': userId,
      'createdAt': createdAt?.millisecondsSinceEpoch,
    };
  }

  factory Category.fromMap(Map<String, dynamic> map) {
    // Map string names back to IconData
    final iconMap = {
      'restaurant': Icons.restaurant,
      'directions_car': Icons.directions_car,
      'movie': Icons.movie,
      'shopping_cart': Icons.shopping_cart,
      'receipt': Icons.receipt,
      'local_hospital': Icons.local_hospital,
      'home': Icons.home,
      'flight': Icons.flight,
      'category': Icons.category,
      'attach_money': Icons.attach_money,
      'work': Icons.work,
      'school': Icons.school,
    };

    // Parse color from hex string
    Color parseColor(String? hexString) {
      if (hexString == null || hexString.isEmpty) return Colors.blue;
      try {
        return Color(int.parse(hexString.replaceFirst('#', '0xFF')));
      } catch (e) {
        return Colors.blue;
      }
    }

    return Category(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      icon: iconMap[map['iconName']] ?? Icons.category,
      color: parseColor(map['colorHex']),
      description: map['description'] ?? '',
      isDefault: map['isDefault'] ?? false,
      userId: map['userId'],
      createdAt: map['createdAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['createdAt'])
          : null,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Category && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Category{id: $id, name: $name, description: $description}';
  }
}