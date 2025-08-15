package;

import moon.toolkit.ChartConvert;
import flixel.FlxG;
import flixel.FlxGame;
import openfl.display.Sprite;

using StringTools;
class Main extends Sprite
{
	public static var fps:FPS;
	public function new()
	{
		super();

		#if sys
		haxe.Log.trace = function(v:Dynamic, ?infos:haxe.PosInfos) 
		{
			// All definitions with each lil prefix.
			final logLevels = [ // Doing sidenotes for the colors cause theyre confusing as fuck
				"DEBUG" => { prefix: "[>]", color: "\x1b[32m" },  // Green
				"WARNING" => { prefix: "[!]", color: "\x1b[33m" },  // Yellow
				"ERROR" => { prefix: "[x]", color: "\x1b[31m" },  // Red
				"INFO" => { prefix: "[?]", color: "\x1b[36m" }   // Cyan blue whatever
			];
		
			// Determine log level.
			final logLevel = infos != null && infos.customParams != null && infos.customParams.length > 0 
				? infos.customParams[0] 
				: "INFO";
		
			// Skips debug messages if debug info is disabled.
			if (logLevel == "DEBUG" && !Constants.TRACE_DEBUG_INFO) return;
		
			// Gets some details. It fallbacks to INFO if the prefix is empty. 
			final levelData = logLevels.exists(logLevel) ? logLevels[logLevel] : logLevels["INFO"];
			final className = infos != null && infos.className != null ? '${infos.className}: ' : '';
			final infoBefore = '> ${levelData.prefix} - ${className}';
		
			// And then displays the pretty text on the console. :D
			Sys.println('${levelData.color}${infoBefore.rpad(" ", 10)}${v}\x1b[0m');
		};
		#end

		FlxG.fixedTimestep = false;

		var game = new MoonGame(Constants.GAME_WIDTH, Constants.GAME_HEIGHT, Constants.INITIAL_STATE, Constants.GAME_FRAMERATE, Constants.GAME_FRAMERATE, Constants.SKIP_SPLASH);
		addChild(game);

		fps = new FPS(10, 10);
		addChild(fps);

		MoonSettings.updateGlobalSettings();
	}
}
