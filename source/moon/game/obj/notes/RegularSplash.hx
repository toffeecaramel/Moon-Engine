package moon.game.obj.notes;

import flixel.FlxG;
import openfl.display.BlendMode;
import moon.dependency.scripting.MoonScript;

class RegularSplash extends MoonSprite
{
    private var script:MoonScript;
    public function new(skin:String, data:Int = 0):Void
    {
        super();

        frames = Paths.getSparrowAtlas('ingame/UI/notes/$skin/splash');

        script = new MoonScript();
        script.set("splash", this);
        script.load('assets/images/ingame/UI/notes/$skin/noteskin.hx');

        alpha = 0.0001;
        final direction = MoonUtils.intToDir(data);
        animation.addByPrefix('splash1', '${direction}10', 32, false);
        animation.addByPrefix('splash2', '${direction}20', 32, false);
        animation.onFinish.add((anim) -> visible = active = false);
        blend = BlendMode.ADD;
        updateHitbox();
        centerAnimations = true;
    }

    override public function update(elapsed:Float){super.update(elapsed);}

    public function spawn():Void
    {
        if(this.alpha <= 0.1) alpha = 1;
        visible = active = true;
        angle = FlxG.random.float(-360, 360);

        playAnim('splash${FlxG.random.int(1, 2)}', true);

        script.get("createSplash")();
    }
}
