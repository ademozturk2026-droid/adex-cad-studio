import 'package:flutter/material.dart';

void main() {
  runApp(const ProCadApp());
}

class ProCadApp extends StatelessWidget {
  const ProCadApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pro CAD 3D AI Lab Studio',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const CadHomeStudio(),
    );
  }
}

class CadHomeStudio extends StatelessWidget {
  const CadHomeStudio({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pro CAD 3D AI Lab Studio'),
        backgroundColor: Colors.blueGrey,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.layers, size: 80, color: Colors.blue),
            SizedBox(height: 20),
            Text(
              'CAD Studio Aktif!',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              'APK başarıyla derlendi ve kuruldu.',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
