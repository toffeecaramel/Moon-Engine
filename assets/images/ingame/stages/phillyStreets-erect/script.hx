import flixel.FlxG;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import moon.dependency.MoonSprite;


function onCreate()
{
	final p = 'ingame/stages/phillyStreets-erect/';
	
}

function onPostCreate()
{
	background.cameraSettings = {
		zoom: 0.9,
        startX: 780,
        startY: 100
	};

	game.camGAME.handheldVFX = {xIntensity: 2.2, yIntensity: 3.2, distance: 11, speed: 0.3};

	background.spectators.setPosition(2000, -5);
	background.spectators.scrollFactor.set(0.65, 0.65);
	background.spectators.scale.set(0.7, 0.7);

	background.players.setPosition(700, -200);
}

var carTimer:Float = 0;
function onUpdate(elapsed)
{

}

function onBeat()
{
}