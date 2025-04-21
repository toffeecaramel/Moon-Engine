package moon.backend;

/**
 * Conductor class. Made by Cobalt for their retired Horizon Engine.
 * and I still can't make a conductor myself btw </3
 * I mean... I *can* but, I don't know how
 * 
 * anyways credits to cobalt! :3
 * https://github.com/CCobaltDev/FNF-Horizon-Engine/blob/rewrite/source/horizon/backend/Conductor.hx
 */

import flixel.FlxG;
import flixel.sound.FlxSound;
import flixel.util.FlxSignal;
import sys.thread.Thread;
using StringTools;
@:publicFields
class Conductor
{
	static var bpm(default, set):Float;

	static var curStep:Int = 0;
	static var curBeat:Int = 0;
	static var curMeasure:Int = 0;

	static var time:Float = 0;
	static var song(default, set):FlxSound;
	static var timeSignature(default, set):TimeSignature = TimeSignature.fromString('4/4');
	static var switchToMusic:Bool = true;

	static var stepLength:Float = -1;
	static var beatLength:Float = -1;
	static var measureLength:Float = -1;

	static var onStep:FlxSignal;
	static var onBeat:FlxSignal;
	static var onMeasure:FlxSignal;

	private static var stepTracker:Float = 0;
	private static var beatTracker:Float = 0;
	private static var measureTracker:Float = 0;

	private static var lastTime:Float = 0;
	private static var startTime:Float = 0;
	@:unreflective private static var thread:Thread;

	static function init()
	{
		onStep = new FlxSignal();
		onBeat = new FlxSignal();
		onMeasure = new FlxSignal();

		reset();

		startTime = Sys.time();
		thread = Thread.create(() -> while (true)
		{
			var dt = Sys.time() - startTime;

			if (song != null)
			{
				if (song.playing)
				{
					if (song.time == lastTime)
						time += dt * 1000;
					else
					{
						time = song.time;
						lastTime = song.time;
					}
				}
			}
			else if (FlxG.sound.music != null && switchToMusic)
				song = FlxG.sound.music;

			while (time >= stepTracker + stepLength)
			{
				stepTracker += stepLength;
				curStep++;
				onStep.dispatch();
			}

			while (time >= beatTracker + beatLength)
			{
				beatTracker += beatLength;
				curBeat++;
				onBeat.dispatch();
			}

			while (time >= measureTracker + measureLength)
			{
				measureTracker += measureLength;
				curMeasure++;
				onMeasure.dispatch();
			}

			var remainingTime = (1 / 240) - (Sys.time() - startTime);
			startTime = Sys.time();
			if (remainingTime > 0)
				Sys.sleep(remainingTime);
		});
	}

	static function reset():Void
	{
		timeSignature = TimeSignature.fromString('4/4');
		bpm = 100;
		switchToMusic = true;
		stepTracker = beatTracker = measureTracker = time = lastTime = startTime = 0;
		curStep = curBeat = curMeasure = 0;
		song = null;
	}

	static inline function recalculateLengths():Void
	{
		beatLength = 60 / bpm * 1000 * (4 / timeSignature.denominator);
		stepLength = beatLength * .25;
		measureLength = beatLength * timeSignature.numerator;
	}

	@:noCompletion static function set_bpm(val:Float):Float
	{
		bpm = val;
		recalculateLengths();
		return val;
	}

	@:noCompletion static function set_song(val:FlxSound):FlxSound
	{
		if (val != null)
			val.onComplete = reset;
		return song = val;
	}

	@:noCompletion static function set_timeSignature(val:TimeSignature):TimeSignature
	{
		timeSignature = val;
		recalculateLengths();
		return val;
	}
}

@:structInit
class TimeSignature
{
	public var numerator:Float;
	public var denominator:Float;

	public static function fromString(sig:String):TimeSignature
	{
		if (!sig.contains('/'))
			return {numerator: 4, denominator: 4}

		var split = sig.trim().split('/');
		return {numerator: Std.parseFloat(split[0].trim()), denominator: Std.parseFloat(split[1].trim())}
	}

	public function toString(sig:TimeSignature):String
		return '$numerator/$denominator';
}