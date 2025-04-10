package moon.game.obj.notes;

import flixel.FlxG;
import moon.dependency.scripting.MoonScript;
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
     * E.G; `MISSED, GOT_HIT, TOO_LATE` etc.
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
        this.direction = direction;
        this.time = time;
        this.type = type;
        centerAnimations = true;

        script = new MoonScript();
        script.load('assets/images/ingame/UI/notes/$skin/noteskin.hx');
        script.set("staticNote", this);

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
            this.x = receptor.x + (receptor.width - this.width) * 0.5;
        }
    }

    private function _updateGraphics():Void
    {
        final curSkin = (type != 'default' && Paths.fileExists('assets/images/ingame/UI/notes/$type')) ? type : skin;
        final dir:String = MoonUtils.intToDir(direction);

        script.get("createStaticNote")(curSkin, dir);
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