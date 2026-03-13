import 'package:flutter/material.dart';

class UserInterface extends StatelessWidget {
  const UserInterface({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: const Text('User Interface')), body: const Center(child: Text('Customer / User Interface')));
  }
}
