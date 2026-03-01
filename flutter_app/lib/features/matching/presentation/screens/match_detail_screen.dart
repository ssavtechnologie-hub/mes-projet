import 'package:flutter/material.dart';

class MatchDetailScreen extends StatelessWidget {
  final String matchId;
  const MatchDetailScreen({super.key, required this.matchId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Détail Match')),
      body: Center(child: Text('Match ID: $matchId')),
    );
  }
}
