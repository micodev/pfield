import 'package:flutter/material.dart';
import 'package:pfield/pfield.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Pfield Widget'),
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
  bool isError = false;
  int fieldCount = 5;
  TextEditingController tc = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Pfield(
              isError: isError,
              count: fieldCount,
              controller: tc,
            ),
            const SizedBox(height: 10),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 10,
              children: [
                ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: isError ? Colors.red : null,
                    ),
                    onPressed: () {
                      setState(() {
                        isError = !isError;
                      });
                    },
                    child: const Text("toggle error")),
                ElevatedButton(
                    onPressed: () {
                      //you can also use this to set data from clipboard
                      // or use it to get it manually for any other purpose.
                      tc.text = "12345";
                    },
                    child: const Text("change value to 12345"))
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: ElevatedButton(
                        onPressed: () {
                          tc.text = "";
                        },
                        child: const Text("clear pin")),
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
