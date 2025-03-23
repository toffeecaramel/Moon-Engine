package moon.game.obj;

import flixel.graphics.FlxGraphic;

class HealthIcon extends MoonSprite
{
    public var icon(default, set):String;
    public function new()
    {
        super();    
    }

    override public function update(elapsed:Float)
    {
        super.update(elapsed);
    }

    /**
     * Will update the icon's framed based on the given health.
     * @param health the health value.
     */
    public dynamic function updateAnim(health:Float)
    {
        if (health < 20)
            animation.curAnim.curFrame = 1;
        else
            animation.curAnim.curFrame = 0;
    }

    @:noCompletion public function set_icon(val:String)
    {
        this.icon = val;

        centerAnimations = true;
        final char = (Paths.fileExists('assets/images/ingame/characters/$val')) ? val : 'dummy';
        
        loadGraphic(Paths.image('ingame/characters/$char/icon'), true, 150, 150);

        animation.add('icon', [0, 1], 0, false);
		playAnim('icon');
		scrollFactor.set();

        updateHitbox();
        return val;
    }
}