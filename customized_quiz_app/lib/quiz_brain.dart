class Question {
  String questionText;
  bool questionAnswer;

  Question(this.questionText, this.questionAnswer);
}

class QuizBrain {
  int _questionNumber = 0;
  bool _useCustomQuestions = false;

  // Default questions list
  List<Question> _defaultQuestionBank = [
    Question('Some cats are allergic to humans', true),
    Question('You can lead a cow downstairs but not upstairs.', false),
    Question('Approximately one quarter of human bones are in the feet.', true),
    Question('A slug\'s blood is green.', true),
    Question('Buzz Aldrin\'s mother\'s maiden name was "Moon".', true),
  ];

  // Custom questions list (initially empty)
  List<Question> customQuestions = [];

  List<Question> get _currentQuestionBank =>
      _useCustomQuestions ? customQuestions : _defaultQuestionBank;

  void useCustomQuestions(bool useCustom) {
    _useCustomQuestions = useCustom;
    reset();  // Reset the quiz to start with the first question in the selected bank
  }

  void addQuestion(String questionText, bool questionAnswer) {
    customQuestions.add(Question(questionText, questionAnswer));
  }

  String getQuestion() {
    if (_currentQuestionBank.isEmpty) {
      return 'No questions available.';
    }
    return _currentQuestionBank[_questionNumber].questionText;
  }

  bool getAnswer() {
    return _currentQuestionBank[_questionNumber].questionAnswer;
  }

  void nextQuestion() {
    if (_questionNumber < _currentQuestionBank.length - 1) {
      _questionNumber++;
    }
  }

  bool isFinished() {
    return _questionNumber >= _currentQuestionBank.length - 1;
  }

  void reset() {
    _questionNumber = 0;
  }

  int totalQuestions() {
    return _currentQuestionBank.length;
  }
}
