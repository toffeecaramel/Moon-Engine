package moon.game.obj;

import flixel.FlxSprite;
import flixel.FlxBasic;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxSpriteGroup;
import openfl.display.BlendMode;

import moon.dependency.scripting.MoonScript;

class Stage extends FlxTypedGroup<FlxBasic>
{
    public var stage(default, set):String;
    public var cameraSettings:{?zoom:Float, ?startX:Float, ?startY:Float};

    public var script:MoonScript;
    
    public function new(stage:String = 'stage')
    {
        super();
        script = new MoonScript();
        this.stage = stage;
    }

    @:noCompletion public function set_stage(stg:String):String
    {
        this.stage = stg;

        if(!Paths.fileExists('assets/images/ingame/stages/$stg/script.hx'))
        {
            throw 'The specified stage "$stg" does not have an hx file at "assets/images/ingame/stages/$stg".';
            return null;
        }
        else
        {
            script.load('assets/images/ingame/stages/$stg/script.hx');
            script.set("background", this);
            script.call('onCreate');
        }

        return stg;    
    }

    override public function update(elapsed:Float)
    {
        super.update(elapsed);
        script.get("onUpdate")(elapsed);
    }
}