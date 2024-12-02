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
      body: Column(
        children: [
          const SizedBox(height: 40.0), // Adds margin above the AppBar
          AppBar(
            title: const Text(
              'Task Tracker',
              style: TextStyle(
                fontSize: 35.0,
                color: Color.fromARGB(255, 240, 240, 251),
                fontWeight: FontWeight.w600,
              ),
            ),
            centerTitle: true,
            elevation: 0, // Optional: Remove AppBar shadow
            backgroundColor: const Color.fromARGB(255, 66, 49, 113),
            actions: [
              Tooltip(
                message: 'Log out', // This is the title you want to show
                child: IconButton(
                  icon: const Icon(
                    Icons.logout,
                    color: Color.fromARGB(
                        255, 240, 240, 251), // Set the icon color here
                  ),
                  onPressed: () async {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Logged out!!')),
                    );
                    // Wait for the snackbar to be dismissed before navigating
                    await Future.delayed(const Duration(seconds: 2));
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const LoginPage()),
                    );
                  },
                ),
              ),
            ],
          ),
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 24.0, vertical: 48.0),
                child: Form(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      TextFormField(
                        controller: studentNameController,
                        decoration: InputDecoration(
                          labelText: 'Task Title',
                          labelStyle: const TextStyle(
                              color: Color.fromARGB(255, 66, 49, 113)),
                          filled: true, // Enables the background color
                          fillColor: const Color.fromARGB(
                              255, 230, 230, 250), // Background color
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Color.fromARGB(
                                  255, 66, 49, 113), // Border color
                              width: 2.0, // Border width
                            ),
                            borderRadius:
                                BorderRadius.circular(8.0), // Rounded corners
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Color.fromARGB(255, 123, 97,
                                  255), // Border color when focused
                              width: 2.0, // Border width when focused
                            ),
                            borderRadius:
                                BorderRadius.circular(8.0), // Rounded corners
                          ),
                          errorBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Colors.red, // Border color for errors
                              width: 2.0,
                            ),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color:
                                  Colors.red, // Border color for focused errors
                              width: 2.0,
                            ),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Title cannot be empty';
                          } else if (value.length < 6) {
                            return 'Title must be at least 3 characters long';
                          } else if (!RegExp(r'^[a-zA-Z]+$').hasMatch(value)) {
                            return 'Title must include only letters';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(
                          height: 20.0), // Adds margin between fields
                      TextFormField(
                        controller: studentTaskController,
                        decoration: InputDecoration(
                          labelText: 'Task Discription',
                          labelStyle: const TextStyle(
                            color: Color.fromARGB(255, 66, 49, 113),
                          ),
                          filled: true, // Enables the background color
                          fillColor: const Color.fromARGB(
                              255, 230, 230, 250), // Background color
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Color.fromARGB(255, 66, 49,
                                  113), // Border color when enabled
                              width: 2.0,
                            ),
                            borderRadius:
                                BorderRadius.circular(8.0), // Rounded corners
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Color.fromARGB(255, 123, 97,
                                  255), // Border color when focused
                              width: 2.0,
                            ),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Colors.red, // Border color for errors
                              width: 2.0,
                            ),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Colors
                                  .redAccent, // Border color when focused and error
                              width: 2.0,
                            ),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ), // Toggles password visibility
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Description cannot be empty.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 50.0),
                      ElevatedButton(
                        onPressed: () => _selectDate(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(
                              255, 66, 49, 113), // Button background color
                          foregroundColor: const Color.fromARGB(
                              255, 240, 240, 251), // Text color (foreground)
                          padding: const EdgeInsets.symmetric(
                              vertical: 12.0,
                              horizontal: 24.0), // Padding for the button
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                8.0), // Rounded corners like input fields
                          ),
                          elevation:
                              5, // Optional: Add shadow for a raised button effect
                          textStyle: const TextStyle(
                            // Custom text style
                            fontSize: 13.0, // Font size
                            fontWeight: FontWeight.w600, // Make text bold
                          ), // Optional: Add shadow for a raised button effect
                        ),
                        child: Text(
                          _selectedDate != null
                              ? 'Selected Date: ${DateFormat('yyyy-MM-dd').format(_selectedDate!.toLocal())}'
                              : 'Select Date',
                        ),
                      ),
                      const SizedBox(height: 50.0),
                      ElevatedButton(
                        onPressed:
                            _selectedTask != null ? _updateTask : addToDo,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(
                              255, 66, 49, 113), // Button background color
                          foregroundColor: const Color.fromARGB(
                              255, 240, 240, 251), // Text color
                          padding: const EdgeInsets.symmetric(
                              vertical: 14.0,
                              horizontal: 24.0), // Padding for the button
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                8.0), // Rounded corners like input fields
                          ),
                          elevation:
                              5, // Optional: Add shadow for a raised button effect
                        ),
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
                                      final varStudentName =
                                          varTodo.get<String>('title')!;
                                      final varStudentTask =
                                          varTodo.get<String>('description')!;
                                      final varDone =
                                          varTodo.get<bool>('done')!;
                                      final varDate = varTodo
                                              .get<DateTime>('date') ??
                                          DateTime
                                              .now(); // Fetch date from ParseObject

                                      return ListTile(
                                        title: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              varStudentTask,
                                              style: const TextStyle(
                                                color: Color.fromARGB(
                                                    255, 66, 49, 113),
                                                fontSize: 15,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            Text(
                                              varStudentName,
                                              style: const TextStyle(
                                                color: Color.fromARGB(
                                                    255, 160, 114, 195),
                                                fontSize: 12,
                                              ),
                                            ),
                                            Text(
                                              'Date: ${DateFormat('yyyy-MM-dd').format(varDate.toLocal())}', // Format date for display
                                              style: const TextStyle(
                                                color: Color.fromARGB(
                                                    255, 160, 114, 195),
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),
                                        leading: CircleAvatar(
                                          backgroundColor: varDone
                                              ? Colors.green
                                              : const Color.fromARGB(
                                                  255, 66, 49, 113),
                                          foregroundColor: const Color.fromARGB(
                                              255, 240, 240, 251),
                                          child: Icon(varDone
                                              ? Icons.check
                                              : Icons.error),
                                        ),
                                        trailing: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Checkbox(
                                              value: varDone,
                                              onChanged: (value) async {
                                                await updateTodo(
                                                    varTodo.objectId!, value!);
                                                setState(() {});
                                              },
                                            ),
                                            IconButton(
                                              icon: const Icon(
                                                Icons.delete,
                                                color: Color.fromARGB(
                                                    255, 66, 49, 113),
                                              ),
                                              onPressed: () async {
                                                await deleteTodo(
                                                    varTodo.objectId!);
                                                setState(() {
                                                  const snackBar = SnackBar(
                                                    content:
                                                        Text("Task deleted!"),
                                                    duration:
                                                        Duration(seconds: 2),
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
                      )
                    ],
                  ),
                ),
              ),
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
