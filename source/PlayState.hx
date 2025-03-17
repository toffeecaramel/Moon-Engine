package;

import moon.game.submenus.PauseScreen;
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

	public var oppTest:Character;

	override public function create()
	{
		super.create();

		this.persistentUpdate = false;
		//this.persistentDraw = false;
		
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
		
		//< -- PLAYFIELD SETUP -- >//
		playField = new PlayField('expurgated', 'hard', 'bf');
		playField.camera = camHUD;
		playField.conductor.onBeat.add(beatHit);
		add(playField);
		
		//< -- BACKGROUND SETUP -- >//
		stage = new Stage('limo', playField.conductor);
		add(stage);

		final chartMeta = playField.chart.content.meta;
		for (opp in chartMeta.opponents) stage.addCharTo(opp, stage.opponents, playField.inputHandlers.get('opponent'));
		for (plyr in chartMeta.players) stage.addCharTo(plyr, stage.players, playField.inputHandlers.get('p1'));
		for (spct in chartMeta.spectators) stage.addCharTo(spct, stage.spectators);
		stage.setDefaultPositions();

		final mainSpec = stage.spectators.members[0];
		camFollower.setPosition(stage.cameraSettings.startX ?? (mainSpec.x ?? 0), stage.cameraSettings.startY ?? (mainSpec.y ?? 0));

		playField.conductor.onBeat.add(stage.script.get('onBeat'));

		Paths.clearUnusedMemory();
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
		if(FlxG.keys.justPressed.SEVEN) FlxG.switchState(() -> new ChartEditor());

		if(FlxG.keys.pressed.RIGHT) camFollower.x += 10;
		if(FlxG.keys.pressed.LEFT) camFollower.x -= 10;
		if(FlxG.keys.pressed.DOWN) camFollower.y += 10;
		if(FlxG.keys.pressed.UP) camFollower.y -= 10;

		//TODO: enhance this so camGAME is able to have custom zooms while bump is active.
		camGAME.zoom = FlxMath.lerp(camGAME.zoom, stage.cameraSettings.zoom ?? 1, elapsed * 10);
		camHUD.zoom = FlxMath.lerp(camHUD.zoom, 1, elapsed * 10);

		if(FlxG.keys.justPressed.NINE) FlxG.switchState(()->new ChartConvert());

		if(MoonInput.justPressed(PAUSE))
		{
			openSubState(new PauseScreen(camALT));
			playField.playback.state = PAUSE;
		}
	}

	public function beatHit(curBeat:Float)
	{
		if ((curBeat % playField.conductor.numerator) == 0)
		{
			camGAME.zoom += 0.015;
			camHUD.zoom += 0.025;
		}
	}
}
