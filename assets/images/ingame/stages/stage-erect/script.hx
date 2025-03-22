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
			case 'lightAbove': light.setPosition(1375, -450);
			case 'brightLightSmall':
				light.scrollFactor.set(1.2, 1.2);
				light.setPosition(1475, -460);
			case 'orangeLight': light.setPosition(290, -340);
		}
		
		light.blend = 0;

		(lights[i] != 'lightAbove') ? background.add(light) : itssojoever.push(light);
	}
	
	background.add(background.spectators);
	background.add(background.opponents);
	background.add(background.players);
	
	var upperStuff = new MoonSprite(-160, -470).loadGraphic(Paths.image(p + 'lights'));
	background.add(upperStuff);
	for(light in itssojoever) background.add(light);
}

function onPostCreate()
{
	background.cameraSettings = {
		zoom: 0.3,
        startX: 780,
        startY: 100
	};
	
	background.opponents.setPosition(420);
	background.spectators.setPosition(770);
	background.players.setPosition(1020);
}

function onUpdate(elapsed)
{

}

function onBeat()
{

}