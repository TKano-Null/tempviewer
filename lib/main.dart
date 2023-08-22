import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'dart:convert';
import 'package:fl_chart/fl_chart.dart';

String _temptext = "";
List<FlSpot> _temp = const [];
List<FlSpot> _humi = const [];
List<FlSpot> _pres = const [];

Future main() async {
  await getTempData();
  runApp(const MyApp());
}

getTempData() async {
  const String tempDataUrl =
      'https://xxxxxx.firebaseio.com/users/xxxxxx/tempdata.json?orderBy="key"&limitToLast=10';
  final response = await Dio().get(tempDataUrl);
  if (response.statusCode == 200) {
    String rawJson = response.toString();
    _temp = [];
    _humi = [];
    _pres = [];
    int index = 0;
    Map<String, dynamic> map = jsonDecode(rawJson);
    map.forEach((key, value) {
      final DateTime date =
          DateTime.fromMillisecondsSinceEpoch((value['date'] * 1000).round());
      final hour = date.hour;
      final minute = date.minute;
      final String timeText = '$hour' '時' '$minute' '分';
      final String temp = value['temp'].toStringAsFixed(1);
      final String tempText = '$temp' '℃';
      final String humi = value['humi'].toStringAsFixed(1);
      final String humiText = '$humi' '%';
      final String pres = (value['pres'] / 100).toStringAsFixed(1);
      final String presText = '$pres' 'hPa';
      _temptext =
          '$timeText' '\n' '$tempText' '\n' '$humiText' '\n' '$presText';
      //final String gTimeText = '$hour' '$minute';
      index++;
      _temp.add(FlSpot(index.toDouble(), double.parse(temp)));
      _humi.add(FlSpot(index.toDouble(), double.parse(humi)));
      _pres.add(FlSpot(index.toDouble(), double.parse(pres)));
    });
    print(map);
  } else {
    print(response.statusCode);
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  //int _counter = 0;

  //void _incrementCounter() {
  void _tempDataController() async {
    await getTempData();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Text(_temptext),
            Container(
              height: 400,
              width: 400,
              child: LineChart(
                LineChartData(lineBarsData: [
                  LineChartBarData(isCurved: true, spots: _temp)
                ]),
              ),
            ),
            Container(
              height: 400,
              width: 400,
              child: LineChart(
                LineChartData(lineBarsData: [
                  LineChartBarData(isCurved: true, spots: _humi)
                ]),
              ),
            ),
            Container(
              height: 400,
              width: 400,
              child: LineChart(
                LineChartData(lineBarsData: [
                  LineChartBarData(isCurved: true, spots: _pres)
                ], minY: 990, maxY: 1010),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _tempDataController,
        child: const Icon(Icons.autorenew),
      ),
    );
  }
}
