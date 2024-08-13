import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class TopWordsBarChart extends StatelessWidget {
  final Map<String, int> wordFrequencies;
  final int topN;

  TopWordsBarChart({
    required this.wordFrequencies,
    this.topN = 10, // Default to top 10 words
  });

  @override
  Widget build(BuildContext context) {
    // Sort and get top N most frequent words
    final sortedEntries = wordFrequencies.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final topEntries = sortedEntries.take(topN).toList();

    // Prepare data for the bar chart
    final bars = topEntries.map((entry) {
      return BarChartGroupData(
        x: topEntries.indexOf(entry),
        barRods: [
          BarChartRodData(
            toY: entry.value.toDouble(),
            color: Colors.amber,
            width: 20, // Width of each bar
          ),
        ],
      );
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Top $topN Most Frequent Words',
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
        child: BarChart(
          BarChartData(
            borderData: FlBorderData(
              show: true,
              border: Border.all(
                color: const Color(0xff37434d),
                width: 1,
              ),
            ),
            gridData: FlGridData(show: true),
            barGroups: bars,
          ),
        ),
      ),
      backgroundColor: Colors.black,
    );
  }
}
