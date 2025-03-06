import 'package:flutter/material.dart';
/*
UI: 
  1. Drag+drop interface to draw new plans into a list
  2. Interactive calendar to drop plans -> specific date
  3. 'Create Plan' button to open modal to enter plan details [name, desc, date]
  4. Color-coded list to display adoption+travel plans based on status [pending, complete]
  5. Plans in list shld have 
    swipe gesture=complete/incomplete, 
    long-press=edit plan name, 
    double-tap=delete plan from list

  PlanManagerScreen=main screen w list of plans [each w obj=name+completion status] as instance var
  method to add/update/complete/remove plan w setstate
  Display=widget marks plans as complete, update plan name, delete plans via setstate

 */
TextEditingController insertName = TextEditingController();
TextEditingController insertDescription = TextEditingController();
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _PlanManagerScreen();
}

class Plan {
  String planName;
  bool markComplete;
  String description;

  Plan(this.planName, this.markComplete, this.description);
}

class _PlanManagerScreen extends State<MyHomePage> {
  List<Plan> _planList = [];

  _createPlan() {
    setState(() {
      _planList.add(Plan(insertName.text, false, insertDescription.text));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            /*const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),*/
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet<void>(
            context: context,
            builder: (BuildContext context) {
              return SizedBox(
                height: 400,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      const Text(
                        'Create Plan',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)
                      ),
                      SizedBox(height: 40.0),
                      TextField(
                        obscureText: false,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Plan Name',
                        ),
                        controller: insertName,
                      ),
                      SizedBox(height: 30.0),
                      TextField(
                        obscureText: false,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Description',
                        ),
                        controller: insertDescription,
                      ),
                      SizedBox(height: 30.0),
                      ElevatedButton(
                        onPressed: () { _createPlan; },
                        child: Text('Confirm'),
                      ),
                    ],
                  ),
                ),
              );
            }
          );
        },
        child: Icon(Icons.add),
      ), 
    );
  }
}
