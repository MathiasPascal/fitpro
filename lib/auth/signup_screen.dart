import 'package:fitpro/widgets/popup_dialog.dart';
import 'package:fitpro/core/auth_service.dart' show AuthService;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fitpro/auth/login_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  bool _isLoading = false;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _obscureText = true;
  bool _obscureConfirmText = true;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  bool _acceptedTerms = false;

  final AuthService _authService = AuthService();

  // Validation functions
  bool _isValidAshesiEmail(String email) {
    return email.isNotEmpty &&
        email.contains('@') &&
        email.toLowerCase().endsWith('@ashesi.edu.gh');
  }

  bool _isValidPassword(String password) {
    // Check if password is at least 8 characters with uppercase, symbol, and number
    RegExp hasUppercase = RegExp(r'[A-Z]');
    RegExp hasSymbol = RegExp(r'[!@#$%^&*(),.?":{}|<>]');
    RegExp hasNumber = RegExp(r'[0-9]');

    return password.length >= 8 &&
        hasUppercase.hasMatch(password) &&
        hasSymbol.hasMatch(password) &&
        hasNumber.hasMatch(password);
  }

  Future<void> registerUser() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;
    UserCredential? userCredential;

    // Check if all fields are filled
    if (name.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder:
            (context) => PopupDialog(
              title: 'Missing Information',
              message: 'Please fill in all fields',
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

    // Validate password requirements
    if (!_isValidPassword(password)) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder:
            (context) => PopupDialog(
              title: 'Invalid Password',
              message:
                  'Password must be at least 8 characters long and include an uppercase letter, a number, and a special character',
              icon: Icons.lock_outlined,
              color: Colors.red,
            ),
      );
      return;
    }

    // Check if passwords match
    if (password != confirmPassword) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder:
            (context) => PopupDialog(
              title: 'Password Mismatch',
              message:
                  'Passwords do not match. Please ensure both passwords are the same.',
              icon: Icons.lock_outlined,
              color: Colors.red,
            ),
      );
      return;
    }

    // Check if terms are accepted
    if (!_acceptedTerms) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder:
            (context) => PopupDialog(
              title: 'Terms Not Accepted',
              message:
                  'Please accept the Terms of Service and Privacy Policy to continue',
              icon: Icons.gavel_outlined,
              color: Colors.orange,
            ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      userCredential = await _authService.registerWithEmailAndPassword(
        email,
        password,
      );

      try {
        // Save user data to Firestore
        final uid = userCredential.user?.uid;
        await _firestore.collection('users').doc(uid).set({
          'name': name,
          'email': email,
          'createdAt': Timestamp.now(),
        });

        if (mounted) {
          setState(() {
            _isLoading = false;
          });
          print('User registered successfully: ${userCredential.user?.uid}');
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const LoginScreen()),
          );
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });

          showDialog(
            context: context,
            barrierDismissible: false,
            builder:
                (context) => PopupDialog(
                  title: 'Account Created',
                  message:
                      'Your account was created, but we couldn\'t save your profile data',
                  icon: Icons.warning_amber_outlined,
                  color: Colors.orange,
                ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        String errorMessage = 'Registration failed';
        IconData errorIcon = Icons.error_outline;

        // Handle specific error cases
        if (e.toString().contains('network')) {
          errorMessage =
              'Network error. Please check your internet connection and try again.';
          errorIcon = Icons.signal_wifi_off;
        } else if (e.toString().contains('email address is already in use')) {
          errorMessage =
              'The email address is already in use by another account.';
          errorIcon = Icons.email_outlined;
        }

        showDialog(
          context: context,
          barrierDismissible: false,
          builder:
              (context) => PopupDialog(
                title: 'Registration Failed',
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
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Logo creation (same as login screen)
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

                // Sign Up Text
                const Text(
                  "Create Account",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),

                // Join the community text
                const Text(
                  "Join our community",
                  style: TextStyle(fontSize: 14, color: Colors.black54),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),

                // Full Name Label
                const Text(
                  "Full Name",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.deepPurple,
                  ),
                ),
                const SizedBox(height: 8),

                // Full Name Input
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      hintText: 'Xi Doe',
                      border: InputBorder.none,
                      prefixIcon: Icon(
                        Icons.person_outline,
                        color: Colors.deepPurple,
                      ),
                      contentPadding: EdgeInsets.symmetric(vertical: 12),
                    ),
                    keyboardType: TextInputType.name,
                  ),
                ),
                const SizedBox(height: 16),

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
                    decoration: const InputDecoration(
                      hintText: 'youremail@ashesi.edu.gh',
                      border: InputBorder.none,
                      prefixIcon: Icon(
                        Icons.email_outlined,
                        color: Colors.deepPurple,
                      ),
                      contentPadding: EdgeInsets.symmetric(vertical: 12),
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                ),
                const SizedBox(height: 16),

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
                const SizedBox(height: 8),
                // Password hint text
                Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: Text(
                    "Password must be at least 8 characters with uppercase, number, and symbol",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Confirm Password Label
                const Text(
                  "Confirm Password",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.deepPurple,
                  ),
                ),
                const SizedBox(height: 8),

                // Confirm Password Input
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: TextField(
                    controller: _confirmPasswordController,
                    obscureText: _obscureConfirmText,
                    decoration: InputDecoration(
                      hintText: '***************',
                      border: InputBorder.none,
                      prefixIcon: const Icon(
                        Icons.lock_outline,
                        color: Colors.deepPurple,
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureConfirmText
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: Colors.deepPurple,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureConfirmText = !_obscureConfirmText;
                          });
                        },
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Terms and conditions checkbox
                Row(
                  children: [
                    Checkbox(
                      value: _acceptedTerms,
                      onChanged: (value) {
                        setState(() {
                          _acceptedTerms = value ?? false;
                        });
                      },
                      activeColor: Colors.deepPurple,
                    ),
                    Expanded(
                      child: RichText(
                        text: const TextSpan(
                          style: TextStyle(color: Colors.black54, fontSize: 12),
                          children: [
                            TextSpan(text: "I agree to the "),
                            TextSpan(
                              text: "Terms of Service",
                              style: TextStyle(
                                color: Colors.deepPurple,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            TextSpan(text: " and "),
                            TextSpan(
                              text: "Privacy Policy",
                              style: TextStyle(
                                color: Colors.deepPurple,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Sign Up Button
                ElevatedButton(
                  onPressed: _isLoading ? null : registerUser,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  child:
                      _isLoading
                          ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                          : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Text(
                                'Create Account',
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

                // Sign In Text
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Already have an account? ",
                        style: TextStyle(color: Colors.black54),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const LoginScreen(),
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
                          "Sign In",
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
