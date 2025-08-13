import flixel.FlxG;
import flxanimate.FlxAnimate;

var fuckers:FlxAnimate;
function onPostCreate()
{	
	fuckers = new FlxAnimate();
    fuckers.loadAtlas(Paths.getPath("images/ingame/results/bf/EXCELLENT/bfgf"));
    results.background.add(fuckers);

    fuckers.visible = false;
    fuckers.anim.addBySymbol("intro", "boyfriend perfect rank", 24, false);
    fuckers.anim.onComplete.add(() -> fuckers.anim.play("bf results excellent", true, false, 29));
	
	FlxG.sound.playMusic(Paths.sound('results/bf/EXCELLENT-intro', 'music'), 1, false);
	
	FlxG.sound.music.onComplete = () -> {
		FlxG.sound.playMusic(Paths.sound('results/bf/EXCELLENT', 'music'));
	}
}

function onIntroEnd()
{
	fuckers.visible = true;
	fuckers.anim.play("intro", true);
	//fuckers.screenCenter();
	fuckers.setPosition(1329, 429);
}