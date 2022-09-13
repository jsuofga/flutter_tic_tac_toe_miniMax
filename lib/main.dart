// import 'dart:ffi';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String gameOutcomeFeedback = '';
  String humanPlayer = 'X';
  String aiPlayer = 'O';
  int counter = 0;

  //gameBoard for drawing the UI using the Gridview Builder.
  //    0 | 1 | 2
  //    3 | 4 | 5
  //    6 | 7 | 8

  List gameBoard =
  [ '', '', '',
    '', '', '',
    '', '', ''
  ];

  void human_move(_index) {
    setState(() {
      gameBoard[_index] = humanPlayer;
      check_gameTied(gameBoard);
      checkWinner(gameBoard, humanPlayer);
    });
    // print('${gameBoard}');

  }

  void computer_move() {
    //Player2
    List availableMove = [];
    int aiMove = 0;

    if( checkWinner(gameBoard, humanPlayer) ||  checkWinner(gameBoard, aiPlayer) || check_gameTied(gameBoard)){
      // game over

    }else{
      //game not over. Make a move

      // Testing - just pick next available spot
      // 1. get all index of unplayed boxes
      // gameBoard.asMap().forEach((index, element) {
      //   if (element == '') {
      //     availableMove.add(index);
      //   }
      // });
      // // 2. pick Next available availableMove.
      // aiMove = availableMove[0];
      //
      // // 3. Update Gameboard with computer selection
      // setState(() {
      //   gameBoard[aiMove] = aiPlayer;
      //   check_gameTied(gameBoard);
      //   checkWinner(gameBoard, aiPlayer);
      // });

      //  Using MiniMax() algorithm

      // First AI move, if human did not play center, play center. if human play center, play any corner
      if(counter == 0){
        List cornerLocations = [0,2,6,8];
        counter++;
        if(gameBoard[4] == humanPlayer){

          setState(() {
            //pick any corner
            gameBoard[cornerLocations[Random().nextInt(cornerLocations.length)]] = aiPlayer;

          });

        }else if(gameBoard[4] == ''){

          setState(() {
            //pick center
            gameBoard[4] = aiPlayer;

          });

        }
        // 2nd AI move and after, use MiniMax()
      }else{
        aiMove = miniMax(gameBoard, aiPlayer)['index'] ;
        setState(() {
          gameBoard[aiMove] = aiPlayer;
          check_gameTied(gameBoard);
          checkWinner(gameBoard, aiPlayer);
        });
      }

      // }


    }



  }


  bool checkWinner(List board, player){
    //Check if winner is 'humanPlayer' or 'aiPlayer' or if neither

    if( board[0] == player &&  board[1] == player  &&  board[2] == player ||
        board[3] == player &&  board[4] == player  &&  board[5] == player ||
        board[6] == player &&  board[7] == player  &&  board[8] == player ||
        board[0] == player &&  board[3] == player  &&  board[6] == player ||
        board[1] == player &&  board[4] == player  &&  board[7] == player ||
        board[2] == player &&  board[5] == player  &&  board[8] == player ||
        board[0] == player &&  board[4] == player  &&  board[8] == player ||
        board[2] == player &&  board[4] == player  &&  board[6] == player
    ){
      gameOutcomeFeedback = '${player} wins';
      return true;
    }else {
      return false;
    }

  }
  bool check_gameTied(List board){

    if(!board.contains('') && !checkWinner(board, aiPlayer) && !checkWinner(board, humanPlayer)){
      gameOutcomeFeedback = 'Game Tied';
      return true;
    }
    else{
      return false;
    }

  }

  Map miniMax(simBoard, player) {

    print('${counter++}');
    // miniMax returns the index ( 0-8)  that AI (X) should play
    //    0 | 1 | 2
    //    3 | 4 | 5
    //    6 | 7 | 8

    // Base case (termination condition)

    if (checkWinner(simBoard, aiPlayer)) {
      // AI has won. Return +10
      return {'score':10};
    }
    else if (checkWinner(simBoard, humanPlayer)) {
      // Human has won,  Return -10
      return {'score':-10};

    } else if (check_gameTied(simBoard)) {
      // Tie,  Return
      return {'score':0};

    }

    // --- End of Base case

    //  AI to play all Open Spaces, evaluate which is the best move.
    var moves = [];

    for ( int i = 0; i < simBoard.length; i++) {

      if( simBoard[i] == ''){
        var move = {}; // create a object for each play
        move['index'] = i; // record the location of the AI move ( 0-8)
        simBoard[i] = player; // play at i

        // call miniMax ( simBoard, ) recursively
        if (player == aiPlayer) {

          var result = miniMax(simBoard, humanPlayer);
          move['score'] = result['score'];
          // move['score'] = result;
          // print('${move}');

        } else {
          var result = miniMax(simBoard, aiPlayer);
          move['score'] = result['score'];
          //move['score'] = result;
          // print('${move}');


        }
        // Reset the spot that was simulated back to ''
        simBoard[i] = '';
        //
        // Save the move and score to moves[]
        moves.add(move);
        // print('${moves}');

      }


    }

    //Finally, return index of the best move for AI
    // Pick the best move
    var bestMove;
    if (player == aiPlayer) {
      var bestScore = -10000;
      for (int i = 0; i < moves.length; i++) {
        if (moves[i]['score'] > bestScore) {
          bestScore = moves[i]['score'];
          bestMove = i;
        }
      }
    } else {
      var bestScore = 10000;
      for (int i = 0; i < moves.length; i++) {
        if (moves[i]['score'] < bestScore) {
          bestScore = moves[i]['score'];
          bestMove = i;
        }
      }
    }
    return moves[bestMove];
  }

  @override
  Widget build(BuildContext context) {

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.blueGrey,

        body: Center(
          child: Container(
            margin: EdgeInsets.all(20),
            width: 600,
            height: 800,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [

                  checkWinner(gameBoard,aiPlayer)||checkWinner(gameBoard,humanPlayer) || check_gameTied(gameBoard)? Text('${gameOutcomeFeedback}',
                    style: TextStyle(color: Colors.white, fontSize: 50),): Text(''),

                  GridView.builder(
                      shrinkWrap: true,  //do not use up the entire allowable space of parent
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,  //number of columns
                          crossAxisSpacing: 5, //gap spacing horizontal between grid elements
                          mainAxisSpacing: 5 //gap spacing vertical between grid elements
                      ),
                      itemCount: gameBoard.length,
                      itemBuilder: (BuildContext ctx, index) {
                        return GestureDetector(
                          onTap: gameBoard[index] != '' || checkWinner(gameBoard, humanPlayer) || checkWinner(gameBoard, aiPlayer) ? null : (){
                            //onTap: (){
                            human_move(index);
                            Future.delayed(Duration(milliseconds: 1000), () {
                              // Do something
                              computer_move();
                            });

                          },
                          child: Container(
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: Colors.black87,
                            ),
                            child: Text(gameBoard[index],
                              style: TextStyle(color: Colors.white, fontSize: 80 ),
                            ),
                          ),
                        );
                      }),

                  SizedBox(height: .05*MediaQuery.of(context).size.height),
                  Visibility(
                    visible: check_gameTied(gameBoard) || checkWinner(gameBoard, humanPlayer) || checkWinner(gameBoard, aiPlayer),
                    child: OutlinedButton(
                      child: Text('Play Again'),
                      style: OutlinedButton.styleFrom(backgroundColor: Colors.transparent,primary: Colors.white,side: BorderSide(color: Colors.orange)),
                      onPressed: (){
                        setState(() {
                          gameBoard =
                          [ '','','',
                            '','','',
                            '','',''
                          ];
                          gameOutcomeFeedback ='';
                          counter = 0;
                        });
                      },
                    ),
                  )
                ],
              ),
            ),
          ),
        ),


      ),
    );
  }
}






