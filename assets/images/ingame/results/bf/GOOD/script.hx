import flixel.FlxG;
import flxanimate.FlxAnimate;
import moon.dependency.MoonSprite;

var bf:FlxAnimate;
var gf:MoonSprite;
function onPostCreate()
{
	gf = new MoonSprite();
	gf.frames = Paths.getSparrowAtlas('ingame/results/bf/GOOD/resultGirlfriendGOOD');
    gf.animation.addByPrefix('appear', 'Girlfriend Good Anim', 24, false);
	gf.animation.onFinish.add((anim) -> {
		gf.playAnim('appear');
		gf.animation.curAnim.curFrame = 9;
	});
    results.background.add(gf);

	bf = new FlxAnimate();
    bf.loadAtlas(Paths.getPath("images/ingame/results/bf/GOOD/bf", null));
    results.background.add(bf);
    
    bf.anim.addBySymbol("intro", "Boyfriend Good Anim", 24, false);
    bf.anim.onComplete.add(() -> bf.anim.play("Boyfriend Good Anim", true, false, 14));
	
	bf.visible = gf.visible = false;
	
	FlxG.sound.playMusic(Paths.sound('results/bf/NORMAL', 'music'));
}

function onIntroEnd()
{
	gf.playAnim("appear", true);
	gf.setPosition(629, 323);
	
	bf.anim.play("intro", true);
	bf.setPosition(662, 361);
	bf.visible = gf.visible = true;
}