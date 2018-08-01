import gato.Storage;

typedef SettingsData = {
  var version:Int;
  var language:String;
}

class Settings {
  static inline var FILENAME = 'settings';
  static inline var VERSION = 1;

  public static var language:String = 'en';
  public static var showTileId:Bool = false;

  public static function load() {
    var settings:Null<SettingsData> = Storage.read(FILENAME);
    if (settings == null || settings.version != VERSION) {
      return;
    }

    language = settings.language;
  }

  public static function save() {
    Storage.write(FILENAME, {
      version:VERSION,
      language:language
    });
  }
}
