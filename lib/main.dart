import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Shopping',
      home: MyHomePage(title: 'Budget List'),
    );
  }
}

List<String> itemList = [];
double total = 0;
bool darkMode = true;

class ShoppingListItem extends StatefulWidget {
  const ShoppingListItem(
      {Key? key,
      required this.title,
      required this.price,
      required this.rank,
      required this.notAlone})
      : super(key: key);

  final String title;
  final String price;
  final int rank;
  final bool notAlone;

  @override
  State<ShoppingListItem> createState() => _ShoppingListItemState();
}

class _ShoppingListItemState extends State<ShoppingListItem> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Row(
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.025,
            ),
            Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.all(5),
              width: MediaQuery.of(context).size.width * 0.25,
              height: 35,
              decoration: BoxDecoration(
                  color: darkMode ? Colors.blueGrey[700] : Colors.grey[200],
                  borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(10),
                      bottomLeft: Radius.circular(10))),
              child: Text(
                widget.price,
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.all(5),
              width: MediaQuery.of(context).size.width * 0.59,
              height: 35,
              decoration: BoxDecoration(
                  color: darkMode ? Colors.blueGrey[700] : Colors.grey[200],
                  borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(10),
                      bottomRight: Radius.circular(10))),
              child: Text(
                widget.title,
                style: const TextStyle(fontSize: 20),
              ),
            ),
            Container(
              margin: const EdgeInsets.fromLTRB(3, 0, 0, 0),
              width: MediaQuery.of(context).size.width * 0.10,
              height: 35,
              child: IconButton(
                splashColor: Colors.red[400],
                splashRadius: 20,
                color: Colors.red,
                onPressed: () {
                  itemList.removeRange(widget.rank, widget.rank + 2);
                },
                icon: const Icon(Icons.exposure_minus_1),
              ),
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.025,
            ),
          ],
        ),
      ],
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late Timer timer;
  final _price = TextEditingController();
  final _title = TextEditingController();
  int listLen = 0;

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(
        const Duration(milliseconds: 50), (Timer t) => setState(() {}));
    _price.clear();
    _title.clear();
    loadData();
  }

  void loadData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      itemList = (prefs.getStringList("DATA") ?? []);
      total = (prefs.getDouble("TOTAL") ?? 0.0);
      darkMode = (prefs.getBool("DARKMODE") ?? true);
      listLen = itemList.length ~/ 2;
    });
  }

  void saveData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      prefs.setStringList("DATA", itemList);
      prefs.setDouble("TOTAL", total);
      prefs.setBool("DARKMODE", darkMode);
      listLen = itemList.length ~/ 2;
    });
  }

  List<Widget> getShoppingList() {
    List<Widget> items = [];
    int i = 0, len = itemList.length;
    listLen = len ~/ 2;
    total = 0;
    while (i < len - 1) {
      items.add(Column(
        children: [
          ShoppingListItem(
              title: itemList[i],
              price: itemList[i + 1],
              rank: i,
              notAlone: len > 2),
          const SizedBox(
            height: 20,
          )
        ],
      ));
      total += double.parse(itemList[i + 1]);
      i += 2;
    }
    return (items);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: Text(
              widget.title,
              style: TextStyle(color: darkMode ? Colors.white70 : Colors.black),
            ),
            centerTitle: true,
            titleTextStyle: TextStyle(
                fontWeight: darkMode ? FontWeight.bold : FontWeight.normal,
                fontSize: 20),
            backgroundColor:
                darkMode ? Colors.black.withBlue(115) : Colors.blue),
        backgroundColor:
            darkMode ? const Color.fromARGB(255, 0, 0, 50) : Colors.white,
        floatingActionButtonLocation:
            FloatingActionButtonLocation.miniCenterDocked,
        floatingActionButton: ButtonBar(
          alignment: MainAxisAlignment.spaceEvenly,
          children: [
            TextButton(
              onPressed: () {
                setState(() {
                  itemList.clear();
                });
              },
              style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(
                darkMode ? Colors.black.withBlue(115) : Colors.lightBlue,
              )),
              child: Text(
                "Clear list",
                style: TextStyle(
                    fontSize: 20,
                    color: darkMode ? Colors.white70 : Colors.black),
              ),
            ),
            IconButton(
              onPressed: () {
                darkMode = !darkMode;
                saveData();
              },
              color: darkMode ? Colors.white70 : Colors.black,
              icon: Icon(darkMode ? Icons.nightlight : Icons.wb_sunny),
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(
                height: 10,
              ),
              Container(
                width: MediaQuery.of(context).size.width,
                padding: const EdgeInsets.all(5),
                alignment: Alignment.center,
                child: Text(
                  "Total: ${total.toStringAsFixed(2)}",
                  style: TextStyle(
                      color: darkMode ? Colors.white70 : Colors.black,
                      fontSize: 30,
                      fontWeight: FontWeight.bold),
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(16, 10, 0, 10),
                alignment: Alignment.centerLeft,
                child: Text(
                    listLen <= 1
                        ? "You have $listLen item"
                        : "You have $listLen items",
                    style: TextStyle(
                        color: darkMode ? Colors.white70 : Colors.black,
                        fontSize: 17)),
              ),
              Row(
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.025,
                  ),
                  Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.all(5),
                    width: MediaQuery.of(context).size.width * 0.25,
                    height: 35,
                    child: Text(
                      "Price",
                      style: TextStyle(
                          color: darkMode ? Colors.white70 : Colors.black,
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.all(5),
                    width: MediaQuery.of(context).size.width * 0.59,
                    height: 35,
                    child: Text(
                      "Info",
                      style: TextStyle(
                          color: darkMode ? Colors.white70 : Colors.black,
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width * 0.10,
                    padding: const EdgeInsets.fromLTRB(5, 0, 0, 0),
                    child: IconButton(
                        color: Colors.green,
                        onPressed: () async {
                          await showDialog<void>(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  backgroundColor: darkMode
                                      ? const Color.fromARGB(255, 0, 0, 75)
                                      : Colors.white,
                                  title: Text(
                                    "Type here the info and price of the article",
                                    style: TextStyle(
                                        color: darkMode
                                            ? Colors.white70
                                            : Colors.black),
                                  ),
                                  content: Column(
                                    children: [
                                      TextField(
                                        style: TextStyle(
                                            color: darkMode
                                                ? Colors.white70
                                                : Colors.black),
                                        controller: _price,
                                        decoration: InputDecoration(
                                            border: const OutlineInputBorder(),
                                            labelText: 'Price',
                                            labelStyle: TextStyle(
                                                color: darkMode
                                                    ? Colors.white70
                                                    : Colors.black)),
                                        keyboardType: const TextInputType
                                            .numberWithOptions(decimal: true),
                                      ),
                                      const SizedBox(
                                        height: 15,
                                      ),
                                      TextField(
                                        style: TextStyle(
                                            color: darkMode
                                                ? Colors.white70
                                                : Colors.black),
                                        controller: _title,
                                        decoration: InputDecoration(
                                          border: const OutlineInputBorder(),
                                          labelText: 'Info',
                                          labelStyle: TextStyle(
                                              color: darkMode
                                                  ? Colors.white70
                                                  : Colors.black),
                                        ),
                                      ),
                                    ],
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        if (_price.text == "") {
                                          Fluttertoast.showToast(
                                              msg: "Price can't be empty");
                                          return;
                                        }
                                        if (_title.text == "") {
                                          Fluttertoast.showToast(
                                              msg: "Info can't be empty");
                                          return;
                                        }
                                        _price.text =
                                            _price.text.replaceAll(",", ".");
                                        int i = 0;
                                        String tmp = _price.text;
                                        while (i < _price.text.length) {
                                          if (_price.text[i] == '.') {
                                            tmp =
                                                _price.text.substring(0, i + 3);
                                          }
                                          i += 1;
                                        }
                                        itemList.add(_title.text);
                                        itemList.add(tmp);
                                        saveData();
                                        _price.clear();
                                        _title.clear();
                                        Navigator.pop(context);
                                      },
                                      child: const Text('OK'),
                                    ),
                                  ],
                                );
                              });
                        },
                        icon: const Icon(Icons.plus_one)),
                  )
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              ...getShoppingList(),
              const SizedBox(
                height: 50,
              ),
            ],
          ),
        ));
  }
}
