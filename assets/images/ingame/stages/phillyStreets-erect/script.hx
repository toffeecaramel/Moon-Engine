import flixel.FlxG;
import flixel.addons.display.FlxBackdrop;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import moon.dependency.MoonSprite;

var trafficLights:MoonSprite;
function onCreate()
{
	final p = 'ingame/stages/phillyStreets-erect/';

	trafficLights = new MoonSprite(1900, 300);
	trafficLights.frames = Paths.getSparrowAtlas(p + 'phillyTraffic');
	trafficLights.animation.addByPrefix('gtr', 'greentored', 24, false);
	trafficLights.animation.addByPrefix('rtg', 'redtogreen', 24, false);
	trafficLights.playAnim('rtg', true);
	background.add(trafficLights);
	
	var fg = new MoonSprite().loadGraphic(Paths.image(p + 'phillyForeground'));
	background.add(fg);

	background.add(background.opponents);

	var smokeFront = new FlxBackdrop(Paths.image(p + 'mistFront'), 0x01);
	smokeFront.y = 220;
	smokeFront.alpha = 0.6;
	smokeFront.velocity.x = -125;
	smokeFront.blend = 0;
	smokeFront.scrollFactor.set(1.3, 1.2);
	background.add(smokeFront);

	FlxTween.tween(smokeFront, {y: smokeFront.y-34}, 3, {ease: FlxEase.quadInOut, type: 4});
}

function onPostCreate()
{
	background.cameraSettings = {
		zoom: 0.2,
        startX: 120,
        startY: 120
	};

	background.opponents.setPosition(700, 340);
	background.players.setPosition(1400, 340);
}

function onUpdate(elapsed)
{
}

function onBeat()
{
}