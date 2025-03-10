import 'package:flutter/material.dart';
import 'package:calendar_view/calendar_view.dart';
import 'package:intl/intl.dart';
/*
UI: 
  X1. Drag+drop interface to draw new plans into a list
  X2. Interactive calendar to drop plans -> specific date
  X3. 'Create Plan' button to open modal to enter plan details [name, desc, date]
  X4. Color-coded list to display adoption+travel plans based on status [pending, complete]
  5. Plans in list shld have 
    Xswipe gesture=complete/incomplete, 
    Xlong-press=edit plan name, 
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
  DateTime date;
  Color color = Colors.red; 

  Plan(this.planName, this.markComplete, this.description, this.date, this.color);
}

class _PlanManagerScreen extends State<MyHomePage> {
  final TextEditingController insertName = TextEditingController();
  final TextEditingController insertDescription = TextEditingController();
  final TextEditingController insertDate = TextEditingController();
  final TextEditingController editName = TextEditingController();
  List<Plan> _planList = [];
  List<Plan> _matchedDates = [];
  DateTime _dateChosen = DateTime(2025, 03, 01);

  _createPlan() {
    setState(() {
      _planList.add(Plan(
        insertName.text, 
        false, 
        insertDescription.text, 
        _dateChosen,
        Colors.red, //incomplete color
      ));
      final event = CalendarEventData(
        date: _dateChosen,
        title: insertName.text,
        description: insertDescription.text,
      );
      //add to calendar view
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

  _filterPlans(DateTime dateToMatch) {
    setState(() {
      _matchedDates.clear();
      for (int i = 0; i < _planList.length; i++) {
        DateTime currentPlanDate = _planList[i].date;
        if (currentPlanDate.compareTo(dateToMatch) == 0) {
          _matchedDates.add(_planList[i]);
        }
      }
    });
  }

  _changeCompletion(int index) {
    setState(() {
      _matchedDates[index].markComplete = !_matchedDates[index].markComplete;
      _matchedDates[index].color = _matchedDates[index].markComplete ? Colors.lightBlue : Colors.red;
      
      for (int i = 0; i < _planList.length; i++) {
        if (_planList[i] == _matchedDates[index]) {
          _planList[i].markComplete = _matchedDates[index].markComplete;
          _planList[i].color = _matchedDates[index].color;
        }
      }
    });
  }

  void _editName(int index, StateSetter setModalState) {
    showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) {
        return SizedBox(
          height: 300, 
          child: Column(
            children: [
              TextField(
                obscureText: false,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  labelText: _matchedDates[index].planName,
                  ),
                controller: editName,
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _matchedDates[index].planName = editName.text;
                    for (int i = 0; i < _planList.length; i++) {
                      if (_planList[i] == _matchedDates[index]) {
                        _planList[i].planName = _matchedDates[index].planName;
                        break;
                      }
                    }
                  });
                  setModalState(() {});
                  Navigator.of(context).pop();
                },
                child: Text("Confirm"),
              ),
            ],
          )
        );
      },
    );
  }

  _deletePlan(int index, StateSetter setModalState) {
    setState(() {
      var cal = CalendarControllerProvider.of(context).controller;
      CalendarEventData? eventToRemove;

      for (int i = 0; i < _planList.length; i++) {
        if (_planList[i] == _matchedDates[index]) {
          _planList.removeAt(i);
          for (var event in cal.events) {
            if (event.date == _matchedDates[index].date &&
                event.title == _matchedDates[index].planName) {
              eventToRemove = event;
              break;
            }
          }
        }
      }
      _matchedDates.removeAt(index);
      if (eventToRemove != null) {
        cal.remove(eventToRemove);
      }
      
    });
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
          Expanded(child: MonthView(
            //PLAN LIST (when click on date/cell)
            onCellTap: (event, date) {
              setState(() { _filterPlans(date); });
              showModalBottomSheet<void>(
                context: context,
                builder: (BuildContext context) {
                  String dateFormat = DateFormat('MM-dd-yyyy').format(date);
                  return SizedBox(
                    height: 700, 
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                              dateFormat,
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                            ),
                          ),
                          Expanded(
                            child: _matchedDates.isEmpty ? const Center(child: Text('No plans! Enjoy your day off.')) :
                            StatefulBuilder(
                              builder: (context, setModalState) {
                                return ListView.builder(
                                  itemCount: _matchedDates.length,
                                  itemBuilder: (context, index) {
                                    return GestureDetector(
                                      onHorizontalDragEnd: (details) {
                                        _changeCompletion(index);
                                        // MODAL REBUILD
                                        setModalState(() {}); 
                                      },
                                      onLongPress: () {
                                        _editName(index, setModalState);
                                        setModalState(() {});
                                      },
                                      onDoubleTap: () {
                                        _deletePlan(index, setModalState);
                                        setModalState(() {});
                                      },
                                      child: ListTile(
                                        title: Text(_matchedDates[index].planName),
                                        tileColor: _matchedDates[index].color,
                                        subtitle: Text('Description: ${_matchedDates[index].description}\nCompletion Status: ${_matchedDates[index].markComplete}'),                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            }
          )),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          //ADD PLAN SHEET
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
