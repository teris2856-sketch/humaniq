import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:swiftspeak/home_page.dart';

class MoodDetails1 extends StatefulWidget {
  const MoodDetails1({super.key, required this.entryId});

  final String entryId;

  @override
  State<MoodDetails1> createState() => _MoodDetails1State();
}

class _MoodDetails1State extends State<MoodDetails1> {
  bool isLoading = true;
  Map<String, dynamic> entry = {};
  String error = "";

  @override
  void initState() {
    super.initState();
    _loadEntry();
  }

  Future<void> _loadEntry() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        setState(() {
          isLoading = false;
          error = "Not logged in.";
        });
        return;
      }

      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('mood_checks')
          .doc(widget.entryId)
          .get();

      final data = doc.data();
      if (data == null) {
        setState(() {
          isLoading = false;
          error = "Entry not found.";
        });
        return;
      }

      setState(() {
        entry = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        error = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blueAccent,
          title: const Text('Mood Check Results'),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    if (error.isNotEmpty) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blueAccent,
          title: const Text('Mood Check Results'),
        ),
        body: Center(child: Text("Error: $error", style: const TextStyle(fontSize: 18))),
      );
    }

    final moodToday = (entry['moodToday'] ?? '').toString();
    final stress = (entry['stress'] ?? 0).toString();
    final energy = (entry['energy'] ?? 0).toString();
    final hope = (entry['hopefulness'] ?? 0).toString();
    final conf = (entry['confidence'] ?? 0).toString();
    final insight = (entry['insight'] ?? '').toString();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        title: const Text('Mood Check Results'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Column(
            children: [
              const SizedBox(height: 20),
              const Text("Here's your results:", style: TextStyle(fontSize: 36), textAlign: TextAlign.center),
              const SizedBox(height: 20),

              buildStatContainer("Your Mood Today:", moodToday),
              buildStatContainer("Your Stress Level:", stress),
              buildStatContainer("Your Energy Level:", energy),
              buildStatContainer("Your Hopefulness Level:", hope),
              buildStatContainer("Your Confidence Level:", conf),

              const SizedBox(height: 12),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(width: 2),
                  color: Colors.blueAccent.shade100,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Column(
                  children: [
                    const Text("AI Insight:", style: TextStyle(fontSize: 26), textAlign: TextAlign.center),
                    const SizedBox(height: 10),
                    Text(
                      insight.isEmpty ? "(No insight saved)" : insight,
                      style: const TextStyle(fontSize: 22),
                      textAlign: TextAlign.center,
                      softWrap: true,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(builder: (context) => HomePage()));
                },
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  child: Text("Back to home", style: TextStyle(fontSize: 24)),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildStatContainer(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(width: 2),
          color: Colors.blueAccent.shade100,
          borderRadius: BorderRadius.circular(25),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(title, style: const TextStyle(fontSize: 24), textAlign: TextAlign.center),
            const SizedBox(height: 6),
            Text(value, style: const TextStyle(fontSize: 24), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}