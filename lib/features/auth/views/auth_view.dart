import 'package:flutter/material.dart';

class authView extends StatelessWidget {
    const authView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("auth View")),
      body: Center(child: Text("This is the auth view")),
    );
  }
}
