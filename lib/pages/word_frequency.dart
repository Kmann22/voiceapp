import 'package:flutter/material.dart';
import 'package:micapp/pages/bar_char.dart';
import 'package:micapp/pages/bubble_chart.dart'; // Ensure this import matches the file path

class WordFrequencyScreen extends StatelessWidget {
  final Map<String, int> wordFrequencies;

  WordFrequencyScreen({required this.wordFrequencies});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Word Frequency',
          style: TextStyle(
            color: Colors.amber,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.black,
        iconTheme: IconThemeData(color: Colors.amber),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: wordFrequencies.isEmpty
                  ? Center(
                      child: Text(
                        'No words recorded yet.',
                        style: TextStyle(
                          color: Colors.amber,
                          fontSize: 18,
                        ),
                      ),
                    )
                  : ListView.builder(
                      itemCount: wordFrequencies.length,
                      itemBuilder: (context, index) {
                        final entry = wordFrequencies.entries.elementAt(index);
                        return Card(
                          color: Colors.grey[900],
                          child: ListTile(
                            title: Text(
                              entry.key,
                              style: TextStyle(
                                color: Colors.amber,
                                fontSize: 18,
                              ),
                            ),
                            trailing: Text(
                              entry.value.toString(),
                              style: TextStyle(
                                color: Colors.amberAccent,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            TopWordsBarChart(wordFrequencies: wordFrequencies),
                      ),
                    );
                  },
                  child: Text('Bar Graph'),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.black,
                    backgroundColor: Colors.amber,
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    textStyle:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            BubbleChartScreen(wordFrequencies: wordFrequencies),
                      ),
                    );
                  },
                  child: Text('Bubble Graph'),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.black,
                    backgroundColor: Colors.amber,
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    textStyle:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    // Implement the cloud upload functionality here
                  },
                  child: Text('Upload on Cloud'),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.black,
                    backgroundColor: Colors.amber,
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    textStyle:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      backgroundColor: Colors.black,
    );
  }
}
