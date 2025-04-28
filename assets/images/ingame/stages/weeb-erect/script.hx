import flixel.FlxG;
import flixel.addons.display.FlxBackdrop;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;

import moon.dependency.MoonSprite;
import moon.game.obj.Character;
import moon.hardcoded_shaders.DropShadowShader;

final p = 'ingame/stages/weeb-erect/';

var shouldReverse:Bool = false;
function onCreate()
{	
	var back = new MoonSprite(400, 240).loadGraphic(Paths.image(p + 'weebSky'));
	back.scrollFactor.set(0.2, 0.2);
	background.add(back);
	
	var backTrees = new MoonSprite(0, 120).loadGraphic(Paths.image(p + 'weebBackTrees'));
	backTrees.scrollFactor.set(0.5, 0.5);
	background.add(backTrees);
	
	var school = new MoonSprite(28, 60).loadGraphic(Paths.image(p + 'weebSchool'));
	school.scrollFactor.set(0.75, 0.75);
	background.add(school);
	
	var street = new MoonSprite(-200, 6).loadGraphic(Paths.image(p + 'weebStreet'));
	background.add(street);
	
	var frontTreesBack = new MoonSprite(-160, -16).loadGraphic(Paths.image(p + 'weebTreesBack'));
	background.add(frontTreesBack);
	
	var frontTreesLeaves = new MoonSprite(-140, -190).loadGraphic(Paths.image(p + 'weebTrees'), true, 317, 82);
	frontTreesLeaves.animation.add('loopi', [0, 1, 2, 3, 4, 5, 6], 12, false); //loop to false cause we got a callback
	frontTreesLeaves.animation.onFinish.add((_) ->
	{
		shouldReverse = !shouldReverse;
		frontTreesLeaves.playAnim('loopi', true, shouldReverse);
	});
	frontTreesLeaves.playAnim('loopi');
	background.add(frontTreesLeaves);
	
	background.add(background.spectators);
	background.add(background.opponents);
	background.add(background.players);
	
	var petals = new MoonSprite(-70, 70);
	petals.frames = Paths.getSparrowAtlas(p + 'petals');
	petals.animation.addByPrefix('woopsii', 'PETALS ALL', 24, true);
	petals.centerAnimations = true;
	petals.playAnim('woopsii');
	background.add(petals);
	
	// thanks for not applying to the characters :pray:
	for(a in background.members)
		a.scale.set(6, 6);
}

function onPostCreate()
{
	background.cameraSettings = {
		zoom: 1,
        startX: 30,
        startY: 100
	};

	game.camHUD.pixelPerfectRender = game.camGAME.pixelPerfectRender = true;
	
	for(member in background.members) member.antialiasing = false; //just to make sure
	background.spectators.setPosition(-115, -30);
	background.opponents.setPosition(-530, 10);
	background.players.setPosition(386, 190);
	
	for (spec in background.spectators.members) addDropshadow(spec, background.spectators);
	for (opp in background.opponents.members) addDropshadow(opp, background.opponents);
	for (player in background.players.members) addDropshadow(player, background.players);
}

function addDropshadow(char:Character, charGroup:FlxSpriteGroup)
{
	var rim = new DropShadowShader();
	rim.setAdjustColor(-66, -10, 24, -23);
    rim.color = 0xFF52351d;
	rim.antialiasAmt = 0;
	rim.attachedSprite = char;
	rim.distance = 5;

	final cPath = 'assets/images/' + p + 'masks/' + char.character + '_mask.png';
	switch(charGroup)
	{
		case background.players:
			rim.angle = 90;
			char.shader = rim;

			rim.loadAltMask(cPath);
			rim.maskThreshold = 1;
			rim.useAltMask = true;

			char.animation.callback = () -> rim.updateFrameInfo(char.frame);

		case background.spectators:
			rim.setAdjustColor(-42, -10, 5, -25);
			rim.angle = 90;
			char.shader = rim;
			rim.distance = 3;
			rim.threshold = 0.3;

			rim.loadAltMask(cPath);
			rim.maskThreshold = 1;
			rim.useAltMask = true;

			char.animation.callback = () -> rim.updateFrameInfo(char.frame);

		case background.opponents:
			rim.angle = 90;
			char.shader = rim;

			rim.loadAltMask(cPath);
			rim.maskThreshold = 1;
			rim.useAltMask = true;

			char.animation.callback = () -> rim.updateFrameInfo(char.frame);
	}
}

function onUpdate(elapsed)
{
}

function onBeat()
{
}