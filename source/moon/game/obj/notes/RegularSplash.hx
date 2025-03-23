package moon.game.obj.notes;

import flixel.FlxG;
import openfl.display.BlendMode;
import moon.dependency.scripting.MoonScript;

class RegularSplash extends MoonSprite
{
    private var script:MoonScript;

    public var totalAnims(default, set):Int = 2;
    public var skin(default, set):String;
    public var data:Int;

    public function new(skin:String, data:Int = 0):Void
    {
        super();
        
        script = new MoonScript();
        this.data = data;
        this.skin = skin;
    }

    override public function update(elapsed:Float){super.update(elapsed);}

    public function spawn():Void
    {
        if(this.alpha <= 0.1) alpha = 1;
        visible = active = true;

        playAnim('splash${FlxG.random.int(1, totalAnims)}', true);
    }

    @:noCompletion public function set_skin(skn:String):String
    {
        skin = skn;
        _updtGraphics();
        return skn;
    }

    @:noCompletion public function set_totalAnims(total:Int)
    {
        this.totalAnims = total;
        this.animation.destroyAnimations();
        final direction = MoonUtils.intToDir(data);

        for (i in 0...totalAnims)
            animation.addByPrefix('splash${i+1}', '${direction}${i+1}0', 32, false);

        return this.totalAnims;
    }

    private function _updtGraphics()
    {
        frames = Paths.getSparrowAtlas('ingame/UI/notes/$skin/splash');
        alpha = 0.0001;
        animation.onFinish.add((anim) -> visible = active = false);
        updateHitbox();
        centerAnimations = true;
    }
}
