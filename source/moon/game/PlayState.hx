package moon.game;

import moon.dependency.scripting.MoonEvent;
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
import moon.toolkit.level_editor.LevelEditor;

class PlayState extends FlxState
{	
	// Just a variable for getting playstate. nothing much.
	public static var playgame:PlayState;

	//-- Gameplay main variables --//

	// The main gameplay interface
	public var playField:PlayField;

	// Just the conductor :P poor little guy,,
	public var conductor:Conductor;
	
	// Background (stage)
	public var stage:Stage;
	
	// Cameras
	public var camHUD:MoonCamera = new MoonCamera();
	public var camALT:MoonCamera = new MoonCamera();
	public var camGAME:MoonCamera = new MoonCamera();
	public var camFollower:FlxObject = new FlxObject();
	
	// Some other values
	public var gameZoom:Float = 1;

	// Events (a array containing every MoonEvent, not the raw events from chart.)
	public static var events:Array<MoonEvent> = [];
	
	override public function create()
	{
		super.create();
		playgame = this;
		
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
		
		//< -- PLAYFIELD SETUP -- >//
		playField = new PlayField('darnell', 'hard', 'bf');
		playField.camera = camHUD;
		playField.conductor.onBeat.add(beatHit);
		add(playField);
		this.conductor = playField.conductor;
		
		//< -- BACKGROUND SETUP -- >//
		stage = new Stage(playField.chart.content.meta.stage, conductor);
		add(stage);
		
		final chartMeta = playField.chart.content.meta;
		for (opp in chartMeta.opponents) stage.addCharTo(opp, stage.opponents, playField.inputHandlers.get('opponent'));
		for (plyr in chartMeta.players) stage.addCharTo(plyr, stage.players, playField.inputHandlers.get('p1'));
		for (spct in chartMeta.spectators) stage.addCharTo(spct, stage.spectators);

		if(stage.script.exists("onBeat")) conductor.onBeat.add(stage.script.get('onBeat'));

		//< -- EVENTS SETUP -- >//
		for(event in playField.chart.content.events)
		{
			var ev = new MoonEvent(event.tag, event.values);
			ev.PRESET_VARIABLES = [
				'game' => this,
				'stage' => stage,
				'playField' => playField
			];
			ev.time = event.time;
			events.push(ev);
		}
		
		// call on post create for scripts
		stage.script.set('game', this);

		if(stage.script.exists('onPostCreate')) stage.script.call('onPostCreate');
		
		final mainSpec = stage.spectators.members[0];
		camFollower.setPosition(stage.cameraSettings.startX ?? (mainSpec.x ?? 0), stage.cameraSettings.startY ?? (mainSpec.y ?? 0));
		gameZoom = stage.cameraSettings.zoom ?? 1;

		//playField.playback.state = PLAY;
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
		
		// EVENTS CHECK
		for (event in events)
		{
			if (event.time <= conductor.time)
			{
				event.exec();
				events.remove(event);
			}
		}
		
		//TODO: enhance this so camGAME is able to have custom zooms while bump is active.
		camGAME.zoom = FlxMath.lerp(camGAME.zoom, gameZoom, elapsed * 16);
		camHUD.zoom = FlxMath.lerp(camHUD.zoom, 1, elapsed * 16);
		
		if(FlxG.keys.justPressed.NINE) FlxG.switchState(()->new ChartConvert());
		if(FlxG.keys.justPressed.SEVEN) FlxG.switchState(() -> new LevelEditor());

		if(MoonInput.justPressed(PAUSE))
		{
			openSubState(new PauseScreen(camALT));
			playField.playback.state = PAUSE;
		}
	}

	public function beatHit(curBeat:Float)
	{
		if (((curBeat % playField.conductor.numerator) == 0) && !playField.inCountdown)
		{
			camGAME.zoom += 0.025;
			camHUD.zoom += 0.030;
		}
	}
}
