import flixel.FlxG;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import moon.dependency.MoonSprite;

var itssojoever:Array<MoonSprite> = [];
function onCreate()
{
	final p = 'ingame/stages/stage-erect/';

	var yummy = new MoonSprite(1300, -400).loadGraphic(Paths.image(p + 'backDark'));
	background.add(yummy);

	//what
	var crowdplexus = new MoonSprite(1000);
	crowdplexus.frames = Paths.getSparrowAtlas(p + 'crowd');
	crowdplexus.animation.addByPrefix('woops', 'Symbol 2 instance 1', 12, true);
	crowdplexus.playAnim('woops');
	background.add(crowdplexus);
	
	var bgStage = new MoonSprite(-200,-500).loadGraphic(Paths.image(p + 'bg'));
	background.add(bgStage);
	
	var server = new MoonSprite(20, -100).loadGraphic(Paths.image(p + 'server'));
	background.add(server);
	
	final lights = ['lightgreen', 'lightred', 'lightAbove', 'brightLightSmall', 'orangeLight'];
	
	for(i in 0...lights.length)
	{
		var light = new MoonSprite().loadGraphic(Paths.image(p + lights[i]));
		
		switch(lights[i])
		{
			case 'lightgreen': light.setPosition(200, -60);
			case 'lightred': light.setPosition(270, 270);
			case 'lightAbove': light.setPosition(1405, -450);
			case 'brightLightSmall':
				light.scrollFactor.set(1.2, 1.2);
				light.setPosition(1505, -460);
			case 'orangeLight': light.setPosition(340, -340);
		}
		
		light.blend = 0;

		(lights[i] != 'lightAbove') ? background.add(light) : itssojoever.push(light);
	}
	
	//background.add(background.spectators);
	background.add(background.opponents);
	background.add(background.players);
	
	var upperStuff = new MoonSprite(-160, -470).loadGraphic(Paths.image(p + 'lights'));
	background.add(upperStuff);

	for(light in itssojoever) background.add(light);

	for(obj in background.members) obj.antialiasing = true;
}

function onPostCreate()
{
	background.cameraSettings = {
		zoom: 0.9,
        startX: 840,
        startY: 150
	};
	
	background.opponents.setPosition(400, -200);
	background.spectators.setPosition(830);
	background.players.setPosition(1080, -70);

	background.adjustGroupColor(background.players, {hue: 12, saturation: 0, brightness: -23, contrast: 7});
	background.adjustGroupColor(background.spectators, {hue: -9, saturation: 0, brightness: -30, contrast: -4});
	background.adjustGroupColor(background.opponents, {hue: -32, saturation: 0, brightness: -33, contrast: -23});
}