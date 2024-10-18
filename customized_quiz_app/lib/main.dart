import 'package:flutter/material.dart';
import 'dart:async';
import 'quiz_brain.dart';

QuizBrain quizBrain = QuizBrain();

void main() => runApp(QuizApp());

class QuizApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.teal,
        fontFamily: 'Roboto',
      ),
      home: QuizPage(),
    );
  }
}

class QuizPage extends StatefulWidget {
  @override
  _QuizPageState createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  List<Icon> scoreKeeper = [];
  int score = 0;
  bool isQuizStarted = false;
  int timer = 10;
  Timer? countdownTimer;
  bool useCustomQuestions = false; // Whether user wants custom questions

  String newQuestionText = '';
  bool newQuestionAnswer = true; // Default answer is true (True/False selection)

  @override
  void initState() {
    super.initState();
  }

  void checkAnswer(bool userPickedAnswer) {
    bool correctAnswer = quizBrain.getAnswer();
    setState(() {
      countdownTimer?.cancel();
      if (correctAnswer == userPickedAnswer) {
        scoreKeeper.add(Icon(Icons.check, color: Colors.teal));
        score++;
      } else {
        scoreKeeper.add(Icon(Icons.close, color: Colors.redAccent));
      }
      if (quizBrain.isFinished()) {
        showResult();
      } else {
        quizBrain.nextQuestion();
        resetTimer();
      }
    });
  }

  void startQuiz() {
    if (useCustomQuestions && quizBrain.customQuestions.isEmpty) {
      // Show a message if no custom questions are added
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("No Custom Questions Added"),
            content: Text("Please add custom questions to start the quiz."),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text("Okay"),
              ),
            ],
          );
        },
      );
    } else {
      setState(() {
        isQuizStarted = true;
        quizBrain.useCustomQuestions(useCustomQuestions); // Ensure QuizBrain uses the correct question bank
        resetTimer();
      });
    }
  }


  void resetTimer() {
    setState(() {
      timer = 10;
    });
    countdownTimer?.cancel();
    countdownTimer = Timer.periodic(Duration(seconds: 1), (Timer t) {
      setState(() {
        if (timer > 0) {
          timer--;
        } else {
          countdownTimer?.cancel();
          checkAnswer(false);
        }
      });
    });
  }

  void addQuestion() {
    if (newQuestionText.isNotEmpty) {
      setState(() {
        quizBrain.addQuestion(newQuestionText, newQuestionAnswer);
      });
      // Clear input fields after adding the question
      newQuestionText = '';
      newQuestionAnswer = true;
    }
  }

  void showResult() {
    countdownTimer?.cancel();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.grey.shade200,
          title: Text(
            "Quiz Completed!",
            style: TextStyle(
                color: Colors.teal.shade700, fontWeight: FontWeight.bold),
          ),
          content: Text(
            "Your score is $score/${quizBrain.totalQuestions()}",
            style: TextStyle(color: Colors.black87),
          ),
          actions: [
            TextButton(
              child: Text("Restart", style: TextStyle(color: Colors.teal)),
              onPressed: () {
                setState(() {
                  quizBrain.reset();
                  scoreKeeper.clear();
                  score = 0;
                  timer = 10;
                  isQuizStarted = false;
                  Navigator.of(context).pop();
                });
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Quiz App'),
        actions: [
          // Show add question button only if custom questions are selected
          if (useCustomQuestions)
            IconButton(
              icon: Icon(Icons.add),
              onPressed: () {
                // Open the add question form dialog
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: Text('Add New Question'),
                      content: StatefulBuilder(
                        builder: (context, setState) {
                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              TextField(
                                onChanged: (value) {
                                  newQuestionText = value;
                                },
                                decoration: InputDecoration(
                                  labelText: 'Question',
                                ),
                              ),
                              SizedBox(height: 10),
                              // Radio button options for True/False
                              Column(
                                children: [
                                  ListTile(
                                    title: const Text('True'),
                                    leading: Radio<bool>(
                                      value: true,
                                      groupValue: newQuestionAnswer,
                                      onChanged: (bool? value) {
                                        setState(() {
                                          newQuestionAnswer = value!;
                                        });
                                      },
                                    ),
                                  ),
                                  ListTile(
                                    title: const Text('False'),
                                    leading: Radio<bool>(
                                      value: false,
                                      groupValue: newQuestionAnswer,
                                      onChanged: (bool? value) {
                                        setState(() {
                                          newQuestionAnswer = value!;
                                        });
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          );
                        },
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            addQuestion();
                            Navigator.of(context).pop();
                          },
                          child: Text('Add'),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.teal.shade100, Colors.teal.shade300],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Use Custom Questions",
                    style: TextStyle(fontSize: 18.0),
                  ),
                  Switch(
                    value: useCustomQuestions,
                    onChanged: (value) {
                      setState(() {
                        useCustomQuestions = value;
                      });
                    },
                  ),
                ],
              ),
              if (!isQuizStarted) // Show the start button when quiz hasn't started
                Center(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal.shade600,
                      padding: EdgeInsets.symmetric(
                          horizontal: 32.0, vertical: 16.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25.0),
                      ),
                    ),
                    child: Text(
                      'Start Quiz',
                      style: TextStyle(fontSize: 24.0, color: Colors.white),
                    ),
                    onPressed: startQuiz,
                  ),
                )
              else // When quiz is started, show questions and answers
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Container(
                      height: 8.0,
                      child: LinearProgressIndicator(
                        value: timer / 10, // Calculate progress based on remaining time
                        backgroundColor: Colors.teal.shade200,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.teal),
                      ),
                    ),
                    SizedBox(height: 10.0),
                    Text(
                      'Time Left: $timer seconds',
                      style: TextStyle(fontSize: 20.0, color: Colors.black87),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 20.0),
                    Card(
                      elevation: 8,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      color: Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Center(
                          child: Text(
                            quizBrain.getQuestion(),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 24.0,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20.0),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                padding: EdgeInsets.all(16.0),
                                backgroundColor: Colors.greenAccent.shade400,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25.0),
                                ),
                              ),
                              child: Text('True',
                                  style: TextStyle(
                                      fontSize: 20.0, color: Colors.white)),
                              onPressed: () {
                                checkAnswer(true);
                              },
                            ),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                padding: EdgeInsets.all(16.0),
                                backgroundColor: Colors.redAccent.shade400,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25.0),
                                ),
                              ),
                              child: Text('False',
                                  style: TextStyle(
                                      fontSize: 20.0, color: Colors.white)),
                              onPressed: () {
                                checkAnswer(false);
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20.0),
                    Row(
                      children: scoreKeeper,
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
