// Inspired by: https://github.com/hamaluik/tundra

package gato;

import kha.Assets;
import kha.Color;
import kha.Framebuffer;
import kha.System;

class Loader {
  @:allow(Main)
  static var onDone:Void->Void = null;

  @:allow(Main)
  static function load(_):Void {
    System.notifyOnFrames(render);
    Assets.loadEverything(function() {
      System.removeFramesListener(render);
      onDone();
    });
  }

  static function render(framebuffers:Array<Framebuffer>):Void {
    var g2 = framebuffers[0].g2;
    g2.begin();
    var width = Assets.progress * System.windowWidth();
    var height = System.windowHeight() * 0.02;
    var y = (System.windowHeight() - height) * 0.5;
    g2.color = Color.White;
    g2.fillRect(0, y, width, height);
    g2.end();
  }
}
