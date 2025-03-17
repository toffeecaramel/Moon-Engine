package moon.game.obj;

import moon.backend.gameplay.InputHandler;
import flixel.FlxSprite;
import flixel.FlxBasic;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxSpriteGroup;
import openfl.display.BlendMode;

import moon.dependency.scripting.MoonScript;

/**
 * The background for songs.
 */
class Stage extends FlxTypedGroup<FlxBasic>
{
    /**
     * The stage name itself, name must match the folder it's in.
     */
    public var stage(default, set):String;

    /**
     * All the camera settings.
     */
    public var cameraSettings:{?zoom:Float, ?startX:Float, ?startY:Float};

    /**
     * All the characters settings.
     */
    public var charSettings:Dynamic;

    /**
     * Background's spectators.
     */
    public var spectators:FlxSpriteGroup = new FlxSpriteGroup();
    public var opponents:FlxSpriteGroup = new FlxSpriteGroup();
    public var players:FlxSpriteGroup = new FlxSpriteGroup();

    public var chars:Array<Character> = [];
    public var conductor:Conductor;

    public var script:MoonScript;

    /**
     * The horizontal space between characters in the same group.
     */
    public var XSeparator:Float = 150;

    public function new(stage:String = 'stage', conductor:Conductor)
    {
        super();
        this.conductor = conductor;
        
        script = new MoonScript();
        this.stage = stage;
    }

    @:noCompletion public function set_stage(stg:String):String
    {
        this.stage = stg;

        if (!Paths.fileExists('assets/images/ingame/stages/$stg/script.hx'))
        {
            throw 'The specified stage "$stg" does not have an hx file at "assets/images/ingame/stages/$stg".';
            return null;
        }
        else
        {
            script.load('assets/images/ingame/stages/$stg/script.hx');
            script.set("background", this);
            script.call('onCreate');
            
            final json = Paths.JSON('ingame/stages/$stg/stageSettings');
            cameraSettings = json.cameraSettings;
            charSettings = json.characterSettings;
        }

        return stg;
    }

    /**
     * Adds a char to a specific group.
     * @param charName The name of the character (e.g. darnell)
     * @param group The group in which the character will be added to.
     * @param attachedInputs The input handler for the character (necessary if you want it to sing when a note is hit.)
     */
    public function addCharTo(charName:String, group:FlxSpriteGroup, ?attachedInputs:InputHandler)
    {
        group.recycle(Character, function():Character
        {
            var char = new Character(0 + (100 * group.members.length), 0, charName, conductor);
            chars.push(char);
            if(attachedInputs != null) attachedInputs.attachedChar = char;
            return char;
        });
    }

    public function setDefaultPositions()
    {
        updateGrpProperty(spectators, 'spectators');
        updateGrpProperty(players, 'players');
        updateGrpProperty(opponents, 'opponents');
    }

    private function updateGrpProperty(group:FlxSpriteGroup, type:String):Void
    {
        final pos:Array<Float> = getField(charSettings.positions, type);
        if(pos != null) group.setPosition(pos[0], pos[1]);

        final sf:Array<Float> = getField(charSettings.scrollFactors, type);
        if(sf != null) group.scrollFactor.set(sf[0], sf[1]);

        final scl:Array<Float> = getField(charSettings.scales, type);
        if(scl != null) group.scale.set(scl[0], scl[1]);
    }

    private function getField(a, b)
        return (Reflect.hasField(a, b)) ? Reflect.field(a, b) : null;

    override public function update(elapsed:Float)
    {
        super.update(elapsed);
        script.get("onUpdate")(elapsed);
    }
}
