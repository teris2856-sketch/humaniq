import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'mood_details1.dart';
import 'home_page.dart';

const List<String> months = <String>[
  'All', 'January', 'February', 'March', 'April', 'May', 'June',
  'July', 'August', 'September', 'October', 'November', 'December'
];
const List<String> years = <String>['All', '2026', '2025', '2024', '2023', '2022', '2021'];

class MoodCheck4 extends StatefulWidget {
  const MoodCheck4({super.key});

  @override
  State<MoodCheck4> createState() => _MoodCheck4State();
}

class _MoodCheck4State extends State<MoodCheck4> {
  String selectedMonth = 'All';
  String selectedYear = 'All';

  String _monthName(int month) => months[month];

  bool _matchesFilters(DateTime dt) {
    final monthOk = selectedMonth == 'All' || _monthName(dt.month) == selectedMonth;
    final yearOk = selectedYear == 'All' || dt.year.toString() == selectedYear;
    return monthOk && yearOk;
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Mood Check History"),
          backgroundColor: Colors.lightBlue[300],
          centerTitle: true,
        ),
        body: const Center(
          child: Text("Please log in first.", style: TextStyle(fontSize: 22)),
        ),
      );
    }

    final query = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('mood_checks')
        .orderBy('createdAt', descending: true);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Mood Check History"),
        backgroundColor: Colors.lightBlue[300],
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: selectedMonth,
                      decoration: InputDecoration(
                        labelText: "Month",
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        filled: true,
                        fillColor: Colors.lightBlue[50],
                      ),
                      items: months.map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
                      onChanged: (value) => setState(() => selectedMonth = value!),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: selectedYear,
                      decoration: InputDecoration(
                        labelText: "Year",
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        filled: true,
                        fillColor: Colors.lightBlue[50],
                      ),
                      items: years.map((y) => DropdownMenuItem(value: y, child: Text(y))).toList(),
                      onChanged: (value) => setState(() => selectedYear = value!),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              Expanded(
                child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: query.snapshots(),
                  builder: (context, snap) {
                    if (snap.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snap.hasError) {
                      return Center(child: Text("Error: ${snap.error}", style: const TextStyle(fontSize: 18)));
                    }

                    final docs = snap.data?.docs ?? [];

                    // Filter by month/year (client-side)
                    final filtered = docs.where((d) {
                      final ts = d.data()['createdAt'];
                      if (ts is Timestamp) {
                        return _matchesFilters(ts.toDate());
                      }
                      // if serverTimestamp hasn’t resolved yet, show it anyway
                      return true;
                    }).toList();

                    if (filtered.isEmpty) {
                      return Center(
                        child: Text("No results found", style: TextStyle(fontSize: 24, color: Colors.grey[700])),
                      );
                    }

                    return ListView.builder(
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final doc = filtered[index];
                        final data = doc.data();
                        final ts = data['createdAt'];
                        DateTime? dt;
                        if (ts is Timestamp) dt = ts.toDate();

                        final titleDate = dt == null
                            ? "Just now"
                            : "${dt.month}/${dt.day}/${dt.year}";

                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => MoodDetails1(entryId: doc.id),
                                ),
                              );
                            },
                            child: Container(
                              height: 70,
                              decoration: BoxDecoration(
                                color: Colors.lightBlue[100],
                                borderRadius: BorderRadius.circular(25),
                                border: Border.all(width: 2),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.black26,
                                    offset: Offset(2, 2),
                                    blurRadius: 5,
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Text(
                                  titleDate,
                                  style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue[900],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),

              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.home),
                  label: const Text("Back to Home", style: TextStyle(fontSize: 24)),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    backgroundColor: Colors.lightBlue[400],
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(builder: (context) => HomePage()));
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}