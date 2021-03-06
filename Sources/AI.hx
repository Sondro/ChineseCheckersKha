import board.Move;

class AI {
  // TODO:[carlito 20180907] minimax algorithm
  public static function minimax(gamesave:Gamesave):Null<Move> {
    if (gamesave.sequence.length != 2) {
      // Works only with 2 players
      return null;
    }

    var moves:Array<Move> = Board.allowedMoves(gamesave);
    if (moves.length > 0) {
      var moveIndex = Math.floor(Math.random() * moves.length);
      return moves[moveIndex];
    }

    return null;
  }
}
