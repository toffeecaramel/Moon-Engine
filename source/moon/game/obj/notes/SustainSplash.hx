package moon.game.obj.notes;

import openfl.display.BlendMode;

class SustainSplash extends MoonSprite
{
    @:isVar public var skin(default, set):String;
    public var data:Int;

    public function new(skin:String, data:Int = 0)
    {
        super();
        this.data = data;
        this.skin = skin;
        this.alpha = 0.0001;
    }

    @:noCompletion public function set_skin(skn:String):String
    {
        skin = skn;
        _updtGraphics();
        return skn;
    }

    var direction:String;
    private function _updtGraphics()
    {
        frames = Paths.getSparrowAtlas('ingame/UI/notes/$skin/holdSplash');
        direction = MoonUtils.intToDir(data);

        this.animation.addByPrefix('pre', 'pre', 24, false);
        this.animation.addByPrefix('$direction-loop', '$direction-loop', 20, true);
        this.animation.addByPrefix('$direction-end', '$direction-end', 24, false);

        this.animation.onFinish.add(function(anim:String)
        {
            if(anim == '$direction-end') this.visible = this.active = false;
            else if (anim == 'pre') this.playAnim('$direction-loop', true);
        });
        this.blend = BlendMode.ADD;
        this.alpha = 0.0001;
        this.updateHitbox();
        this.centerAnimations = true;
    }

    public var isOnLoop:Bool;
    public function spawn()
    {
        if(!isOnLoop)
        {
            isOnLoop = true;
            if (this.alpha < 0.1) this.alpha = 1;
            this.visible = this.active = true;
            this.playAnim('pre', true);
        }
    }

    public function despawn(isCPU:Bool)
    {
        if(isOnLoop)
        {
            isOnLoop = false;
            if(isCPU) this.active = this.visible = false;
            else this.playAnim('$direction-end', true);
        }
    }
}