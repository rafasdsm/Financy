import 'package:flutter/material.dart';
import 'storage_service.dart';
import 'home_screen.dart'; 
import 'login_screen.dart';
import 'cadastro_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializar o banco de dados local
  await StorageService.init();
  
  runApp(const FinanceApp());
}

class FinanceApp extends StatelessWidget {
  const FinanceApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Verificar se há usuário logado
    final storage = StorageService();
    final isLogado = storage.isLogado();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Financy',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: false, 
      ),
      // Se estiver logado, vai direto para Home, senão para Login
      initialRoute: isLogado ? HomeScreen.routeName : LoginScreen.routeName,
      
      routes: {
        LoginScreen.routeName: (context) => const LoginScreen(),
        CadastroScreen.routeName: (context) => const CadastroScreen(),
        HomeScreen.routeName: (context) => const HomeScreen(),
      },
    );
  }
}