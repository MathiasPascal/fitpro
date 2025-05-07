import 'package:fitpro/widgets/popup_dialog.dart';
import 'package:flutter/material.dart';
import 'package:fitpro/auth/signup_screen.dart';
import 'package:fitpro/core/auth_service.dart';
import 'package:fitpro/features/home.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  bool _obscureText = true;
  bool _isLoading = false;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  
  // Animation controllers
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeIn,
      ),
    );
    
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutBack,
      ),
    );
    
    // Start the animation when the screen loads
    _animationController.forward();
  }

  // Validation functions
  bool _isValidAshesiEmail(String email) {
    return email.isNotEmpty && email.toLowerCase().endsWith('@ashesi.edu.gh');
  }

  void _loginUser() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    // Validate fields
    if (email.isEmpty || password.isEmpty) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder:
            (context) => PopupDialog(
              title: 'Missing Information',
              message: 'Please enter both email and password',
              icon: Icons.error_outline,
              color: Colors.orange,
            ),
      );
      return;
    }

    // Validate email format
    if (!_isValidAshesiEmail(email)) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder:
            (context) => PopupDialog(
              title: 'Invalid Email',
              message:
                  'Please enter a valid Ashesi email address (@ashesi.edu.gh)',
              icon: Icons.email_outlined,
              color: Colors.red,
            ),
      );
      return;
    }

    // Start loading animation
    setState(() {
      _isLoading = true;
    });

    try {
      await _authService.signInWithEmailAndPassword(email, password);
      if (mounted) {
        // Stop loading animation
        setState(() {
          _isLoading = false;
        });
        
        showDialog(
          context: context,
          builder:
              (context) => PopupDialog(
                title: 'Success',
                message: 'Login successful. Welcome back!',
                icon: Icons.check_circle_outline,
                color: Colors.green,
                onDismiss: () {
                  Navigator.pushReplacement(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) => const HomePage(),
                      transitionsBuilder: (context, animation, secondaryAnimation, child) {
                        var begin = const Offset(1.0, 0.0);
                        var end = Offset.zero;
                        var curve = Curves.easeInOut;
                        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                        return SlideTransition(
                          position: animation.drive(tween),
                          child: child,
                        );
                      },
                    ),
                  );
                },
              ),
        );
      }
    } catch (e) {
      if (mounted) {
        // Stop loading animation
        setState(() {
          _isLoading = false;
        });
        
        String errorMessage = 'Login failed';
        IconData errorIcon = Icons.error_outline;

        // Handle specific error cases
        if (e.toString().contains('network')) {
          errorMessage =
              'Network error. Please check your internet connection and try again.';
          errorIcon = Icons.signal_wifi_off;
        } else if (e.toString().contains('auth credential is incorrect')) {
          errorMessage = 'Incorrect email or password';
          errorIcon = Icons.access_time;
        }

        showDialog(
          context: context,
          builder:
              (context) => PopupDialog(
                title: 'Login Failed',
                message: errorMessage,
                icon: errorIcon,
                color: Colors.red,
              ),
        );
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Logo creation
                    Center(
                      child: SizedBox(
                        width: 80,
                        height: 80,
                        child: Stack(
                          children: [
                            Positioned(
                              right: 0,
                              child: Container(
                                width: 50,
                                height: 40,
                                decoration: const BoxDecoration(
                                  color: Color.fromARGB(255, 173, 155, 238),
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(8),
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              left: 0,
                              child: Container(
                                width: 50,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: Colors.deepPurple.shade300,
                                  borderRadius: const BorderRadius.all(
                                    Radius.circular(8),
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              left: 10,
                              child: Container(
                                width: 20,
                                height: 20,
                                decoration: BoxDecoration(
                                  color: Colors.deepPurple.shade100,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 10,
                              child: Container(
                                width: 20,
                                height: 20,
                                decoration: BoxDecoration(
                                  color: Colors.deepPurple.shade100,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Sign In Text
                    const Text(
                      "Let's Get You In.",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),

                    // Ready to Collaborate Text
                    const Text(
                      "Ready to Rejuvinate?",
                      style: TextStyle(fontSize: 14, color: Colors.black54),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),

                    // Email Label
                    const Text(
                      "Email Address",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.deepPurple,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Email Input
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: TextField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          hintText: 'youremail@ashesi.edu.gh',
                          border: InputBorder.none,
                          prefixIcon: const Icon(
                            Icons.email_outlined,
                            color: Colors.deepPurple,
                          ),
                          contentPadding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        keyboardType: TextInputType.emailAddress,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Password Label
                    const Text(
                      "Password",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.deepPurple,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Password Input
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: TextField(
                        controller: _passwordController,
                        obscureText: _obscureText,
                        decoration: InputDecoration(
                          hintText: '***************',
                          border: InputBorder.none,
                          prefixIcon: const Icon(
                            Icons.lock_outline,
                            color: Colors.deepPurple,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureText
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: Colors.deepPurple,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscureText = !_obscureText;
                              });
                            },
                          ),
                          contentPadding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Sign In Button with Loading Animation
                    ElevatedButton(
                      onPressed: _isLoading ? null : _loginUser,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                        disabledBackgroundColor: Colors.deepPurple.shade200,
                      ),
                      child: _isLoading 
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Text(
                              'Sign In',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(width: 8),
                            Icon(Icons.arrow_forward, size: 18),
                          ],
                        ),
                    ),
                    const SizedBox(height: 24),

                    // Sign Up Text
                    Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "Don't have an account yet? ",
                            style: TextStyle(color: Colors.black54),
                          ),
                          TextButton(
                            onPressed: () {
                              // Navigate to sign up screen
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const SignupScreen(),
                                ),
                              );
                            },
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              foregroundColor: Colors.deepPurple,
                            ),
                            child: const Text(
                              "Sign Up",
                              style: TextStyle(fontWeight: FontWeight.w500),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}