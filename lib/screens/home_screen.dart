import 'package:flutter/material.dart';
import '../widgets/custom_drawer.dart';
class HomeScreen extends StatelessWidget {


  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Eyewear Store'),
        actions: [],
      ),
      drawer: CustomDrawer(),
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [

          ],
        ),
      ),
    );
  }
}