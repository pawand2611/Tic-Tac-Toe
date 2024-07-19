import 'package:flutter/material.dart';
import 'package:tic_tac_toe/main.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: FloatingActionButton(
          onPressed: (){
            Navigator.of(context)
                .push(MaterialPageRoute(builder: (context) =>TicTacToeScreen()),
            );
          },
        ),
      ),
    );
  }
}
