import 'package:flutter/material.dart';
import 'package:bubble_chart/bubble_chart.dart';

class BubbleChartScreen extends StatelessWidget {
  final Map<String, int> wordFrequencies;

  BubbleChartScreen({required this.wordFrequencies});

  @override
  Widget build(BuildContext context) {
    // Create BubbleNode with child nodes for each word frequency
    List<BubbleNode> nodes = wordFrequencies.entries
        .map((entry) => BubbleNode.leaf(
              options: BubbleOptions(
                color: Colors.amber,
                child: Text(
                  entry.key,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              value: entry.value.toDouble(),
            ))
        .toList();

    // Create a root BubbleNode to contain all the nodes
    BubbleNode rootNode = BubbleNode.node(
      padding: 15,
      children: nodes,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Bubble Chart',
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
        child: BubbleChartLayout(
          children: [],
        ),
      ),
      backgroundColor: Colors.black,
    );
  }
}
