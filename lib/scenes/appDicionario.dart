import 'package:flutter/material.dart';
import './home_page.dart';

class DictionaryApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dictionary App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: DictionaryHomePage(),
    );
  }
}