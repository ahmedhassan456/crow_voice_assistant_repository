import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:saqr_voice_assistant/Cubits/Observer/bloc_observer.dart';
import 'package:saqr_voice_assistant/Styles/Colors/pallete.dart';
import 'Modules/home_page.dart';

void main() {
  Bloc.observer = MyBlocObserver();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Crow',
      theme: ThemeData.light(useMaterial3: true).copyWith(
        scaffoldBackgroundColor: Pallete.whiteColor,
        appBarTheme: const AppBarTheme(
          backgroundColor: Pallete.whiteColor,
        ),
      ),
      home: const HomePage(),
    );
  }
}
