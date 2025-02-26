package moon.game.obj.notes;

import flixel.group.FlxGroup.FlxTypedGroup;
import moon.dependency.scripting.MoonScript;
import flixel.group.FlxSpriteGroup;

class Receptor extends FlxSpriteGroup
{
    @:isVar public var skin(default, set):String = 'v-slice';
    public var direction:Int = 0;
    public var isCPU:Bool = false;
    public var playerID:String;

    public var strumNote:MoonSprite = new MoonSprite();
    public var splash:RegularSplash;

    public var conductor:Conductor;
    public var script:MoonScript;
    
    public var notesGroup:FlxTypedGroup<MoonSprite> = new FlxTypedGroup<MoonSprite>();
    public var sustainsGroup:FlxTypedGroup<NoteSustain> = new FlxTypedGroup<NoteSustain>();
    public var splashGroup:FlxTypedGroup<RegularSplash> = new FlxTypedGroup<RegularSplash>();

    public function new(x:Float, y:Float, ?skin:String = 'v-slice', direction:Int, ?isCPU:Bool = false, playerID:String, conductor:Conductor)
    {
        this.direction = direction;
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
        splashGroup.add(splash);
    }

    private function _updtGraphics()
    {
        final dir = MoonUtils.intToDir(direction);
        strumNote.centerAnimations = true;
        strumNote.frames = Paths.getSparrowAtlas('ingame/UI/notes/$skin/strumline');
        strumNote.animation.addByPrefix('$dir-static', '$dir-static', 24, true);
        strumNote.animation.addByPrefix('$dir-press', '$dir-press', 24, false);
        strumNote.animation.addByPrefix('$dir-confirm', '$dir-confirm', 24, false);

        strumNote.playAnim('$dir-static', true);

        strumNote.animation.onFinish.add(function(animation:String)
        {
            if(!this.isCPU)
            {
                if(animation == '$dir-confirm') strumNote.playAnim('$dir-press');
            }
            else
            {
                if(animation == '$dir-confirm') strumNote.playAnim('$dir-static');
            }
        });

        splash = new RegularSplash(skin, direction);
        script.get("createStrumNote")();
        strumNote.updateHitbox();
    }

    public function onNoteHit(judgement:String = 'sick', isSustain:Bool = false)
    {
        final dir = MoonUtils.intToDir(direction);
        strumNote.playAnim('$dir-confirm', true);
        if(judgement == 'sick' && !isCPU && !isSustain)
        {
            final strumCenterX = strumNote.x + strumNote.width / 2;
            final strumCenterY = strumNote.y + strumNote.height / 2;
            splash.setPosition(strumCenterX - splash.width / 2, strumCenterY - splash.height / 2);
            splash.spawn();
        }
    }

    @:noCompletion public function set_skin(skin:String):String
    {
        this.skin = skin;
        _updtGraphics();
        return skin;
    }
}