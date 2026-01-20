import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../services/firestore_service.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isSigningIn = false;
  bool _isRegisterMode = false;
  bool _autoValidate = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String _getErrorMessage(Object e) {
    if (e is FirebaseAuthException) {
      switch (e.code) {
        case 'user-not-found':
          return 'No user found for that email.';
        case 'wrong-password':
          return 'Incorrect password provided.';
        case 'email-already-in-use':
          return 'An account already exists for that email.';
        case 'invalid-email':
          return 'The email address is not valid.';
        case 'weak-password':
          return 'The password is too weak (min 6 characters).';
        case 'network-request-failed':
          return 'Network error. Check your connection and try again.';
        default:
          return e.message ?? 'Authentication error: ${e.code}';
      }
    }
    return e.toString();
  }

  Future<void> _showError(Object e) async {
    if (!mounted) return;

    final msg = _getErrorMessage(e);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: Colors.red[700],
      ),
    );
  }

  Future<void> _signInWithEmail() async {
    FocusScope.of(context).unfocus();
    setState(() => _autoValidate = true);

    if (!(_formKey.currentState?.validate() ?? false)) return;

    try {
      setState(() => _isSigningIn = true);

      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
    } catch (e) {
      await _showError(e);
    } finally {
      if (mounted) setState(() => _isSigningIn = false);
    }
  }

  Future<void> _signUpWithEmail() async {
    FocusScope.of(context).unfocus();
    setState(() => _autoValidate = true);

    if (!(_formKey.currentState?.validate() ?? false)) return;

    try {
      setState(() => _isSigningIn = true);

      final userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      await FirestoreService().setDocument(
        'user_profiles',
        userCredential.user!.uid,
        {
          'email': _emailController.text.trim(),
          'uid': userCredential.user?.uid,
          'createdAt': DateTime.now().toUtc(),
          'authProvider': 'email',
        },
      );
    } catch (e) {
      await _showError(e);
    } finally {
      if (mounted) setState(() => _isSigningIn = false);
    }
  }

  Future<void> _sendPasswordResetEmail() async {
    FocusScope.of(context).unfocus();

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: _emailController.text.trim(),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password reset email sent.')),
      );
    } catch (e) {
      await _showError(e);
    }
  }

  String? _emailValidator(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Email is required.';
    if (!v.contains('@') || !v.contains('.')) {
      return 'Enter a valid email address.';
    }
    return null;
  }

  String? _passwordValidator(String? value) {
    final v = value ?? '';
    if (v.isEmpty) return 'Password is required.';
    if (v.length < 6) return 'Password must be at least 6 characters.';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData localTheme = Theme.of(context).copyWith(
      primaryColor: const Color(0xFF2E7D32),
      scaffoldBackgroundColor: const Color(0xFFF6FFF7),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF2E7D32),
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2E7D32),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF2E7D32)),
        ),
      ),
    );

    return Theme(
      data: localTheme,
      child: Scaffold(
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 450),
              child: Card(
                elevation: 6,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(22.0),
                  child: Form(
                    key: _formKey,
                    autovalidateMode: _autoValidate
                        ? AutovalidateMode.always
                        : AutovalidateMode.disabled,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 12),

                        // ✨ TITLE
                        Center(
                          child: Text(
                            'Qalby2Heart Login',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.green[800],
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                            labelText: 'Email',
                            border: OutlineInputBorder(),
                          ),
                          validator: _emailValidator,
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(height: 12),

                        TextFormField(
                          controller: _passwordController,
                          obscureText: true,
                          decoration: const InputDecoration(
                            labelText: 'Password',
                            border: OutlineInputBorder(),
                          ),
                          validator: _passwordValidator,
                          textInputAction: TextInputAction.done,
                          onFieldSubmitted: (_) async {
                            if (_isRegisterMode) {
                              await _signUpWithEmail();
                            } else {
                              await _signInWithEmail();
                            }
                          },
                        ),
                        const SizedBox(height: 14),

                        ElevatedButton(
                          onPressed: _isSigningIn
                              ? null
                              : () async {
                                  setState(() => _autoValidate = true);

                                  if (!(_formKey.currentState?.validate() ??
                                      false)) return;

                                  if (_isRegisterMode) {
                                    await _signUpWithEmail();
                                  } else {
                                    await _signInWithEmail();
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            _isRegisterMode ? 'Create account' : 'Sign in',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),

                        const SizedBox(height: 10),

                        TextButton(
                          onPressed: () => setState(
                              () => _isRegisterMode = !_isRegisterMode),
                          child: Text(
                            _isRegisterMode
                                ? 'Have an account? Sign in'
                                : 'Create an account',
                          ),
                        ),

                        const SizedBox(height: 8),

                        TextButton(
                          onPressed: _sendPasswordResetEmail,
                          child: const Text('Forgot Password?'),
                        ),

                        const SizedBox(height: 14),

                        if (_isSigningIn)
                          const Center(child: CircularProgressIndicator()),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
