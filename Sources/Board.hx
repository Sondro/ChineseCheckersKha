import kha.Color;

//
// State
//

typedef Move = {
  var from:Int;
  var to:Int;
}

typedef Player = {
  var id:Int;
  var color:Color;
}

typedef Tile = {
  var id:Int;
  var x:Int;
  var y:Int;
  var owner:Null<Int>;
  var piece:Null<Int>;
}

typedef Sequence = Array<Int>;

typedef State = {
  var ready:Bool;
  var width:Int;
  var height:Int;
  var sequence:Sequence;
  var players:Map<Int, Player>;
  var tiles:Map<Int, Tile>;
  var moves:Array<Move>;
  var standings:Array<Int>;
}

//
// Raw Board
//

typedef RawPlayer = {
  var home:Int;
  var color:Color;
}

#if debug
class ChineseCheckers {
  static public var board(default, null):Array<String> = [
    '  2  ',
    ' * * ',
    '1 * 3',
  ];

  static public var players(default, null):Array<RawPlayer> = [
    { home:2, color:Color.Black },
    { home:3, color:Color.Red },
    { home:1, color:Color.fromBytes(  0, 128,   0) }, // green
  ];

  static public var sequences(default, null):Array<Sequence> = [
    [ 1, 2, 3 ],
  ];
}
#else
class ChineseCheckers {
  static public var board(default, null):Array<String> = [
    '            4            ',
    '           4 4           ',
    '          4 4 4          ',
    '         4 4 4 4         ',
    '3 3 3 3 * * * * * 5 5 5 5',
    ' 3 3 3 * * * * * * 5 5 5 ',
    '  3 3 * * * * * * * 5 5  ',
    '   3 * * * * * * * * 5   ',
    '    * * * * * * * * *    ',
    '   2 * * * * * * * * 6   ',
    '  2 2 * * * * * * * 6 6  ',
    ' 2 2 2 * * * * * * 6 6 6 ',
    '2 2 2 2 * * * * * 6 6 6 6',
    '         1 1 1 1         ',
    '          1 1 1          ',
    '           1 1           ',
    '            1            ',
  ];

  static public var players(default, null):Array<RawPlayer> = [
    { home:4, color:Color.Black },
    { home:5, color:Color.fromBytes(  0, 128, 128) }, // teal
    { home:6, color:Color.fromBytes(  0, 128,   0) }, // green
    { home:1, color:Color.Red },
    { home:2, color:Color.Purple },
    { home:3, color:Color.Yellow },
  ];

  static public var sequences(default, null):Array<Sequence> = [
    [ 1, 4 ],
    [ 1, 3, 5 ],
    [ 1, 3, 4, 6 ],
    [ 1, 2, 3, 4, 5, 6 ],
  ];
}
#end

//
// Board
//

class Board {
  static public function create(sequenceIndex:Null<Int>):State {
    var width:Int = ChineseCheckers.board[0].length;
    var height:Int = ChineseCheckers.board.length;
    var sequence:Sequence = [];
    var players:Map<Int, Player> = new Map<Int, Player>();
    var tiles:Map<Int, Tile> = new Map<Int, Tile>();
    var moves:Array<Move> = [];
    var standings:Array<Int> = [];

    // Players
    var owners = new Map<Int, Int>();
    if (sequenceIndex != null) {
      sequence = ChineseCheckers.sequences[sequenceIndex];
      for (id in sequence) {
        var player = ChineseCheckers.players[id-1];
        players[id] = {
          id:id,
          color:player.color,
        };
        owners[player.home] = id;
      }
    }

    // Tiles
    var id = 0;
    for (y in 0...height) {
      var row = ChineseCheckers.board[y];
      for (x in 0...width) {
        var value = row.charAt(x);
        if (value != ' ') {
          var player = Std.parseInt(value);
          tiles[++id] = {
            id:id,
            x:x + 1,
            y:y + 1,
            owner:(player != null) ? owners[player] : null,
            piece:(player != null && players[player] != null) ? player : null,
          };
        } 
      }
    }

    return {
      ready:false,
      width:width,
      height:height,
      sequence:sequence,
      players:players,
      tiles:tiles,
      moves:moves,
      standings:standings,
    }
  }

  //
  // Players
  //

  static public function currentPlayer(state:State):Null<Player> {
    if (!state.ready || isOver(state)) {
      return null;
    }
    if (state.moves.length == 0) {
      return state.players[state.sequence[0]];
    }
    var move = state.moves[state.moves.length-1];
    var index = state.sequence.indexOf(state.tiles[move.to].piece);
    if (index == -1) {
      return null;
    }
    var player;
    do {
      index++;
      if (index == state.sequence.length) {
        index = 0;
      }
      player = state.players[state.sequence[index]];
    } while(state.standings.indexOf(player.id) > -1);
    return player;
  }

  static public function isOver(state:State):Bool {
    return (state.standings.length == state.sequence.length);
  }

  //
  // Allowed moves
  //

  static function neighbors(state:State, tile:Tile):Array<Tile> {
    //    (1) (2)
    //      \ /
    //  (3)- * -(4)
    //      / \
    //    (5) (6)
    var tiles:Array<Tile> = [];
    for (neighbor in state.tiles) {
      if (
        ((neighbor.x == tile.x - 1) && (neighbor.y == tile.y - 1)) || // (1)
        ((neighbor.x == tile.x + 1) && (neighbor.y == tile.y - 1)) || // (2)
        ((neighbor.x == tile.x - 2) && (neighbor.y == tile.y    )) || // (3)
        ((neighbor.x == tile.x + 2) && (neighbor.y == tile.y    )) || // (4)
        ((neighbor.x == tile.x - 1) && (neighbor.y == tile.y + 1)) || // (5)
        ((neighbor.x == tile.x + 1) && (neighbor.y == tile.y + 1))    // (6)
      ) {
        tiles.push(neighbor);
      }
    }

    return tiles;
  }

  static function jump(state:State, from:Tile, via:Tile):Null<Tile> {
    var x = via.x + (via.x - from.x);
    var y = via.y + (via.y - from.y);
    for (tile in state.tiles) {
      if (tile.x == x && tile.y == y) {
        return tile;
      }
    }
    return null;
  }

  static function jumps(state:State, tile:Tile, tiles:Array<Tile>) {
    for (neighbor in neighbors(state, tile)) {
      if (neighbor.piece != null) {
        var jumpTile = jump(state, tile, neighbor);
        if (jumpTile != null && jumpTile.piece == null && tiles.indexOf(jumpTile) == -1) {
          tiles.push(jumpTile);
          jumps(state, jumpTile, tiles);
        }
      }
    }
  }

  static public function allowedMoves(state:State, tile:Tile):Array<Tile> {
    var moves:Array<Tile> = [];
    if (currentPlayer(state) == null || tile.piece != currentPlayer(state).id) {
      return moves;
    }

    jumps(state, tile, moves);
    for (neighbor in neighbors(state, tile)) {
      if (neighbor.piece == null) {
        moves.push(neighbor);
      }
    }

    // Once a peg has reached his home, it may not leave it
    var currentPlayerId = currentPlayer(state).id;
    if (tile.owner == currentPlayerId) {
      var i = 0;
      while (i < moves.length) {
        var moveTile = moves[i];
        if (moveTile.owner != currentPlayerId) {
          moves.splice(i, 1);
        }
        else {
          ++i;
        }
      }
    }

    return moves;
  }

  //
  // Movements
  //

  static public function move(state:State, from:Tile, to:Tile):Bool {
    if (allowedMoves(state, from).indexOf(to) == -1) {
      return false;
    }
    to.piece = from.piece;
    from.piece = null;
    state.moves.push({from:from.id, to:to.id});

    // Victory?
    var victory = true;
    for (tile in state.tiles) {
      if (tile.piece == to.piece && tile.owner != to.piece) {
        victory = false;
        break;
      }
    }
    if (victory) {
      state.standings.push(to.piece);
      if (state.standings.length == state.sequence.length-1) {
        // Who is the great loser?
        for (player in state.players) {
          if (state.standings.indexOf(player.id) == -1) {
            state.standings.push(player.id);
          }
        }
      }
    }

    return true;
  }

  static public function cancelLastMove(state:State) {
    if (state.moves.length == 0) {
      return;
    }

    var move = state.moves.pop();
    var from = state.tiles[move.from];
    var to = state.tiles[move.to];
    from.piece = to.piece;
    to.piece = null;

    if (state.standings.length > 0 && state.standings[state.standings.length] == to.piece) {
      state.standings.pop();
    }
  }
}
