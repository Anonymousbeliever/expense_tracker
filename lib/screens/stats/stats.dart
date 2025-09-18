import 'package:flutter/cupertino.dart';

class StatScreen extends StatelessWidget {
  const StatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 10.0),
        child: Column(children: [
            Text(
              "Transaction Stats",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              
              ),
            )
          ],
          ),
      ),
    );
  }
}
