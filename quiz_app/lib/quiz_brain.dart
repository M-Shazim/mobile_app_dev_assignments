class Quiz {
  String questionText;
  bool answer;
  Quiz({required this.questionText, required this.answer});
}

class QuizBrain {
  int _questionIndex = 0;
  List<Quiz> _questionBank = [
    Quiz(questionText: 'Flutter is a framework?', answer: true),
    Quiz(questionText: 'Flutter uses Dart language?', answer: true),
    Quiz(questionText: "Is Dart a statically typed programming language?", answer: true),
    Quiz(questionText: "Is var in Dart used to declare a constant variable?", answer: false),
    Quiz(questionText: "Can Flutter apps be written using JavaScript?", answer: false),
    Quiz(questionText: "Is the Scaffold widget used to structure the basic visual layout of a Flutter app?", answer: true),
    Quiz(questionText: "Is Flutter only for mobile app development?", answer: false),
    Quiz(questionText: "Is the ListView widget used for displaying a single item in Flutter?", answer: false),
    Quiz(questionText: "Does Flutter support hot reload for faster development?", answer: true),
    Quiz(questionText: "Is the setState() method used in Flutter to rebuild the UI?", answer: true),


    // Add 8 more questions here
  ];
  String getQuestion() {
    return _questionBank[_questionIndex].questionText;
  }
  bool getAnswer() {
    return _questionBank[_questionIndex].answer;
  }
  void nextQuestion() {
    if (_questionIndex < _questionBank.length - 1) {
      _questionIndex++;
    }
  }
  bool isFinished() {
    return _questionIndex >= _questionBank.length - 1;
  }
  void reset() {
    _questionIndex = 0;
  }
}
