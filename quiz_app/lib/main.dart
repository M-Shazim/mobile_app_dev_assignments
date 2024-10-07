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
    setState(() {
      isQuizStarted = true;
      resetTimer();
    });
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

  void showResult() {
    countdownTimer?.cancel();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.grey.shade200,
          title: Text(
            "Quiz Completed!",
            style: TextStyle(color: Colors.teal.shade700, fontWeight: FontWeight.bold),
          ),
          content: Text(
            "Your score is $score/10",
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
          child: isQuizStarted
              ? Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              // Progress Bar
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

              // Question Section inside Card
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
                          backgroundColor: Colors.teal.shade600,
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
                          backgroundColor: Colors.redAccent,
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
                mainAxisAlignment: MainAxisAlignment.center,
                children: scoreKeeper,
              ),
            ],
          )
              : Center(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(
                    vertical: 16.0, horizontal: 48.0),
                backgroundColor: Colors.teal.shade400,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
              ),
              onPressed: startQuiz,
              child: Text(
                'Start Quiz',
                style: TextStyle(fontSize: 24.0, color: Colors.white),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    countdownTimer?.cancel();
    super.dispose();
  }
}
