import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:micapp/pages/bar_char.dart';
import 'package:micapp/pages/bubble_chart.dart';
import 'package:dart_sentiment/dart_sentiment.dart';

class WordFrequencyScreen extends StatelessWidget {
  final Map<String, int> wordFrequencies;

  WordFrequencyScreen({required this.wordFrequencies});

  Future<void> uploadDataToCloud(Map<String, int> wordSentiments) async {
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      CollectionReference wordCollection =
          firestore.collection('wordfrequencies');

      // Iterate through the wordFrequencies map and add each word as a document
      for (var entry in wordFrequencies.entries) {
        final word = entry.key;
        final frequency = entry.value;
        final sentiment = wordSentiments[word] ?? 0;

        await wordCollection.doc(word).set({
          'frequency': frequency,
          'sentiment': sentiment,
        });
      }

      // Display a success message
      print('Data uploaded successfully!');
    } catch (e) {
      // Handle errors here
      print('Failed to upload data: $e');
    }
  }

  Map<String, int> performSentimentAnalysis() {
    final sentiment = Sentiment();
    Map<String, int> wordSentiments = {};

    // Analyze sentiment for each word
    wordFrequencies.forEach((word, frequency) {
      var analysis = sentiment.analysis(word);
      int score = analysis['score'];

      wordSentiments[word] = score;
    });

    return wordSentiments;
  }

  @override
  Widget build(BuildContext context) {
    Map<String, int> wordSentiments = performSentimentAnalysis();

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
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
                        final word = entry.key;
                        final frequency = entry.value;
                        final sentimentScore = wordSentiments[word] ?? 0;

                        return Card(
                          color: Colors.grey[900],
                          child: ListTile(
                            title: Text(
                              word,
                              style: TextStyle(
                                color: Colors.amber,
                                fontSize: 18,
                              ),
                            ),
                            subtitle: Text(
                              'Sentiment: $sentimentScore',
                              style: TextStyle(
                                color: sentimentScore > 0
                                    ? Colors.greenAccent
                                    : sentimentScore < 0
                                        ? Colors.redAccent
                                        : Colors.white,
                                fontSize: 16,
                              ),
                            ),
                            trailing: Text(
                              'Frequency: $frequency',
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
                  onPressed: () async {
                    await uploadDataToCloud(wordSentiments);
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
