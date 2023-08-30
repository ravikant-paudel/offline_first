import 'package:flutter/material.dart';
import 'package:offline_first/add_data_Page.dart';

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: AppBar(title: const Text('Test')),
      body: const _HomeBody(),
      floatingActionButton: FloatingActionButton.small(onPressed: (){
        //Move to add page
        Navigator.push(context, MaterialPageRoute(builder: (context) => const AddDataPage()),);

      }),
    );
  }
}

class _HomeBody extends StatelessWidget {
  const _HomeBody({super.key});

  @override
  Widget build(BuildContext context) {
    return  Container(

    );
  }
}
