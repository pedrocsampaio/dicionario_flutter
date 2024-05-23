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
          var xmlDoc = xml.XmlDocument.parse(utf8.decode(xmlData.runes.toList()));
          var definitions = xmlDoc.findAllElements('def').map((e) => e.text).join('\n');
          definition += definitions + '\n';
        }
      }
      setState(() {
        _definition = definition;
        _searchHistory.add(word);
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
      initialIndex: 0,
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          title: const Padding(
            padding: EdgeInsets.symmetric(vertical: 10.0),
            child: Text(
              'Dicionário',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          backgroundColor: Color.fromARGB(255, 46, 58, 44),
          
        ),
        backgroundColor: Colors.grey[200],
        body: Column(
          children: [
            Container(
              color: Color.fromARGB(255, 46, 58, 44),
              padding: EdgeInsets.only(bottom: 17.0, left: 17.0, right: 17.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10.0),
                ),
                padding: EdgeInsets.symmetric(horizontal: 10.0),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Digite uma palavra',
                    border: InputBorder.none,
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
            TabBar(
              tabs: [
                Tab(text: 'Definição'),
                Tab(text: 'Histórico'),
              ],
              labelColor: Colors.black,
              indicatorColor: Colors.black,
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _buildDefinitionTab(),
                  _buildHistoryTab(),
                ],
              ),
            ),
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
        ),
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: ListView.builder(
            itemCount: _searchHistory.length,
            itemBuilder: (context, index) {
              return Column(
                children: [
                  ListTile(
                    title: Text(_searchHistory[index]),
                    onTap: () {
                      _searchController.clear();
                      _fetchDefinition(_searchHistory[index]);
                      DefaultTabController.of(context).animateTo(0);
                    },
                  ),
                  Divider(
                    color: Colors.grey[300],
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
          padding: EdgeInsets.all(18.0),
          child: Column(
            children: [
              _definition.isEmpty
                  ? Container()
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Container(
                          padding: EdgeInsets.all(22.0),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                "Significado de ${_searchController.text}:",
                                style: TextStyle(
                                  fontSize: 20.0,
                                  fontWeight: FontWeight.w900
                                ),
                              ),
                              SizedBox(height: 10.0),
                              ListView.builder(
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                itemCount: _definition.split('\n').length,
                                itemBuilder: (context, index) {
                                  String definition = _definition.split('\n')[index];
                                  return Column(
                                    children: [
                                      Text(
                                        definition,
                                        textAlign: TextAlign.justify,
                                        style: TextStyle(
                                          fontSize: 18.0,
                                          color: Color.fromARGB(255, 71, 71, 71),
                                          fontWeight: FontWeight.normal,
                                        ),
                                      ),
                                      SizedBox(height: 5.0),
                                      Container(
                                        height: 1,
                                        color: Colors.grey[300],
                                      ),
                                      SizedBox(height: 10.0),
                                    ],
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          );
        }
      }
