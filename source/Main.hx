package;

import haxe.ui.Toolkit;
import moon.toolkit.ChartConvert;
import flixel.FlxG;
import flixel.FlxGame;
import openfl.display.Sprite;

class Main extends Sprite
{
	public function new()
	{
		super();
		addChild(new FlxGame(0, 0, PlayState));

		// - Init haxeui stuff - //
		Toolkit.init();
		Toolkit.theme = 'dark';
		Toolkit.autoScale = false;
		haxe.ui.focus.FocusManager.instance.autoFocus = false;

		FlxG.fixedTimestep = false;
	}
}
