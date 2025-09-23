import 'package:flutter/material.dart';

class Expense {
  final String id;
  final double amount;
  final String category;
  final DateTime date;
  final String description;
  final IconData icon;
  final Color color;

  Expense({
    required this.id,
    required this.amount,
    required this.category,
    required this.date,
    this.description = '',
    required this.icon,
    required this.color,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amount': amount,
      'category': category,
      'date': date.millisecondsSinceEpoch,
      'description': description,
    };
  }

  factory Expense.fromMap(Map<String, dynamic> map, IconData icon, Color color) {
    return Expense(
      id: map['id'] ?? '',
      amount: map['amount']?.toDouble() ?? 0.0,
      category: map['category'] ?? '',
      date: DateTime.fromMillisecondsSinceEpoch(map['date'] ?? 0),
      description: map['description'] ?? '',
      icon: icon,
      color: color,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Expense && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Expense{id: $id, amount: $amount, category: $category, date: $date}';
  }
}