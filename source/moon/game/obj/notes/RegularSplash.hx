package moon.game.obj.notes;

import flixel.FlxG;
import openfl.display.BlendMode;

class RegularSplash extends MoonSprite
{
    public var skin(default, set):String;
    public var data:Int;

    public function new(skin:String, data:Int = 0):Void
    {
        super();
        
        this.data = data;
        this.skin = skin;
    }

    override public function update(elapsed:Float){super.update(elapsed);}

    public function spawn():Void
    {
        playAnim('splash' + FlxG.random.int(1, this.animation.getAnimationList().length - 1), true);
        if(this.alpha <= 0.1) alpha = 1;
        visible = active = true;
    }

    @:noCompletion public function set_skin(skn:String):String
    {
        skin = skn;
        _updtGraphics();
        return skn;
    }

    private function _updtGraphics()
    {
        animation.onFinish.add((anim) -> visible = active = false);
        alpha = 0.0001;
        centerAnimations = true;
    }
}
