import 'package:flutter/material.dart';
import 'pages/register_form_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Register Form Demo',
      theme: ThemeData(
          brightness: Brightness.light,
          appBarTheme: const AppBarTheme(
              backgroundColor: Color.fromARGB(255, 7, 31, 50)),
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding: const EdgeInsets.symmetric(
              vertical: 22,
              horizontal: 26,
            ),
            labelStyle: const TextStyle(
              fontSize: 20,
            ),
            
          )),
      home: const RegisterFormPage(),
    );
  }
}
