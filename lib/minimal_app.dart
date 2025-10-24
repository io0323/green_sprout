import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '茶園管理AI',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: MyHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  List<String> _analysisResults = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('茶園管理AI'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(
              Icons.eco,
              size: 100,
              color: Colors.green,
            ),
            SizedBox(height: 20),
            Text(
              '茶園管理AIが正常に動作しています！',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            SizedBox(height: 20),
            Text(
              '解析回数: $_counter',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _analyzeTea,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              ),
              child: Text('茶葉を解析'),
            ),
            SizedBox(height: 20),
            if (_analysisResults.isNotEmpty) ...[
              Text(
                '最近の解析結果:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
              Container(
                height: 200,
                width: 300,
                child: ListView.builder(
                  itemCount: _analysisResults.length,
                  itemBuilder: (context, index) {
                    return Card(
                      margin: EdgeInsets.all(5),
                      child: ListTile(
                        leading: Icon(Icons.eco, color: Colors.green),
                        title: Text(_analysisResults[index]),
                        subtitle: Text('解析完了'),
                      ),
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _analyzeTea,
        backgroundColor: Colors.green,
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _analyzeTea() {
    setState(() {
      _counter++;
      _analysisResults.insert(
          0, '解析結果 #$_counter - ${DateTime.now().toString().substring(0, 19)}');
      if (_analysisResults.length > 5) {
        _analysisResults.removeLast();
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('茶葉の解析が完了しました！'),
        backgroundColor: Colors.green,
      ),
    );
  }
}
