package;

import moon.toolkit.ChartConvert;
import flixel.FlxG;
import flixel.FlxGame;
import openfl.display.Sprite;

class Main extends Sprite
{
	public function new()
	{
		super();
		addChild(new FlxGame(0, 0, ChartConvert));
		FlxG.fixedTimestep = false;
	}
}
