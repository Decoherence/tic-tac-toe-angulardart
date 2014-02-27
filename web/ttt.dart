library tictactoe;



// Temporary, please follow https://github.com/angular/angular.dart/issues/476
@MirrorsUsed(targets: const['tictactoe',
                            'angular.core'
                            ], override: '*')
//@MirrorsUsed(override: 'toString')
import 'dart:mirrors';
import 'package:angular/angular.dart';


import 'dart:math';
//import 'package:perf_api/perf_api.dart';


class MyAppModule extends Module {
  MyAppModule() {
    type(TicTacToeController);
    type(Cell);
    type(Player);
    //type(Profiler, implementedBy: Profiler); // comment out to enable profiling
  }
}

main() {
  ngBootstrap(module: new MyAppModule());
}


/* Use the NgController annotation to indicate that this class is an
 * Angular Controller. The compiler will instantiate the controller if
 * it finds it in the DOM.
 *
 * The selector field defines the CSS selector that will trigger the
 * controller. It can be any valid CSS selector which does not cross
 * element boundaries.
 *
 * The publishAs field specifies that the controller instance should be
 * assigned to the current scope under the name specified.
 *
 * The controller's public fields are available for data binding from the view.
 * Similarly, the controller's public methods can be invoked from the view.
 */
@NgController(
    selector: '[game]',
    publishAs: 'ctrl')
 class TicTacToeController {
  String message = "Hello!";
  List<Cell> board;
  Player human;
  Player robot;
  bool game_over;
  String game_status;

  TicTacToeController() {
    // Set initial state
    game_over = false;
    game_status = "Click square to play";

    // Create players
    human = new Player('You', 'X');
    robot = new Robot('AI', 'O');

    // Setup board
    board = [new Cell.blank(), new Cell.blank(), new Cell.blank(),
             new Cell.blank(), new Cell.blank(), new Cell.blank(),
             new Cell.blank(), new Cell.blank(), new Cell.blank()];

    print('GAME: Begin');
  }

  void reset() {
    // Recreate blank board
    board = [new Cell.blank(), new Cell.blank(), new Cell.blank(),
             new Cell.blank(), new Cell.blank(), new Cell.blank(),
             new Cell.blank(), new Cell.blank(), new Cell.blank()];
    // Set initial state
    game_over = false;
    game_status = "Click square to play";
    print('GAME: Reset');
  }

  void cellClicked(index) {
    print("cellClicked $index");
    if (!game_over) {
      // Human makes first move
      human.makeMove(board, index);

      bool human_wins = checkWinner(human);

      if (human_wins) {
        game_status = 'WINNER: $human';
        game_over = true;
        print('WINNER: $human');
        return;
      }

      // If no winner, Robot makes move
      robot.makeMove(board, index);

      bool robot_wins = checkWinner(robot);

      if (robot_wins) {
        game_status = 'WINNER: $robot';
        game_over = true;
        print('WINNER: $robot');
        return;
      }
    }
  }

  bool checkWinner(Player p) {
    return checkRows(p) || checkColumns(p) || checkDiagonals(p);
  }

  bool checkRows(Player p) {
    // Create sublist for each row and check that all values match
    bool row1 = board.sublist(0,3).every((Cell c) => c.symbol == p.letter);
    bool row2 = board.sublist(3,6).every((Cell c) => c.symbol == p.letter);
    bool row3 = board.sublist(6,9).every((Cell c) => c.symbol == p.letter);

    return row1 || row2 || row3;
  }

  bool checkColumns(Player p) {
    // Index values for first, second, third column
    var first = [0, 3, 6];
    var second = [1, 4, 7];
    var third = [2, 5, 8];
    /*
     * Check each column for a winner
     * - Map index values above to build each column vector
     * - Check if every Cell value matches the Player's letter
     */
    bool col1 =  first.map((i) => board[i]).every((Cell c) => c.symbol == p.letter);
    bool col2 =  second.map((i) => board[i]).every((Cell c) => c.symbol == p.letter);
    bool col3 =  third.map((i) => board[i]).every((Cell c) => c.symbol == p.letter);

    return col1 || col2 || col3;
  }

  bool checkDiagonals(Player p) {
    // Index values for two diagnoals
    var top_left  = [0, 4, 8];
    var top_right = [2, 4, 6];

    /*
    * Check each diagonal for a winner
    * - Map index values above to build each vector
    * - Check if every Cell value matches the Player's letter
    */
    bool diag1 = top_left.map((i) => board[i]).every((Cell c) => c.symbol == p.letter);
    bool diag2 = top_right.map((i) => board[i]).every((Cell c) => c.symbol == p.letter);

    return diag1 || diag2;
  }
}


class Cell {
  String symbol;
  Cell(this.symbol);
  Cell.blank() : symbol = '';
  bool isEmpty() => symbol.isEmpty;
  String toString() => this.symbol;

}

class Player {
  String name;
  String letter;

  Player(this.name, this.letter);

  String toString() => name;

  void makeMove(List board, int index) {
    // Get reference to Cell

    Cell cell = board[index];




    // If cell is blank, mark cell with Player's letter
    if( cell.isEmpty() ) {
      print('PLAYER: $name CELL: $index ($letter)');

      cell.symbol = letter;
      board[index] = cell;
    }
    // Otherwise inform player cell already used
    else {
      print('PLAYER: $name CELL: $index USED');
    }
  }
}

class Robot extends Player {

  Robot(String name, String letter) : super(name, letter);

  void makeMove(List board, int index) {
    // Number of cells left to play
    int remaining_cells = board.where((Cell c) => c.isEmpty()).length;

    var rand = new Random();
    bool success = false;

    // Try random cells until finding an empty one
    while (!success && remaining_cells != 0) {
      Cell cell = board[rand.nextInt(9)];

      if( cell.isEmpty() ) {
        cell.symbol = letter;
        success = true;
        print('PLAYER: $name CELL: $index ($letter)');
      } else {
        print('PLAYER: $name Thinking...');
      }
    }
  }
}
