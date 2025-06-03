import 'package:client/model/auth.dart';
import 'package:client/model/user.dart';
import 'package:client/page/home_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool isSignIn = true;
  late PageController _pageController;

  final Color primaryColor = const Color(0xFF2C11A6);
  final Color greyColor = const Color(0xFFFFFFFF);

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  // Buat controller buat login (terpisah antara login dan register)
  final TextEditingController _loginEmailController = TextEditingController();
  final TextEditingController _loginPasswordController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _loginEmailController.dispose();
    _loginPasswordController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void navigateToHome(BuildContext context) async {
    await Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const HomePage()),
    );
  }

  void handleLogin() async {
    final authData = Auth(
      _loginEmailController.text.trim(),
      _loginPasswordController.text.trim(),
    );

    // Buat debugging sambil nunggu backend jadi
    print("Email: ${authData.email}, Password: ${authData.password}");

    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:8080/api/user/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': authData.email,
          'password': authData.password,
        }),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final token = data['token'];
        final user = data['user'];

        // TO-DO: Simpan token ke storage lokal (shared_preferences atau secure_storage)
        print("Login successful! Token: $token");

        navigateToHome(context);
      } else {
        print("Login failed: ${response.body}");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Login gagal: ${jsonDecode(response.body)['message'] ?? 'Unknown error'}",
            ),
          ),
        );
      }
    } catch (e) {
      // Tangani error disini, misalnya tampilkan snackbar atau dialog
      print("Login failed: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Login failed: $e")));
    }
  }

  void handleRegister() async {
    final userData = User(
      _nameController.text,
      _emailController.text.trim(),
      _passwordController.text.trim(),
    );

    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:8080/api/user/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': userData.name,
          'email': userData.email,
          'password': userData.password,
        }),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        print("Registrasi berhasil: $data");

        // Tunggu 1 detik agar backend siap
        await Future.delayed(Duration(seconds: 1));

        // Otomatis login
        handleLogin();
      } else {
        print("Registrasi gagal: $data");
      }
    } catch (e) {
      print("Error saat registrasi: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: greyColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // Top-Navigation bar
              Container(
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFA1A1A1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() => isSignIn = true);
                          _pageController.animateToPage(
                            0,
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        },
                        child: Container(
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: isSignIn ? Colors.white : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow:
                                isSignIn
                                    ? [
                                      BoxShadow(
                                        color: Colors.black26,
                                        blurRadius: 4,
                                        offset: Offset(0, 2),
                                      ),
                                    ]
                                    : [],
                          ),
                          child: Text(
                            'Sign In',
                            style: TextStyle(
                              color:
                                  isSignIn
                                      ? primaryColor
                                      : const Color.fromARGB(255, 88, 88, 88),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() => isSignIn = false);
                          _pageController.animateToPage(
                            1,
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        },
                        child: Container(
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color:
                                !isSignIn ? Colors.white : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow:
                                !isSignIn
                                    ? [
                                      BoxShadow(
                                        color: Colors.black26,
                                        blurRadius: 4,
                                        offset: Offset(0, 2),
                                      ),
                                    ]
                                    : [],
                          ),
                          child: Text(
                            'Sign up',
                            style: TextStyle(
                              color:
                                  !isSignIn
                                      ? primaryColor
                                      : const Color.fromARGB(255, 88, 88, 88),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // PageView buat SignIn dan SignUp
              const SizedBox(height: 32),

              // Swipeable PageView
              Expanded(
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      isSignIn = index == 0;
                    });
                  },
                  children: [buildSignInPage(), buildSignUpPage()],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Setting Form buat Register & Login
  final _loginFormKey = GlobalKey<FormState>();
  final _registerFormKey = GlobalKey<FormState>();

  Widget buildSignInPage() {
    return SingleChildScrollView(
      child: SizedBox(
        height: MediaQuery.of(context).size.height - 200,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Form(
                key: _loginFormKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Welcome back,",
                      style: TextStyle(
                        fontSize: 32,
                        color: primaryColor,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const Text(
                      "Good to see you again",
                      style: TextStyle(color: Colors.grey),
                    ),

                    // buat ngasih break antara text dengan text-field
                    const SizedBox(height: 16),

                    // Email field
                    TextFormField(
                      controller: _loginEmailController,
                      decoration: InputDecoration(
                        labelText: "Email",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 16,
                        ),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Email is required";
                        }
                        // Validasi format email
                        final emailRegex = RegExp(
                          r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
                        );
                        if (!emailRegex.hasMatch(value)) {
                          return "Please enter a valid email address";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16), // Spasi antara field
                    // Password field
                    TextFormField(
                      controller: _loginPasswordController,
                      decoration: InputDecoration(
                        labelText: "Password",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 16,
                        ),
                      ),
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Password is required";
                        }
                        if (value.length < 6) {
                          return "Password must be at least 6 characters";
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 32), // Spasi antara field
                    // Sign-in button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                        onPressed: () {
                          if (_loginFormKey.currentState!.validate()) {
                            handleLogin();
                          }
                        },
                        child: const Text(
                          "Login",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildSignUpPage() {
    return SingleChildScrollView(
      child: SizedBox(
        height: MediaQuery.of(context).size.height - 200,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Form(
                key: _registerFormKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Hello there,",
                      style: TextStyle(
                        fontSize: 32,
                        color: primaryColor,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const Text(
                      "We are excited to see you here",
                      style: TextStyle(color: Colors.grey),
                    ),

                    const SizedBox(height: 16),

                    // Name field
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: "Name",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 16,
                        ),
                      ),
                      keyboardType: TextInputType.name,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Name is required";
                        }
                        if (value.length < 3) {
                          return "Name must be at least 3 characters";
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    // Email field
                    TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: "Email",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 16,
                        ),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Email is required";
                        }
                        // Validasi format email
                        final emailRegex = RegExp(
                          r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
                        );
                        if (!emailRegex.hasMatch(value)) {
                          return "Please enter a valid email address";
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    // Password field
                    TextFormField(
                      controller: _passwordController,
                      decoration: InputDecoration(
                        labelText: "Password",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 16,
                        ),
                      ),
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Password is required";
                        }
                        if (value.length < 6) {
                          return "Password must be at least 6 characters";
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    // Confirm Password field
                    TextFormField(
                      controller: _confirmPasswordController,
                      decoration: InputDecoration(
                        labelText: "Confirm Password",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 16,
                        ),
                      ),
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Confirm Password is required";
                        }
                        if (value != _passwordController.text) {
                          return "Passwords do not match";
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 32), // Spasi antara field
                    // Sign-up button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                        onPressed: () {
                          if (_registerFormKey.currentState!.validate()) {
                            handleRegister();
                          }
                        },
                        child: const Text(
                          "Register",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
