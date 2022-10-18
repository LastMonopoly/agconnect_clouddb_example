import 'package:agconnect_clouddb/agconnect_clouddb.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initCloudDB();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const title = 'CloudDB Demo';
    return MaterialApp(
      title: title,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: title),
    );
  }
}

initCloudDB() async {
  final cloudDB = AGConnectCloudDB.getInstance();
  await cloudDB.initialize();
  await cloudDB.createObjectType();
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Map<String, dynamic>>? objects;
  Object? error;

  Future<void> _incrementCounter() async {
    try {
      final cloudDB = AGConnectCloudDB.getInstance();
      final zoneConfig = AGConnectCloudDBZoneConfig(
        zoneName: "Alpha",
      );
      final AGConnectCloudDBZone zone = await cloudDB.openCloudDBZone(
        zoneConfig: zoneConfig,
      );
      var objectTypeName = "AppInfo";
      var query = AGConnectCloudDBQuery(objectTypeName);
      try {
        AGConnectCloudDBZoneSnapshot snapshot = await zone.executeQuery(
          query: query,
          policy: AGConnectCloudDBZoneQueryPolicy.POLICY_QUERY_DEFAULT,
        );
        objects = snapshot.snapshotObjects;
        error = null;
      } catch (e) {
        error = e;
      }
      setState(() {});
      await cloudDB.closeCloudDBZone(zone: zone);
    } catch (e) {
      setState(() {
        error = e;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            error == null
                ? Text(objects?.fold('', ((previousValue, element) {
                      return '${previousValue!}$element\n';
                    })) ??
                    '')
                : Text(error.toString()),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.search),
      ),
    );
  }
}
