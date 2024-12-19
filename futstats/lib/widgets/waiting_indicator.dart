import 'package:flutter/material.dart';

class WaitingIndicator extends StatelessWidget {
  const WaitingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }
}
