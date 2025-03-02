package;

import flixel.math.FlxMath;
import flixel.FlxCamera;
import flixel.util.FlxColor;
import flixel.FlxSprite;
import flixel.FlxG;
import flixel.FlxState;
import moon.game.obj.PlayField;
import moon.toolkit.ChartConvert;

class PlayState extends FlxState
{
	// Gameplay (playfield)
	private var playField:PlayField;

	// Cameras
	public var camHUD:FlxCamera = new FlxCamera();
	public var camALT:FlxCamera = new FlxCamera();
	public var camGAME:FlxCamera;
	override public function create()
	{
		super.create();
		
		//< -- CAMERAS SETUP -- >//
		camHUD.bgColor = 0x00000000;
		camALT.bgColor = 0x00000000;

		FlxG.cameras.add(camHUD, false);
		FlxG.cameras.add(camALT, false);
		camGAME = FlxG.camera;

		var bg = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.GRAY);
		add(bg);

		//< -- PLAYFIELD SETUP -- >//
		playField = new PlayField('toast', 'hard', 'bf');
		playField.camera = camHUD;
		playField.conductor.onBeat.add(beatHit);
		add(playField);
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
		camHUD.zoom = FlxMath.lerp(camHUD.zoom, 1, elapsed * 10);

		if(FlxG.keys.justPressed.NINE) FlxG.switchState(()->new ChartConvert());
	}

	public function beatHit(curBeat:Float)
	{
		if ((curBeat % playField.conductor.numerator) == 0)
		{
			camHUD.zoom += 0.025;
		}
	}
}
