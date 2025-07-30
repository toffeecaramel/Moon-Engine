import flixel.FlxG;
import flxanimate.FlxAnimate;

var fuckers:FlxAnimate;
function onPostCreate()
{
	//TODO: naughtyness shit
	FlxG.sound.cache(Paths.getPath("music/results/bf/PERFECT.ogg", "SOUND"));
	fuckers = new FlxAnimate();
    fuckers.loadAtlas(Paths.getPath("images/ingame/results/bf/PERFECT/bed", null));
    results.background.add(fuckers);

    fuckers.visible = false;
    fuckers.anim.addBySymbol("intro", "boyfriend perfect rank", 24, false);
    fuckers.anim.onComplete.add(() -> fuckers.anim.play("intro", true, false, 120));
}

function onIntroEnd()
{
	FlxG.sound.playMusic(Paths.sound('results/bf/PERFECT', 'music'));
	fuckers.visible = true;
	fuckers.anim.play("intro", true);
	//fuckers.screenCenter();
	fuckers.setPosition(1385, 370);
}