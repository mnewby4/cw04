import 'package:flutter/material.dart';
import 'package:calendar_view/calendar_view.dart';
import 'dart:ui';
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

  XPlanManagerScreen=main screen w list of plans [each w obj=name+completion status] as instance var
  method to add/update/complete/remove plan w setstate
  Display=widget marks plans as complete, update plan name, delete plans via setstate

 */
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return 
    CalendarControllerProvider(
      controller: EventController(),
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: const MyHomePage(title: 'Plan Manager'),
      ),
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
  String date;

  Plan(this.planName, this.markComplete, this.description, this.date);
}

class _PlanManagerScreen extends State<MyHomePage> {
  final TextEditingController insertName = TextEditingController();
  final TextEditingController insertDescription = TextEditingController();
  final TextEditingController insertDate = TextEditingController();
  List<Plan> _planList = [];
  DateTime _dateChosen = DateTime(2025, 03, 01);

  _createPlan() {
    setState(() {
      _planList.add(Plan(
        insertName.text, 
        false, 
        insertDescription.text, 
        insertDate.text,
      ));
      final event = CalendarEventData(
        date: _dateChosen,
        title: insertName.text,
        description: insertDescription.text,
      );
      CalendarControllerProvider.of(context).controller.add(event);
    });
  }
  Future<void> _selectDate() async {
    DateTime? _picked = await showDatePicker(
      context: context, 
      initialDate: DateTime.now(),
      firstDate: DateTime.utc(2025, DateTime.now().month, 1), 
      lastDate: DateTime.utc(2025, DateTime.now().month + 1, 0),
    );
    if (_picked != null) {
      setState(() {
        insertDate.text = _picked.toString().split(" ")[0];
        _dateChosen = _picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Column(
        children: [
          Expanded(child: MonthView()),
        ],
      ),
      // ADD PLAN MODAL
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
                      SizedBox(height: 20.0),
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
                      TextField(
                        controller: insertDate,
                        decoration: InputDecoration(
                          labelText: 'Date',
                          filled: true, 
                        ),
                        readOnly: true,
                        onTap: () { 
                          _selectDate();
                        }
                      ),
                      SizedBox(height: 20.0),
                      ElevatedButton(
                        onPressed: () { 
                          _createPlan();
                          Navigator.pop(context); 
                        },
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
