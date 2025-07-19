import flixel.FlxG;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import moon.dependency.MoonSprite;

var dialogues:Array<MoonSprite> = [];
function onCreate()
{
	final p = 'ingame/stages/gerso/';
	
	var bg = new MoonSprite().loadGraphic(Paths.image(p + 'gersbg'));
	bg.scrollFactor.set();
	bg.scale.set(2.9, 2.9);
	background.add(bg);
	
	for (i in 0...2)
	{
		var dial = new MoonSprite((i == 0) ? 170 : 30,(i == 0) ? 45 : 415);
		dial.frames = Paths.getSparrowAtlas((i == 0) ? p + 'gersdial' : p + 'gersfakedial');
		dial.animation.addByPrefix('bump', (i == 0) ? 'gersdial' : 'gersfakedial', 24, false);
		background.add(dial);
		dialogues.push(dial);
	}
	
	background.add(background.opponents);
	background.add(background.players);
}

function onPostCreate()
{
	background.cameraSettings = {
		zoom: 0.525,
        startX: 780,
        startY: 100
	};
	
	FlxG.camera.zoom = 0.525;
	background.spectators.setPosition(2000, -5);
	background.players.setPosition(830, -90);
	background.opponents.setPosition(-400, -460);
}

function onUpdate(elapsed)
{
}

function onBeat()
{
	for(d in dialogues) d.playAnim('bump');
}