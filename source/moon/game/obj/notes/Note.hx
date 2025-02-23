package moon.game.obj.notes;

import flixel.FlxG;
import sys.FileSystem;
import moon.dependency.scripting.MoonScript;
import sys.io.File;
import haxe.Json;
import flixel.FlxSprite;
import flixel.util.FlxColor;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;

enum NoteState 
{
    CHART_EDITOR;
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

    /**
     * The receptor in which the note will go to.
     */
    public var receptor:Receptor;

    /**
     * This note's sustain.
     */
    public var child:NoteSustain;

    public var conductor:Conductor;
    public var script:MoonScript;

    /**
     * Creates a note on screen.
     * @param direction
     * @param time
     * @param type
     * @param skin
     * @param duration
     * @param conductor
     */
    public function new(direction, time, ?type = 'v-slice', ?skin = 'v-slice', duration, conductor) 
    {
        super();
        centerAnimations = true;
        this.direction = direction;
        this.time = time;
        this.type = type;

        script = new MoonScript();
        script.set("staticNote", this);
        script.load('assets/images/ingame/UI/notes/$skin/noteskin.hx');

        this.skin = skin;
        this.duration = duration;
        this.conductor = conductor;
    }

    override public function update(dt:Float):Void
    {
        super.update(dt);
        if((receptor != null || state != CHART_EDITOR) && this.state == NONE)
        {
            final downscrollLogic:Bool = (receptor.y > FlxG.height / 2);
            final time = (this.time - conductor.time);
            this.visible = true;
            this.y = (downscrollLogic) ? receptor.y - time * speed : receptor.y + time * speed;
            if(child != null) child.downscroll = downscrollLogic;
            this.x = receptor.x;

            //TODO: Remove this, its just a placeholder for testing purposes.
            if(this.time - conductor.time <= 0)
            {
                this.state = GOT_HIT;
                this.active = false;
                this.visible = false;
            }
        }
    }

    private function _updateGraphics():Void
    {
        final curSkin = (type != 'default' && FileSystem.exists('assets/images/ingame/UI/notes/$type')) ? type : skin;
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