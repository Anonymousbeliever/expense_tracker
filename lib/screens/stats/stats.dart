import 'package:expense_tracker/screens/stats/chart.dart';
import 'package:flutter/material.dart';

class StatScreen extends StatelessWidget {
  const StatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Transaction Stats",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          const  SizedBox(height: 20),
            Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(20)
              ),
              // color: Colors.red,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 20, 12, 12),
                child: const MyChart(),
              ),
            )
          ],
          ),
      ),
    );
  }
}
