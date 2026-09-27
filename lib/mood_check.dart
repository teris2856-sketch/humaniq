import 'package:flutter/material.dart';
import 'package:swiftspeak/mood_check2.dart';
import 'mood_check4.dart';

class MoodCheck extends StatefulWidget {
  const MoodCheck({super.key});

  @override
  State<MoodCheck> createState() => _MoodCheckState();
}

class _MoodCheckState extends State<MoodCheck> {
  void _goToSliders(String mood) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => MoodCheck2(moodToday: mood)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        title: const Text('Mood Check'),
      ),
      body: Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Text("How are you doing today?", style: TextStyle(fontSize: 30)),
          const SizedBox(height: 10),

          ElevatedButton(
            child: const Text("😊 Good", style: TextStyle(fontSize: 30)),
            onPressed: () => _goToSliders("Good"),
          ),
          const SizedBox(height: 10),

          ElevatedButton(
            child: const Text("🙂 Okay", style: TextStyle(fontSize: 30)),
            onPressed: () => _goToSliders("Okay"),
          ),
          const SizedBox(height: 10),

          ElevatedButton(
            child: const Text("😐 Neutral", style: TextStyle(fontSize: 30)),
            onPressed: () => _goToSliders("Neutral"),
          ),
          const SizedBox(height: 10),

          ElevatedButton(
            child: const Text("🙁 Not Good", style: TextStyle(fontSize: 30)),
            onPressed: () => _goToSliders("Not Good"),
          ),
          const SizedBox(height: 10),

          ElevatedButton(
            child: const Text("😢 Difficult", style: TextStyle(fontSize: 30)),
            onPressed: () => _goToSliders("Difficult"),
          ),

          const SizedBox(height: 50),

          ElevatedButton(
            child: const Text("Mood Check history", style: TextStyle(fontSize: 26)),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const MoodCheck4()),
              );
            },
          ),
        ]),
      ),
    );
  }
}