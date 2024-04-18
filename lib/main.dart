import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sentiment Analysis Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: SentimentAnalysisScreen(),
    );
  }
}

class SentimentAnalysisScreen extends StatefulWidget {
  @override
  _SentimentAnalysisScreenState createState() =>
      _SentimentAnalysisScreenState();
}

class _SentimentAnalysisScreenState extends State<SentimentAnalysisScreen> {
  final TextEditingController _textInputController = TextEditingController();
  String _outputText = '';

  Future<void> _submitInput() async {
  final String inputText = _textInputController.text;
  final String apiUrl =
      "https://api-inference.huggingface.co/models/cardiffnlp/twitter-roberta-base-sentiment";
  final Map<String, String> headers = {
    "Authorization": "Bearer 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",
    "Content-Type": "application/json",
  };

  final Map<String, String> payload = {"inputs": inputText};

  final http.Response response =
      await http.post(Uri.parse(apiUrl), headers: headers, body: jsonEncode(payload));

  print(response.body); // Print the response body to understand its structure

  if (response.statusCode == 200) {
    final List<dynamic> responseData = jsonDecode(response.body);
    if (responseData.isNotEmpty) {
      final List<dynamic> sentimentData = responseData[0];

      final Map<String, dynamic> sentiments = {
        'Positive': sentimentData.firstWhere((sentiment) => sentiment['label'] == 'LABEL_2', orElse: () => null),
        'Neutral': sentimentData.firstWhere((sentiment) => sentiment['label'] == 'LABEL_1', orElse: () => null),
        'Negative': sentimentData.firstWhere((sentiment) => sentiment['label'] == 'LABEL_0', orElse: () => null),
      };

      setState(() {
        _outputText = '';
        sentiments.forEach((key, value) {
          if (value != null) {
            _outputText += '$key Sentiment: Score: ${value['score'].toStringAsFixed(4)}\n';
          } else {
            _outputText += '$key Sentiment: Not Detected\n';
          }
        });
      });
    } else {
      setState(() {
        _outputText = 'No sentiment detected';
      });
    }
  } else {
    setState(() {
      _outputText = 'Error: ${response.statusCode}';
    });
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sentiment Analysis'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _textInputController,
              decoration: InputDecoration(
                labelText: 'Enter your text',
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submitInput,
              child: Text('Analyze Sentiment'),
            ),
            SizedBox(height: 20),
            Text(
              'Output: $_outputText',
              style: TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}
