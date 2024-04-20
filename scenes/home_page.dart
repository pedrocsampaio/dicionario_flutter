import 'dart:html';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:xml/xml.dart' as xml;

class DictionaryHomePage extends StatefulWidget {
  @override
  _DictionaryHomePageState createState() => _DictionaryHomePageState();
}

class _DictionaryHomePageState extends State<DictionaryHomePage> {
  TextEditingController _searchController = TextEditingController();
  String _definition = '';

  Future<void> _fetchDefinition(String word) async {
    final response = await http.get(
      Uri.parse('https://api.dicionario-aberto.net/word/$word'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      String definition = '';
      for (var item in data) {
        if (item.containsKey('xml')) {
          var xmlData = item['xml'];
          var xmlDoc = xml.XmlDocument.parse(utf8.decode(xmlData.runes.toList())); // Decodifica os bytes da resposta para UTF-8
          var definitions = xmlDoc.findAllElements('def').map((e) => e.text).join('\n');
          definition += definitions + '\n';
        }
      }
      setState(() {
        _definition = definition;
      });
    } else {
      setState(() {
        _definition = 'Falha';
      });
    }
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dicionário'),
      backgroundColor: Color.fromARGB(255, 46, 58, 44),
      ),
      body: Column(
        children: [
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Digite uma palavra',
              suffixIcon: IconButton(
                icon: Icon(Icons.search),
                onPressed: () {
                  _fetchDefinition(_searchController.text);
                },
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(20.0),
                child: Text(
                  _definition,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18.0),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}