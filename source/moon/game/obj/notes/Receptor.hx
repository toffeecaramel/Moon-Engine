package moon.game.obj.notes;

import flixel.group.FlxGroup.FlxTypedGroup;
import moon.dependency.scripting.MoonScript;
import flixel.group.FlxSpriteGroup;

class Receptor extends FlxSpriteGroup
{
    /**
     * Skin used for the receptor, if you change it, it will be updated.
     */
    @:isVar public var skin(default, set):String = 'v-slice';

    /**
     * The direction data (e.g. 0, 1, 2, 3...)
     */
    public var data:Int = 0;

    /**
     * Whether is a CPU or not.
     */
    public var isCPU:Bool = false;

    /**
     * The player ID for this. can be opponent, p1, etc...
     */
    public var playerID:String;

    /**
     * The conductor for this class.
     */
    public var conductor:Conductor;

    /**
     * The strum note.
     */
    public var strumNote:StrumNote;

    /**
     * The note splash.
     */
    public var splash:RegularSplash;

    /**
     * The sustain note splash (when holding one.)
     */
    public var sustainSplash:SustainSplash;

    /**
     * Script for the noteskins.
     */
    public var script:MoonScript;
    
    /**
     * Group for the notes on this receptor.
     */
    public var notesGroup:FlxTypedSpriteGroup<MoonSprite> = new FlxTypedSpriteGroup<MoonSprite>();

    /**
     * Group for the sustain pieces on this receptor.
     */
    public var sustainsGroup:FlxTypedSpriteGroup<NoteSustain> = new FlxTypedSpriteGroup<NoteSustain>();

    /**
     * Group for the notes on this receptor.
     */
    public var splashGroup:FlxTypedSpriteGroup<MoonSprite> = new FlxTypedSpriteGroup<MoonSprite>();

    /**
     * Creates a receptor on your desired position with skin and other data stuff.
     * @param x         X Position
     * @param y         Y Position
     * @param skin      Skin for it (default is v-slice)
     * @param data      Direction data (E.G. 0, 1, 2, 3...)
     * @param isCPU     Whether is CPU or not.
     * @param playerID  The player ID for this. can be opponent, p1, etc...
     * @param conductor The conductor, useful for tracking time n stuff.
     */
    public function new(x:Float, y:Float, ?skin:String = 'v-slice', data:Int, ?isCPU:Bool = false, playerID:String, conductor:Conductor)
    {
        this.data = data;
        this.isCPU = isCPU;
        this.playerID = playerID;
        this.conductor = conductor;
        
        //load script
        script = new MoonScript();
        script.load('assets/images/ingame/UI/notes/$skin/noteskin.hx');
        script.set("this", this);

        super(x, y);

        this.skin = skin;
    }

    private function _updtGraphics()
    {
        // -- Create Strum Arrow -- //

        if(strumNote != null) strumNote.kill();
        strumNote = new StrumNote(skin, data, isCPU);
        add(strumNote);
        
        script.set("strumNote", strumNote);

        // -- Create Note Splash -- //

        if(splash != null) splash.kill();
        splash = new RegularSplash(skin, data);
        splashGroup.add(splash);

        script.set("splash", splash);
        
        // -- Create Sustain Splash -- //

        if(sustainSplash != null) sustainSplash.kill();
        sustainSplash = new SustainSplash(skin, data);
        splashGroup.add(sustainSplash);

        script.set("sustainSplash", sustainSplash);
        
        script.call("createReceptor");
        strumNote.updateHitbox();
    }

    /**
     * Called upon note hittin.
     * @param note      The note that got hit.
     * @param judgement The judgement when hitting the note.
     * @param isSustain Whether or not is a sustain note.
     */
    public function onNoteHit(?note:Note, judgement:String = 'sick', isSustain:Bool = false)
    {
        // set positions
        final dir = MoonUtils.intToDir(data);
        final strumCenterX = strumNote.x + strumNote.width / 2;
        final strumCenterY = strumNote.y + strumNote.height / 2;
        
        // then play anims
        strumNote.playAnim('$dir-confirm', true);
        if(judgement == 'sick' && !isCPU && !isSustain)
        {
            splash.setPosition(strumCenterX - splash.width / 2, strumCenterY - splash.height / 2);
            splash.spawn();
        }
        
        if(isSustain)
        {
            sustainSplash.setPosition(strumCenterX - sustainSplash.width / 2, strumCenterY - sustainSplash.height / 2);
            sustainSplash.spawn();
        }

        if(script.exists('onNoteHit')) script.get('onNoteHit')(note, judgement, isSustain);
    }

    @:noCompletion public function set_skin(skin:String):String
    {
        this.skin = skin;
        _updtGraphics();
        return skin;
    }
}