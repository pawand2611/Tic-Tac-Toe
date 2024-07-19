import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(TicTacToeApp());
}

class TicTacToeApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Tic Tac Toe',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: TicTacToeScreen(),
    );
  }
}

class TicTacToeScreen extends StatefulWidget {
  @override
  _TicTacToeScreenState createState() => _TicTacToeScreenState();
}

class _TicTacToeScreenState extends State<TicTacToeScreen> {
  DatabaseReference _gameRef = FirebaseDatabase.instance.ref('tic_tac_toe_game');
  List<List<String>> _board = List.generate(3, (_) => List.filled(3, ''));
  String _currentPlayer = 'X';
  bool _gameOver = false;

  @override
  void initState() {
    super.initState();
    _initializeBoard();
    _gameRef.onValue.listen((event) {
      if (event.snapshot.value != null) {
        Map data = event.snapshot.value as Map;
        setState(() {
          _board = List.generate(3, (i) => List<String>.from(data['board'][i]));
          _currentPlayer = data['currentPlayer'];
          _gameOver = data['gameOver'];
        });
      }
    });
  }

  void _resetGame() {
    _initializeBoard();
    _updateFirebase();
  }

  void _initializeBoard() {
    _board = List.generate(3, (_) => List.filled(3, ''));
    _currentPlayer = 'X';
    _gameOver = false;
  }

  void _makeMove(int row, int col) {
    if (_board[row][col] == '' && !_gameOver) {
      setState(() {
        _board[row][col] = _currentPlayer;
        _checkWin(row, col);
        _togglePlayer();
      });
      _updateFirebase();
    }
  }

  void _checkWin(int row, int col) {
    if (_board[row][0] == _currentPlayer &&
        _board[row][1] == _currentPlayer &&
        _board[row][2] == _currentPlayer ||
        _board[0][col] == _currentPlayer &&
            _board[1][col] == _currentPlayer &&
            _board[2][col] == _currentPlayer ||
        (_board[0][0] == _currentPlayer &&
            _board[1][1] == _currentPlayer &&
            _board[2][2] == _currentPlayer) ||
        (_board[0][2] == _currentPlayer &&
            _board[1][1] == _currentPlayer &&
            _board[2][0] == _currentPlayer)) {
      _endGame();
    } else if (!_board.any((row) => row.any((cell) => cell == ''))) {
      _gameOver = true;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: Text('Game Over'),
          content: Text('It\'s a draw!'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _resetGame();
              },
              child: Text('Play Again'),
            ),
          ],
        ),
      );
      _updateFirebase();
    }
  }

  void _endGame() {
    _gameOver = true;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text('Game Over'),
        content: Text('Player $_currentPlayer wins!'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _resetGame();
            },
            child: Text('Play Again'),
          ),
        ],
      ),
    );
    _updateFirebase();
  }

  void _togglePlayer() {
    _currentPlayer = (_currentPlayer == 'X') ? 'O' : 'X';
  }

  void _updateFirebase() {
    _gameRef.set({
      'board': _board,
      'currentPlayer': _currentPlayer,
      'gameOver': _gameOver,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Tic Tac Toe'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Current Player: $_currentPlayer',
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 20),
            GridView.builder(
              shrinkWrap: true,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 8.0,
                mainAxisSpacing: 8.0,
              ),
              itemCount: 9,
              itemBuilder: (context, index) {
                int row = index ~/ 3;
                int col = index % 3;
                return GestureDetector(
                  onTap: () => _makeMove(row, col),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black),
                    ),
                    child: Center(
                      child: Text(
                        _board[row][col],
                        style: TextStyle(fontSize: 40),
                      ),
                    ),
                  ),
                );
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _resetGame,
              child: Text('Reset Game'),
            ),
          ],
        ),
      ),
    );
  }
}




// import 'package:flutter/material.dart';
// import 'package:tic_tac_toe/Screens/home.dart';
//
// void main() {
//   runApp(TicTacToeApp());
// }
//
// class TicTacToeApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       title: 'Tic Tac Toe',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//       ),
//       home: HomeScreen(),
//     );
//   }
// }
//
// class TicTacToeScreen extends StatefulWidget {
//   @override
//   _TicTacToeScreenState createState() => _TicTacToeScreenState();
// }
//
// class _TicTacToeScreenState extends State<TicTacToeScreen> {
//   List<List<String>> _board = List.generate(3, (_) => List.filled(3, '')); // Initialize _board
//   String _currentPlayer = 'X'; // Initialize _currentPlayer
//   bool _gameOver = false; // Initialize _gameOver
//
//   void _resetGame() {
//     setState(() {
//       _initializeBoard();
//     });
//   }
//
//   void _initializeBoard() {
//     _board = List.generate(3, (_) => List.filled(3, ''));
//     _currentPlayer = 'X';
//     _gameOver = false;
//   }
//
//   void _makeMove(int row, int col) {
//     if (_board[row][col] == '' && !_gameOver) {
//       setState(() {
//         _board[row][col] = _currentPlayer;
//         _checkWin(row, col);
//         _togglePlayer();
//       });
//     }
//   }
//
//   void _checkWin(int row, int col) {
//     // Check rows
//     if (_board[row][0] == _currentPlayer &&
//         _board[row][1] == _currentPlayer &&
//         _board[row][2] == _currentPlayer) {
//       _endGame();
//     }
//     // Check columns
//     else if (_board[0][col] == _currentPlayer &&
//         _board[1][col] == _currentPlayer &&
//         _board[2][col] == _currentPlayer) {
//       _endGame();
//     }
//     // Check diagonals
//     else if ((row == col ||
//         (row + col) == _board.length - 1) &&
//         ((_board[0][0] == _currentPlayer &&
//             _board[1][1] == _currentPlayer &&
//             _board[2][2] == _currentPlayer) ||
//             (_board[0][2] == _currentPlayer &&
//                 _board[1][1] == _currentPlayer &&
//                 _board[2][0] == _currentPlayer))) {
//       _endGame();
//     }
//     // Check for draw
//     else if (!_board.any((row) => row.any((cell) => cell == ''))) {
//       _gameOver = true;
//       showDialog(
//         context: context,
//         barrierDismissible: false,
//         builder: (context) => AlertDialog(
//           title: Text('Game Over'),
//           content: Text('It\'s a draw!'),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 Navigator.pop(context);
//                 _resetGame();
//               },
//               child: Text('Play Again'),
//             ),
//           ],
//         ),
//       );
//     }
//   }
//   void _endGame() {
//     _gameOver = true;
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (context) => AlertDialog(
//         title: Text('Game Over'),
//         content: Text('Player $_currentPlayer wins!'),
//         actions: [
//           TextButton(
//             onPressed: () {
//               Navigator.pop(context);
//               _resetGame();
//             },
//             child: Text('Play Again'),
//           ),
//         ],
//       ),
//     );
//   }
//
//   void _togglePlayer() {
//     _currentPlayer = (_currentPlayer == 'X') ? 'O' : 'X';
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         centerTitle: true,
//         title: Text('Tic Tac Toe'),
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: <Widget>[
//             Text(
//               'Current Player: $_currentPlayer',
//               style: TextStyle(fontSize: 20),
//             ),
//             SizedBox(height: 20),
//             GridView.builder(
//               shrinkWrap: true,
//               gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//                 crossAxisCount: 3,
//                 crossAxisSpacing: 8.0,
//                 mainAxisSpacing: 8.0,
//               ),
//               itemCount: 9,
//               itemBuilder: (context, index) {
//                 int row = index ~/ 3;
//                 int col = index % 3;
//                 return GestureDetector(
//                   onTap: () => _makeMove(row, col),
//                   child: Container(
//                     decoration: BoxDecoration(
//                       border: Border.all(color: Colors.black),
//                     ),
//                     child: Center(
//                       child: Text(
//                         _board[row][col],
//                         style: TextStyle(fontSize: 40),
//                       ),
//                     ),
//                   ),
//                 );
//               },
//             ),
//             SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: _resetGame,
//               child: Text('Reset Game'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
