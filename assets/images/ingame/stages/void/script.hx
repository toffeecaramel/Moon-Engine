import flixel.FlxG;
import flixel.addons.display.FlxBackdrop;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import moon.dependency.MoonSprite;

var trafficLights:MoonSprite;
function onCreate()
{
	var back = new MoonSprite(-500).makeGraphic(FlxG.width * 2, FlxG.height * 2, 0xFFffe300);
	background.add(back);
}

function onPostCreate()
{
	background.cameraSettings = {
		zoom: 5,
        startX: 300,
        startY: 300
	};
	
	game.playField.strumlines[0].visible = false;
	game.playField.healthBar.visible = false;
	game.playField.tst.visible = false;
}

function onUpdate(elapsed)
{
}

function onBeat()
{
}