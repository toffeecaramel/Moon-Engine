import flixel.FlxG;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import moon.dependency.MoonSprite;

function onCreate()
{
	final p = 'ingame/stages/phillyStreets-erect/';
	
	var fg = new MoonSprite().loadGraphic(Paths.image(p + 'phillyForeground'));
	background.add(fg);

	background.add(background.opponents);
}

function onPostCreate()
{
	background.cameraSettings = {
		zoom: 0.9,
        startX: 10,
        startY: 10
	};

	background.opponents.setPosition(700, 340);
}

function onUpdate(elapsed)
{

}

function onBeat()
{
}