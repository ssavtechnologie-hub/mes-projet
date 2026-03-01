import 'package:flutter/material.dart';

class SupplierDetailScreen extends StatelessWidget {
  final String supplierId;
  const SupplierDetailScreen({super.key, required this.supplierId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Détail Fournisseur')),
      body: Center(child: Text('Fournisseur ID: $supplierId')),
    );
  }
}
