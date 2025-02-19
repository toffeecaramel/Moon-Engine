package;

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
	private var conductor:Conductor;
	private var soul:FlxSprite = new FlxSprite();
	override public function create()
	{
		super.create();

		conductor = new Conductor(115, 6, 4);
		conductor.onBeat.add(beatHit);

		soul.loadGraphic('assets/soul.png');
		soul.scale.set(0.1, 0.1);
		soul.screenCenter();
		soul.x -= 100;
		soul.y -= 100;
		add(soul);

		FlxTween.tween(soul, {x: soul.x + 200}, conductor.crochet / 1000 * conductor.numerator, {ease: FlxEase.quadInOut, type:PINGPONG});
		FlxTween.tween(soul, {y: soul.y + 200}, conductor.crochet / 1000 * 3, {ease: FlxEase.quadInOut, type:PINGPONG});

		FlxG.sound.playMusic('assets/Undyne 115.ogg');
	}

	override public function update(elapsed:Float):Void
	{
		(FlxG.sound.music != null) ? conductor.time = FlxG.sound.music.time /** FlxG.sound.music.pitch*/ : null;
		super.update(elapsed);
	}

	public function beatHit(curBeat:Float)
	{
		if ((curBeat % conductor.numerator) == 0)
		{
			// cam zoom
		}
	}
}
