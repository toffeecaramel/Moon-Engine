package moon.game.obj;

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

    public var animationHold:Float = 0;

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
    
        if ((animation.curAnim.name.startsWith("idle") 
            || animation.curAnim.name.startsWith("dance"))
            && (Std.int(curBeat) % data.danceFrequency == 0))
            this.dance();
    }
        
    override public function update(elapsed:Float)
    {
        if (animation.curAnim != null && 
            (animation.curAnim.name.startsWith('sing') || animation.curAnim.name.startsWith('miss')))
            animationHold += elapsed;
        
        if (animationHold >= conductor.stepCrochet * 8) 
        {
            dance();
            animationHold = 0;
        }
    
        super.update(elapsed);
    }

    var danced:Bool = true;
    public function dance(?force:Bool = false) 
    {
        if (animation.getByName('danceLeft') != null && animation.getByName('danceRight') != null)
        {
            danced = !danced;
            playAnim((danced) ? 'danceRight' : 'danceLeft', force);
        }
        else playAnim('idle', force);
    }

    @:noCompletion public function set_character(char:String):String
    {
        this.character = char;
        data = cast Paths.JSON('ingame/characters/$char/data');
        this.frames = Paths.getSparrowAtlas('ingame/characters/$char/$char');

        for (i in 0...data.animations.length)
        {
            final anim = data.animations[i];
            this.animation.addByPrefix(anim.name, anim.prefix, anim.fps ?? 24, anim.looped ?? false);
            this.addOffset(anim.name, anim.x ?? 0, anim.y ?? 0);
        }

        this.playAnim('idle');

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