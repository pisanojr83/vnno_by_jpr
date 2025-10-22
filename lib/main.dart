// lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Ejemplo mínimo de provider (puedes reemplazar con tu lógica real)
class AppState with ChangeNotifier {
  String titulo = 'VNNO by JPR';
  void setTitulo(String t) {
    titulo = t;
    notifyListeners();
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Aquí iniciarías Firebase, Hive, etc. por ejemplo:
  // await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppState(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'VNNO by JPR',
        theme: ThemeData(
          primarySwatch: Colors.grey, // luego aplicaremos negro/dorado
          useMaterial3: true,
        ),
        home: const HomeScreen(),
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(appState.titulo),
        backgroundColor: Colors.black87,
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.account_balance_wallet_outlined, size: 64),
            const SizedBox(height: 12),
            const Text('Bienvenido a VNNO', style: TextStyle(fontSize: 20)),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                // ejemplo: cambiar título con provider
                appState.setTitulo('VNNO - Demo');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber[800], // dorado
                foregroundColor: Colors.black,
              ),
              child: const Text('Probar provider'),
            ),
          ],
        ),
      ),
    );
  }
}
