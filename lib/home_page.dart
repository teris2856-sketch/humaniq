import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:swiftspeak/body_check.dart';
import 'package:swiftspeak/communicate.dart';
import 'package:swiftspeak/login.dart';
import 'package:swiftspeak/mood_check.dart';
import 'package:swiftspeak/new_chat.dart';
import 'package:swiftspeak/patient_profile_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lightBlue[100],
        title: const Text("Welcome"),
        actions: [
          IconButton(
            tooltip: 'Profile',
            icon: const Icon(Icons.person_outline),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PatientProfilePage(),
                ),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              children: [
                const SizedBox(height: 20),

                const Text(
                  "Patient Tools",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 20),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    /// LEFT COLUMN
                    Column(
                      children: [

                        /// BODY CHECK
                        InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const BodyCheck(),
                              ),
                            );
                          },
                          child: SizedBox(
                            height: 150,
                            width: 150,
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  width: 1,
                                  color: Colors.grey,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  CircleAvatar(
                                    radius: 30,
                                    backgroundImage: NetworkImage(
                                      "https://cdn-icons-png.flaticon.com/512/6522/6522516.png",
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text("Body Check"),
                                  Text("Tap the areas of pain"),
                                ],
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 10),

                        /// MOOD CHECK
                        InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const MoodCheck(),
                              ),
                            );
                          },
                          child: SizedBox(
                            height: 150,
                            width: 150,
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  width: 1,
                                  color: Colors.grey,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  CircleAvatar(
                                    radius: 30,
                                    backgroundImage: NetworkImage(
                                      "https://cdn-icons-png.flaticon.com/512/6522/6522516.png",
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text("Mood Check"),
                                  Text("How are you feeling?"),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(width: 20),

                    /// RIGHT COLUMN
                    Column(
                      children: [

                        /// COMMUNICATION BOARD
                        InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const Communicate(),
                              ),
                            );
                          },
                          child: SizedBox(
                            height: 150,
                            width: 150,
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  width: 1,
                                  color: Colors.grey,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  CircleAvatar(
                                    radius: 30,
                                    backgroundImage: NetworkImage(
                                      "https://cdn-icons-png.flaticon.com/512/6522/6522516.png",
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    "Communication",
                                    textAlign: TextAlign.center,
                                  ),
                                  Text(
                                    "Express your needs easily",
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 10),

                        /// AI CHATBOT
                        InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const NewChat(),
                              ),
                            );
                          },
                          child: SizedBox(
                            height: 150,
                            width: 150,
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  width: 1,
                                  color: Colors.grey,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  CircleAvatar(
                                    radius: 30,
                                    backgroundImage: NetworkImage(
                                      "https://cdn-icons-png.flaticon.com/512/6522/6522516.png",
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    "AI Chatbot",
                                    textAlign: TextAlign.center,
                                  ),
                                  Text(
                                    "Get personalized AI responses",
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),

            /// LOGOUT BUTTON
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 0, 0, 100),
              child: ElevatedButton(
                child: const Text(
                  "Log Out",
                  style: TextStyle(fontSize: 22),
                ),
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();

                  if (!mounted) return;

                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (_) => const Login(),
                    ),
                        (route) => false,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}