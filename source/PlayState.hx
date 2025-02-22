package;

import moon.game.obj.PlayField;
import moon.game.obj.Song;
import moon.toolkit.ChartConvert;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.FlxSprite;
import flixel.math.FlxMath;
import flixel.FlxG;
import flixel.sound.FlxSound;
import moon.backend.Conductor;
import flixel.FlxState;

class PlayState extends FlxState
{
	private var playField:PlayField;
	override public function create()
	{
		super.create();

		playField = new PlayField('2hot', 'hard', 'pico');
		playField.conductor.onBeat.add(beatHit);
		add(playField);
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);

		if(FlxG.keys.justPressed.NINE) FlxG.switchState(()->new ChartConvert());
	}

	public function beatHit(curBeat:Float)
	{
		if ((curBeat % playField.conductor.numerator) == 0)
		{
			//TODO: cam zoom
		}
	}
}
