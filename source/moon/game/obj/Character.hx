package moon.game.obj;

import flixel.FlxG;

using StringTools;

typedef CharacterData = 
{
    var isPlayer:Bool;
    var flipX:Bool;
    var camOffsets:Array<Float>;
    var healthbarColors:Array<Int>;
    var danceFrequency:Int;
    var animations:Array<Paths.AnimationData>;
}

class Character extends MoonSprite
{
    public var conductor:Conductor;
    public var character(default, set):String;
    public var isPlayer(default,set):Bool;

    public var data:CharacterData;
    public var idleAnims:Array<String>;
    
    public var animationHold:Float = 0;
    var danceIndex:Int = 0;
    var lastDanceBeat:Int = -1;

    /**
     * Creates a character on the screen.
     * @param x         X Position.
     * @param y         Y Position.
     * @param character The character name.
     * @param conductor The conductor instance.
     */
    public function new(?x:Float = 0, ?y:Float = 0, ?character:String = 'dad', conductor:Conductor)
    {
        super(x, y);
        this.conductor = conductor;
        this.character = character;
        conductor.onBeat.add(checkDance);
    }
    
    public function flipLeftRight():Void 
    {
        final oldRight = animation.getByName('singRIGHT').frames;
        animation.getByName('singRIGHT').frames = animation.getByName('singLEFT').frames;
        animation.getByName('singLEFT').frames = oldRight;

        if (animation.getByName('singRIGHTmiss') != null) 
        {
            final oldMiss = animation.getByName('singRIGHTmiss').frames;
            animation.getByName('singRIGHTmiss').frames = animation.getByName('singLEFTmiss').frames;
            animation.getByName('singLEFTmiss').frames = oldMiss;
        }
    }

    public function checkDance(curBeat:Float)
    {
        if (animation.curAnim == null) return;
        if (animation.curAnim.name.startsWith('sing') || animation.curAnim.name.startsWith('miss'))
            animationHold += conductor.stepCrochet;
        var beatInt = Std.int(curBeat);
        if ((animation.curAnim.name.startsWith("idle") || animation.curAnim.name.startsWith("dance"))
            && (beatInt % data.danceFrequency == 0) && (beatInt != lastDanceBeat))
        {
            lastDanceBeat = beatInt;
            this.dance(true);
        }
    }
        
    override public function update(elapsed:Float)
    {        
        if (animationHold >= conductor.stepCrochet * 3) 
        {
            dance(true);
            animationHold = 0;
        }
        super.update(elapsed);
    }

    public function dance(?force:Bool = false) 
    {
        if (idleAnims != null && idleAnims.length > 0)
        {
            playAnim(idleAnims[danceIndex], force);
            danceIndex = (danceIndex + 1) % idleAnims.length;
        }
        else
        {
            if(animation.exists("idle-0"))
            {
                playAnim("idle-0", force);
                danceIndex = 0;
            }
        }
    }

    @:noCompletion public function set_character(char:String):String
    {
        if(!Paths.fileExists('assets/images/ingame/characters/$char/data.json')) char = 'darnell';
        
        this.character = char;
        data = cast Paths.JSON('ingame/characters/$char/data');
        this.frames = Paths.getSparrowAtlas('ingame/characters/$char/$char');

        idleAnims = [];

        for (i in 0...data.animations.length)
        {
            final anim = data.animations[i];
            (anim.indices != null)
            ? this.animation.addByIndices(anim.name, anim.prefix, anim.indices, '', anim.fps ?? 24, anim.looped ?? false)
            : this.animation.addByPrefix(anim.name, anim.prefix, anim.fps ?? 24, anim.looped ?? false);
            this.addOffset(anim.name, anim.x ?? 0, anim.y ?? 0);
            
            if(anim.name.startsWith("idle-"))
                idleAnims.push(anim.name);
        }
        this.playAnim("idle-0");
        return char;
    }

    @:noCompletion public function set_isPlayer(isPlyr:Bool):Bool
    {
        isPlayer = isPlyr;
        flipX = !flipX;
        flipLeftRight();
        return isPlyr;
    }
}