package;

import moon.game.obj.Character;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxG;
import flixel.FlxState;
import flixel.math.FlxRect;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.math.FlxMath;
import flixel.util.FlxColor;

import moon.game.obj.Stage;
import moon.game.obj.PlayField;
import moon.toolkit.ChartConvert;
import moon.toolkit.chart_editor.ChartEditor;

class PlayState extends FlxState
{
	// Gameplay (playfield)
	private var playField:PlayField;

	// Background (stage)
	private var stage:Stage;

	// Cameras
	public var camHUD:MoonCamera = new MoonCamera();
	public var camALT:MoonCamera = new MoonCamera();
	public var camGAME:MoonCamera = new MoonCamera();

	public var camFollower:FlxObject = new FlxObject();

	var ralsei:MoonSprite = new MoonSprite(); //lol

	public var oppTest:Character;

	override public function create()
	{
		super.create();
		
		//< -- CAMERAS SETUP -- >//
		camGAME.bgColor = 0xFF000000;
		camHUD.bgColor = 0x00000000;
		camALT.bgColor = 0x00000000;

		FlxG.cameras.add(camGAME, true);
		FlxG.cameras.add(camHUD, false);
		FlxG.cameras.add(camALT, false);
		camFollower.setPosition(0, 0);
		camGAME.follow(camFollower, LOCKON, 1);
		camGAME.focusOn(camFollower.getPosition());
		camGAME.handheldVFX = {xIntensity: 2.2, yIntensity: 3.2, distance: 11, speed: 0.3};

		//< -- BACKGROUND SETUP -- >//
		stage = new Stage('limo');
		add(stage);
		//TODO: Set null value to be Spectator's(GF's) position once added.
		camFollower.setPosition(stage.cameraSettings.startX ?? 0, stage.cameraSettings.startY ?? 0);
		
		//< -- PLAYFIELD SETUP -- >//
		playField = new PlayField('2hot', 'hard', 'pico');
		playField.camera = camHUD;
		playField.conductor.onBeat.add(beatHit);
		add(playField);

		playField.conductor.onBeat.add(stage.script.get('onBeat'));

		ralsei.loadGraphic(Paths.image('ralsei'));
		ralsei.scale.set(0.2, 0.2);
		ralsei.screenCenter(X);
		ralsei.y = 1400;
		add(ralsei);

		oppTest = new Character(30, 30, 'darnell', playField.conductor);
		add(oppTest);

		Paths.clearUnusedMemory();
	}

	var canBump:Bool = false;
	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
		if(FlxG.keys.justPressed.SEVEN) FlxG.switchState(() -> new ChartEditor());

		if(FlxG.keys.justPressed.O) canBump = !canBump;
		if(canBump)
		{
			ralsei.screenCenter(X);
			ralsei.y = FlxMath.lerp(ralsei.y, (FlxG.height - ralsei.height) / 2, elapsed * 17);
			ralsei.updateHitbox();
		}

		if(FlxG.keys.pressed.RIGHT) camFollower.x += 10;
		if(FlxG.keys.pressed.LEFT) camFollower.x -= 10;
		if(FlxG.keys.pressed.DOWN) camFollower.y += 10;
		if(FlxG.keys.pressed.UP) camFollower.y -= 10;

		//TODO: enhance this so camGAME is able to have custom zooms while bump is active.
		camGAME.zoom = FlxMath.lerp(camGAME.zoom, stage.cameraSettings.zoom ?? 1, elapsed * 10);
		camHUD.zoom = FlxMath.lerp(camHUD.zoom, 1, elapsed * 10);

		if(FlxG.keys.justPressed.NINE) FlxG.switchState(()->new ChartConvert());
	}

	var twn:FlxTween;
	public function beatHit(curBeat:Float)
	{
		if(canBump)
		{
			final dur = playField.conductor.crochet / 2000;
			if(twn != null && twn.active) twn.cancel();

			twn = FlxTween.tween(camHUD, {y: -20}, dur, {ease: FlxEase.circOut, onComplete: function(_)
			{
				twn = FlxTween.tween(camHUD, {y: 0}, dur, {ease: FlxEase.circIn});
			}});
		}

		ralsei.flipX = !ralsei.flipX;
		ralsei.y += 25;
		if ((curBeat % playField.conductor.numerator) == 0)
		{
			camGAME.zoom += 0.015;
			camHUD.zoom += 0.025;
		}
	}
}
