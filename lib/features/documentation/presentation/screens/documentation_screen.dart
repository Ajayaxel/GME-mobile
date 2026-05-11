import 'package:flutter/material.dart';

class DocumentationScreen extends StatelessWidget {
  const DocumentationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        "Export Documentation Content",
        style: TextStyle(color: Colors.white, fontSize: 18),
      ),
    );
  }
}
