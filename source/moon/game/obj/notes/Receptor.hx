package moon.game.obj.notes;

import flixel.group.FlxGroup.FlxTypedGroup;
import moon.dependency.scripting.MoonScript;
import flixel.group.FlxSpriteGroup;

class Receptor extends FlxSpriteGroup
{
    @:isVar public var skin(default, set):String = 'v-slice';
    public var data:Int = 0;
    public var isCPU:Bool = false;
    public var playerID:String;

    public var strumNote:MoonSprite = new MoonSprite();
    public var splash:RegularSplash;
    public var sustainSplash:SustainSplash;

    public var conductor:Conductor;
    public var script:MoonScript;
    
    public var notesGroup:FlxTypedSpriteGroup<MoonSprite> = new FlxTypedSpriteGroup<MoonSprite>();
    public var sustainsGroup:FlxTypedSpriteGroup<NoteSustain> = new FlxTypedSpriteGroup<NoteSustain>();
    public var splashGroup:FlxTypedSpriteGroup<MoonSprite> = new FlxTypedSpriteGroup<MoonSprite>();

    public function new(x:Float, y:Float, ?skin:String = 'v-slice', data:Int, ?isCPU:Bool = false, playerID:String, conductor:Conductor)
    {
        this.data = data;
        this.isCPU = isCPU;
        this.conductor = conductor;
        this.playerID = playerID;
        
        script = new MoonScript();

        script.set("this", this);
        script.set("receptor", strumNote);

        script.load('assets/images/ingame/UI/notes/$skin/noteskin.hx');

        super(x, y);

        this.skin = skin;

        add(strumNote);
    }

    private function _updtGraphics()
    {
        // -- Create Strum Arrow -- //
        final dir = MoonUtils.intToDir(data);
        strumNote.centerAnimations = true;
        strumNote.frames = Paths.getSparrowAtlas('ingame/UI/notes/$skin/strumline');
        strumNote.animation.addByPrefix('$dir-static', '$dir-static', 24, true);
        strumNote.animation.addByPrefix('$dir-press', '$dir-press', 24, false);
        strumNote.animation.addByPrefix('$dir-confirm', '$dir-confirm', 24, false);

        strumNote.playAnim('$dir-static', true);

        strumNote.animation.onFinish.add(function(animation:String)
        {
            if(animation == '$dir-confirm') strumNote.playAnim((!this.isCPU) ? '$dir-press' : '$dir-static');
        });

        // -- Create Note Splash -- //

        if(splash != null) splash.kill();
        splash = new RegularSplash(skin, data);
        splashGroup.add(splash);
        
        // -- Create Sustain Splash -- //

        if(sustainSplash != null) sustainSplash.kill();
        sustainSplash = new SustainSplash(skin, data);
        splashGroup.add(sustainSplash);
        
        script.get("createStrumNote")();
        strumNote.updateHitbox();
    }

    public function onNoteHit(?note:Note, judgement:String = 'sick', isSustain:Bool = false)
    {
        final dir = MoonUtils.intToDir(data);
        final strumCenterX = strumNote.x + strumNote.width / 2;
        final strumCenterY = strumNote.y + strumNote.height / 2;

        strumNote.playAnim('$dir-confirm', true);
        if(judgement == 'sick' && !isCPU && !isSustain)
        {
            splash.setPosition(strumCenterX - splash.width / 2, strumCenterY - splash.height / 2);
            splash.spawn();
        }

        if(isSustain)
        {
            sustainSplash.x = strumCenterX - sustainSplash.width / 2; 
            sustainSplash.y = strumCenterY - sustainSplash.height / 2;
            if (note.duration >= 30) sustainSplash.spawn();
        }
    }

    @:noCompletion public function set_skin(skin:String):String
    {
        this.skin = skin;
        _updtGraphics();
        return skin;
    }
}