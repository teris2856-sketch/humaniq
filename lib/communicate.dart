import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

class Communicate extends StatefulWidget {
  const Communicate({super.key});

  @override
  State<Communicate> createState() => _CommunicateState();
}

class _CommunicateState extends State<Communicate> {
  final FlutterTts _flutterTts = FlutterTts();

  @override
  void initState() {
    super.initState();
    _flutterTts.setLanguage("en-US");
    _flutterTts.setSpeechRate(0.45);
    _flutterTts.setPitch(1.0);
  }

  @override
  void dispose() {
    _flutterTts.stop();
    super.dispose();
  }

  Future<void> _speak(String text) async {
    await _flutterTts.speak(text);
  }

  Widget buildTile({
    required Widget icon,
    required String text,
    VoidCallback? onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      elevation: 4,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        splashColor: Colors.blue.withOpacity(0.2),
        onTap: () {
          _speak(text);
          if (onTap != null) onTap();
        },
        child: SizedBox(
          height: 140,
          width: 140,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                icon,
                const SizedBox(height: 10),
                Text(
                  text,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget emergencyButton() {
    return GestureDetector(
      onTap: () => _speak("I need emergency help right now"),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 6,
              offset: Offset(0, 3),
            )
          ],
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.warning, color: Colors.white, size: 30),
            SizedBox(width: 10),
            Text(
              "Emergency Help",
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildRow(List<Widget> tiles) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: tiles
            .map((tile) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: tile,
        ))
            .toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F7),
      appBar: AppBar(
        title: const Text("Communicate"),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            /// EMERGENCY BUTTON
            emergencyButton(),

            const SizedBox(height: 10),

            /// FREQUENTLY USED
            sectionTitle("Frequently Used"),

            buildRow([
              buildTile(
                icon: const Icon(Icons.help, size: 55, color: Colors.amber),
                text: "I need help",
              ),
              buildTile(
                icon: const Icon(Icons.medication, size: 55, color: Colors.red),
                text: "I need medication",
              ),
            ]),

            /// COMMON NEEDS
            sectionTitle("Common Needs"),

            buildRow([
              buildTile(
                icon: const Icon(Icons.restaurant, size: 55, color: Colors.orange),
                text: "I'm hungry",
              ),
              buildTile(
                icon: const Icon(Icons.water_drop, size: 55, color: Colors.blue),
                text: "I'm thirsty",
              ),
            ]),

            buildRow([
              buildTile(
                icon: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.man_2, size: 45, color: Colors.blue),
                    SizedBox(width: 6),
                    Icon(Icons.woman_2, size: 45, color: Colors.pink),
                  ],
                ),
                text: "I need the bathroom",
              ),
              buildTile(
                icon: const Icon(Icons.self_improvement,
                    size: 55, color: Colors.green),
                text: "I need therapy",
              ),
            ]),

            /// TEMPERATURE
            sectionTitle("Temperature"),

            buildRow([
              buildTile(
                icon: const Icon(Icons.ac_unit, size: 55, color: Colors.lightBlue),
                text: "I'm cold",
              ),
              buildTile(
                icon: const Icon(Icons.wb_sunny, size: 55, color: Colors.orange),
                text: "I'm hot",
              ),
            ]),
          ],
        ),
      ),
    );
  }
}