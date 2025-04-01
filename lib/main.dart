import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'core/routes.dart';
import 'core/theme.dart';
import 'providers/auth_provider.dart';
import 'screens/auth/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const RentNovaApp());
}

class RentNovaApp extends StatelessWidget {
  const RentNovaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => AuthProvider())],
      child: MaterialApp(
        title: 'RentNova',
        theme: appTheme(),
        home: const LoginScreen(),
        onGenerateRoute: RouteGenerator.generateRoute,
      ),
    );
  }
}
