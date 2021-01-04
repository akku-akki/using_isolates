import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:isolate';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

//  TWO WAYS TO CREATE ISOLATES

// Isolate.spawn()

// compute()

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: TenIso()
        // MyHomePage(),
        );
  }
}

// Manually Spawning

class TenIso extends StatefulWidget {
  @override
  _TenIsoState createState() => _TenIsoState();
}

class _TenIsoState extends State<TenIso> {
  List list = [];

  @override
  void initState() {
    loadIsolate();
    super.initState();
  }

  Future loadIsolate() async {
    ReceivePort receivePort = ReceivePort();
    await Isolate.spawn(isolateEntry, receivePort.sendPort);
    SendPort sendPort = await receivePort.first;
    List message = await sendReceive(
        sendPort, "https://jsonplaceholder.typicode.com/comments");
    setState(() {
      list = message;
    });
  }

  static isolateEntry(SendPort sendport) async {
    ReceivePort port = ReceivePort();
    sendport.send(port.sendPort);
    await for (var msg in port) {
      String data = msg[0];
      SendPort replyPort = msg[1];
      String url = data;
      http.Response response = await http.get(url);
      replyPort.send(json.decode(response.body));
    }
  }

  Future sendReceive(SendPort send, message) {
    ReceivePort responsePort = ReceivePort();
    send.send([message, responsePort.sendPort]);
    return responsePort.first;
  }

  Widget loadData() {
    if (list.length == 0) {
      return Center(
        child: CircularProgressIndicator(),
      );
    } else {
      return ListView.builder(
        itemCount: list.length,
        itemBuilder: (context, int i) {
          return Container(
            padding: EdgeInsets.all(5.0),
            child: Text('Item: ${list[i]["body"]}'),
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Isolates"),
      ),
      body: loadData(),
    );
  }
}

// isolateFunction(int finalNum) {
//   int _count = 0;

//   for (int i = 0; i <= finalNum; i++) {
//     _count++;
//     print(_count.hashCode);
//     if ((_count % 100) == 0) {
//       print("Isolate" + _count.toString());
//     }
//   }
// }

// int computeFunction(int finalNum) {
//   int _count = 0;

//   for (int i = 0; i <= finalNum; i++) {
//     _count++;
//     print(_count.hashCode);
//     if ((_count % 100) == 0) {
//       print("Isolate" + _count.toString());
//     }
//   }

//   return _count;
// }

// class MyHomePage extends StatefulWidget {
//   @override
//   _MyHomePageState createState() => _MyHomePageState();
// }

// class _MyHomePageState extends State<MyHomePage> {
//   int _counter = 0;

//   void _incrementCounter() {
//     Isolate.spawn(isolateFunction, 1000);
//     setState(() {
//       _counter++;
//     });
//   }

//   Future<void> runCompute() async {
//     int value = await compute(computeFunction, 2000);
//     _counter = _counter + value;
//     setState(() {});
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Isolates"),
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: <Widget>[
//             Text(
//               'You have pushed the button this many times:',
//             ),
//             Text(
//               '$_counter',
//               style: Theme.of(context).textTheme.headline4,
//             ),
//             RaisedButton(
//               onPressed: () {
//                 runCompute();
//               },
//               child: Text("Compute Isolate"),
//             )
//           ],
//         ),
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: _incrementCounter,
//         tooltip: 'Increment',
//         child: Icon(Icons.add),
//       ),
//     );
//   }
// }
