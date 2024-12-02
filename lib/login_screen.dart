import 'package:assignment/signup_screen.dart';
import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

import 'home_screen.dart';

void main() {
  runApp(const LoginApp());
}

class LoginApp extends StatelessWidget {
  const LoginApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Login Demo',
      home: LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const SizedBox(height: 40.0), // Adds margin above the AppBar
          AppBar(
            title: const Text(
              'Login to QuickTask',
              style: TextStyle(
                fontSize: 35.0,
                color: Color.fromARGB(255, 66, 49, 113),
                fontWeight: FontWeight.w600,
              ),
            ),
            centerTitle: true,
            elevation: 0, // Optional: Remove AppBar shadow
            backgroundColor:
                Colors.transparent, // Transparent background for padding
          ),
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 24.0, vertical: 48.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: 'Email',
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
                            return 'Please enter your email';
                          } else if (!RegExp(
                                  r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+')
                              .hasMatch(value)) {
                            return 'Please enter a valid email address';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(
                          height: 20.0), // Adds margin between fields
                      TextFormField(
                        controller: _passwordController,
                        decoration: InputDecoration(
                          labelText: 'Password',
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
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isPasswordVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: const Color.fromARGB(255, 66, 49, 113),
                            ),
                            onPressed: () {
                              setState(() {
                                _isPasswordVisible = !_isPasswordVisible;
                              });
                            },
                          ),
                        ),
                        obscureText:
                            !_isPasswordVisible, // Toggles password visibility
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Password cannot be empty';
                          } else if (value.length < 6) {
                            return 'Password must be at least 6 characters long';
                          } else if (!RegExp(
                                  r'^(?=.*[0-9])(?=.*[a-zA-Z])([a-zA-Z0-9]+)$')
                              .hasMatch(value)) {
                            return 'Password must include both letters and numbers';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 50.0),
                      ElevatedButton(
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            // Get email and password from the controllers
                            String email = _emailController.text;
                            String password = _passwordController.text;

                            // Call the login function
                            try {
                              final user =
                                  await loginWithBack4App(email, password);

                              if (user != null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text('Logging you in...')),
                                );

                                // Wait for the snackbar to be dismissed before navigating
                                await Future.delayed(
                                    const Duration(seconds: 2));
                                // Successfully logged in, navigate to the home screen
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => const HomeScreen()),
                                );
                              } else {
                                // Show error if login fails
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text(
                                          'Invalid credentials. Please check your email and password.')),
                                );
                              }
                            } catch (e) {
                              // Catch any error and show the message
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Error: $e')),
                              );
                            }
                          }
                        },
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
                        child: const Text(
                          'Login',
                          style: TextStyle(
                            fontSize: 18.0, // Font size
                            fontWeight: FontWeight.bold, // Make text bold
                          ),
                        ),
                      ),
                      const SizedBox(height: 50.0),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          const Text(
                            'Do not have an account?',
                            style: TextStyle(
                              fontSize: 16.0, // Set font size for the text
                              fontWeight:
                                  FontWeight.normal, // Normal font weight
                              color: Color.fromARGB(
                                  255, 66, 49, 113), // Color to match the theme
                            ),
                          ),
                          const SizedBox(height: 15),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const SignUpPage()),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color.fromARGB(
                                  255, 66, 49, 113), // Button background color
                              foregroundColor: const Color.fromARGB(255, 240,
                                  240, 251), // Text color (foreground)
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
                              ),
                            ),
                            child: const Text('Sign up'),
                          ),
                        ],
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

  Future<ParseUser?> loginWithBack4App(String email, String password) async {
    // Create a ParseUser instance
    ParseUser user = ParseUser(email, password, email);

    // Perform login
    var response = await user.login();

    if (response.success) {
      return user; // Return the authenticated user
    } else {
      return null; // Return null if login fails
    }
  }
}
