import flixel.FlxG;
import animate.FlxAnimate;
import animate.FlxAnimateFrames;

var fuckers:FlxAnimate;
function onPostCreate()
{
	fuckers = new FlxAnimate();
    fuckers.frames = FlxAnimateFrames.fromAnimate(Paths.getPath("images/ingame/results/bf/LOSS/bfgf"));
    results.background.add(fuckers);

    fuckers.visible = false;
    fuckers.anim.addBySymbol("intro", "LOSS Animation", 24, false);
    fuckers.anim.onFinish.add(() -> fuckers.anim.play("LOSS Animation", true, false, 160));
	
	FlxG.sound.playMusic(Paths.sound('results/bf/LOSS-intro', 'music'), 1, false);
	
	FlxG.sound.music.onComplete = () -> {
		FlxG.sound.playMusic(Paths.sound('results/bf/LOSS', 'music'));
	}
}

function onIntroEnd()
{
	fuckers.visible = true;
	fuckers.anim.play("intro", true);
	//fuckers.screenCenter();
	fuckers.setPosition(670, 410);
}