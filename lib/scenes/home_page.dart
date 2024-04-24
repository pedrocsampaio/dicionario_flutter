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
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Dicionário',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          backgroundColor: Color.fromARGB(255, 46, 58, 44),
          bottom: TabBar(
            tabs: [
              Tab(text: 'Definição'),
              Tab(text: 'Sinônimos'),
            ],
          ),
        ),
        backgroundColor: Colors.grey[200], // Definindo a cor de fundo como cinza claro
        body: TabBarView(
          children: [
            _buildDefinitionTab(),
            _buildSynonymsTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildDefinitionTab() {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.all(30.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 3,
                  blurRadius: 7,
                  offset: Offset(0, 3), // changes position of shadow
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Digite uma palavra',
                  border: InputBorder.none, // Removendo a borda padrão
                  suffixIcon: IconButton(
                    icon: Icon(Icons.search),
                    onPressed: () {
                      _fetchDefinition(_searchController.text);
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(30.0),
              child: _definition.isEmpty
                  ? Container() // Mostra um Container vazio se a definição estiver vazia
                  : Container(
                      padding: EdgeInsets.all(25.0), // Adicionando espaçamento interno
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 3,
                            blurRadius: 7,
                            offset: Offset(0, 3), //muda a posição da sombra
                          ),
                        ],
                      ),
                      child: Text(
                        _definition,
                        textAlign: TextAlign.justify,
                        style: TextStyle(
                          fontSize: 18.0,
                          color: const Color.fromARGB(255, 255, 255, 255),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSynonymsTab() {
    return Center(
      child: Text(
        'Aqui serão exibidos os sinônimos da palavra pesquisada',
        style: TextStyle(fontSize: 20.0),
      ),
    );
  }
}