import flixel.FlxG;
import flixel.addons.display.FlxBackdrop;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import moon.dependency.MoonSprite;

var trafficLights:MoonSprite;
function onCreate()
{
}

function onPostCreate()
{
	background.cameraSettings = {
		zoom: 5,
        startX: 300,
        startY: 300
	};
	
	if(game.song == 'amusia')
	{
		for (i in 0...game.playField.strumlines[0].members.length)
		{
			final strum = game.playField.strumlines[0].members[i];
			FlxTween.tween(strum, {y: strum.y - 95}, 2, {ease: FlxEase.quadInOut, type: 4, startDelay: 0.2 * i});
		}
	}
	
	//game.playField.strumlines[0].visible = false;
	//game.playField.healthBar.visible = false;
	//game.playField.tst.visible = false;
}

function onUpdate(elapsed)
{
}

function onBeat(beat)
{
	if(game.song == 'monochrome' && beat == 32)
	{
		var text = new flixel.text.FlxText();
		text.text = 'foi mal, morri mesmo :/';
		text.setFormat(Paths.font('vcr.ttf'), 32);
		text.camera = game.camHUD;
		text.screenCenter();
		game.add(text);
		FlxTween.tween(text, {alpha: 0}, 5, {startDelay: 4});
		
		for (i in 0...game.playField.strumlines[0].members.length)
		{
			final strum = game.playField.strumlines[0].members[i];
			FlxTween.tween(strum, {x: -900, angle: 180}, 2, {ease: FlxEase.backInOut});
		}
	}
}