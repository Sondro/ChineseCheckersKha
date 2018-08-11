import gato.Storage;
import gato.input.Command;

import types.Settings;
import types.State;

class Commands {
  public static function call(commands:Array<Command>) {
    // @@Improvement: use strings for commands (eg: 'quickload 1' should call Commands.quickload(1))
    for (command in commands) {
      switch command {
      case Action('ChangeLanguage'):
        changeLanguage();
      case Action('ToggleHitbox'):
        toggleHitbox();
      case Action('ToggleTileId'):
        toggleTileId();
      case Action('QuickLoad1'):
        quickLoad(1);
      case Action('QuickLoad2'):
        quickLoad(2);
      case Action('QuickLoad3'):
        quickLoad(3);
      case Action('QuickSave1'):
        quickSave(1);
      case Action('QuickSave2'):
        quickSave(2);
      case Action('QuickSave3'):
        quickSave(3);
      case Action('Undo'):
        undo();
      default:
        trace('Unknown command: $command');
      }
    }
  }

  public static function changeLanguage() {
    Translations.language = (Translations.language == 'en') ? 'fr' : 'en';
    Game.settings.data.language = Translations.language;
    if (!Game.localSettings) {
      Game.settings.save(Game.SETTINGS_FILENAME);
    }
  }

  public static function quickLoad(id:Int) {
    var gamesave = new Storage<State>();
    gamesave.load('gamesave$id', Board.GAMESAVE_VERSION);
    if (gamesave.data == null) {
      return;
    }

    trace('Quick Load $id');
    Game.state = gamesave.data;
    Game.scene = Game.scenePlay;
  }

  public static function quickSave(id:Int) {
    if (!Board.isRunning(Game.state)) {
      return;
    }

    trace('Quick Save $id');
    var gamesave = new Storage<State>();
    gamesave.data = Game.state;
    gamesave.save('gamesave$id');
  }

  public static function toggleHitbox() {
    UI.showHitbox = !UI.showHitbox;
  }

  public static function toggleTileId() {
    Game.settings.data.showTileId = !Game.settings.data.showTileId;
  }

  public static function undo() {
    if (Board.isRunning(Game.state)) {
      Board.cancelLastMove(Game.state);
    }
  }
}
