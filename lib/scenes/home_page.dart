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
  List<String> _searchHistory = [];

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
        _searchHistory.add(word); // Adiciona a palavra ao histórico
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
      initialIndex: 0, // Definição aparece primeiro
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
              Tab(text: 'Histórico'),
            ],
          ),
        ),
        backgroundColor: Colors.grey[200], // Definindo a cor de fundo como cinza claro
        body: TabBarView(
          children: [
            _buildDefinitionTab(),
            _buildHistoryTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryTab() {
    return Padding(
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
          padding: const EdgeInsets.all(30.0), // Adiciona padding interno
          child: ListView.builder(
            itemCount: _searchHistory.length,
            itemBuilder: (context, index) {
              return Column(
                children: [
                  ListTile(
                    title: Text(_searchHistory[index]),
                    onTap: () {
                      _searchController.clear(); // Limpa o campo de pesquisa
                      _fetchDefinition(_searchHistory[index]);
                      DefaultTabController.of(context).animateTo(0); // Redireciona para a aba de definição
                    },
                  ),
                  Divider(
                    color: Colors.grey[300], // Adiciona uma linha cinza abaixo de cada item da lista
                    thickness: 1,
                    height: 1,
                  ),
                ],
              );
            },
          ),
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: _definition
                            .split('\n')
                            .map((definition) => Column(
                                  children: [
                                    Text(
                                      definition,
                                      textAlign: TextAlign.justify,
                                      style: TextStyle(
                                        fontSize: 18.0,
                                        color: Color.fromARGB(255, 0, 0, 0),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: 5.0),
                                    Container(
                                      height: 1,
                                      color: Colors.grey[300], // Linha cinza fina
                                    ),
                                    SizedBox(height: 10.0),
                                  ],
                                ))
                            .toList(),
                      ),
                    ),
            ),
          ),
        ),
      ],
    );
  }
}
