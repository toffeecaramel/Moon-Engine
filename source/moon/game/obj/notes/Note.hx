package moon.game.obj.notes;

import moon.dependency.scripting.MoonScript;

/**
 * The state of a note in the game.
 */
enum NoteState 
{
    /**
     * Means that the note won't be updated in any way.
     */
    CHART_EDITOR;

    /**
     * When a note is hit.
     */
    GOT_HIT;

    /**
     * When a note is too late.
     */
    TOO_LATE;

    /**
     * When a note is missed.
     */
    MISSED;

    /**
     * None state.
     */
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

    private static var sharedScripts:Map<String, MoonScript> = new Map();

    public function new(direction:Int, time:Float, ?type:String = "default", ?skinName:String = "v-slice", 
        duration:Float, conductor:Conductor)
    {
        super();
        this.direction = direction;
        this.time = time;
        this.type = type;
        this.duration = duration;
        this.conductor = conductor;
        centerAnimations = true;
        
        this.skin = skinName;
    }

    private function _updateGraphics():Void
    {
        var curSkin = ((type != "default" || type != null) && Paths.exists('assets/images/ingame/UI/notes/$type')) ? type : skin;
        var dir = MoonUtils.intToDir(direction);

        if (!sharedScripts.exists(curSkin))
        {
            var wawa = new MoonScript();
            wawa.load('assets/images/ingame/UI/notes/$curSkin/noteskin.hx');
            sharedScripts.set(curSkin, wawa);
        }

        script = sharedScripts.get(curSkin);
        script.set("staticNote", this);
        script.get("createStaticNote")(curSkin, dir);
        updateHitbox();
        playAnim(dir);
    }

    @:noCompletion public function set_skin(skinName:String):String
    {
        this.skin = skinName;
        _updateGraphics();
        return skinName;
    }

    override public function update(dt:Float):Void
    {
        super.update(dt);
        updateNotePos();
    }

    public function updateNotePos()
    {
        if (receptor != null && state == NoteState.NONE)
        {
            visible = active = true;

            var timeDiff = (time - conductor.time);
            var ypos = receptor.y + timeDiff * speed;

            if (MoonSettings.callSetting('Downscroll')) ypos = receptor.y - timeDiff * speed;

            y = ypos;
            x = receptor.x + (receptor.width - width) * 0.5;

            if (child != null) child.downscroll = MoonSettings.callSetting('Downscroll');
        }
    }

    override function destroy():Void {
        child = null;
        super.destroy();
    }
}