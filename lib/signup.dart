import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'home_page.dart';
import 'staff_home_page.dart';

class Signup extends StatefulWidget {
  const Signup({super.key});

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _isLoading = false;
  String? selectedRole; // "patient" or "staff"

  Future<void> signUpUser() async {
    final displayName = nameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty || selectedRole == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Please fill all fields and choose a role")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Create Firebase Auth user
      UserCredential userCred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (displayName.isNotEmpty) {
        try {
          await userCred.user!.updateDisplayName(displayName);
        } catch (_) {
          // Account is still valid; Firestore below remains source of truth.
        }
      }

      // Save role to Firestore
      try {
        final profile = <String, dynamic>{
          'email': email,
          'role': selectedRole,
          'createdAt': FieldValue.serverTimestamp(),
        };
        if (displayName.isNotEmpty) {
          profile['displayName'] = displayName;
        }
        await _firestore.collection('users').doc(userCred.user!.uid).set(profile);
      } catch (_) {
        await userCred.user?.delete();
        rethrow;
      }

      if (!mounted) return;

      // Navigate based on role
      if (selectedRole == "patient") {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const HomePage()),
              (route) => false,
        );
      } else if (selectedRole == "staff") {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const StaffHomePage()),
              (route) => false,
        );
      }
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'email-already-in-use':
          message = 'This email is already registered.';
          break;
        case 'invalid-email':
          message = 'The email address is invalid.';
          break;
        case 'weak-password':
          message = 'Password should be at least 6 characters.';
          break;
        default:
          message = e.message ?? 'Signup failed.';
      }
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    } on FirebaseException catch (e) {
      if (!mounted) return;
      if (kDebugMode) {
        debugPrint('Signup Firestore error: ${e.code} ${e.message}');
      }
      final String message = e.code == 'permission-denied'
          ? 'Firestore blocked saving your profile. Deploy firestore.rules or update Rules in the Firebase console.'
          : (e.message ?? 'Database error (${e.code}).');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    } catch (e, st) {
      if (kDebugMode) {
        debugPrint('Signup error: $e\n$st');
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            kDebugMode
                ? 'Error: $e'
                : 'Something went wrong. Please try again.',
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget roleButton(String roleName, String value) {
    final bool selected = selectedRole == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => selectedRole = value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: selected ? Colors.lightBlue[300] : Colors.grey[300],
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.center,
          child: Text(roleName, style: const TextStyle(fontSize: 16)),
        ),
      ),
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView( // ensures screen scrolls if keyboard covers fields
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("Sign Up", style: TextStyle(fontSize: 50)),
              const SizedBox(height: 20),

              Padding(
                padding: const EdgeInsets.all(10),
                child: TextField(
                  controller: nameController,
                  textCapitalization: TextCapitalization.words,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    hintText: "Your name (optional)",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(10),
                child: TextField(
                  controller: emailController,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    hintText: "Email",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(10),
                child: TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    hintText: "Password",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 10),
              const Text("Select Role", style: TextStyle(fontSize: 18)),
              const SizedBox(height: 10),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    roleButton("Patient", "patient"),
                    const SizedBox(width: 10),
                    roleButton("Hospital Staff", "staff"),
                  ],
                ),
              ),

              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.lightBlue[300],
                ),
                onPressed: _isLoading ? null : signUpUser,
                child: Text(
                  _isLoading ? "Creating..." : "Create Account",
                  style: const TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}