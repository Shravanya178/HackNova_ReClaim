// Material Capture Screen
import 'package:flutter/material.dart';

class MaterialCaptureScreen extends StatelessWidget {
  const MaterialCaptureScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Capture Materials')),
      body: const Center(
        child: Text('Material Capture\n\nCamera + AI Detection\nComing Soon!', 
                    textAlign: TextAlign.center, style: TextStyle(fontSize: 18)),
      ),
    );
  }
}