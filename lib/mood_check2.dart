import 'package:flutter/material.dart';
import 'package:swiftspeak/mood_check3.dart';

class MoodCheck2 extends StatefulWidget {
  const MoodCheck2({super.key, required this.moodToday});

  final String moodToday;

  @override
  State<MoodCheck2> createState() => _MoodCheck2State();
}

class _MoodCheck2State extends State<MoodCheck2> {
  double _currentEnergyValue = 2.5;
  double _currentStressValue = 2.5;
  double _currentHopefulnessValue = 2.5;
  double _currentConfidenceValue = 2.5;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        title: const Text('Mood Check'),
      ),
      body: Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Text("Stress Level", style: TextStyle(fontSize: 30)),
          Slider(
            value: _currentStressValue,
            min: 0,
            max: 5,
            divisions: 10,
            label: _currentStressValue.round().toString(),
            onChanged: (double value) {
              setState(() {
                _currentStressValue = value;
              });
            },
          ),

          const Text("Energy Level", style: TextStyle(fontSize: 30)),
          Slider(
            value: _currentEnergyValue,
            min: 0,
            max: 5,
            divisions: 10,
            label: _currentEnergyValue.round().toString(),
            onChanged: (double value) {
              setState(() {
                _currentEnergyValue = value;
              });
            },
          ),

          const Text("Hopefulness", style: TextStyle(fontSize: 30)),
          Slider(
            value: _currentHopefulnessValue,
            min: 0,
            max: 5,
            divisions: 10,
            label: _currentHopefulnessValue.round().toString(),
            onChanged: (double value) {
              setState(() {
                _currentHopefulnessValue = value;
              });
            },
          ),

          const Text("Confidence in Recovery", style: TextStyle(fontSize: 30)),
          Slider(
            value: _currentConfidenceValue,
            min: 0,
            max: 5,
            divisions: 10,
            label: _currentConfidenceValue.round().toString(),
            onChanged: (double value) {
              setState(() {
                _currentConfidenceValue = value;
              });
            },
          ),

          const SizedBox(height: 30),

          ElevatedButton(
            child: const Text("Next page", style: TextStyle(fontSize: 26)),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => MoodCheck3(
                    moodToday: widget.moodToday,
                    stress: _currentStressValue,
                    energy: _currentEnergyValue,
                    hopefulness: _currentHopefulnessValue,
                    confidence: _currentConfidenceValue,
                  ),
                ),
              );
            },
          ),
        ]),
      ),
    );
  }
}