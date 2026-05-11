import 'package:flutter/material.dart';

class MaterialTypesScreen extends StatelessWidget {
  const MaterialTypesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        "Material Types",
        style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }
}
