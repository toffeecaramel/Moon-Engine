package moon;

import moon.menus.*;
import moon.game.*;
import moon.toolkit.level_editor.LevelEditor;
import flixel.FlxState;

@:publicFields
class Constants
{
	// - Game's main informations.
	static final VERSION:String = '0.0.0';
	static final GAME_WIDTH:Int = 1280;
	static final GAME_HEIGHT:Int = 720;
	static final GAME_FRAMERATE:Int = 60;
	static final SKIP_SPLASH:Bool = true;
	static final TRACE_DEBUG_INFO:Bool = true;

    static final INITIAL_STATE:Class<FlxState> = TestState;
}