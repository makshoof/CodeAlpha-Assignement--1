import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

void main() {
  runApp(StudyFlashcardApp());
}

class StudyFlashcardApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Study Flashcard Quiz',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
      ),
      home: FlashcardHome(),
    );
  }
}

class FlashcardHome extends StatefulWidget {
  @override
  _FlashcardHomeState createState() => _FlashcardHomeState();
}

class _FlashcardHomeState extends State<FlashcardHome> {
  List<Map<String, String>> _flashcards = [];
  int _score = 0;

  @override
  void initState() {
    super.initState();
    _loadFlashcards();
  }

  Future<void> _loadFlashcards() async {
    final prefs = await SharedPreferences.getInstance();
    final storedFlashcards = prefs.getString('flashcards');
    if (storedFlashcards != null) {
      setState(() {
        _flashcards =
            List<Map<String, String>>.from(json.decode(storedFlashcards));
      });
    }
  }

  Future<void> _saveFlashcards() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('flashcards', json.encode(_flashcards));
  }

  void _addFlashcard(String question, String answer, String category) {
    setState(() {
      _flashcards
          .add({'question': question, 'answer': answer, 'category': category});
    });
    _saveFlashcards();
  }

  void _startQuiz() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => QuizScreen(
          flashcards: _flashcards,
          onQuizComplete: (score) {
            setState(() {
              _score = score;
            });
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Gradient Background
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blueAccent, Colors.lightBlue.shade100],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header
                  Text(
                    'Study Flashcards',
                    style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                  Text(
                    'Master your study material with ease!',
                    style: TextStyle(fontSize: 18, color: Colors.white70),
                  ),
                  SizedBox(height: 20),
                  // Flashcards
                  Expanded(
                    child: _flashcards.isEmpty
                        ? Center(
                            child: Text(
                              'No Flashcards Available',
                              style: TextStyle(
                                  fontSize: 18, color: Colors.white70),
                            ),
                          )
                        : ListView.builder(
                            itemCount: _flashcards.length,
                            itemBuilder: (context, index) {
                              final flashcard = _flashcards[index];
                              return Card(
                                elevation: 4,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: ListTile(
                                  title: Text(flashcard['question']!),
                                  subtitle: Text(
                                      'Category: ${flashcard['category']}'),
                                  trailing: Icon(Icons.flash_on,
                                      color: Colors.blueAccent),
                                ),
                              );
                            },
                          ),
                  ),
                  // Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                              vertical: 16, horizontal: 24),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => AddFlashcardScreen(
                                onAddFlashcard: _addFlashcard),
                          ),
                        ),
                        child: Text('Add Flashcard'),
                      ),
                      if (_flashcards.isNotEmpty)
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(
                                vertical: 16, horizontal: 24),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          onPressed: _startQuiz,
                          child: Text('Start Quiz'),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AddFlashcardScreen extends StatelessWidget {
  final Function(String, String, String) onAddFlashcard;
  final _questionController = TextEditingController();
  final _answerController = TextEditingController();
  final _categoryController = TextEditingController();

  AddFlashcardScreen({required this.onAddFlashcard});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('Add Flashcard')),
        body: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blueAccent, Colors.lightBlue.shade100],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                children: [
                  TextField(
                    controller: _questionController,
                    decoration: InputDecoration(
                        labelText: 'Question', border: OutlineInputBorder()),
                  ),
                  SizedBox(height: 12),
                  TextField(
                    controller: _answerController,
                    decoration: InputDecoration(
                        labelText: 'Answer', border: OutlineInputBorder()),
                  ),
                  SizedBox(height: 12),
                  TextField(
                    controller: _categoryController,
                    decoration: InputDecoration(
                        labelText: 'Category', border: OutlineInputBorder()),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      if (_questionController.text.isNotEmpty &&
                          _answerController.text.isNotEmpty &&
                          _categoryController.text.isNotEmpty) {
                        onAddFlashcard(
                          _questionController.text,
                          _answerController.text,
                          _categoryController.text,
                        );
                        Navigator.of(context).pop();
                      }
                    },
                    child: Text('Add Flashcard'),
                  ),
                ],
              ),
            ),
          ],
        ));
  }
}

class QuizScreen extends StatefulWidget {
  final List<Map<String, String>> flashcards;
  final Function(int) onQuizComplete;

  QuizScreen({required this.flashcards, required this.onQuizComplete});

  @override
  _QuizScreenState createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int _currentIndex = 0;
  int _score = 0;
  final _answerController = TextEditingController();

  void _submitAnswer() {
    if (_answerController.text.trim().toLowerCase() ==
        widget.flashcards[_currentIndex]['answer']!.trim().toLowerCase()) {
      _score++;
    }
    if (_currentIndex + 1 < widget.flashcards.length) {
      setState(() {
        _currentIndex++;
        _answerController.clear();
      });
    } else {
      widget.onQuizComplete(_score);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('Quiz')),
        body: Stack(children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blueAccent, Colors.lightBlue.shade100],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: [
                LinearProgressIndicator(
                    value: (_currentIndex + 1) / widget.flashcards.length),
                SizedBox(height: 20),
                Text(
                  'Question ${_currentIndex + 1}: ${widget.flashcards[_currentIndex]['question']}',
                  style: TextStyle(fontSize: 20),
                ),
                SizedBox(height: 20),
                TextField(
                  controller: _answerController,
                  decoration: InputDecoration(
                      labelText: 'Your Answer', border: OutlineInputBorder()),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _submitAnswer,
                  child: Text('Submit'),
                ),
              ],
            ),
          ),
        ]));
  }
}
