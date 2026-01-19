import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:flutter/foundation.dart';
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
        case 'account-exists-with-different-credential':
          return 'An account exists with a different sign-in method.';
        case 'network-request-failed':
          return 'Network error. Check your connection and try again.';
        default:
          return e.message ?? 'Authentication error: ${e.code}';
      }
    } else if (e is FirebaseException) {
      return e.message ?? 'Firebase error: ${e.code}';
    }
    return e.toString();
  }

  Future<void> _showError(Object e) async {
    if (!mounted) return;
    final msg = _getErrorMessage(e);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _signInWithEmail() async {
    FocusScope.of(context).unfocus();
    setState(() {
      _autoValidate = true;
    });

    if (!(_formKey.currentState?.validate() ?? false)) return;

    try {
      setState(() => _isSigningIn = true);
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
    } on FirebaseAuthException catch (e) {
      await _showError(e);
    } catch (e) {
      await _showError(e);
    } finally {
      if (mounted) {
        setState(() => _isSigningIn = false);
      }
    }
  }

  Future<void> _signUpWithEmail() async {
    FocusScope.of(context).unfocus();
    setState(() {
      _autoValidate = true;
    });

    if (!(_formKey.currentState?.validate() ?? false)) return;

    try {
      setState(() => _isSigningIn = true);
      final userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // Save user profile to Firestore
      await FirestoreService()
          .setDocument('user_profiles', userCredential.user!.uid, {
        'email': _emailController.text.trim(),
        'uid': userCredential.user?.uid,
        'createdAt': DateTime.now().toUtc(),
        'authProvider': 'email',
      });
    } on FirebaseAuthException catch (e) {
      await _showError(e);
    } catch (e) {
      await _showError(e);
    } finally {
      if (mounted) {
        setState(() => _isSigningIn = false);
      }
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() => _isSigningIn = true);
    try {
      UserCredential userCredential;
      if (kIsWeb) {
        // For web, use Firebase Auth's signInWithPopup
        final GoogleAuthProvider googleProvider = GoogleAuthProvider();
        googleProvider.addScope('email');
        googleProvider.addScope('profile');
        userCredential =
            await FirebaseAuth.instance.signInWithPopup(googleProvider);
      } else {
        // For mobile, use GoogleSignIn
        final googleUser = await GoogleSignIn.instance.authenticate();

        // GoogleSignInAuthentication only contains an ID token. Request an
        // authorization token (access token) using the authorization client.
        final idToken = googleUser.authentication.idToken;
        GoogleSignInClientAuthorization? authz;
        try {
          // Try lightweight token retrieval first (no UI). If null, fall back to
          // an explicit scope authorization request which may show UI.
          authz = await googleUser.authorizationClient.authorizationForScopes(
            const ['openid', 'email', 'profile'],
          );
          authz ??= await googleUser.authorizationClient.authorizeScopes(
            const ['openid', 'email', 'profile'],
          );
        } catch (_) {
          // If authorization fails, we still attempt sign-in with the ID token
          // which may be sufficient on some platforms.
        }

        final credential = GoogleAuthProvider.credential(
          accessToken: authz?.accessToken,
          idToken: idToken,
        );

        userCredential =
            await FirebaseAuth.instance.signInWithCredential(credential);
      }

      // Save user profile to Firestore (for new users or updates)
      await FirestoreService()
          .setDocument('user_profiles', userCredential.user!.uid, {
        'email': userCredential.user?.email,
        'displayName': userCredential.user?.displayName,
        'uid': userCredential.user?.uid,
        'createdAt': DateTime.now().toUtc(),
        'authProvider': 'google',
      });
    } on FirebaseAuthException catch (e) {
      await _showError(e);
    } catch (e) {
      await _showError(e);
    } finally {
      if (mounted) {
        setState(() => _isSigningIn = false);
      }
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
    return Scaffold(
      appBar: AppBar(title: const Text('Sign in')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Form(
              key: _formKey,
              autovalidateMode: _autoValidate
                  ? AutovalidateMode.always
                  : AutovalidateMode.disabled,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(labelText: 'Email'),
                    validator: _emailValidator,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(labelText: 'Password'),
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
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _isSigningIn
                        ? null
                        : () async {
                            setState(() => _autoValidate = true);
                            if (!(_formKey.currentState?.validate() ?? false)) {
                              return;
                            }
                            if (_isRegisterMode) {
                              await _signUpWithEmail();
                            } else {
                              await _signInWithEmail();
                            }
                          },
                    child: Text(_isRegisterMode ? 'Create account' : 'Sign in'),
                  ),
                  TextButton(
                    onPressed: () =>
                        setState(() => _isRegisterMode = !_isRegisterMode),
                    child: Text(_isRegisterMode
                        ? 'Have an account? Sign in'
                        : 'Create an account'),
                  ),
                  const SizedBox(height: 8),
                  const Divider(),
                  const SizedBox(height: 8),
                  SignInButton(
                    Buttons.Google,
                    onPressed: _isSigningIn ? null : _signInWithGoogle,
                  ),
                  const SizedBox(height: 8),
                  if (_isSigningIn)
                    const Center(child: CircularProgressIndicator()),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
