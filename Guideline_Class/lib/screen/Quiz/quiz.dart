import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  _QuizScreenState createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int _currentQuestionIndex = 0;
  final List<Map<String, Object>> _questions = [
    {
      'question': 'What is the capital of France?',
      'answers': ['Paris', 'London', 'Rome', 'Berlin'],
    },
    {
      'question': 'What is 2 + 2?',
      'answers': ['3', '4', '5', '6'],
    },
    {
      'question': 'Who wrote "To Kill a Mockingbird"?',
      'answers': [
        'Harper Lee',
        'J.K. Rowling',
        'Ernest Hemingway',
        'Mark Twain'
      ],
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Quiz', style: GoogleFonts.poppins()),
        backgroundColor: const Color.fromARGB(255, 0, 0, 0),
      ),
      body: Center(
        child: Container(
          child: const Text(
            "Feature will be Availbe Soon",
            style: TextStyle(fontSize: 29, fontStyle: FontStyle.normal),
          ),
        ),
      ),
      // body: Padding(
      //   padding: const EdgeInsets.all(16.0),
      //   child: Column(
      //     crossAxisAlignment: CrossAxisAlignment.start,
      //     children: [
      //       Text(
      //         'Question ${_currentQuestionIndex + 1}/${_questions.length}',
      //         style: GoogleFonts.poppins(
      //           textStyle: TextStyle(
      //             fontSize: 22,
      //             fontWeight: FontWeight.bold,
      //           ),
      //         ),
      //       ),
      //       const SizedBox(height: 10),
      //       Text(
      //         _questions[_currentQuestionIndex]['question'] as String,
      //         style: GoogleFonts.poppins(
      //           textStyle: TextStyle(
      //             fontSize: 20,
      //           ),
      //         ),
      //       ),
      //       const SizedBox(height: 20),
      //       ...(_questions[_currentQuestionIndex]['answers'] as List<String>)
      //           .map((answer) {
      //         return Padding(
      //           padding: const EdgeInsets.symmetric(vertical: 5),
      //           child: ElevatedButton(
      //             onPressed: () {
      //               setState(() {
      //                 if (_currentQuestionIndex < _questions.length - 1) {
      //                   _currentQuestionIndex++;
      //                 } else {
      //                   _showQuizCompletedDialog();
      //                 }
      //               });
      //             },
      //             child: Text(answer, style: GoogleFonts.poppins()),
      //           ),
      //         );
      //       }).toList(),
      //     ],
      //   ),
      // ),
    );
  }

  void _showQuizCompletedDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Quiz Completed', style: GoogleFonts.poppins()),
        content:
            Text('You have completed the quiz!', style: GoogleFonts.poppins()),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _currentQuestionIndex = 0;
              });
              Navigator.of(ctx).pop();
            },
            child: Text('Restart', style: GoogleFonts.poppins()),
          ),
        ],
      ),
    );
  }
}
