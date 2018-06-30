// Inspired by: https://www.gamedev.net/blogs/entry/2250186-designing-a-robust-input-handling-system-for-games/

typedef Command = {
  var f:Void->Void;
  var repeat:Bool;
}

typedef CommandId = String;

typedef InputContext = Map<VirtualKey, CommandId>;

class Commands {
  static var commands:Map<CommandId, Command> = new Map();

  public static function map(id:CommandId, f:Void->Void, ?repeat:Bool = false) {
    commands.set(id, { f:f, repeat:repeat });
  }

  public static function update(context:InputContext) {
    for (vk in context.keys()) {
      var id = context[vk];
      var command = commands[id];
      if (command == null) {
        continue;
      }
      if (Input.isPressed(vk, command.repeat)) {
        command.f();
      }
    }
  }
}
