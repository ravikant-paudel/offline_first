import 'package:flutter/material.dart';
import 'package:offline_first/add_data_Page.dart';
import 'package:offline_first/locator.dart';
import 'package:offline_first/model/offline_model.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late Future<List<OfflineModel>> offlineModel;

  @override
  void initState() {
    super.initState();
    offlineModel = getUserData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Test')),
      body: _HomeBody(offlineModel),
      floatingActionButton: FloatingActionButton.small(
          child: const Icon(Icons.add),
          onPressed: () {
            //Move to add page
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AddDataPage()),
            );
          }),
    );
  }
}

class _HomeBody extends StatelessWidget {
  final Future<List<OfflineModel>> offlineModel;

  const _HomeBody(this.offlineModel);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<OfflineModel>>(
      future: offlineModel,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else if (!snapshot.hasData) {
          return const Text('No data available.');
        } else {
          final items = snapshot.data;
          return ListView.builder(
            itemCount: items?.length ?? 0,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(items?[index].name ?? ''),
              );
            },
          );
        }
      },
    );
  }
}

Future<List<OfflineModel>> getUserData() async {
  final offlineDb = locator.offlineDbase.openStore<OfflineModel>();

  final data = await offlineDb.fetch(
    resolve: (json) => OfflineModel.fromJson(json),
  );
  print('GET USER  data');
  return data;
}
