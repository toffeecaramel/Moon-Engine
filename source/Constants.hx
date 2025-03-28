package;

import moon.toolkit.chart_editor.ChartEditor;
import flixel.FlxState;

class Constants
{
	public static final VERSION:String = '0.0.0';

	// - Game's main informations.
	public static final GAME_WIDTH:Int = 1280;
	public static final GAME_HEIGHT:Int = 720;
	public static final GAME_FRAMERATE:Int = 60;
	public static final SKIP_SPLASH:Bool = true;
	public static final TRACE_DEBUG_INFO:Bool = true;

    public static final INITIAL_STATE:Class<FlxState> = ChartEditor;
}