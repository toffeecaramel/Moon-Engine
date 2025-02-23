package moon.game.obj.notes;

import flixel.group.FlxGroup.FlxTypedGroup;
import moon.dependency.scripting.MoonScript;
import flixel.group.FlxSpriteGroup;

class Receptor extends FlxSpriteGroup
{
    public var direction:Int = 0;
    public var isCPU:Bool = false;
    @:isVar public var skin(default, set):String = 'v-slice';
    public var conductor:Conductor;
    public var strumNote:MoonSprite = new MoonSprite();
    public var script:MoonScript;
    
    public var notesGroup:FlxTypedGroup<MoonSprite> = new FlxTypedGroup<MoonSprite>();
    public var sustainsGroup:FlxTypedGroup<NoteSustain> = new FlxTypedGroup<NoteSustain>();

    public function new(x:Float, y:Float, ?skin:String = 'v-slice', direction:Int, ?isCPU:Bool = false, conductor:Conductor)
    {
        this.direction = direction;
        this.isCPU = isCPU;
        this.conductor = conductor;

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
                final confirm = '$dir-confirm';
                if(animation == confirm) strumNote.playAnim('$dir-press');
            }
        });

        script.get("createStrumNote")();
        strumNote.updateHitbox();
    }

    public function onNoteHit(judgement:String = 'sick')
    {
        final dir = MoonUtils.intToDir(direction);
        strumNote.playAnim('$dir-confirm', true);
    }

    @:noCompletion public function set_skin(skin:String):String
    {
        this.skin = skin;
        _updtGraphics();
        return skin;
    }
}