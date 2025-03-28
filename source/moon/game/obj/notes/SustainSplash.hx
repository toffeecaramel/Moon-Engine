package moon.game.obj.notes;

import openfl.display.BlendMode;

class SustainSplash extends MoonSprite
{
    @:isVar public var skin(default, set):String;
    public var data:Int;

    /**
     * Creates a hold note splash instance
     * @param skin skin for it.
     * @param data direction data (0, 1, 2...)
     */
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

    /**
     * Updates all the animations to the current skin.
     */
    private function _updtGraphics()
    {
        this.alpha = 0.0001;
        this.updateHitbox();
        this.centerAnimations = true;
    }

    public var isOnLoop:Bool;

    /**
     * Spawns a hold note splash, note that if this function gets called again, the animation will not reset.
     */
    public function spawn()
    {
        // just a check for making the animation not loop if the function is called again
        if(!isOnLoop)
        {
            isOnLoop = true;
            if (this.alpha < 0.1) this.alpha = 1;
            this.visible = this.active = true;
            this.playAnim('pre', true);
        }
    }

    /**
     * Despawns the note splash.
     * @param insta if true, it'll disappear instantly. Else, it'll play the end animation and then disappear
     */
    public function despawn(insta:Bool)
    {
        if(isOnLoop)
        {
            isOnLoop = false;
            if(insta) this.active = this.visible = false;
            else this.playAnim('${MoonUtils.intToDir(data)}-end', true);
        }
    }
}