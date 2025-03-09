import flixel.FlxG;
import flixel.tweens.FlxTween;
import moon.dependency.MoonSprite;

var animProgress:Int = 0;
var veryFastCar:MoonSprite;
var henchdudes:Array<MoonSprite> = [];
function onCreate()
{
	animProgress = 0;
	final p = 'ingame/stages/limo/';

	var back = new MoonSprite(-325, -200).loadGraphic(Paths.image(p + 'limoSunset'));
	back.scrollFactor.set(0.1, 0.1);
	background.add(back);

	var backDriver = new MoonSprite(120, 180);
	backDriver.frames = Paths.getSparrowAtlas(p + 'bgLimo');
	backDriver.animation.addByPrefix('drivin', 'background limo pink', 24, true);
	backDriver.playAnim('drivin',true);
	background.add(backDriver);
	
	for (i in 0...4)
	{
		var dancer = new MoonSprite(backDriver.x + 290 + (390 *i), backDriver.y - 380);
		dancer.frames = Paths.getSparrowAtlas(p + 'limoDancer');
		dancer.animation.addByIndices('danceLeft', 'bg dancer sketch PINK', [0, 1, 2, 3, 4, 5, 6, 7, 8], "", 24, false);
		dancer.animation.addByIndices('danceLeftPause', 'bg dancer sketch PINK', [9, 10, 11, 12, 13, 14], "", 24, false);
		dancer.animation.addByIndices('danceRight', 'bg dancer sketch PINK', [15, 16, 17, 18, 19, 20, 21, 22, 23], "",24, false);
		dancer.animation.addByIndices('danceRightPause', 'bg dancer sketch PINK', [24, 25, 26, 27, 28, 29], "",24, false);
		background.add(dancer);
		henchdudes.push(dancer);
	}
	
	var frontDriver = new MoonSprite(-150, 250);
	frontDriver.frames = Paths.getSparrowAtlas(p + 'limoDrive');
	frontDriver.animation.addByPrefix('ok', 'Limo stage', 24, true);
	frontDriver.playAnim('ok', true);
	background.add(frontDriver);

	veryFastCar = new MoonSprite(1600, 100).loadGraphic(Paths.image(p + 'fastCarLol'));
	veryFastCar.scale.set(0.8, 0.8);
	background.add(veryFastCar);
}

var carTimer:Float = 0;
function onUpdate(elapsed)
{
	carTimer += elapsed;
	if(carTimer >= FlxG.random.float(4, 10))
	{
		carTimer = 0;
		FlxG.sound.play(Paths.sound('stages/limo/carPass' + FlxG.random.int(0, 1), "sounds"));
		FlxTween.tween(veryFastCar, {x: -1200}, 0.13, {startDelay: 1, onComplete: (_) -> veryFastCar.x = 1600});
	}
}

final animsOrder:Array<String> = ['danceLeft', 'danceLeftPause', 'danceRight', 'danceRightPause'];
function onBeat()
{
	animProgress += 1;
	for (dancer in henchdudes)
	{
		if(animProgress > animsOrder.length - 1) animProgress = 0;
		dancer.playAnim(animsOrder[animProgress], true);
	}
}