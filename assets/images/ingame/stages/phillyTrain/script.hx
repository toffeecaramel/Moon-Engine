import flixel.FlxG;
import flixel.math.FlxMath;
import flixel.addons.display.FlxBackdrop;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import moon.dependency.MoonSprite;

var city:MoonSprite;
var buildingWindow:MoonSprite;

final p = 'ingame/stages/phillyTrain/';
function onCreate()
{	
	var sky = new MoonSprite(-180, -130).loadGraphic(Paths.image(p + 'sky'));
	sky.scrollFactor.set(0, 0);
	background.add(sky);
	
	city = new MoonSprite(-590, -430).loadGraphic(Paths.image(p+'city'));
	city.scrollFactor.set(0.85, 0.85);
	background.add(city);
	
	buildingWindow = new MoonSprite();
	buildingWindow.loadGraphic(Paths.image(p+'win0'));
	buildingWindow.scrollFactor.set(0.85, 0.85);
	background.add(buildingWindow);
	buildingWindow.visible = false;
	
	var ground = new MoonSprite(-770, -500).loadGraphic(Paths.image(p + 'street'));
	background.add(ground);
	
	background.add(background.spectators);
	background.add(background.opponents);
	background.add(background.players);
}

function onPostCreate()
{
	background.cameraSettings = {
		zoom: 1,
        startX: 0,
        startY: 0
	};
	
	game.camGAME.zoom = 0.85;
	background.opponents.setPosition(-500, -100);
}

function onUpdate(elapsed)
{
	buildingWindow.alpha = FlxMath.lerp(buildingWindow.alpha, 0, elapsed);
}

function onBeat(beat)
{
	// basically call on every first beat
	if((beat % game.playField.conductor.numerator) == 0)
	{
		buildingWindow.visible = true;
		buildingWindow.loadGraphic(Paths.image(p + 'win' + FlxG.random.int(0, 4)));
		buildingWindow.setPosition(city.x, city.y);
		buildingWindow.alpha = 1;
	}
}