import 'package:assignment/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import 'package:intl/intl.dart'; // Import for date formatting

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  const keyApplicationId = 'Z9RK20JOAB8OvB66147mXu8h9nbDEU0NXv3OesG6';
  const keyClientKey = '4gjiSUReWlHeHOggT455aNUy1AgEtrQ2zhQ552xH';
  const keyParseServerUrl = 'https://parseapi.back4app.com';

  await Parse().initialize(keyApplicationId, keyParseServerUrl,
      clientKey: keyClientKey, debug: true);

  runApp(const MaterialApp(
    home: HomeScreen(),
    debugShowCheckedModeBanner: false,
  ));
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final studentNameController = TextEditingController();
  final studentTaskController = TextEditingController();
  DateTime? _selectedDate; // New DateTime variable for date selection

  ParseObject? _selectedTask;

  void addToDo() async {
    if (studentTaskController.text.trim().isEmpty ||
        studentNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Empty fields"),
        duration: Duration(seconds: 2),
      ));
      return;
    }
    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Please select a date"),
        duration: Duration(seconds: 2),
      ));
      return;
    }
    await saveTodo(
        studentTaskController.text, studentNameController.text, _selectedDate!);
    setState(() {
      studentTaskController.clear();
      studentNameController.clear();
      _selectedDate = null;
    });
  }

  // Function to show the date picker
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  void _clearSelectedTask() {
    setState(() {
      _selectedTask = null;
      studentTaskController.clear();
      studentNameController.clear();
      _selectedDate = null; // Clear selected date
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text(
            "Student Tracker",
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.blueAccent),
      body: Column(
        children: <Widget>[
          Container(
            padding: const EdgeInsets.fromLTRB(17.0, 1.0, 7.0, 1.0),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    autocorrect: true,
                    textCapitalization: TextCapitalization.sentences,
                    controller: studentNameController,
                    decoration: const InputDecoration(
                      labelText: "Student name",
                      labelStyle: TextStyle(color: Colors.blueAccent),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(17.0, 1.0, 7.0, 1.0),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    autocorrect: true,
                    textCapitalization: TextCapitalization.sentences,
                    controller: studentTaskController,
                    decoration: const InputDecoration(
                      labelText: "Student task",
                      labelStyle: TextStyle(color: Colors.blueAccent),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          // Button to select date
          ElevatedButton(
            onPressed: () => _selectDate(context),
            child: Text(
              _selectedDate != null
                  ? 'Selected Date: ${DateFormat('yyyy-MM-dd').format(_selectedDate!.toLocal())}'
                  : 'Select Date',
            ),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              foregroundColor: const Color.fromARGB(255, 221, 230, 164),
              backgroundColor: Colors.blueAccent,
            ),
            onPressed: _selectedTask != null ? _updateTask : addToDo,
            child: Text(_selectedTask != null ? "UPDATE" : "ADD"),
          ),
          Expanded(
            child: FutureBuilder<List<ParseObject>>(
              future: getTodo(),
              builder: (context, snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.none:
                  case ConnectionState.waiting:
                    return const Center(
                      child: SizedBox(
                        width: 100,
                        height: 100,
                        child: CircularProgressIndicator(),
                      ),
                    );
                  default:
                    if (snapshot.hasError) {
                      return const Center(
                        child: Text("Error..."),
                      );
                    }
                    if (!snapshot.hasData) {
                      return const Center(
                        child: Text("No Data..."),
                      );
                    } else {
                      return ListView.builder(
                        padding: const EdgeInsets.only(top: 10.0),
                        itemCount: snapshot.data!.length,
                        itemBuilder: (context, index) {
                          final varTodo = snapshot.data![index];
                          final varStudentName = varTodo.get<String>('title')!;
                          final varStudentTask =
                              varTodo.get<String>('description')!;
                          final varDone = varTodo.get<bool>('done')!;
                          final varDate = varTodo.get<DateTime>('date') ??
                              DateTime.now(); // Fetch date from ParseObject

                          return ListTile(
                            title: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(varStudentTask),
                                Text(
                                  varStudentName,
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                ),
                                Text(
                                  'Date: ${DateFormat('yyyy-MM-dd').format(varDate.toLocal())}', // Format date for display
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                            leading: CircleAvatar(
                              backgroundColor:
                                  varDone ? Colors.green : Colors.blue,
                              foregroundColor:
                                  const Color.fromARGB(255, 221, 230, 164),
                              child: Icon(varDone ? Icons.check : Icons.error),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Checkbox(
                                  value: varDone,
                                  onChanged: (value) async {
                                    await updateTodo(varTodo.objectId!, value!);
                                    setState(() {});
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.blue,
                                  ),
                                  onPressed: () async {
                                    await deleteTodo(varTodo.objectId!);
                                    setState(() {
                                      const snackBar = SnackBar(
                                        content: Text("Task deleted!"),
                                        duration: Duration(seconds: 2),
                                      );
                                      ScaffoldMessenger.of(context)
                                        ..removeCurrentSnackBar()
                                        ..showSnackBar(snackBar);
                                    });
                                  },
                                )
                              ],
                            ),
                          );
                        },
                      );
                    }
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> saveTodo(String title, String description, DateTime date) async {
    final todo = ParseObject('tasks')
      ..set('title', title)
      ..set('description', description)
      ..set('done', false)
      ..set('date', date); // Save selected date
    await todo.save();
  }

  Future<List<ParseObject>> getTodo() async {
    QueryBuilder<ParseObject> queryTodo =
        QueryBuilder<ParseObject>(ParseObject('tasks'));
    final ParseResponse apiResponse = await queryTodo.query();
    if (apiResponse.success && apiResponse.results != null) {
      return apiResponse.results as List<ParseObject>;
    } else {
      return [];
    }
  }

  Future<void> updateTodo(String id, bool done) async {
    var todo = ParseObject('tasks')
      ..objectId = id
      ..set('done', done);
    await todo.save();
  }

  Future<void> deleteTodo(String id) async {
    var todo = ParseObject('tasks')..objectId = id;
    await todo.delete();
  }

  Future<void> _updateTask() async {
    if (_selectedTask != null) {
      final title = studentTaskController.text.trim();
      final description = studentNameController.text.trim();
      if (title.isNotEmpty && description.isNotEmpty) {
        _selectedTask!.set<String>('title', title);
        _selectedTask!.set<String>('description', description);
        _selectedTask!
            .set<DateTime>('date', _selectedDate!); // Update selected date
        await _selectedTask!.save();
        _clearSelectedTask();
      }
    }
  }
}
