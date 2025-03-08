package moon.game.obj;

import moon.dependency.scripting.MoonScript;
import sys.FileSystem;
import flixel.group.FlxSpriteGroup;

class Stage extends FlxSpriteGroup
{
    public var stage(default, set):String;
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
        if(!FileSystem.exists(Paths.data('stages/$stg.hx')))
        {
            throw 'The specified stage "$stg" does not have an hx file at "assets/data/stages".';
            return null;
        }
        else
        {
            script.load(Paths.data('stages/$stg.hx'));
            script.get('onCreate')();
        }

        return stg;    
    }
}