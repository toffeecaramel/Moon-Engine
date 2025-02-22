package moon.game.obj.notes;

import moon.dependency.scripting.MoonScript;
import sys.io.File;
import haxe.Json;
import flixel.FlxSprite;
import flixel.util.FlxColor;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;

enum NoteState 
{
    GOT_HIT;
    TOO_LATE;
    MISSED;
    NONE;
}
class Note extends MoonSprite
{
    /**
     * Defines the note state.
     * E.G `MISSED, GOT_HIT, TOO_LATE` etc.
     */
    public var state:NoteState = NONE;

    /**
     * The note's direction.
     */
    public var direction:Int = 0;

    /**
     * The note's time in miliseconds.
     */
    public var time:Float = 0;

    /**
     * The note's speed, used for sustain length calculations.
     */
    public var speed:Float = 1;

    /**
     * The note's type.
     */
    public var type:String = 'default';

    /**
     * The note's skin, usually based on how it's on settings.
     */
    public var skin(default, set):String = 'default';

    /**
     * The note's sustain duration.
     */
    public var duration:Float = 0;

    /**
     * The note's strumline, in which it's attached to
     */
    public var lane:String = 'P1';

    public var conductor:Conductor;
    public var script:MoonScript;

    /**
     * Creates a note on screen.
     * @param direction
     * @param time
     * @param type
     * @param skin
     * @param duration
     */
    public function new(direction, time, ?type = 'v-slice', ?skin = 'default', duration) 
    {
        super();
        centerAnimations = true;
        this.direction = direction;
        this.time = time;
        this.type = type;

        script.set("staticNote", this);
        script.load('assets/images/ingame/UI/notes/$skin/noteskin.hx');

        this.skin = skin;
        this.duration = duration;
    }

    override public function update(dt:Float):Void
    {
        super.update(dt);
        if(active && state == GOT_HIT) alpha = 0;
    }

    private function _updateGraphics():Void
    {
        final curSkin = (type != 'v-slice') ? skin : type;
        final dir:String = MoonUtils.intToDir(direction);

        frames = Paths.getSparrowAtlas('ingame/UI/notes/$curSkin/staticArrows');

        animation.addByPrefix(dir, '${dir}0', 24, true);
        animation.addByPrefix('$dir-hold', '${dir}-hold0', 24, true);
        animation.addByPrefix('$dir-holdEnd', '${dir}-holdend0', 24, true);

        script.get("createStaticNote")();

        updateHitbox();

        playAnim(dir);
    }

    @:noCompletion public function set_skin(skinName:String)
    {
        this.skin = skinName;
        _updateGraphics();
        return skinName;
    }
}