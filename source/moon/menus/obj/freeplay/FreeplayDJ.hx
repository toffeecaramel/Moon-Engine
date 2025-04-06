package moon.menus.obj.freeplay;

import moon.dependency.scripting.MoonScript;
import flxanimate.FlxAnimate;

class FreeplayDJ extends FlxAnimate
{
    /**
     * Timer used for playing AFK Animations.
     */
    public var AFK_TIMER:Float = 0;

    /**
     * Wheter or not to allow the dj to dance on beat.
     */
    public var canDance:Bool = false;

    /**
     * Script used for this DJ.
     */
    public var script:MoonScript;

    public function new(character:String = 'bf')
    {
        super();

        script = new MoonScript();
        script.load(Paths.getPath('images/menus/freeplay/$character/DJ.hx', TEXT));
        script.set('dj', this);
        if(script.exists('onCreate')) script.call('onCreate');
    }

    override public function update(elapsed:Float)
    {
        super.update(elapsed);
        AFK_TIMER += elapsed;

        if(script.exists('onUpdate')) script.get('onUpdate')(elapsed);
    }
}