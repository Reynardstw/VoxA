import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool isSignIn = true;
  late PageController _pageController;

  final Color primaryColor = const Color(0xFF6200EE);
  final Color greyColor = const Color(0xFFE0E0E0);

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
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

  Widget buildSignInPage() {
    return Center(
      child: Text(
        'Sign In Page Placeholder',
        style: TextStyle(fontSize: 24, color: primaryColor),
      ),
    );
  }

  Widget buildSignUpPage() {
    return Center(
      child: Text(
        'Sign Up Page Placeholder',
        style: TextStyle(fontSize: 24, color: primaryColor),
      ),
    );
  }
}
